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
  *)
    echo "Usage: $0 {init|create-worktree <branch-base> <task-id> [base-branch]|list-worktrees|remove-worktree|add-task|update-status|get-tasks|get-running|remove-task|init-daily <task-id> <agent>|append-daily <task-id> <agent> <content>|init-context|create-handoff}"
    exit 1 ;;
esac
