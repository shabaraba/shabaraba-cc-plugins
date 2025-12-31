---
name: merge
description: Merge completed feature branch and cleanup worktree
argument-hint: "<branch-name>"
---

# Merge Command

Merge a completed feature branch into main and cleanup the worktree.

## Input

<branch>$ARGUMENTS</branch>

## Execution

### Step 1: Validate Branch

```bash
# Check if branch exists
git branch --list "<branch>"

# Check if worktree exists
ls .worktrees/<branch-slug>/
```

### Step 2: Verify Completion

1. Check task state for this branch
2. Confirm status is "complete" or "review"
3. If still "running", warn CEO and ask for confirmation

### Step 3: Review Changes

```bash
# Show what will be merged
git log main..<branch> --oneline
git diff main..<branch> --stat
```

Present summary to CEO:
```markdown
## Merge Preview: <branch>

### Commits to merge
<commit list>

### Files changed
<file stats>

### Handoff Summary
<from .claude-work/handoff/<branch>.md>

Proceed with merge?
```

### Step 4: Execute Merge

```bash
# Ensure on main
git checkout main
git pull origin main

# Merge
git merge <branch> --no-ff -m "Merge branch '<branch>'"

# Verify
git log -1 --oneline
```

### Step 5: Cleanup

```bash
# Remove worktree
bash ${CLAUDE_PLUGIN_ROOT}/scripts/work-manager.sh remove-worktree "<branch-slug>"

# Update task state
bash ${CLAUDE_PLUGIN_ROOT}/scripts/work-manager.sh update-status "$TASK_ID" "complete"
bash ${CLAUDE_PLUGIN_ROOT}/scripts/work-manager.sh remove-task "$TASK_ID"
```

### Step 6: Report

```markdown
## Merge Complete

| Item | Value |
|------|-------|
| Branch | <branch> |
| Merged to | main |
| Merge commit | <hash> |
| Worktree | Removed |

### Summary
<from handoff>

### Files Changed
<list>

### Next Steps
- Push to remote: `git push origin main`
- Or continue with more tasks
```

## Error Handling

### Merge Conflict

```markdown
## Merge Conflict Detected

Conflicting files:
<list>

Options:
1. Resolve manually in worktree
2. Cancel merge and investigate
3. Force merge (not recommended)
```

### Branch Not Found

```markdown
## Branch Not Found

Branch `<branch>` does not exist.

Available branches for merge:
<list from status>
```
