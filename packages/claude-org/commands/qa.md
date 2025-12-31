---
name: qa
description: Start QA design task for a feature
argument-hint: "<feature-name or PRD-path>"
---

# QA Command

Start an async QA design task to create test cases for a feature.

## Input

<feature>$ARGUMENTS</feature>

## Execution

### Step 1: Resolve Feature Reference

If input is a file path (e.g., `docs/prd/xxx.md`):
- Read the PRD file
- Extract feature name and requirements

If input is a feature name:
- Search for related PRD in `docs/prd/`
- Search for related implementation in context files

### Step 2: Initialize Work Environment

```bash
# Branch name
BRANCH="qa/<feature-slug>"

# Create worktree
bash ${CLAUDE_PLUGIN_ROOT}/scripts/work-manager.sh init
WORKTREE_PATH=$(bash ${CLAUDE_PLUGIN_ROOT}/scripts/work-manager.sh create-worktree "$BRANCH")

# Initialize context
bash ${CLAUDE_PLUGIN_ROOT}/scripts/work-manager.sh init-context "$BRANCH"

# Generate task ID
TASK_ID="task-$(date +%s)-$RANDOM"
```

### Step 3: Launch QA Design Agent

```
Task:
  description: "QA: <feature>"
  subagent_type: qa-design
  run_in_background: true
  prompt: |
    # QA Design Task

    ## Environment
    - Task ID: $TASK_ID
    - Branch: $BRANCH
    - Worktree: $WORKTREE_PATH

    ## Feature
    <feature description or PRD content>

    ## Related Context
    <links to implementation context files if any>

    ## Instructions
    1. cd to worktree
    2. Read PRD and implementation context
    3. Update daily log
    4. Design comprehensive test cases:
       - Normal cases
       - Error cases
       - Boundary values
       - Regression targets
    5. Commit test case documentation
    6. Create handoff file
    7. Return completion JSON

    ## Output Location
    docs/test-cases/<feature>.md
```

### Step 4: Record and Report

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/work-manager.sh add-task \
  "$TASK_ID" "$AGENT_ID" "qa-design" "$BRANCH" "QA design for <feature>"
```

```markdown
## QA Task Started

| Item | Value |
|------|-------|
| Task ID | $TASK_ID |
| Branch | $BRANCH |
| Agent | qa-design |
| Feature | <feature> |
| Status | Running |

The QA design agent is analyzing the feature and creating test cases.

Use `/claude-org:status` to check progress.
```

## Examples

```bash
# From PRD
/claude-org:qa docs/prd/live-activities.md

# From feature name
/claude-org:qa "Live Activities"

# From branch (inherits context)
/claude-org:qa feature/live-activities
```
