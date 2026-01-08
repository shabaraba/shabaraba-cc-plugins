---
name: dev
description: Start full development workflow (design → develop → review → QA) with async sub-agents. Returns immediately - phases auto-continue via hook.
argument-hint: "<feature description>"
---

# Dev Command (Async Workflow)

Start a complete development workflow. **Returns immediately** - you can continue working while phases execute in background. Phases auto-continue when you interact with Claude.

## Input

<task_description>$ARGUMENTS</task_description>

## Workflow Overview

```
/dev "Live Activities 実装"
        │
        ▼ (immediate return)
┌──────────────────────────────────────┐
│ Phase 1: Design (background)         │
│ → You can work on other things       │
└──────────────────────────────────────┘
        │ (auto-continue on next interaction)
        ▼
┌──────────────────────────────────────┐
│ Phase 2: Development (background)    │
└──────────────────────────────────────┘
        │
        ▼
┌──────────────────────────────────────┐
│ Phase 3: Review (background)         │
└──────────────────────────────────────┘
        │
        ▼
┌──────────────────────────────────────┐
│ Phase 4: QA (background)             │
└──────────────────────────────────────┘
        │
        ▼
    Complete → Auto-report
```

## Execution Steps

### Step 1: Parse & Initialize

1. Extract branch base: `feature/<slug>` (kebab-case, max 30 chars)
2. Determine platform:
   - iOS/Swift/SwiftUI/Widget/LiveActivity → `ios`
   - React/Next.js/Tailwind/LP/Landing → `frontend`
   - API/Workers/D1/Hono/Backend → `backend`
3. Generate Task ID:
   ```bash
   TASK_ID="task-$(date +%s)-$RANDOM"
   ```

### Step 2: Initialize Workflow

```bash
# Initialize workspace
bash ${CLAUDE_PLUGIN_ROOT}/scripts/work-manager.sh init

# Create worktree
WORKTREE_PATH=$(bash ${CLAUDE_PLUGIN_ROOT}/scripts/work-manager.sh create-worktree "feature/<slug>" "$TASK_ID")
BRANCH_NAME="feature/<slug>-${TASK_ID}"

# Initialize workflow state
bash ${CLAUDE_PLUGIN_ROOT}/scripts/work-manager.sh init-workflow "$TASK_ID" "$BRANCH_NAME" "<platform>" "$WORKTREE_PATH" "<task_description>"

# Initialize context
bash ${CLAUDE_PLUGIN_ROOT}/scripts/work-manager.sh init-context "$BRANCH_NAME"
```

### Step 3: Start Phase 1 (Design) in Background

```
Task:
  description: "Design: $BRANCH_NAME"
  subagent_type: claude-org:designer
  run_in_background: true
  prompt: |
    # Design Task
    - Task ID: $TASK_ID
    - Branch: $BRANCH_NAME
    - Worktree: $WORKTREE_PATH
    - Platform: <platform>

    ## Requirements
    <task_description>

    ## Instructions
    1. cd $WORKTREE_PATH
    2. Read platform skill: skills/<platform>-dev/SKILL.md
    3. Create design document at .claude-work/design/$BRANCH_NAME.md
    4. Log progress: bash ${CLAUDE_PLUGIN_ROOT}/scripts/work-manager.sh append-daily "$TASK_ID" "designer" "<log entry>"
    5. Return completion JSON with agent_id for tracking
```

**After launching**: Update workflow state with agent task ID:
```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/work-manager.sh start-phase "1" "<agent_task_id>"
```

### Step 4: Return to User Immediately

**DO NOT WAIT FOR COMPLETION.** Return control to user with status:

```markdown
## 🚀 Workflow Started: $BRANCH_NAME

**Task ID**: $TASK_ID
**Platform**: <platform>

| Phase | Status |
|-------|--------|
| 1. Design | 🔄 Running |
| 2. Develop | ⏳ Pending |
| 3. Review | ⏳ Pending |
| 4. QA | ⏳ Pending |

**Phase 1 (Designer)** is running in background.
You can continue working - phases will auto-continue when you interact with me.

Check status anytime: `/claude-org:status`
```

## Auto-Continue Protocol

The `workflow-continue.sh` hook automatically runs on each user interaction:

1. **Detects active workflow** from `.claude-work/workflow.json`
2. **Checks current phase status** using `TaskOutput` (non-blocking)
3. **If phase complete**: Starts next phase automatically
4. **Reports progress** to user

### Phase Transition Logic

When current phase completes:

```bash
# Mark phase complete
bash ${CLAUDE_PLUGIN_ROOT}/scripts/work-manager.sh complete-phase "$CURRENT_PHASE"

# If not final phase, start next
if [ $CURRENT_PHASE -lt 4 ]; then
  # Launch next phase agent (see orchestrator skill for prompts)
  # Update workflow state
  bash ${CLAUDE_PLUGIN_ROOT}/scripts/work-manager.sh start-phase "$NEXT_PHASE" "<new_agent_task_id>"
fi

# If final phase (4) complete
if [ $CURRENT_PHASE -eq 4 ]; then
  bash ${CLAUDE_PLUGIN_ROOT}/scripts/work-manager.sh complete-workflow
  # Generate final report
fi
```

## Phase Agent Prompts

Reference `skills/orchestrator/SKILL.md` for full prompts. Summary:

| Phase | Agent | Input | Output |
|-------|-------|-------|--------|
| 1 | designer | Task description | `.claude-work/design/<branch>.md` |
| 2 | engineer | Design doc | Implementation + commits |
| 3 | reviewer | Code diff | `.claude-work/review/<branch>.md` |
| 4 | qa | Design + Review | `.claude-work/qa/<branch>.md` |

## Error Handling

If a phase returns `status: "blocked"`:

1. Update workflow state with blocker info
2. On next interaction, ask user:
   ```
   AskUserQuestion:
     question: "Phase <N> で問題が発生: <blocker>\n続行しますか？"
     options:
       - label: "再試行"
       - label: "スキップして続行"
       - label: "中断"
   ```

## Hook Setup (Required)

For auto-continue to work, add to `.claude/settings.json`:

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/workflow-continue.sh"
          }
        ]
      }
    ]
  }
}
```

## Examples

```bash
# Start iOS feature (returns immediately)
/claude-org:dev "Live Activities でタイマー表示"
# → Phase 1 starts, you can work on other things

# Check status anytime
/claude-org:status

# Phases auto-continue on each interaction
# Eventually all 4 phases complete automatically
```

## User Interaction

User only needs to:
1. Run this command (phases start automatically)
2. Continue working normally (phases progress on each interaction)
3. Answer questions if phases encounter blockers
4. Run `/claude-org:merge` when complete

**No manual phase transitions required.**
