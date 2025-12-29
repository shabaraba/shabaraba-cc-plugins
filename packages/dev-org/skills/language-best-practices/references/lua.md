# Lua Best Practices

## Local Variables

### Always Use Local
```lua
-- Bad: Global pollution
counter = 0

-- Good: Local scope
local counter = 0
```

### Local Function References
```lua
-- Cache frequently used functions
local insert = table.insert
local format = string.format
```

## Tables

### Module Pattern
```lua
local M = {}

function M.process(data)
    return data
end

return M
```

### Avoid Table Growth in Loops
```lua
-- Bad: Table grows each iteration
local t = {}
for i = 1, 1000 do
    t[#t + 1] = i
end

-- Good: Pre-allocate when size known
local t = {}
for i = 1, 1000 do
    t[i] = i
end
```

## Metatables for OOP

```lua
local Class = {}
Class.__index = Class

function Class.new(name)
    local self = setmetatable({}, Class)
    self.name = name
    return self
end

function Class:greet()
    return "Hello, " .. self.name
end

return Class
```

## Coroutines

```lua
local co = coroutine.create(function()
    for i = 1, 10 do
        coroutine.yield(i)
    end
end)

while coroutine.status(co) ~= "dead" do
    local _, value = coroutine.resume(co)
    print(value)
end
```

## String Handling

```lua
-- Bad: Concatenation in loop
local result = ""
for _, s in ipairs(strings) do
    result = result .. s  -- Creates new string each time
end

-- Good: Use table.concat
local parts = {}
for i, s in ipairs(strings) do
    parts[i] = s
end
local result = table.concat(parts)
```

## Anti-Patterns

| Anti-Pattern | Better Approach |
|--------------|-----------------|
| Global variables | Always use `local` |
| String concat in loops | `table.concat()` |
| `pairs` for arrays | `ipairs` for sequential |
| Deep nesting | Early returns |
| Not caching table.* | Local references |
