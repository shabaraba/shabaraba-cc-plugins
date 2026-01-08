---
name: orchestrator
description: Orchestrates the async development workflow (design → develop → review → QA). Handles phase transitions when triggered by workflow-continue hook.
---

# Orchestrator Skill (Async Workflow)

You are the Secretary (Claude Code main process) orchestrating an **async** development workflow.

## Key Principle: Non-Blocking Execution

**NEVER block on phase completion.** Each phase runs in background. Phase transitions happen on user interactions via the workflow-continue hook.

## Workflow State

State is stored in `.claude-work/workflow.json`:

```json
{
  "task_id": "task-1234567890-12345",
  "branch": "feature/live-activities-task-1234567890-12345",
  "platform": "ios",
  "worktree": ".worktrees/feature/...",
  "description": "Live Activities でタイマー表示",
  "current_phase": 1,
  "phases": {
    "1": {"name": "design", "agent": "designer", "status": "running", "agent_task_id": "abc123"},
    "2": {"name": "develop", "agent": "engineer", "status": "pending", "agent_task_id": null},
    "3": {"name": "review", "agent": "reviewer", "status": "pending", "agent_task_id": null},
    "4": {"name": "qa", "agent": "qa", "status": "pending", "agent_task_id": null}
  },
  "status": "running"
}
```

## Phase Prompts

### Phase 1: Design (designer agent)

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
    - Platform: $PLATFORM

    ## Requirements
    $TASK_DESCRIPTION

    ## Instructions
    1. cd $WORKTREE_PATH
    2. Read platform skill: skills/$PLATFORM-dev/SKILL.md
    3. Create design document at .claude-work/design/$BRANCH_NAME.md
    4. Log progress: bash ${CLAUDE_PLUGIN_ROOT}/scripts/work-manager.sh append-daily "$TASK_ID" "designer" "<log>"
    5. Return completion JSON
```

### Phase 2: Development (engineer agent)

```
Task:
  description: "Dev: $BRANCH_NAME"
  subagent_type: claude-org:engineer
  run_in_background: true
  prompt: |
    # Development Task
    - Task ID: $TASK_ID
    - Branch: $BRANCH_NAME
    - Worktree: $WORKTREE_PATH
    - Platform: $PLATFORM

    ## Design Document
    Read: .claude-work/design/$BRANCH_NAME.md

    ## Requirements
    $TASK_DESCRIPTION

    ## Instructions
    1. cd $WORKTREE_PATH
    2. Read platform skill: skills/$PLATFORM-dev/SKILL.md
    3. Read design document
    4. Implement following design
    5. Run build/tests
    6. Commit changes
    7. Log progress
    8. Return completion JSON
```

### Phase 3: Review (reviewer agent)

```
Task:
  description: "Review: $BRANCH_NAME"
  subagent_type: claude-org:reviewer
  run_in_background: true
  prompt: |
    # Code Review Task
    - Task ID: $TASK_ID
    - Branch: $BRANCH_NAME
    - Worktree: $WORKTREE_PATH
    - Platform: $PLATFORM

    ## Instructions
    1. cd $WORKTREE_PATH
    2. Review all changes: git diff main
    3. Fix critical issues
    4. Create review report at .claude-work/review/$BRANCH_NAME.md
    5. Log progress
    6. Return completion JSON
```

### Phase 4: QA (qa agent)

```
Task:
  description: "QA: $BRANCH_NAME"
  subagent_type: claude-org:qa
  run_in_background: true
  prompt: |
    # QA Task
    - Task ID: $TASK_ID
    - Branch: $BRANCH_NAME
    - Worktree: $WORKTREE_PATH
    - Platform: $PLATFORM

    ## Context
    - Design: .claude-work/design/$BRANCH_NAME.md
    - Review: .claude-work/review/$BRANCH_NAME.md

    ## Instructions
    1. cd $WORKTREE_PATH
    2. Design test cases
    3. Run tests
    4. Create QA report at .claude-work/qa/$BRANCH_NAME.md
    5. Log progress
    6. Return completion JSON
```

## Auto-Continue Protocol

When `<workflow-auto-continue>` tag appears (from hook), follow this protocol:

### 1. Check Current Phase Completion

```
TaskOutput:
  task_id: <agent_task_id from workflow.json>
  block: false
```

### 2. If Phase Complete

```bash
# Update state
bash ${CLAUDE_PLUGIN_ROOT}/scripts/work-manager.sh complete-phase "$CURRENT_PHASE"
```

Report to user:
```markdown
✅ **Phase $CURRENT_PHASE ($PHASE_NAME) Complete**
```

### 3. Start Next Phase (if not phase 4)

Launch next agent with appropriate prompt (see above), then:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/work-manager.sh start-phase "$NEXT_PHASE" "<new_agent_task_id>"
```

Report:
```markdown
🔄 **Phase $NEXT_PHASE ($NEXT_PHASE_NAME) Started**
```

### 4. If All Phases Complete (phase 4 done)

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/work-manager.sh complete-workflow
bash ${CLAUDE_PLUGIN_ROOT}/scripts/work-manager.sh create-handoff "$BRANCH" "orchestrator" "$SUMMARY"
```

Generate final report:
```markdown
## ✅ 開発完了: $BRANCH_NAME

**Task ID**: $TASK_ID

| Phase | Status | Duration |
|-------|--------|----------|
| Design | ✅ | Xm |
| Develop | ✅ | Xm |
| Review | ✅ | Xm |
| QA | ✅ | Xm |
| **Total** | | **Xm** |

### Summary
<brief implementation summary>

### Artifacts
- Design: .claude-work/design/$BRANCH_NAME.md
- Review: .claude-work/review/$BRANCH_NAME.md
- QA: .claude-work/qa/$BRANCH_NAME.md

### Next Steps
`/claude-org:merge $BRANCH_NAME` でマージ
```

## Status Check Protocol

When user asks for status or `/claude-org:status`:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/work-manager.sh workflow-summary
```

Also check if current phase is complete (non-blocking TaskOutput).

## Error Handling

If agent returns `status: "blocked"`:

1. Note the blocker in workflow state
2. Ask user:
   ```
   AskUserQuestion:
     question: "Phase $N で問題発生: $BLOCKER\n続行しますか？"
     options:
       - label: "再試行"
       - label: "スキップして続行"
       - label: "中断"
   ```

## Workflow Commands

```bash
# Initialize new workflow
work-manager.sh init-workflow "$TASK_ID" "$BRANCH" "$PLATFORM" "$WORKTREE" "$DESC"

# Get workflow info
work-manager.sh get-workflow
work-manager.sh get-workflow-status
work-manager.sh get-current-phase
work-manager.sh get-phase-status "$PHASE"
work-manager.sh get-phase-agent-id "$PHASE"
work-manager.sh workflow-summary

# Update workflow
work-manager.sh start-phase "$PHASE" "$AGENT_TASK_ID"
work-manager.sh complete-phase "$PHASE"
work-manager.sh complete-workflow
work-manager.sh clear-workflow
```

## Key Points

1. **Never block** - Always use `run_in_background: true`
2. **Return immediately** - After starting a phase, return to user
3. **Check on interaction** - Hook triggers phase checks on each user message
4. **State-driven** - All decisions based on `workflow.json`
5. **Auto-progress** - No manual phase transitions needed
