# Python Best Practices

## Pythonic Idioms

### List Comprehensions
```python
# Instead of loops for simple transformations
squares = [x**2 for x in range(10)]
active_users = [u for u in users if u.active]
```

### Generator Expressions
```python
# For large datasets, use generators
sum(x**2 for x in range(1000000))
```

### Context Managers
```python
# Always use with for resources
with open("file.txt") as f:
    content = f.read()
```

### Dataclasses
```python
from dataclasses import dataclass

@dataclass
class User:
    id: str
    name: str
    age: int = 0
```

## Type Hints

```python
def process(items: list[str]) -> dict[str, int]:
    return {item: len(item) for item in items}
```

## Error Handling

```python
# Specific exceptions, not bare except
try:
    value = data["key"]
except KeyError as e:
    logger.error(f"Missing key: {e}")
    raise
```

## Anti-Patterns

| Anti-Pattern | Better Approach |
|--------------|-----------------|
| `except:` bare clause | Specific exception types |
| Mutable default args `def f(x=[])` | `def f(x=None)` then `x = x or []` |
| `from module import *` | Explicit imports |
| Global variables | Dependency injection |
| Manual resource management | Context managers |
| String concatenation in loops | `''.join()` or f-strings |
