# dev-org - Development Organization Plugin

Comprehensive development organization plugin for Claude Code featuring AI-driven refactoring, implementation, and code analysis workflows.

## Features

### `/refactor` Command

Comprehensive refactoring workflow with parallel AI agents:

1. **Analysis Phase**: Multiple specialized analyzers examine code
   - SOLID principles violations
   - Cyclomatic & cognitive complexity
   - Code smells detection
   - Security vulnerabilities
   - Code duplication

2. **Design Phase**: Architecture designer proposes refactoring plan
   - Module breakdown suggestions
   - SOLID compliance improvements
   - Readability enhancements

3. **Implementation Phase**: Automated refactoring execution
   - Module-by-module implementation
   - Automatic lint/format application
   - 3-retry error handling

4. **QA Phase**: Impact analysis and test design
   - Affected scope identification
   - Test strategy creation

5. **Test Implementation**: Automated test generation
   - Unit tests
   - Integration tests
   - E2E tests (as needed)
   - Auto-fix broken existing tests

6. **Review Phase**: Multi-perspective code review
   - Security review
   - Performance review
   - Maintainability review
   - Testability review

## Usage

```bash
# Refactor entire project
/refactor

# Refactor specific path
/refactor src/components

# Refactor single file
/refactor src/utils/helper.ts

# Analyze PR
/refactor --pr 123

# Analysis only (no implementation)
/refactor --analysis-only
```

## Supported Languages

- TypeScript
- JavaScript
- Java
- PHP
- Lua
- Go
- Python

## Installation

```bash
# Install from local directory
cc --plugin-dir /path/to/claude-code-plugins/packages/dev-org

# Or copy to project .claude-plugin directory
cp -r packages/dev-org /path/to/your/project/.claude-plugin/
```

## Components

### Agents (13)

**Analyzers (5)**:
- `code-analyzer-solid`: SOLID principles checker
- `code-analyzer-complexity`: Complexity metrics analyzer
- `code-analyzer-smells`: Code smell detector
- `code-analyzer-security`: Security vulnerability scanner
- `code-analyzer-duplication`: Duplicate code finder

**Workflow Agents (4)**:
- `architecture-designer`: Refactoring architecture designer
- `implementation-agent`: Code implementation executor
- `qa-agent`: QA and test strategy planner
- `test-implementer`: Test code generator

**Reviewers (4)**:
- `code-reviewer-security`: Security-focused reviewer
- `code-reviewer-performance`: Performance-focused reviewer
- `code-reviewer-maintainability`: Maintainability-focused reviewer
- `code-reviewer-testability`: Testability-focused reviewer

### Skills (4)

- `solid-principles`: Detailed SOLID principles guide
- `refactoring-patterns`: Refactoring pattern catalog
- `code-quality-metrics`: Complexity metrics and thresholds
- `language-best-practices`: Language-specific best practices (TS/JS/Java/PHP/Lua/Go/Python)

## Future Commands

- `/implement`: AI-driven feature implementation
- `/investigate`: Deep code investigation and analysis

## License

MIT
