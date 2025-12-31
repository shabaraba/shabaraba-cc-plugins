---
name: dev
description: Start async development task with dedicated worktree
argument-hint: "<feature description>"
---

# Dev Command

Start an async development task in an isolated git worktree.

## Input

<task_description>$ARGUMENTS</task_description>

## Execution

### Step 1: Parse Input

Extract feature description and determine:
- Branch name: `feature/<slug>` (kebab-case, max 30 chars)
- Appropriate agent based on keywords:
  - iOS/Swift/SwiftUI/Widget/LiveActivity → `eng-ios`
  - React/Next.js/Web/LP/Landing → `eng-web`
  - PRD/仕様/Spec/API設計 → `product-spec`

### Step 2: Initialize Work Environment

```bash
# Initialize work directories
bash ${CLAUDE_PLUGIN_ROOT}/scripts/work-manager.sh init

# Create worktree
WORKTREE_PATH=$(bash ${CLAUDE_PLUGIN_ROOT}/scripts/work-manager.sh create-worktree "<branch>")

# Initialize context file
bash ${CLAUDE_PLUGIN_ROOT}/scripts/work-manager.sh init-context "<branch>"
```

### Step 3: Generate Task ID

```bash
TASK_ID="task-$(date +%s)-$RANDOM"
```

### Step 4: Launch Async Agent

Use the Task tool with `run_in_background: true`:

```
Task:
  description: "Dev: <branch>"
  subagent_type: <selected-agent>  # eng-ios, eng-web, or product-spec
  run_in_background: true
  prompt: |
    # Task Assignment

    ## Environment
    - Task ID: $TASK_ID
    - Branch: <branch>
    - Worktree: $WORKTREE_PATH

    ## Requirements
    <task_description>

    ## Instructions
    1. cd to worktree: `cd $WORKTREE_PATH`
    2. Read existing code patterns
    3. Update daily log: `bash ${CLAUDE_PLUGIN_ROOT}/scripts/work-manager.sh append-daily <agent> "開始: <task>"`
    4. Implement the feature
    5. Run build/tests
    6. Commit changes
    7. Update daily log with completion
    8. Create handoff file
    9. Return completion JSON

    ## Completion Format
    Return JSON with: task_id, agent, status, branch, commits, summary, files_changed, next_steps, blockers, duration_minutes
```

### Step 5: Record Task State

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/work-manager.sh add-task \
  "$TASK_ID" \
  "$AGENT_ID" \
  "<agent-name>" \
  "<branch>" \
  "<description>"
```

### Step 6: Report to CEO

```markdown
## Task Started

| Item | Value |
|------|-------|
| Task ID | $TASK_ID |
| Branch | <branch> |
| Agent | <agent-name> |
| Worktree | $WORKTREE_PATH |
| Status | Running |

The agent is working in the background. You can:
- `/claude-org:status` - Check progress
- Continue with other tasks
```

## Agent Selection Logic

```
if description contains iOS/Swift/SwiftUI/Widget/LiveActivity:
    agent = eng-ios
elif description contains React/Next/Web/LP/Landing/Tailwind:
    agent = eng-web
elif description contains PRD/仕様/Spec/設計/API:
    agent = product-spec
else:
    ask CEO which agent to use
```

## Examples

```bash
# iOS development
/claude-org:dev "Live Activities 機能を実装"

# Web development
/claude-org:dev "LP のヒーローセクションをリニューアル"

# Specification
/claude-org:dev "ウィジェット機能のPRDを作成"
```
