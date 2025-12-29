---
name: refactor
description: Comprehensive AI-driven refactoring workflow with parallel analysis, design proposal, implementation, testing, and review
argument-hint: "[path] [--analysis-only] [--pr NUMBER]"
allowed-tools: ["Read", "Write", "Edit", "Grep", "Glob", "Bash", "Task", "TodoWrite", "AskUserQuestion"]
---

# Refactoring Workflow Orchestrator

Execute a comprehensive refactoring workflow for the specified target.

## Arguments

- **path** (optional): Directory or file to refactor. Default: entire project
- **--analysis-only**: Stop after analysis and design proposal (no implementation)
- **--pr NUMBER**: Analyze and refactor based on PR changes

## Critical Rules

### 1. Always Verify Subagent Output
After every subagent completes, YOU (orchestrator) must verify:
- Files claimed to be created → `Glob` to confirm existence
- Files claimed to be modified → `Read` to confirm changes
- Tests claimed to pass → `Bash` to run tests yourself

### 2. Feedback Loops Are Mandatory
```
Test Failed? → Back to Implementation (max 3 times)
Review Issues? → Back to Implementation (max 3 times)
Still Failing? → Stop and ask user
```

### 3. Maximum Retry Limits
- Implementation retry: 3 times per module
- Test fix retry: 3 times total
- Review fix retry: 3 times total
- After max retries: STOP and report to user

## Workflow Phases

```
┌─────────────┐
│ Preparation │
└──────┬──────┘
       ▼
┌─────────────┐
│  Analysis   │ (5 analyzers in parallel)
└──────┬──────┘
       ▼
┌─────────────┐
│   Design    │ → USER APPROVAL REQUIRED
└──────┬──────┘
       ▼
┌─────────────┐     ┌──────────────────┐
│Implementation│◄───│ Feedback Loop    │
└──────┬──────┘     │ (max 3 retries)  │
       ▼            └────────▲─────────┘
┌─────────────┐              │
│  QA & Test  │──── FAIL ────┘
└──────┬──────┘
       │ PASS
       ▼
┌─────────────┐     ┌──────────────────┐
│   Review    │────►│ Fix Issues       │
└──────┬──────┘     └────────┬─────────┘
       │                     │
       │◄────────────────────┘
       ▼
┌─────────────┐
│ Completion  │
└─────────────┘
```

---

## Phase 1: Preparation

**Actions**:
1. Parse arguments to determine scope
2. Create Git branch: `refactor/YYYYMMDD-{scope}`
3. Initialize TodoWrite with all phases

```bash
git checkout -b refactor/$(date +%Y%m%d)-{scope_slug}
```

**TodoWrite initialization**:
```
- [ ] Analysis Phase
- [ ] Design Phase
- [ ] User Approval
- [ ] Implementation Phase
- [ ] QA & Test Phase
- [ ] Review Phase
- [ ] Completion
```

---

## Phase 2: Analysis (Parallel)

Launch 5 analyzer agents in parallel:

```
Task(subagent_type="code-analyzer-solid", prompt="...")
Task(subagent_type="code-analyzer-complexity", prompt="...")
Task(subagent_type="code-analyzer-smells", prompt="...")
Task(subagent_type="code-analyzer-security", prompt="...")
Task(subagent_type="code-analyzer-duplication", prompt="...")
```

**After all complete**: Aggregate results into unified analysis report.

---

## Phase 3: Design

Launch `architecture-designer` agent:
```
Task(subagent_type="architecture-designer", prompt="Design refactoring based on: {analysis_results}")
```

**USER APPROVAL REQUIRED**:
```
AskUserQuestion(
  question="Proceed with this refactoring plan?",
  options=[
    {label: "Approve", description: "Continue to implementation"},
    {label: "Modify", description: "Request changes to design"},
    {label: "Cancel", description: "Stop refactoring"}
  ]
)
```

If `--analysis-only` or user cancels: Generate report and stop.

---

## Phase 4: Implementation

### 4.1 Execute Implementation

Launch `implementation-agent`:
```
Task(subagent_type="implementation-agent", prompt="Implement: {approved_design}")
```

### 4.2 Verify Output (MANDATORY)

**YOU must verify after subagent completes:**

```python
# For each file claimed as created:
for file in claimed_created_files:
    result = Glob(pattern=file)
    if not result:
        VERIFICATION_FAILED = True

# For each file claimed as modified:
for file in claimed_modified_files:
    content = Read(file)
    if expected_changes not in content:
        VERIFICATION_FAILED = True
```

**If verification fails**:
1. Log which files are missing/incorrect
2. Re-launch implementation-agent with specific instructions
3. Max 3 retries, then stop and report to user

### 4.3 Run Lint/Format

```bash
# Detect and run appropriate tools
npm run lint 2>/dev/null || npx eslint . --fix
npm run format 2>/dev/null || npx prettier --write .
```

---

## Phase 5: QA & Test

### 5.1 QA Analysis

