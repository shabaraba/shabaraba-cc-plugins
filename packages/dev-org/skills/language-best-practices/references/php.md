# PHP Best Practices

## Modern PHP (8.x)

### Strict Types
```php
<?php
declare(strict_types=1);
```

### Constructor Property Promotion
```php
class User {
    public function __construct(
        public readonly string $id,
        public readonly string $name,
        public int $age = 0
    ) {}
}
```

### Named Arguments
```php
$user = new User(
    id: '123',
    name: 'John',
    age: 30
);
```

### Match Expression
```php
$result = match($status) {
    'active' => handleActive(),
    'pending' => handlePending(),
    default => handleDefault(),
};
```

### Null Coalescing
```php
$name = $user['name'] ?? 'Unknown';
$name ??= 'Default';
```

## PSR Standards

- **PSR-1**: Basic coding standard
- **PSR-4**: Autoloading
- **PSR-12**: Extended coding style

## Error Handling

```php
try {
    $result = riskyOperation();
} catch (SpecificException $e) {
    $this->logger->error($e->getMessage());
    throw new DomainException('Operation failed', 0, $e);
}
```

## Anti-Patterns

| Anti-Pattern | Better Approach |
|--------------|-----------------|
| `@` error suppression | Proper error handling |
| Dynamic code execution | Static code paths |
| SQL string concatenation | Prepared statements |
| Mixed HTML/PHP | Template engine or separation |
| Global variables | Dependency injection |
| `extract()` on user input | Explicit variable assignment |
