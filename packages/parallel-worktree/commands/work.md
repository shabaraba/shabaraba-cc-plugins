---
name: work
description: Start parallel async tasks in isolated git worktrees. Each task runs in a background agent.
argument-hint: "<task-description> [task-description-2] [task-description-3] ..."
---

# Parallel Work Command

Start one or more tasks in parallel, each in its own git worktree with a background agent.

## Input

<tasks>$ARGUMENTS</tasks>

## Execution

### Step 1: Parse Tasks

Parse the input to extract individual task descriptions. Tasks can be:
- Multiple quoted strings: `"task 1" "task 2" "task 3"`
- A single task: `"implement authentication"`
- A file path containing task details: `plan.md`

For each task, generate a short branch name (kebab-case, max 30 chars).

### Step 2: For Each Task

Execute the following for **each task** (can be done in parallel if multiple tasks):

#### 2.1 Create Worktree

```bash
# Generate unique task ID
TASK_ID="task-$(date +%s)-$RANDOM"

# Create branch name from task description (first 30 chars, kebab-case)
BRANCH_NAME=$(echo "$TASK_DESCRIPTION" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | cut -c1-30 | sed 's/-$//')

# Create worktree
bash ${CLAUDE_PLUGIN_ROOT}/scripts/worktree-manager.sh create "$BRANCH_NAME"
```

#### 2.2 Launch Background Agent

Use the Task tool with `run_in_background: true`:

```
Task:
  description: "Parallel work: $BRANCH_NAME"
  subagent_type: general-purpose
  run_in_background: true
  prompt: |
    You are working in an isolated git worktree.

    Working directory: .worktrees/$BRANCH_NAME

    ## Task
    $TASK_DESCRIPTION

    ## Instructions
    1. cd to the worktree directory first
    2. Implement the task following existing code patterns
    3. Write tests for new functionality
    4. Run tests to verify
    5. Commit changes with descriptive message
    6. Report completion status

    ## Important
    - Stay within the worktree directory
    - Do not push to remote (user will review first)
    - Follow project conventions (check CLAUDE.md if exists)
```

#### 2.3 Record Task State

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/worktree-manager.sh add-task \
  "$TASK_ID" \
  "$AGENT_ID" \
  "$BRANCH_NAME" \
  "$TASK_DESCRIPTION"
```

### Step 3: Report to User

After launching all background agents, immediately report:

```markdown
## Parallel Tasks Started

| Task ID | Branch | Description | Status |
|---------|--------|-------------|--------|
| task-xxx | feature-auth | Implement authentication | Running |
| task-yyy | feature-search | Add search functionality | Running |

Use `/parallel-worktree:status` to check progress.
Use `/parallel-worktree:cleanup` when tasks complete.
```

## Key Points

- **Async execution**: Background agents run independently
- **Immediate return**: User regains control immediately after launch
- **Isolated environments**: Each task has its own worktree
- **State tracking**: Task status stored in `.claude/parallel-worktree-state.json`

## Examples

### Single Task
```
/parallel-worktree:work "Add user authentication with JWT"
```

### Multiple Tasks
```
/parallel-worktree:work "Add login page" "Add signup page" "Add password reset"
```

### From File
```
/parallel-worktree:work feature-spec.md
```
