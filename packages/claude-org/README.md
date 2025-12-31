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

## Agents

| Agent | Role |
|-------|------|
| designer | Technical design before implementation |
| engineer | Software implementation (uses platform skills) |
| reviewer | Code review and auto-fix |
| qa | Test design and execution |
| product-spec | PRD, API specs, requirements |
| qa-design | Test case design only (no execution) |
| marketing-content | ASO, SNS, blog, release notes |

## Platform Skills

The `engineer` agent uses platform-specific skills:

| Skill | Platform |
|-------|----------|
| ios-dev | Swift, SwiftUI, Live Activities, WidgetKit, XCTest |
| frontend-dev | React, Next.js, Tailwind CSS, TypeScript, Vitest |
| backend-dev | Cloudflare Workers, Hono, D1, Drizzle ORM, REST API |
| orchestrator | Full workflow orchestration (design → develop → review → QA) |

## Directory Structure

```
project/
├── .worktrees/                    # Agent work environments
│   ├── feature-live-activities/
│   └── feature-lp-renewal/
│
├── .claude-work/                  # Work logs & artifacts
│   ├── state.json                 # Task state
│   ├── daily/                     # Daily logs
│   │   └── 2025-01-01/
│   │       ├── designer.md
│   │       ├── engineer.md
│   │       ├── reviewer.md
│   │       └── qa.md
│   ├── design/                    # Phase 1 output
│   │   └── feature-xxx.md
│   ├── review/                    # Phase 3 output
│   │   └── feature-xxx.md
│   ├── qa/                        # Phase 4 output
│   │   └── feature-xxx.md
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

2. Secretary (Claude Code):
   - Creates worktree: .worktrees/feature-live-activities
   - Reads orchestrator skill
   - Starts 4-phase workflow

3. Phase 1 - Design:
   - Launches designer agent (background)
   - Waits for completion
   - Output: .claude-work/design/feature-live-activities.md

4. Phase 2 - Development:
   - Launches engineer agent (background)
   - Reads design doc, implements
   - Waits for completion
   - Output: Code + commits

5. Phase 3 - Review:
   - Launches reviewer agent (background)
   - Reviews code, fixes issues
   - Waits for completion
   - Output: .claude-work/review/feature-live-activities.md

6. Phase 4 - QA:
   - Launches qa agent (background)
   - Designs tests, runs tests
   - Waits for completion
   - Output: .claude-work/qa/feature-live-activities.md

7. Secretary reports to CEO:
   - "✅ 開発完了: feature/live-activities"
   - Phase summary with durations
   - "マージしますか？"

8. CEO: "/claude-org:merge feature/live-activities"

9. Secretary:
   - Merges to main
   - Removes worktree
   - Cleanup complete
```

**User only needs to:**
1. Run `/dev` command
2. Answer questions if phases encounter blockers
3. Run `/merge` when complete

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