Launch `qa-agent`:
```
Task(subagent_type="qa-agent", prompt="Analyze impact and design tests for changes")
```

### 5.2 Test Implementation

Launch `test-implementer`:
```
Task(subagent_type="test-implementer", prompt="Implement tests: {test_design}")
```

### 5.3 Run Tests (MANDATORY)

**YOU must run tests yourself:**
```bash
npm test || pytest || go test ./... || mvn test
```

### 5.4 Handle Test Results

```
IF all tests pass:
    → Proceed to Phase 6 (Review)

IF tests fail:
    → Increment retry_count
    → IF retry_count > 3:
        → STOP and report to user:
          "Tests failed 3 times. Issues: {failures}"
          "Options: 1) Fix manually 2) Skip tests 3) Abort"
    → ELSE:
        → Go back to Phase 4.1 with prompt:
          "Fix test failures: {failure_details}"
```

---

## Phase 6: Review

### 6.1 Execute Reviews (Parallel)

Launch 4 reviewer agents:
```
Task(subagent_type="code-reviewer-security", prompt="...")
Task(subagent_type="code-reviewer-performance", prompt="...")
Task(subagent_type="code-reviewer-maintainability", prompt="...")
Task(subagent_type="code-reviewer-testability", prompt="...")
```

### 6.2 Aggregate Findings

Categorize issues:
- **Critical**: Must fix before completion
- **Major**: Should fix, ask user
- **Minor**: Can fix automatically or defer

### 6.3 Handle Review Issues

```
IF no critical/major issues:
    → Proceed to Phase 7 (Completion)

IF critical issues found:
    → Increment review_retry_count
    → IF review_retry_count > 3:
        → STOP and report to user:
          "Critical issues not resolved after 3 attempts"
          "Issues: {critical_issues}"
    → ELSE:
        → Go back to Phase 4.1 with prompt:
          "Fix critical review issues: {issue_details}"

IF only major issues:
    → AskUserQuestion:
        "Review found these issues: {issues}"
        Options:
        - "Fix now" → Back to Phase 4.1
        - "Fix later" → Record as tech debt, continue
        - "Ignore" → Continue without fixing
```

### 6.4 Auto-fix Minor Issues

For minor issues (formatting, naming, etc.):
1. Apply fixes directly using Edit tool
2. Re-run lint/format
3. Verify fixes applied

---

## Phase 7: Completion

### 7.1 Final Verification

**Run full test suite:**
```bash
npm test || pytest || go test ./... || mvn test
```

**Verify all claimed files exist:**
```python
for file in all_created_files:
    assert Glob(file) is not empty
```

### 7.2 Generate Summary Report

```markdown
## Refactoring Summary

### Changes Made
- Files created: {count} (all verified)
- Files modified: {count} (all verified)
- Files deleted: {count}

### Analysis Findings Addressed
- SOLID violations fixed: {count}
- Code smells removed: {count}
- Duplications eliminated: {count}

### Test Results
- Total tests: {count}
- Passing: {count}
- Coverage: {percentage}%

### Review Results
- Critical issues: 0 (all resolved)
- Major issues: {count} ({resolved} fixed, {deferred} deferred)
- Minor issues: {count} (auto-fixed)

### Iterations Required
- Implementation retries: {count}
- Test fix retries: {count}
- Review fix retries: {count}
```

### 7.3 Present to User

Show summary and ask:
```
AskUserQuestion(
  question="Refactoring complete. What next?",
  options=[
    {label: "Merge", description: "Merge branch to main/develop"},
    {label: "Create PR", description: "Create pull request for review"},
    {label: "Keep branch", description: "Leave changes in branch"}
  ]
)
```

---

## State Tracking

Maintain these variables throughout:

```yaml
state:
  current_phase: "implementation"
  implementation_retry_count: 0
  test_retry_count: 0
  review_retry_count: 0
  max_retries: 3

  created_files: []
  modified_files: []
  deleted_files: []

  test_results:
    passed: 0
    failed: 0
    failures: []

  review_issues:
    critical: []
    major: []
    minor: []
```

---

## Error Handling

| Situation | Action |
|-----------|--------|
| Analyzer fails | Continue with others, note partial results |
| Implementation fails (< 3 retries) | Retry with error details |
| Implementation fails (>= 3 retries) | Stop, report to user |
| Tests fail (< 3 retries) | Back to implementation |
| Tests fail (>= 3 retries) | Stop, ask user what to do |
| Critical review issue (< 3 retries) | Back to implementation |
| Critical review issue (>= 3 retries) | Stop, report to user |
| Verification fails | Retry subagent or fix manually |

---

## Skills to Load

- `solid-principles` - SOLID violation patterns
- `refactoring-patterns` - Refactoring techniques
- `code-quality-metrics` - Complexity thresholds
- `language-best-practices` - Language-specific patterns

---

## Example Usage

```bash
# Refactor entire project
/refactor

# Refactor specific directory
/refactor src/services

# Analysis only (no changes)
/refactor src/api --analysis-only

# Refactor based on PR
/refactor --pr 123
```
