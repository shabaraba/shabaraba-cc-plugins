#!/bin/bash
set -e

WORK_DIR=".claude-work"
WORKTREE_DIR=".worktrees"
STATE_FILE="$WORK_DIR/state.json"
LOCK_FILE="$WORK_DIR/.state.lock"

# Lock acquisition for state.json operations
acquire_lock() {
  local timeout=30
  local count=0

  while [ -f "$LOCK_FILE" ]; do
    sleep 0.1
    count=$((count + 1))
    if [ $count -gt $((timeout * 10)) ]; then
      echo "error: Lock timeout after ${timeout}s" >&2
      return 1
    fi
  done

  echo $$ > "$LOCK_FILE"
  trap "rm -f $LOCK_FILE" EXIT INT TERM
}

# Lock release
release_lock() {
  rm -f "$LOCK_FILE"
  trap - EXIT INT TERM
}

init() {
  mkdir -p "$WORK_DIR"/{daily,context,handoff}
  mkdir -p "$WORKTREE_DIR"
  if [ ! -f "$STATE_FILE" ]; then
    echo '{"tasks":[]}' > "$STATE_FILE"
  fi
  if ! grep -q "^\.worktrees" .gitignore 2>/dev/null; then
    echo ".worktrees" >> .gitignore
  fi
  if ! grep -q "^\.claude-work" .gitignore 2>/dev/null; then
    echo ".claude-work" >> .gitignore
  fi
}

create_worktree() {
  local branch_base="$1"
  local task_id="$2"
  local base_branch="${3:-main}"

  init

  # Construct unique branch name with task ID
  local branch_name="${branch_base}-${task_id}"

  if [ -d "$WORKTREE_DIR/$branch_name" ]; then
    echo "error: Worktree $branch_name already exists" >&2
    return 1
  fi

  git fetch origin "$base_branch" 2>/dev/null || true
  git worktree add "$WORKTREE_DIR/$branch_name" -b "$branch_name" "origin/$base_branch" 2>/dev/null || \
    git worktree add "$WORKTREE_DIR/$branch_name" -b "$branch_name" "$base_branch"

  for env_file in .env .env.local .env.test .env.development; do
    [ -f "$env_file" ] && cp "$env_file" "$WORKTREE_DIR/$branch_name/"
  done

  echo "$WORKTREE_DIR/$branch_name"
}

list_worktrees() {
  git worktree list --porcelain | grep "^worktree" | sed 's/worktree //'
}

remove_worktree() {
  local branch_name="$1"
  local worktree_path="$WORKTREE_DIR/$branch_name"

  if [ -d "$worktree_path" ]; then
    git worktree remove "$worktree_path" --force 2>/dev/null || true
    git branch -D "$branch_name" 2>/dev/null || true
    echo "Removed: $branch_name"
  fi
}

add_task() {
  local task_id="$1"
  local agent_id="$2"
  local agent_name="$3"
  local branch="$4"
  local description="$5"

  init
  acquire_lock

  local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  local tmp=$(mktemp)

  jq --arg id "$task_id" \
     --arg agent_id "$agent_id" \
     --arg agent "$agent_name" \
     --arg branch "$branch" \
     --arg desc "$description" \
     --arg ts "$timestamp" \
     --arg status "running" \
     '.tasks += [{
       "id": $id,
       "agent_id": $agent_id,
       "agent": $agent,
       "branch": $branch,
       "description": $desc,
       "started_at": $ts,
       "status": $status
     }]' "$STATE_FILE" > "$tmp" && mv "$tmp" "$STATE_FILE"

  release_lock
}

update_status() {
  local task_id="$1"
  local status="$2"

  acquire_lock

  local tmp=$(mktemp)
  jq --arg id "$task_id" --arg status "$status" \
     '(.tasks[] | select(.id == $id)).status = $status' \
     "$STATE_FILE" > "$tmp" && mv "$tmp" "$STATE_FILE"

  release_lock
}

get_tasks() {
  init
  cat "$STATE_FILE"
}

get_running_tasks() {
  init
  jq -r '.tasks[] | select(.status == "running") | "\(.id)\t\(.agent)\t\(.branch)\t\(.started_at)"' "$STATE_FILE"
}

