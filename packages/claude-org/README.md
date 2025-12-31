# claude-org

Star-topology AI organization with async sub-agents, worktree isolation, daily logs, and context handoff.

## Concept

```
                    CEO (You)
                       │
                       ▼
              ┌─────────────────┐
              │   Secretary     │  ← Claude Code Main
              │  (Orchestrator) │
              └────────┬────────┘
                       │
       ┌───────────────┼───────────────┐
       │               │               │
       ▼               ▼               ▼
  ┌──────────┐   ┌──────────┐   ┌──────────┐
  │ engineer │   │ qa-design│   │   ...    │  ← Async Sub-agents
  │ +skills  │   │          │   │          │
  └──────────┘   └──────────┘   └──────────┘
       │               │               │
       ▼               ▼               ▼
  .worktrees/    .worktrees/    .worktrees/  ← Isolated Environments
```

## Features

- **Async Execution**: Tasks run in background, CEO always has control
- **Worktree Isolation**: Each task in its own git worktree
- **Daily Logs**: Agents report progress in `.claude-work/daily/`
- **Context Handoff**: Information flows between agents via context files
- **Star Topology**: Secretary orchestrates, agents work independently

## Quick Start

```bash
# Install plugin
/plugin marketplace add shabaraba/shabaraba-cc-plugins
/plugin install claude-org

# Start a development task
/claude-org:dev "Live Activities 機能を実装"

# Check progress
/claude-org:status

# Merge when complete
/claude-org:merge feature/live-activities
```

## Commands

| Command | Description |
|---------|-------------|
| `/claude-org:dev <task>` | Start async development task |
| `/claude-org:status` | Show all active tasks |
| `/claude-org:merge <branch>` | Merge completed branch |
| `/claude-org:cancel <branch>` | Cancel running task |
| `/claude-org:qa <feature>` | Start QA design task |
| `/claude-org:content <type> <topic>` | Create marketing content |

## Agents (Phase 1)

| Agent | Role |
|-------|------|
| product-spec | PRD, API specs, requirements |
| engineer | Software implementation (uses platform skills) |
| qa-design | Test case design, boundary analysis |
| marketing-content | ASO, SNS, blog, release notes |

## Platform Skills

The `engineer` agent uses platform-specific skills:

| Skill | Platform |
|-------|----------|
| ios-dev | Swift, SwiftUI, Live Activities, WidgetKit, XCTest |
| frontend-dev | React, Next.js, Tailwind CSS, TypeScript, Vitest |
| backend-dev | Cloudflare Workers, Hono, D1, Drizzle ORM, REST API |

## Directory Structure

```
project/
├── .worktrees/                    # Agent work environments
│   ├── feature-live-activities/
│   └── feature-lp-renewal/
│
├── .claude-work/                  # Work logs & context
│   ├── state.json                 # Task state
│   ├── daily/                     # Daily logs
│   │   └── 2025-01-01/
│   │       ├── eng-ios.md
│   │       └── eng-web.md
│   ├── context/                   # Task context for handoff
│   │   └── feature-xxx.md
│   └── handoff/                   # Completion reports
│       └── feature-xxx.md
│
├── docs/
│   ├── prd/                       # Product specs
│   ├── test-cases/                # QA output
│   └── marketing/                 # Content output
│
└── src/
```

## Workflow Example

```
1. CEO: "/claude-org:dev Live Activities 実装"

2. Secretary:
   - Creates worktree: .worktrees/feature-live-activities
   - Launches engineer (async, platform: ios)
   - Reports: "engineer に依頼しました (ios-dev skill)"

3. CEO: (does other work)

4. CEO: "/claude-org:status"

5. Secretary:
   - Checks TaskOutput
   - Reads daily log
   - Reports progress and blockers

6. engineer completes:
   - Commits code
   - Writes handoff file
   - Returns completion JSON

7. Secretary:
   - "✅ feature/live-activities 完了"
   - "マージしますか？"

8. CEO: "/claude-org:merge feature/live-activities"

9. Secretary:
   - Merges to main
   - Removes worktree
   - Cleanup complete
```

## Daily Log Format

Agents write progress to `.claude-work/daily/{date}/{agent}.md`:

```markdown
# engineer 分報 - 2025-01-01

## タスク: feature/live-activities (platform: ios)

### 14:30 開始
- Live Activities 実装開始
- worktree: .worktrees/feature-live-activities

### 15:00 進捗
- ActivityKit 基本実装完了
- 💡 Info.plist に設定必要

### 15:30 困りごと
- 🚧 Push Token 取得方法が不明

### 16:00 完了
- ✅ 基本機能実装完了
- 📝 commits: abc1234
```

## Expansion Roadmap

### Phase 2
- qa-automation (XCTest/Playwright)
- product-discovery (Market research)

### Phase 3
- eng-infra (CI/CD)
- marketing-growth (Viral, ASO)
- cs-feedback (Review analysis)

### Phase 4
- marketing-analytics
- cs-support
- ops-finance
- ops-legal

## License

MIT
