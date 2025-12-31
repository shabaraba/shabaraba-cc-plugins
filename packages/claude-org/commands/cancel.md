---
name: cancel
description: Cancel running task and cleanup worktree
argument-hint: "<branch-name>"
---

# Cancel Command

Cancel a running task and cleanup its worktree.

## Input

<branch>$ARGUMENTS</branch>

## Execution

### Step 1: Find Task

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/work-manager.sh get-tasks | jq '.tasks[] | select(.branch == "<branch>")'
```

### Step 2: Confirm Cancellation

```markdown
## Cancel Task?

| Item | Value |
|------|-------|
| Branch | <branch> |
| Agent | <agent> |
| Status | <status> |
| Started | <time> |
| Worktree | .worktrees/<branch-slug> |

**Warning**: This will:
- Discard all uncommitted changes
- Remove the worktree
- Delete the branch

Proceed?
```

Use AskUserQuestion if needed.

### Step 3: Stop Background Agent

If agent is still running:
- The background agent will naturally fail when worktree is removed
- No explicit kill mechanism needed

### Step 4: Cleanup

```bash
# Update state first
bash ${CLAUDE_PLUGIN_ROOT}/scripts/work-manager.sh update-status "$TASK_ID" "cancelled"

# Remove worktree (force)
bash ${CLAUDE_PLUGIN_ROOT}/scripts/work-manager.sh remove-worktree "<branch-slug>"

# Remove from task list
bash ${CLAUDE_PLUGIN_ROOT}/scripts/work-manager.sh remove-task "$TASK_ID"

# Log cancellation
bash ${CLAUDE_PLUGIN_ROOT}/scripts/work-manager.sh append-daily "<agent>" "❌ Task cancelled by CEO: <branch>"
```

### Step 5: Report

```markdown
## Task Cancelled

| Item | Value |
|------|-------|
| Branch | <branch> |
| Agent | <agent> |
| Status | Cancelled |
| Worktree | Removed |

No changes were merged.
```

## Error Handling

### Task Not Found

```markdown
## Task Not Found

No active task for branch `<branch>`.

Active tasks:
<list from status>
```

### Already Complete

```markdown
## Task Already Complete

Task for `<branch>` has already completed.

Use `/claude-org:merge <branch>` to merge, or
Use `/claude-org:status` to see details.
```
