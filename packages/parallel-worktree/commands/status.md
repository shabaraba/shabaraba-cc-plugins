---
name: status
description: Check the status of all parallel background tasks
---

# Parallel Status Command

Check the status of all running parallel tasks.

## Execution

### Step 1: Load Task State

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/worktree-manager.sh get-tasks
```

This returns JSON with all tracked tasks.

### Step 2: Check Each Running Task

For each task with `status: "running"`:

1. Use `TaskOutput` with `block: false` to check agent status:
   ```
   TaskOutput:
     task_id: $AGENT_ID
     block: false
   ```

2. Parse the result:
   - `status: running` → Still in progress
   - `status: completed` → Finished (update state file)

### Step 3: Update State File

For any completed tasks, update the state:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/worktree-manager.sh update-status "$TASK_ID" "completed"
```

### Step 4: Report Status

Display a summary table:

```markdown
## Parallel Task Status

| Task ID | Branch | Description | Status | Progress |
|---------|--------|-------------|--------|----------|
| task-xxx | feature-auth | Implement authentication | ✅ Completed | Done |
| task-yyy | feature-search | Add search functionality | 🔄 Running | Implementing... |
| task-zzz | feature-api | Create REST API | 🔄 Running | Writing tests... |

### Completed Tasks
- **feature-auth**: Ready for review at `.worktrees/feature-auth`

### Running Tasks
- **feature-search**: Currently implementing search logic
- **feature-api**: Running test suite

Use `/parallel-worktree:cleanup` to remove completed worktrees.
```

## Output Details

For completed tasks, show:
- Final result summary
- Path to worktree for review
- Any errors or warnings

For running tasks, show:
- Current activity (from TaskOutput)
- Estimated progress if available
