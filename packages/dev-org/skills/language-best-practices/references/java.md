# Java Best Practices

## Modern Java Features

### Records (Java 14+)
```java
// Instead of verbose POJOs
public record User(String id, String name, int age) {}
```

### Pattern Matching (Java 16+)
```java
if (obj instanceof String s) {
    System.out.println(s.length());
}
```

### Sealed Classes (Java 17+)
```java
sealed interface Shape permits Circle, Rectangle, Triangle {}
```

## Stream API

```java
// Prefer streams for collection processing
List<String> names = users.stream()
    .filter(u -> u.isActive())
    .map(User::getName)
    .sorted()
    .collect(Collectors.toList());
```

## Optional

```java
// Return Optional for nullable returns
public Optional<User> findById(String id) {
    return Optional.ofNullable(repository.get(id));
}

// Use methods, not isPresent() + get()
user.map(User::getName).orElse("Unknown");
```

## Builder Pattern

```java
User user = User.builder()
    .name("John")
    .email("john@example.com")
    .build();
```

## Anti-Patterns

| Anti-Pattern | Better Approach |
|--------------|-----------------|
| Null returns | `Optional<T>` |
| Checked exceptions everywhere | Unchecked for programming errors |
| Primitive obsession | Value objects |
| instanceof chains | Polymorphism or visitor |
| StringBuilder in loops | `String.join()` or streams |
| Raw types | Generics `List<String>` |
