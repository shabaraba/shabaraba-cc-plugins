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
- Appropriate agent and platform:
  - iOS/Swift/SwiftUI/Widget/LiveActivity → `engineer` (platform: ios)
  - React/Next.js/Tailwind/LP/Landing → `engineer` (platform: frontend)
  - API/Workers/D1/Hono/Backend → `engineer` (platform: backend)
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
  subagent_type: <selected-agent>  # engineer or product-spec
  run_in_background: true
  prompt: |
    # Task Assignment

    ## Environment
    - Task ID: $TASK_ID
    - Branch: <branch>
    - Worktree: $WORKTREE_PATH
    - Platform: <platform>  # ios, frontend, or backend

    ## Requirements
    <task_description>

    ## Instructions
    1. cd to worktree: `cd $WORKTREE_PATH`
    2. **Read the platform skill first**: Read `skills/<platform>-dev/SKILL.md` for coding standards and patterns
    3. Read existing code patterns
    4. Update daily log: `bash ${CLAUDE_PLUGIN_ROOT}/scripts/work-manager.sh append-daily engineer "開始: <task>"`
    5. Implement following the skill guidelines
    6. Run build/tests (per skill instructions)
    7. Commit changes
    8. Update daily log with completion
    9. Create handoff file
    10. Return completion JSON

    ## Completion Format
    Return JSON with: task_id, agent, platform, status, branch, commits, summary, files_changed, next_steps, blockers, duration_minutes
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

## Agent & Platform Selection Logic

```
if description contains iOS/Swift/SwiftUI/Widget/LiveActivity:
    agent = engineer, platform = ios
elif description contains React/Next/LP/Landing/Tailwind/Frontend:
    agent = engineer, platform = frontend
elif description contains API/Workers/D1/Hono/Backend/REST:
    agent = engineer, platform = backend
elif description contains PRD/仕様/Spec/設計:
    agent = product-spec, platform = null
else:
    ask CEO which agent/platform to use
```

## Examples

```bash
# iOS development (engineer + ios-dev skill)
/claude-org:dev "Live Activities 機能を実装"

# Frontend development (engineer + frontend-dev skill)
/claude-org:dev "LP のヒーローセクションをリニューアル"

# Backend development (engineer + backend-dev skill)
/claude-org:dev "ユーザー認証 API を実装"

# Specification (product-spec agent)
/claude-org:dev "ウィジェット機能のPRDを作成"
```
