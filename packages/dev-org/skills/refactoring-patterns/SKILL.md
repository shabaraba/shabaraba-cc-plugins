---
name: Refactoring Patterns
description: This skill should be used when the user asks about "refactoring", "code smells", "extract method", "extract class", "rename refactoring", "move method", or when improving code structure without changing behavior. Provides Martin Fowler's refactoring catalog and code smell detection.
version: 0.1.0
---

# Refactoring Patterns Guide

## Overview

Refactoring is the process of improving code structure without changing its external behavior. This skill provides guidance based on Martin Fowler's refactoring catalog and industry best practices for detecting code smells and applying appropriate refactoring patterns.

## Core Principles

### The Refactoring Cycle

1. **Identify** - Detect code smells or improvement opportunities
2. **Test** - Ensure tests cover the code to be refactored
3. **Refactor** - Apply small, incremental changes
4. **Verify** - Run tests after each change
5. **Repeat** - Continue until goal is achieved

### When to Refactor

- Before adding new features
- When fixing bugs
- During code review
- When code smells are detected
- To improve test coverage

### When NOT to Refactor

- No test coverage exists (write tests first)
- Deadline pressure (schedule dedicated time)
- Complete rewrite is needed

## Code Smells Categories

### Bloaters

Code that has grown too large:

| Smell | Indicators | Refactoring |
|-------|------------|-------------|
| Long Method | >20 lines, multiple concerns | Extract Method |
| Large Class | >300 lines, many fields | Extract Class |
| Primitive Obsession | Overuse of primitives for data | Replace with Object |
| Long Parameter List | >3-4 parameters | Introduce Parameter Object |
| Data Clumps | Same data groups repeated | Extract Class |

### Object-Orientation Abusers

Incorrect OO design:

| Smell | Indicators | Refactoring |
|-------|------------|-------------|
| Switch Statements | Type-based switching | Replace with Polymorphism |
| Parallel Inheritance | Matching class hierarchies | Move Method, Collapse Hierarchy |
| Refused Bequest | Subclass doesn't use inherited | Replace Inheritance with Delegation |
| Temporary Field | Fields only sometimes used | Extract Class |

### Change Preventers

Code that resists modification:

| Smell | Indicators | Refactoring |
|-------|------------|-------------|
| Divergent Change | Class changes for multiple reasons | Extract Class |
| Shotgun Surgery | One change affects many classes | Move Method, Inline Class |
| Parallel Inheritance | Adding subclass requires another | Move Method |

### Dispensables

Unnecessary code:

| Smell | Indicators | Refactoring |
|-------|------------|-------------|
| Comments | Explaining bad code | Extract Method (self-documenting) |
| Duplicate Code | Same code in multiple places | Extract Method/Class |
| Dead Code | Unreachable code | Delete |
| Lazy Class | Class does too little | Inline Class |
| Speculative Generality | Unused abstraction | Collapse Hierarchy |

### Couplers

Excessive coupling:

| Smell | Indicators | Refactoring |
|-------|------------|-------------|
| Feature Envy | Method uses other class's data | Move Method |
| Inappropriate Intimacy | Classes know too much about each other | Move Method, Extract Class |
| Message Chains | a.b().c().d() chains | Hide Delegate |
| Middle Man | Class only delegates | Remove Middle Man |

## Essential Refactoring Patterns

### Extract Method

Transform code fragment into a method with descriptive name.

**When to apply**:
- Code block has a clear purpose
- Same code appears in multiple places
- Method is too long

**Process**:
1. Identify code to extract
2. Check for local variables used
3. Create new method with clear name
4. Replace original code with method call
5. Compile and test

### Extract Class

Move related fields and methods to a new class.

**When to apply**:
- Class has multiple responsibilities
- Subset of fields always used together
- Class is too large

**Process**:
1. Identify cohesive group of fields/methods
2. Create new class
3. Move fields first, then methods
4. Update references
5. Consider making new class a field

### Move Method

Move method to the class that uses its data most.

**When to apply**:
- Method uses data from another class
- Feature envy detected
- Better cohesion possible

### Introduce Parameter Object

Group related parameters into an object.

**When to apply**:
- Same parameter groups repeated
- More than 3-4 parameters
- Parameters represent a concept

### Replace Conditional with Polymorphism

Replace type-based switching with inheritance.

**When to apply**:
- Switch on type code
- Same conditional in multiple places
- New types require code changes

## Refactoring Safety Checklist

Before refactoring:
- [ ] Tests exist and pass
- [ ] Code is under version control
- [ ] IDE refactoring tools available
- [ ] Small steps planned

During refactoring:
- [ ] One change at a time
- [ ] Compile after each change
- [ ] Test after each step
- [ ] Commit working states

After refactoring:
- [ ] All tests pass
- [ ] Code review completed
- [ ] Documentation updated
- [ ] Performance verified

## Additional Resources

### Reference Files

For comprehensive pattern catalog and detection scripts:
- **`references/fowler-catalog.md`** - Complete refactoring pattern catalog
- **`references/smell-detection.md`** - Code smell detection techniques

### Integration with Other Skills

Combine with:
- `solid-principles` for design principle guidance
- `code-quality-metrics` for quantitative analysis
