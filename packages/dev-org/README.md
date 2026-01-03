# dev-org - Refactoring Specialized Plugin

Refactoring-specialized plugin for Claude Code with regression prevention, architecture compliance checks, and feedback loops.

**For new feature development, use [compounding-engineering](https://github.com/EveryInc/compound-engineering-plugin) instead.**

## Why This Plugin?

Unlike general-purpose development plugins, dev-org focuses exclusively on **safe refactoring**:

| Feature | dev-org | Others |
|---------|---------|--------|
| Regression Prevention | White-box + Black-box checks | Limited |
| Architecture Compliance | Automated layer dependency checks | Manual |
| Feedback Loops | Auto-retry on failure (max 3) | Stop on error |
| SOLID Analysis | 5 specialized analyzers | Generic |

## `/refactor` Command

```bash
# Refactor entire project
/refactor

# Refactor specific path
/refactor src/components

# Analysis only (no implementation)
/refactor --analysis-only

# Refactor based on PR
/refactor --pr 123
```

## Workflow

```
┌─────────────┐
│  Analysis   │ ← 5 parallel analyzers (SOLID, complexity, smells, security, duplication)
└──────┬──────┘
       ▼
┌─────────────┐
│   Design    │ ← Architecture rules defined here
└──────┬──────┘
       ▼
┌─────────────────────────────────────┐
│          FEEDBACK LOOP              │
│  ┌─────────────┐                    │
│  │Implementation│                    │
│  └──────┬──────┘                    │
│         ▼                           │
│  ┌─────────────┐                    │
│  │ White-box   │ ← Dangling refs?   │
│  │ Regression  │   API changed?     │
│  └──────┬──────┘                    │
│         ▼                           │
│  ┌─────────────┐                    │
│  │Architecture │ ← Layer violation? │
│  │ Compliance  │                    │
│  └──────┬──────┘                    │
│         ▼                           │
│  ┌─────────────┐                    │
│  │ Black-box   │ ← Behavior changed?│
│  │ Regression  │                    │
│  └─────────────┘                    │
│    ↑ Retry up to 3 times on failure │
└─────────────────────────────────────┘
       ▼
┌─────────────┐
│   Review    │ ← Security, Performance, Maintainability, Testability
└──────┬──────┘
       ▼
┌─────────────┐
│ Completion  │
└─────────────┘
```

## Key Features

### 1. Regression Prevention

**White-box (Code Level)**:
- No dangling references to deleted symbols
- Public APIs preserved (same signatures)
- Same external dependencies called

**Black-box (Behavior Level)**:
- All existing tests pass
- Same inputs → same outputs
- Error handling unchanged

### 2. Architecture Compliance

Automatically checks layer dependencies:

| Architecture | Forbidden |
|--------------|-----------|
| Clean Architecture | Application → Presentation |
| Clean Architecture | Domain → Infrastructure |
| Hexagonal | Core → Adapter |

### 3. Feedback Loops

On any failure:
1. Auto-retry with specific fix instructions
2. Max 3 retries per check type
3. If still failing → Stop and report to user

## Components

### Agents (13)

**Analyzers (5)**:
- `code-analyzer-solid`
- `code-analyzer-complexity`
- `code-analyzer-smells`
- `code-analyzer-security`
- `code-analyzer-duplication`

**Workflow (4)**:
- `architecture-designer`
- `implementation-agent`
- `qa-agent`
- `test-implementer`

**Reviewers (4)**:
- `code-reviewer-security`
- `code-reviewer-performance`
- `code-reviewer-maintainability`
- `code-reviewer-testability`

### Skills (4)

- `solid-principles`: SOLID violation patterns and fixes
- `refactoring-patterns`: Fowler's refactoring catalog
- `code-quality-metrics`: Complexity thresholds
- `self-directed-debugging`: Autonomous workflow with proactive questions, automated verification, and browser testing

#### Self-Directed Debugging Skill

**NEW**: Transforms Claude Code into a proactive, quality-focused developer.

**Key Behaviors:**
1. **Ask First, Code Later** - Uses AskUserQuestion tool to clarify ambiguous requirements before implementation
2. **Comprehensive Verification** - Runs linter, type check, tests, build, and browser verification for every change
3. **Auto-Fix Linter Errors** - Automatically fixes formatting and style issues
4. **Browser Testing** - Opens DevTools and verifies actual functionality in browser
5. **Transparent Reporting** - Reports all verification results to user

**Example workflow:**
```markdown
User: "Add dark mode toggle"

Claude:
1. ❓ Asks: "Should dark mode persist? Respect system preferences?"
2. 💻 Implements toggle component
3. ✅ Verifies:
   - npm run lint:fix → Auto-fixed 2 issues
   - tsc --noEmit → Passed
   - npm test → 8/8 passed
   - npm run dev → Browser check: No console errors
4. 📊 Reports: "Feature verified and ready to commit!"
```

**Use when:** Implementing features, fixing bugs, or refactoring to ensure quality through autonomous verification.

## Installation

```bash
/plugin marketplace add shabaraba/shabaraba-cc-plugins
/plugin install dev-org
```

## License

MIT
