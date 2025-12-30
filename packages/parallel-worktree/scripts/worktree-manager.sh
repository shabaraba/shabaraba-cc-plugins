#!/bin/bash
set -e

STATE_FILE=".claude/parallel-worktree-state.json"
WORKTREE_DIR=".worktrees"

init_state() {
  mkdir -p .claude
  if [ ! -f "$STATE_FILE" ]; then
    echo '{"tasks":[]}' > "$STATE_FILE"
  fi
}

create_worktree() {
  local branch_name="$1"
  local base_branch="${2:-main}"

  mkdir -p "$WORKTREE_DIR"

  if [ -d "$WORKTREE_DIR/$branch_name" ]; then
    echo "Worktree $branch_name already exists"
    return 1
  fi

  git fetch origin "$base_branch" 2>/dev/null || true
  git worktree add "$WORKTREE_DIR/$branch_name" -b "$branch_name" "origin/$base_branch" 2>/dev/null || \
    git worktree add "$WORKTREE_DIR/$branch_name" -b "$branch_name" "$base_branch"

  # Copy .env files
  for env_file in .env .env.local .env.test .env.development; do
    if [ -f "$env_file" ]; then
      cp "$env_file" "$WORKTREE_DIR/$branch_name/"
    fi
  done

  # Add .worktrees to .gitignore if not present
  if ! grep -q "^\.worktrees" .gitignore 2>/dev/null; then
    echo ".worktrees" >> .gitignore
  fi

  echo "$WORKTREE_DIR/$branch_name"
}

list_worktrees() {
  git worktree list --porcelain | grep "^worktree" | cut -d' ' -f2
}

remove_worktree() {
  local branch_name="$1"
  local worktree_path="$WORKTREE_DIR/$branch_name"

  if [ -d "$worktree_path" ]; then
    git worktree remove "$worktree_path" --force 2>/dev/null || true
    git branch -D "$branch_name" 2>/dev/null || true
    echo "Removed worktree: $branch_name"
  else
    echo "Worktree not found: $branch_name"
  fi
}

add_task() {
  local task_id="$1"
  local agent_id="$2"
  local worktree="$3"
  local description="$4"

  init_state

  local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  local tmp_file=$(mktemp)

  jq --arg id "$task_id" \
     --arg agent_id "$agent_id" \
     --arg worktree "$worktree" \
     --arg desc "$description" \
     --arg ts "$timestamp" \
     '.tasks += [{"id": $id, "agent_id": $agent_id, "worktree": $worktree, "description": $desc, "started_at": $ts, "status": "running"}]' \
     "$STATE_FILE" > "$tmp_file" && mv "$tmp_file" "$STATE_FILE"
}

update_task_status() {
  local task_id="$1"
  local status="$2"

  local tmp_file=$(mktemp)
  jq --arg id "$task_id" --arg status "$status" \
     '(.tasks[] | select(.id == $id)).status = $status' \
     "$STATE_FILE" > "$tmp_file" && mv "$tmp_file" "$STATE_FILE"
}

get_tasks() {
  init_state
  cat "$STATE_FILE"
}

get_running_tasks() {
  init_state
  jq '.tasks | map(select(.status == "running"))' "$STATE_FILE"
}

remove_task() {
  local task_id="$1"

  local tmp_file=$(mktemp)
  jq --arg id "$task_id" '.tasks = [.tasks[] | select(.id != $id)]' \
     "$STATE_FILE" > "$tmp_file" && mv "$tmp_file" "$STATE_FILE"
}

case "$1" in
  create)
    create_worktree "$2" "$3"
    ;;
  list)
    list_worktrees
    ;;
  remove)
    remove_worktree "$2"
    ;;
  add-task)
    add_task "$2" "$3" "$4" "$5"
    ;;
  update-status)
    update_task_status "$2" "$3"
    ;;
  get-tasks)
    get_tasks
    ;;
  get-running)
    get_running_tasks
    ;;
  remove-task)
    remove_task "$2"
    ;;
  *)
    echo "Usage: $0 {create|list|remove|add-task|update-status|get-tasks|get-running|remove-task}"
    exit 1
    ;;
esac