remove_task() {
  local task_id="$1"

  acquire_lock

  local tmp=$(mktemp)
  jq --arg id "$task_id" '.tasks = [.tasks[] | select(.id != $id)]' \
     "$STATE_FILE" > "$tmp" && mv "$tmp" "$STATE_FILE"

  release_lock
}

init_daily_log() {
  local task_id="$1"
  local agent="$2"
  local today=$(date +%Y-%m-%d)
  local log_dir="$WORK_DIR/daily/$today"
  local log_file="$log_dir/${task_id}_${agent}.md"

  mkdir -p "$log_dir"
  if [ ! -f "$log_file" ]; then
    cat > "$log_file" << EOF
# $agent 分報 - $today
Task ID: $task_id

EOF
  fi
  echo "$log_file"
}

append_daily_log() {
  local task_id="$1"
  local agent="$2"
  local content="$3"
  local log_file=$(init_daily_log "$task_id" "$agent")
  local time=$(date +%H:%M)

  echo -e "\n### $time\n$content" >> "$log_file"
}

init_context() {
  local branch="$1"
  local context_file="$WORK_DIR/context/$branch.md"

  if [ ! -f "$context_file" ]; then
    cat > "$context_file" << EOF
# Context: $branch

## 基本情報
- branch: $branch
- 起票: $(date +"%Y-%m-%d %H:%M")
- 担当:
- 関連PRD:

## 要件サマリー


## 設計判断


## 依存関係
- 前提:
- 後続:

## 後続エージェントへの申し送り


## 参照ファイル


## 未解決事項


## 更新履歴
| 日時 | 更新者 | 内容 |
|------|--------|------|

EOF
  fi
  echo "$context_file"
}

create_handoff() {
  local branch="$1"
  local agent="$2"
  local summary="$3"
  local handoff_file="$WORK_DIR/handoff/$branch.md"

  cat > "$handoff_file" << EOF
# Handoff: $branch

## 完了サマリー
- 完了日: $(date +%Y-%m-%d)
- 担当: $agent
- マージ先: main

## 実装内容
$summary

## 主要な変更ファイル
| ファイル | 変更内容 |
|----------|----------|

## 設計判断の記録


## 学び・知見


## 残課題


## 関連リンク
- コンテキスト: .claude-work/context/$branch.md
- 分報: .claude-work/daily/$(date +%Y-%m-%d)/ (Task ID別)
EOF

  echo "$handoff_file"
}

# ============================================
# Workflow Management (Async Phase Execution)
# ============================================

WORKFLOW_FILE="$WORK_DIR/workflow.json"

init_workflow() {
  local task_id="$1"
  local branch="$2"
  local platform="$3"
  local worktree="$4"
  local description="$5"

  init
  acquire_lock

  local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  cat > "$WORKFLOW_FILE" << EOF
{
  "task_id": "$task_id",
  "branch": "$branch",
  "platform": "$platform",
  "worktree": "$worktree",
  "description": "$description",
  "started_at": "$timestamp",
  "current_phase": 1,
  "phases": {
    "1": {"name": "design", "agent": "designer", "status": "pending", "agent_task_id": null},
    "2": {"name": "develop", "agent": "engineer", "status": "pending", "agent_task_id": null},
    "3": {"name": "review", "agent": "reviewer", "status": "pending", "agent_task_id": null},
    "4": {"name": "qa", "agent": "qa", "status": "pending", "agent_task_id": null}
  },
  "status": "running"
}
EOF

  release_lock
  echo "$WORKFLOW_FILE"
}

get_workflow() {
  if [ -f "$WORKFLOW_FILE" ]; then
    cat "$WORKFLOW_FILE"
  else
    echo "{}"
  fi
}

get_workflow_status() {
  if [ -f "$WORKFLOW_FILE" ]; then
    jq -r '.status // "none"' "$WORKFLOW_FILE"
  else
    echo "none"
  fi
}

get_current_phase() {
  if [ -f "$WORKFLOW_FILE" ]; then
    jq -r '.current_phase // 0' "$WORKFLOW_FILE"
  else
    echo "0"
  fi
}

get_phase_status() {
  local phase="$1"
  if [ -f "$WORKFLOW_FILE" ]; then
    jq -r ".phases.\"$phase\".status // \"none\"" "$WORKFLOW_FILE"
  else
    echo "none"
  fi
}

