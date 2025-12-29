---
name: Language Best Practices
description: This skill should be used when the user asks about "TypeScript best practices", "Python idioms", "Java patterns", "Go conventions", "PHP standards", "Lua patterns", or when analyzing code for language-specific improvements. Provides best practices for TypeScript, JavaScript, Java, PHP, Lua, Go, and Python.
version: 0.1.0
---

# Language Best Practices Guide

## Overview

This skill provides language-specific best practices, idioms, and anti-patterns for supported languages. Use in conjunction with SOLID principles and refactoring patterns for comprehensive code improvement.

## Supported Languages

- TypeScript / JavaScript
- Java
- Python
- Go
- PHP
- Lua

## Universal Principles

These principles apply across all languages:

### Naming Conventions

| Element | Convention |
|---------|------------|
| Variables | Descriptive, reveal intent |
| Functions | Verb + noun (action-oriented) |
| Classes | Noun (represents entity) |
| Constants | UPPER_SNAKE_CASE |
| Booleans | is/has/can prefix |

### Code Organization

1. **Imports first** - Grouped by origin (std lib, external, internal)
2. **Constants and types** - After imports
3. **Main logic** - Core functionality
4. **Helper functions** - Supporting code

### Error Handling

- Fail fast - Check preconditions early
- Be specific - Use typed errors when possible
- Log context - Include relevant debugging info
- Clean up - Use finally/defer for resource cleanup

## Language-Specific Quick Reference

### TypeScript / JavaScript

**Key Patterns**:
- Strict null checks enabled
- Prefer `const` over `let`
- Use type inference wisely
- Async/await over raw promises
- Immutable data patterns

**Anti-patterns**:
- `any` type abuse
- Type assertions without validation
- Callback hell
- Mutable shared state

### Java

**Key Patterns**:
- Effective Java patterns (Builder, etc.)
- Stream API for collections
- Optional for nullable returns
- Dependency injection
- Interface-based design

**Anti-patterns**:
- Null pointer exceptions
- Checked exception abuse
- Primitive obsession
- God classes

### Python

**Key Patterns**:
- Pythonic idioms (list comprehensions, etc.)
- Context managers for resources
- Dataclasses for data containers
- Type hints for documentation
- Generator expressions

**Anti-patterns**:
- Bare except clauses
- Mutable default arguments
- Global state
- Import * usage

### Go

**Key Patterns**:
- Small interfaces (1-3 methods)
- Error wrapping with context
- Channels for concurrency
- Table-driven tests
- Composition over inheritance

**Anti-patterns**:
- Naked returns
- Ignored errors
- Package-level variables
- Interface pollution

### PHP

**Key Patterns**:
- PSR standards compliance
- Strict types declaration
- Null coalescing operators
- Named arguments (8.0+)
- Attributes for metadata

**Anti-patterns**:
- Deprecated functions
- SQL injection vulnerabilities
- Mixed HTML/PHP
- Missing error handling

### Lua

**Key Patterns**:
- Local variable preference
- Metatables for OOP
- Coroutines for async
- Module pattern
- Tail call optimization

**Anti-patterns**:
- Global variable pollution
- Table mutation side effects
- Deep nesting
- String concatenation loops

## Detection Workflow

When analyzing code for language-specific issues:

1. **Identify language** from file extension and content
2. **Load language reference** from `references/`
3. **Check naming conventions** per language
4. **Identify anti-patterns** specific to language
5. **Suggest idiomatic alternatives**
6. **Verify with linter rules** when available

## Additional Resources

### Reference Files

Detailed patterns for each language:
- **`references/typescript.md`** - TypeScript/JavaScript patterns
- **`references/java.md`** - Java patterns
- **`references/python.md`** - Python patterns
- **`references/golang.md`** - Go patterns
- **`references/php.md`** - PHP patterns
- **`references/lua.md`** - Lua patterns

### Integration with Other Skills

Combine with:
- `solid-principles` for OOP design
- `code-quality-metrics` for complexity analysis
- `refactoring-patterns` for improvement techniques
