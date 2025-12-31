---
name: status
description: Show all active async tasks and their progress
---

# Status Command

Display status of all active async tasks with daily log excerpts.

## Execution

### Step 1: Load Task State

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/work-manager.sh get-tasks
```

### Step 2: Check Each Running Task

For each task with `status: "running"`:

1. Use `TaskOutput` with `block: false` to check agent status
2. Parse result:
   - `status: running` → Still working
   - `status: completed` → Finished
3. Update state if completed:
   ```bash
   bash ${CLAUDE_PLUGIN_ROOT}/scripts/work-manager.sh update-status "$TASK_ID" "complete"
   ```

### Step 3: Gather Daily Log Excerpts

For each active agent, read recent entries from:
```
.claude-work/daily/$(date +%Y-%m-%d)/<agent>.md
```

Extract:
- Last 3 entries
- Any 🚧 (blocked) or ❓ (question) items

### Step 4: Report

```markdown
## Active Tasks

| Branch | Agent | Status | Elapsed | Daily Log |
|--------|-------|--------|---------|-----------|
| feature/live-activities | eng-ios | 🔄 Running | 12m | [📝](.claude-work/daily/2025-01-01/eng-ios.md) |
| feature/lp-renewal | eng-web | ✅ Complete | 25m | [📝](.claude-work/daily/2025-01-01/eng-web.md) |
| feature/widget-prd | product-spec | 🚧 Blocked | 8m | [📝](.claude-work/daily/2025-01-01/product-spec.md) |

## Blockers & Questions

### eng-ios
- 🚧 Push Token の取得方法が不明

### product-spec
- ❓ Widget のデータ更新頻度の要件

## Recent Progress

### eng-ios (14:30)
- ActivityKit の基本実装完了
- Info.plist 設定追加

### eng-web (14:15)
- Hero セクション完了
- レスポンシブ対応済み

## Completed Tasks (Ready for Review)

| Branch | Agent | Commits | Handoff |
|--------|-------|---------|---------|
| feature/lp-renewal | eng-web | abc1234 | [📄](.claude-work/handoff/feature-lp-renewal.md) |

## Worktrees

```
.worktrees/
├── feature-live-activities/  (eng-ios, running)
├── feature-lp-renewal/       (eng-web, complete)
└── feature-widget-prd/       (product-spec, blocked)
```

## Actions

- `/claude-org:merge feature/lp-renewal` - Merge completed branch
- `/claude-org:cancel feature/widget-prd` - Cancel blocked task
```

## Automatic Actions

If a task completed:
1. Update state to "review"
2. Notify CEO with summary and handoff link
3. Suggest merge command
