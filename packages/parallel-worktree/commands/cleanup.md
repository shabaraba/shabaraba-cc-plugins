---
name: cleanup
description: Clean up completed parallel tasks and their worktrees
---

# Parallel Cleanup Command

Remove completed task worktrees and clean up state.

## Execution

### Step 1: Load Task State

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/worktree-manager.sh get-tasks
```

### Step 2: Identify Completed Tasks

Filter tasks where `status: "completed"`.

If no completed tasks exist, report and exit:
```
No completed tasks to clean up.
Use /parallel-worktree:status to check task progress.
```

### Step 3: Confirm with User

Before cleanup, show what will be removed:

```markdown
## Tasks Ready for Cleanup

| Branch | Description | Worktree Path |
|--------|-------------|---------------|
| feature-auth | Implement authentication | .worktrees/feature-auth |
| feature-search | Add search functionality | .worktrees/feature-search |

**Warning**: This will remove the worktrees. Make sure you have:
- Reviewed the changes
- Merged or pushed important branches

Proceed with cleanup? (Review each or clean all)
```

Use AskUserQuestion:
```
options:
  - "Clean all completed"
  - "Review each one"
  - "Cancel"
```

### Step 4: Execute Cleanup

#### If "Clean all completed":

For each completed task:
```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/worktree-manager.sh remove "$BRANCH_NAME"
bash ${CLAUDE_PLUGIN_ROOT}/scripts/worktree-manager.sh remove-task "$TASK_ID"
```

#### If "Review each one":

For each completed task, ask:
```
Branch: feature-auth
Description: Implement authentication
Path: .worktrees/feature-auth

Options:
  - "Remove this worktree"
  - "Keep for now"
  - "Show diff first"
```

If "Show diff first":
```bash
cd .worktrees/$BRANCH_NAME && git diff main...HEAD --stat
```

### Step 5: Report Results

```markdown
## Cleanup Complete

### Removed
- ✅ feature-auth (worktree removed, branch deleted)
- ✅ feature-search (worktree removed, branch deleted)

### Kept
- feature-api (still running)

Remaining active tasks: 1
```

## Options

### Force Cleanup (skip confirmation)
If user adds `--force` flag, skip confirmation and remove all completed tasks.

### Keep Branches
If user adds `--keep-branches` flag, remove worktrees but keep git branches for later use.
