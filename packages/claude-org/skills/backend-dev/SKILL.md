---
name: backend-dev
description: Backend development skill for Cloudflare Workers, D1 database, and REST API. Use when implementing API features.
---

# Backend Development Skill

Platform-specific knowledge for backend/API development.

## Tech Stack

| Component | Technology |
|-----------|------------|
| Runtime | Cloudflare Workers |
| Framework | Hono |
| Database | D1 (SQLite) |
| ORM | Drizzle ORM |
| Validation | Zod |
| Auth | JWT / Cloudflare Access |

## Coding Standards

### Naming
- Functions/Variables: `camelCase`
- Types/Interfaces: `PascalCase`
- Constants: `SCREAMING_SNAKE_CASE`
- Database tables: `snake_case`
- API endpoints: `kebab-case`
- Language: English

### File Organization
```
src/
├── index.ts           # Entry point, Hono app
├── routes/
│   ├── users.ts       # /api/users routes
│   └── posts.ts       # /api/posts routes
├── services/
│   ├── user-service.ts
│   └── post-service.ts
├── db/
│   ├── schema.ts      # Drizzle schema
│   └── migrations/
├── middleware/
│   ├── auth.ts
│   └── cors.ts
└── types/
    └── index.ts
```

### Hono Patterns
```typescript
import { Hono } from 'hono'
import { zValidator } from '@hono/zod-validator'
import { z } from 'zod'

const app = new Hono<{ Bindings: Env }>()

// Route with validation
const createUserSchema = z.object({
  name: z.string().min(1),
  email: z.string().email(),
})

app.post('/users', zValidator('json', createUserSchema), async (c) => {
  const data = c.req.valid('json')
  const db = c.env.DB

  const result = await db
    .prepare('INSERT INTO users (name, email) VALUES (?, ?)')
    .bind(data.name, data.email)
    .run()

  return c.json({ id: result.lastRowId }, 201)
})

export default app
```

## Build Commands

```bash
# Development
pnpm dev  # or wrangler dev

# Deploy
pnpm deploy  # or wrangler deploy

# Database migration
pnpm db:generate  # Generate migration
pnpm db:migrate   # Apply migration (local)
pnpm db:migrate:prod  # Apply to production

# Type generation
pnpm cf-typegen
```

## D1 Database

### Schema with Drizzle
```typescript
// src/db/schema.ts
import { sqliteTable, text, integer } from 'drizzle-orm/sqlite-core'

export const users = sqliteTable('users', {
  id: integer('id').primaryKey({ autoIncrement: true }),
  name: text('name').notNull(),
  email: text('email').notNull().unique(),
  createdAt: text('created_at').default(sql`CURRENT_TIMESTAMP`),
})

export const posts = sqliteTable('posts', {
  id: integer('id').primaryKey({ autoIncrement: true }),
  userId: integer('user_id').references(() => users.id),
  title: text('title').notNull(),
  content: text('content'),
})
```

### Query Patterns
```typescript
import { drizzle } from 'drizzle-orm/d1'
import { eq } from 'drizzle-orm'
import * as schema from './db/schema'

// In route handler
const db = drizzle(c.env.DB, { schema })

// Select
const users = await db.select().from(schema.users).all()

// Select with where
const user = await db.select()
  .from(schema.users)
  .where(eq(schema.users.id, id))
  .get()

// Insert
const result = await db.insert(schema.users)
  .values({ name, email })
  .returning()

// Update
await db.update(schema.users)
  .set({ name: newName })
  .where(eq(schema.users.id, id))

// Delete
await db.delete(schema.users)
  .where(eq(schema.users.id, id))
```

## API Design

### REST Conventions
```
GET    /api/users          # List users
POST   /api/users          # Create user
GET    /api/users/:id      # Get user
PUT    /api/users/:id      # Update user
DELETE /api/users/:id      # Delete user
GET    /api/users/:id/posts # List user's posts
```

### Response Format
```typescript
// Success
{
  "data": { ... },
  "meta": {
    "total": 100,
    "page": 1,
    "limit": 20
  }
}

// Error
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid email format",
    "details": [...]
  }
}
```

### Error Handling
```typescript
import { HTTPException } from 'hono/http-exception'

// Throw error
if (!user) {
  throw new HTTPException(404, { message: 'User not found' })
}

// Global error handler
app.onError((err, c) => {
  if (err instanceof HTTPException) {
    return c.json({ error: { message: err.message } }, err.status)
  }
  console.error(err)
  return c.json({ error: { message: 'Internal Server Error' } }, 500)
})
```

## Authentication

### JWT Pattern
```typescript
import { jwt } from 'hono/jwt'

// Middleware
app.use('/api/*', jwt({ secret: c.env.JWT_SECRET }))

// Access payload
app.get('/api/me', (c) => {
  const payload = c.get('jwtPayload')
  return c.json({ userId: payload.sub })
})

// Generate token
import { sign } from 'hono/jwt'

const token = await sign(
  { sub: user.id, exp: Math.floor(Date.now() / 1000) + 60 * 60 },
  env.JWT_SECRET
)
```

## Testing

```typescript
import { describe, it, expect } from 'vitest'
import app from './index'

describe('Users API', () => {
  it('GET /api/users returns users', async () => {
    const res = await app.request('/api/users')
    expect(res.status).toBe(200)
    const data = await res.json()
    expect(Array.isArray(data.data)).toBe(true)
  })
})
```

## Common Issues

### "D1_ERROR: no such table"
- Run migrations: `wrangler d1 migrations apply DB`
- Check wrangler.toml database binding

### CORS errors
- Add CORS middleware:
  ```typescript
  import { cors } from 'hono/cors'
  app.use('*', cors())
  ```

### Environment variables
- Local: `.dev.vars` file
- Production: `wrangler secret put SECRET_NAME`
