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

## Workflow Phases

### Phase 1: Preparation
1. Parse arguments to determine scope (project, path, or PR)
2. Create Git branch: `refactor/YYYYMMDD-{scope}`
3. Initialize progress tracking with TodoWrite

### Phase 2: Analysis (Parallel)
Launch 5 analyzer agents in parallel using Task tool:
- `code-analyzer-solid` - SOLID principle violations
- `code-analyzer-complexity` - Complexity metrics
- `code-analyzer-smells` - Code smell detection
- `code-analyzer-security` - Security vulnerabilities
- `code-analyzer-duplication` - Duplicate code detection

Wait for all analyzers to complete and aggregate results.

### Phase 3: Design
Launch `architecture-designer` agent to:
- Synthesize analysis findings
- Propose refactoring architecture
- Create implementation plan
- Identify risks and dependencies

**USER APPROVAL REQUIRED**: Present design to user and wait for approval.

If `--analysis-only` flag: Stop here and report findings.

### Phase 4: Implementation
After user approval, launch `implementation-agent` to:
- Implement changes module by module
- Run lint/format after each module
- Retry up to 3 times on errors
- Report progress via TodoWrite

### Phase 5: QA & Test Design
Launch `qa-agent` to:
- Analyze impact scope
- Design test strategy
- Create test specifications

### Phase 6: Test Implementation
Launch `test-implementer` to:
- Implement unit tests
- Implement integration tests
- Implement E2E tests (if needed)
- Fix broken existing tests
- Verify all tests pass

### Phase 7: Review (Parallel)
Launch 4 reviewer agents in parallel:
- `code-reviewer-security` - Security review
- `code-reviewer-performance` - Performance review
- `code-reviewer-maintainability` - Maintainability review
- `code-reviewer-testability` - Testability review

Aggregate review findings. Auto-fix simple issues, propose fixes for complex ones.

### Phase 8: Completion
- Run final test suite
- Generate summary report
- Present results to user

## Execution Instructions

### Step 1: Parse Arguments
```
if args contains "--pr":
  scope = "PR #{number}"
  target = get PR changed files
elif args contains path:
  scope = path
  target = specified path
else:
  scope = "project"
  target = entire project
```

### Step 2: Git Branch
```bash
git checkout -b refactor/$(date +%Y%m%d)-{scope_slug}
```

### Step 3: Initialize Tracking
Use TodoWrite to create:
- [ ] Analysis Phase
- [ ] Design Phase
- [ ] User Approval
- [ ] Implementation Phase
- [ ] QA Phase
- [ ] Test Implementation
- [ ] Review Phase
- [ ] Completion

### Step 4: Run Analyzers (Parallel)
Use Task tool to launch all 5 analyzers simultaneously:
```
Task(subagent_type="code-analyzer-solid", prompt="Analyze {target} for SOLID violations")
Task(subagent_type="code-analyzer-complexity", prompt="Analyze {target} complexity")
Task(subagent_type="code-analyzer-smells", prompt="Detect code smells in {target}")
Task(subagent_type="code-analyzer-security", prompt="Scan {target} for security issues")
Task(subagent_type="code-analyzer-duplication", prompt="Find duplicates in {target}")
```

### Step 5: Design Phase
Launch architecture-designer with analysis results:
```
Task(subagent_type="architecture-designer", prompt="Design refactoring based on: {analysis_results}")
```

### Step 6: User Approval
Present design and ask:
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

If `--analysis-only`: Skip to completion with analysis report.

### Step 7: Implementation
```
Task(subagent_type="implementation-agent", prompt="Implement: {approved_design}")
```

### Step 8: QA
```
Task(subagent_type="qa-agent", prompt="Analyze impact and design tests for changes")
```

### Step 9: Test Implementation
```
Task(subagent_type="test-implementer", prompt="Implement tests: {test_design}")
```

### Step 10: Review (Parallel)
```
Task(subagent_type="code-reviewer-security", prompt="Security review of changes")
Task(subagent_type="code-reviewer-performance", prompt="Performance review of changes")
Task(subagent_type="code-reviewer-maintainability", prompt="Maintainability review")
Task(subagent_type="code-reviewer-testability", prompt="Testability review")
```

### Step 11: Final Report
Generate comprehensive summary:
- Changes made
- Issues found and fixed
- Test coverage
- Recommendations

## Skills to Load

Load these skills for detailed guidance:
- `solid-principles` - SOLID violation patterns
- `refactoring-patterns` - Refactoring techniques
- `code-quality-metrics` - Complexity thresholds
- `language-best-practices` - Language-specific patterns

## Error Handling

- On analyzer failure: Continue with other analyzers, report partial results
- On implementation error: Retry 3 times, then report to user
- On test failure: Report failures, allow user to decide next steps
- On review issues: Auto-fix simple issues, propose fixes for complex ones

## Output

Final report includes:
1. Executive Summary
2. Analysis Findings
3. Changes Implemented
4. Test Coverage Report
5. Review Results
6. Recommendations

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
