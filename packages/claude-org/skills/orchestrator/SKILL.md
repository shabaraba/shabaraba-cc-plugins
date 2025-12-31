---
name: orchestrator
description: Orchestrates the full development workflow (design → develop → review → QA) using sequential async sub-agents. Use this skill when executing /dev command.
---

# Orchestrator Skill

You are the Secretary (Claude Code main process) orchestrating a full development workflow.

## Workflow Overview

```
design → develop → review → QA → complete
```

Each phase is handled by a specialized sub-agent running in background. You wait for each phase to complete before starting the next.

## Phase Details

### Phase 1: Design (designer agent)

**Purpose**: Create technical design document before implementation.

**Launch**:
```
Task:
  subagent_type: designer
  run_in_background: true
  prompt: |
    # Design Task

    ## Context
    - Branch: <branch>
    - Worktree: <worktree_path>
    - Platform: <platform>

    ## Requirements
    <original_task_description>

    ## Deliverables
    1. Create design doc at `.claude-work/design/<branch>.md`
    2. Include: architecture, components, data flow, API design
    3. Return completion JSON
```

**Wait**: Use `TaskOutput` with `block: true` to wait for completion.

**Verify**: Check design doc exists and has content.

---

### Phase 2: Development (engineer agent)

**Purpose**: Implement based on design document.

**Launch**:
```
Task:
  subagent_type: engineer
  run_in_background: true
  prompt: |
    # Development Task

    ## Context
    - Branch: <branch>
    - Worktree: <worktree_path>
    - Platform: <platform>

    ## Design Document
    Read: .claude-work/design/<branch>.md

    ## Requirements
    <original_task_description>

    ## Instructions
    1. Read platform skill (<platform>-dev)
    2. Read design document
    3. Implement following design
    4. Run build/tests
    5. Commit changes
    6. Return completion JSON
```

**Wait**: Use `TaskOutput` with `block: true`.

**Verify**: Check commits exist, build passed.

---

### Phase 3: Review (reviewer agent)

**Purpose**: Review implementation for quality, bugs, and improvements.

**Launch**:
```
Task:
  subagent_type: reviewer
  run_in_background: true
  prompt: |
    # Code Review Task

    ## Context
    - Branch: <branch>
    - Worktree: <worktree_path>
    - Platform: <platform>

    ## Scope
    Review all commits on this branch.

    ## Review Checklist
    - Code quality and readability
    - Bug detection
    - Security issues
    - Performance concerns
    - Adherence to platform conventions

    ## Deliverables
    1. Create review report at `.claude-work/review/<branch>.md`
    2. If critical issues found: fix them and commit
    3. Return completion JSON with issues found
```

**Wait**: Use `TaskOutput` with `block: true`.

**Handle Issues**: If reviewer made fixes, continue. If blocking issues remain, report to user.

---

### Phase 4: QA (qa agent)

**Purpose**: Design test cases and verify implementation.

**Launch**:
```
Task:
  subagent_type: qa
  run_in_background: true
  prompt: |
    # QA Task

    ## Context
    - Branch: <branch>
    - Worktree: <worktree_path>
    - Platform: <platform>

    ## Scope
    - Design document: .claude-work/design/<branch>.md
    - Review report: .claude-work/review/<branch>.md

    ## Deliverables
    1. Create test cases at `.claude-work/qa/<branch>.md`
    2. Run tests (unit, integration as applicable)
    3. Report test results
    4. Return completion JSON
```

**Wait**: Use `TaskOutput` with `block: true`.

**Verify**: Check test results, all tests should pass.

---

## Orchestration Protocol

### Before Each Phase

1. Log phase start to daily log:
   ```bash
   bash ${CLAUDE_PLUGIN_ROOT}/scripts/work-manager.sh append-daily secretary "Phase N: <phase_name> 開始"
   ```

2. Update task state:
   ```bash
   bash ${CLAUDE_PLUGIN_ROOT}/scripts/work-manager.sh update-task-phase "$TASK_ID" "<phase_name>"
   ```

### After Each Phase

1. Check agent output for errors/blockers
2. If blocked: Ask user for guidance (use AskUserQuestion)
3. If success: Log completion and proceed to next phase

### Error Handling

```
if agent returns status: "blocked":
    - Log the blocker
    - Ask user: "Phase <N> で問題が発生しました: <blocker>. 続行しますか？"
    - Wait for user response
    - Either retry or abort

if agent times out (>30 min):
    - Check daily log for progress
    - Ask user whether to continue waiting or abort
```

### Completion

When all phases complete:

1. Log final status:
   ```bash
   bash ${CLAUDE_PLUGIN_ROOT}/scripts/work-manager.sh append-daily secretary "全フェーズ完了 ✅"
   ```

2. Create summary handoff:
   ```bash
   bash ${CLAUDE_PLUGIN_ROOT}/scripts/work-manager.sh create-handoff "<branch>" "<summary>"
   ```

3. Report to user:
   ```markdown
   ## ✅ 開発完了: <branch>

   | Phase | Status | Duration |
   |-------|--------|----------|
   | Design | ✅ | Xm |
   | Develop | ✅ | Xm |
   | Review | ✅ | Xm |
   | QA | ✅ | Xm |

   ### Summary
   <implementation_summary>

   ### Files Changed
   - file1.ts
   - file2.ts

   ### Next Steps
   - `/claude-org:merge <branch>` でマージ
   ```

## Inter-Phase Data Flow

```
.claude-work/
├── design/<branch>.md    ← Phase 1 output, Phase 2 input
├── review/<branch>.md    ← Phase 3 output, Phase 4 input
├── qa/<branch>.md        ← Phase 4 output
└── handoff/<branch>.md   ← Final summary
```

## User Interaction Points

The user only needs to:
1. Run `/claude-org:dev <task>` initially
2. Answer questions if a phase encounters blockers
3. Run `/claude-org:merge <branch>` when complete

No other interaction required.
