---
name: dev
description: Start full development workflow (design → develop → review → QA) with async sub-agents
argument-hint: "<feature description>"
---

# Dev Command

Start a complete development workflow with automated phases.

## Input

<task_description>$ARGUMENTS</task_description>

## Before Starting

**Read the orchestrator skill**: `skills/orchestrator/SKILL.md`

This skill contains the full orchestration protocol.

## Execution Overview

```
/dev "Live Activities 実装"
        │
        ▼
┌──────────────────────────────────────┐
│ Phase 1: Design                       │
│ → designer agent (background)         │
│ → Wait for completion                 │
│ → Output: .claude-work/design/<branch>.md
└──────────────────────────────────────┘
        │
        ▼
┌──────────────────────────────────────┐
│ Phase 2: Development                  │
│ → engineer agent (background)         │
│ → Wait for completion                 │
│ → Output: Implementation + commits    │
└──────────────────────────────────────┘
        │
        ▼
┌──────────────────────────────────────┐
│ Phase 3: Review                       │
│ → reviewer agent (background)         │
│ → Wait for completion                 │
│ → Output: .claude-work/review/<branch>.md
└──────────────────────────────────────┘
        │
        ▼
┌──────────────────────────────────────┐
│ Phase 4: QA                           │
│ → qa agent (background)               │
│ → Wait for completion                 │
│ → Output: .claude-work/qa/<branch>.md │
└──────────────────────────────────────┘
        │
        ▼
    Complete → Report to user
```

## Step 1: Parse & Initialize

1. Extract branch base: `feature/<slug>` (kebab-case, max 30 chars)
2. Determine platform:
   - iOS/Swift/SwiftUI/Widget/LiveActivity → `ios`
   - React/Next.js/Tailwind/LP/Landing → `frontend`
   - API/Workers/D1/Hono/Backend → `backend`
3. Initialize environment:
   ```bash
   bash ${CLAUDE_PLUGIN_ROOT}/scripts/work-manager.sh init
   TASK_ID="task-$(date +%s)-$RANDOM"
   WORKTREE_PATH=$(bash ${CLAUDE_PLUGIN_ROOT}/scripts/work-manager.sh create-worktree "feature/<slug>" "$TASK_ID")
   BRANCH_NAME="feature/<slug>-${TASK_ID}"
   bash ${CLAUDE_PLUGIN_ROOT}/scripts/work-manager.sh init-context "$BRANCH_NAME"
   ```

   **NOTE**: Worktree and branch names now include Task ID for parallel execution safety.

## Step 2: Phase 1 - Design

```
Task:
  description: "Design: $BRANCH_NAME"
  subagent_type: designer
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
    5. Return completion JSON
```

**Wait**: `TaskOutput(task_id, block=true)`

**Verify**: Design doc exists and has content.

## Step 3: Phase 2 - Development

```
Task:
  description: "Dev: $BRANCH_NAME"
  subagent_type: engineer
  run_in_background: true
  prompt: |
    # Development Task
    - Task ID: $TASK_ID
    - Branch: $BRANCH_NAME
    - Worktree: $WORKTREE_PATH
    - Platform: <platform>

    ## Design Document
    .claude-work/design/$BRANCH_NAME.md

    ## Requirements
    <task_description>

    ## Instructions
    1. cd $WORKTREE_PATH
    2. Read platform skill: skills/<platform>-dev/SKILL.md
    3. Read design document
    4. Implement following design
    5. Run build/tests
    6. Commit changes
    7. Log progress: bash ${CLAUDE_PLUGIN_ROOT}/scripts/work-manager.sh append-daily "$TASK_ID" "engineer" "<log entry>"
    8. Return completion JSON
```

**Wait**: `TaskOutput(task_id, block=true)`

**Verify**: Commits exist, build passed.

## Step 4: Phase 3 - Review

```
Task:
  description: "Review: $BRANCH_NAME"
  subagent_type: reviewer
  run_in_background: true
  prompt: |
    # Code Review Task
    - Task ID: $TASK_ID
    - Branch: $BRANCH_NAME
    - Worktree: $WORKTREE_PATH
    - Platform: <platform>

    ## Instructions
    1. cd $WORKTREE_PATH
    2. Read platform skill: skills/<platform>-dev/SKILL.md
    3. Review all changes: git diff main
    4. Fix critical issues
    5. Create review report at .claude-work/review/$BRANCH_NAME.md
    6. Log progress: bash ${CLAUDE_PLUGIN_ROOT}/scripts/work-manager.sh append-daily "$TASK_ID" "reviewer" "<log entry>"
    7. Return completion JSON
```

**Wait**: `TaskOutput(task_id, block=true)`

**Handle**: If blocking issues, ask user.

## Step 5: Phase 4 - QA

```
Task:
  description: "QA: $BRANCH_NAME"
  subagent_type: qa
  run_in_background: true
  prompt: |
    # QA Task
    - Task ID: $TASK_ID
    - Branch: $BRANCH_NAME
    - Worktree: $WORKTREE_PATH
    - Platform: <platform>

    ## Context
    - Design: .claude-work/design/$BRANCH_NAME.md
    - Review: .claude-work/review/$BRANCH_NAME.md

    ## Instructions
    1. cd $WORKTREE_PATH
    2. Read platform skill for test commands
    3. Design test cases
    4. Run tests
    5. Create QA report at .claude-work/qa/$BRANCH_NAME.md
    6. Log progress: bash ${CLAUDE_PLUGIN_ROOT}/scripts/work-manager.sh append-daily "$TASK_ID" "qa" "<log entry>"
    7. Return completion JSON
```

**Wait**: `TaskOutput(task_id, block=true)`

**Verify**: All tests pass.

## Step 6: Completion Report

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

### Files Changed
- path/to/file1.ts
- path/to/file2.ts

### Artifacts
- Design: .claude-work/design/$BRANCH_NAME.md
- Review: .claude-work/review/$BRANCH_NAME.md
- QA: .claude-work/qa/$BRANCH_NAME.md
- Daily Logs: .claude-work/daily/<date>/$TASK_ID_*.md

### Next Steps
`/claude-org:merge $BRANCH_NAME` でマージ
```

## Error Handling

If any phase returns `status: "blocked"`:

1. Log the blocker
2. Ask user:
   ```
   AskUserQuestion:
     question: "Phase <N> で問題が発生しました: <blocker>
               続行しますか？"
     options:
       - label: "再試行"
       - label: "スキップして続行"
       - label: "中断"
   ```
3. Handle based on response

## Examples

```bash
# iOS app feature (all 4 phases)
/claude-org:dev "Live Activities でタイマー表示"
# → Branch: feature/live-activities-task-1735987654-12345

# Web frontend feature
/claude-org:dev "LP のヒーローセクションをリニューアル"
# → Branch: feature/hero-section-renewal-task-1735987655-23456

# Backend API feature
/claude-org:dev "ユーザー認証 API を実装"
# → Branch: feature/user-auth-api-task-1735987656-34567

# Parallel execution is now safe - same feature can run multiple times
/claude-org:dev "Live Activities でタイマー表示"  # First instance
/claude-org:dev "Live Activities でタイマー表示"  # Second instance (different Task ID)
```

## User Interaction

User only needs to:
1. Run this command
2. Answer questions if phases encounter blockers
3. Run `/claude-org:merge` when complete

Everything else is automated.