get_phase_agent_task_id() {
  local phase="$1"
  if [ -f "$WORKFLOW_FILE" ]; then
    jq -r ".phases.\"$phase\".agent_task_id // \"\"" "$WORKFLOW_FILE"
  else
    echo ""
  fi
}

start_phase() {
  local phase="$1"
  local agent_task_id="$2"

  acquire_lock

  local tmp=$(mktemp)
  local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  jq --arg phase "$phase" \
     --arg agent_task_id "$agent_task_id" \
     --arg ts "$timestamp" \
     '.current_phase = ($phase | tonumber) |
      .phases[$phase].status = "running" |
      .phases[$phase].agent_task_id = $agent_task_id |
      .phases[$phase].started_at = $ts' \
     "$WORKFLOW_FILE" > "$tmp" && mv "$tmp" "$WORKFLOW_FILE"

  release_lock
}

complete_phase() {
  local phase="$1"

  acquire_lock

  local tmp=$(mktemp)
  local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  local next_phase=$((phase + 1))

  jq --arg phase "$phase" \
     --arg ts "$timestamp" \
     --argjson next "$next_phase" \
     '.phases[$phase].status = "complete" |
      .phases[$phase].completed_at = $ts |
      if $next <= 4 then .current_phase = $next else . end' \
     "$WORKFLOW_FILE" > "$tmp" && mv "$tmp" "$WORKFLOW_FILE"

  release_lock
}

complete_workflow() {
  acquire_lock

  local tmp=$(mktemp)
  local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  jq --arg ts "$timestamp" \
     '.status = "complete" | .completed_at = $ts' \
     "$WORKFLOW_FILE" > "$tmp" && mv "$tmp" "$WORKFLOW_FILE"

  release_lock
}

clear_workflow() {
  rm -f "$WORKFLOW_FILE"
}

workflow_summary() {
  if [ ! -f "$WORKFLOW_FILE" ]; then
    echo "No active workflow"
    return
  fi

  jq -r '
    "Workflow: \(.task_id)\n" +
    "Branch: \(.branch)\n" +
    "Status: \(.status)\n" +
    "Current Phase: \(.current_phase)\n" +
    "Phases:\n" +
    "  1. Design: \(.phases."1".status)\n" +
    "  2. Develop: \(.phases."2".status)\n" +
    "  3. Review: \(.phases."3".status)\n" +
    "  4. QA: \(.phases."4".status)"
  ' "$WORKFLOW_FILE"
}

case "$1" in
  init) init ;;
  create-worktree) create_worktree "$2" "$3" "$4" ;;
  list-worktrees) list_worktrees ;;
  remove-worktree) remove_worktree "$2" ;;
  add-task) add_task "$2" "$3" "$4" "$5" "$6" ;;
  update-status) update_status "$2" "$3" ;;
  get-tasks) get_tasks ;;
  get-running) get_running_tasks ;;
  remove-task) remove_task "$2" ;;
  init-daily) init_daily_log "$2" "$3" ;;
  append-daily) append_daily_log "$2" "$3" "$4" ;;
  init-context) init_context "$2" ;;
  create-handoff) create_handoff "$2" "$3" "$4" ;;
  # Workflow commands
  init-workflow) init_workflow "$2" "$3" "$4" "$5" "$6" ;;
  get-workflow) get_workflow ;;
  get-workflow-status) get_workflow_status ;;
  get-current-phase) get_current_phase ;;
  get-phase-status) get_phase_status "$2" ;;
  get-phase-agent-id) get_phase_agent_task_id "$2" ;;
  start-phase) start_phase "$2" "$3" ;;
  complete-phase) complete_phase "$2" ;;
  complete-workflow) complete_workflow ;;
  clear-workflow) clear_workflow ;;
  workflow-summary) workflow_summary ;;
  *)
    echo "Usage: $0 <command> [args]"
    echo "Commands:"
    echo "  init, create-worktree, list-worktrees, remove-worktree"
    echo "  add-task, update-status, get-tasks, get-running, remove-task"
    echo "  init-daily, append-daily, init-context, create-handoff"
    echo "  init-workflow, get-workflow, get-workflow-status, get-current-phase"
    echo "  get-phase-status, get-phase-agent-id, start-phase, complete-phase"
    echo "  complete-workflow, clear-workflow, workflow-summary"
    exit 1 ;;
esac
