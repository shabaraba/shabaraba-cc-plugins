# Go Best Practices

## Interfaces

### Small Interfaces
```go
// Good: Single method interface
type Reader interface {
    Read(p []byte) (n int, err error)
}

// Bad: Fat interface
type Service interface {
    Create() error
    Read() error
    Update() error
    Delete() error
    List() error
    // ... too many methods
}
```

### Accept Interfaces, Return Structs
```go
func Process(r io.Reader) *Result { }
```

## Error Handling

### Always Check Errors
```go
result, err := doSomething()
if err != nil {
    return fmt.Errorf("doSomething failed: %w", err)
}
```

### Error Wrapping
```go
if err != nil {
    return fmt.Errorf("failed to process %s: %w", id, err)
}
```

## Concurrency

### Channels for Communication
```go
ch := make(chan Result)
go func() {
    ch <- process()
}()
result := <-ch
```

### Context for Cancellation
```go
func Process(ctx context.Context) error {
    select {
    case <-ctx.Done():
        return ctx.Err()
    default:
        // continue processing
    }
}
```

## Testing

### Table-Driven Tests
```go
tests := []struct {
    name     string
    input    string
    expected int
}{
    {"empty", "", 0},
    {"single", "a", 1},
}
for _, tt := range tests {
    t.Run(tt.name, func(t *testing.T) {
        if got := Len(tt.input); got != tt.expected {
            t.Errorf("got %d, want %d", got, tt.expected)
        }
    })
}
```

## Anti-Patterns

| Anti-Pattern | Better Approach |
|--------------|-----------------|
| Ignored errors `_ = f()` | Always handle errors |
| Naked returns | Named returns only when helpful |
| Package-level vars | Dependency injection |
| Interface pollution | Small, focused interfaces |
| `panic` for errors | Return errors |
