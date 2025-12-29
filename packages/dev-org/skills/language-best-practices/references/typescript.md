# TypeScript / JavaScript Best Practices

## Type System

### Strict Mode
Enable strict mode in `tsconfig.json` for better type safety.

### Type Inference
Let TypeScript infer types when obvious. Annotate function returns and complex types.

### Avoid `any`
Use `unknown` for truly unknown types, generics for flexibility.

### Type Guards
```typescript
function isUser(obj: unknown): obj is User {
  return typeof obj === "object" && obj !== null && "id" in obj;
}
```

### Discriminated Unions
```typescript
type Result<T> = { success: true; data: T } | { success: false; error: Error };
```

## Functions

- Arrow functions for callbacks (preserves `this`)
- Options object for multiple optional parameters
- Async/await over promise chains

## Objects

- Prefer immutability with spread operator
- Use `Readonly<T>` for immutable interfaces
- Composition over inheritance

## Anti-Patterns

| Anti-Pattern | Better Approach |
|--------------|-----------------|
| `any` everywhere | `unknown` + type guards |
| `!` non-null assertion | Optional chaining `?.` |
| Barrel exports `export *` | Direct imports |
| Mutable shared state | Immutable updates |
| Callback hell | Async/await |
