# `cell` - shared state

A thread-safe mutable box. The one place in Ecko where sharing mutable state is
intentional.

```ecko fragment
hits = cell(0)

http.serve(8080, fn(req) {
    n = cell_update(hits, fn(v) v + 1)     # atomic read-modify-write
    http.text("request #{n}")
})
```

## Why it exists

Parallel workers - [`pmap`](./pmap.md), `http.serve` handlers,
[async tasks](./async.md) - each see a *snapshot* of captured variables. Mutating
an ordinary `mut` inside one changes that worker's copy and nothing else. That
makes races impossible by default, and it makes a shared counter impossible too.

A cell is the escape hatch, and it is deliberately a different thing with a
different name, so that shared mutable state is visible in the source rather than
implied by where a variable was declared.

## The operations

| call | effect |
|---|---|
| `cell(initial)` | Create a cell |
| `cell_get(c)` | Read the current value (a copy) |
| `cell_set(c, v)` | Replace the value |
| `cell_update(c, fn)` | Run `fn(current)` under the lock, store the result, return it |

## Use `cell_update` for anything read-modify-write

```ecko fragment
cell_update(hits, fn(v) v + 1)          # atomic
cell_set(hits, cell_get(hits) + 1)      # races - two workers can read the same v
```

The second form is two operations with a gap between them. `cell_update` holds
the lock across the read and the write, which is the only way a counter is
correct under concurrency.

## Cells share on assignment

```ecko
a = cell(0)
b = a  # b and a are the same cell
cell_set(b, 5)
cell_get(a)  # 5
```

Everything else in Ecko has value semantics - binding a list to a new name gives
you an independent list. A cell shares, and that is exactly why it survives being
captured into a spawned task.

## The one trap

**Do not touch the same cell inside its own `cell_update`.** The lock is not
reentrant, so it deadlocks:

```ecko fragment
cell_update(c, fn(v) cell_get(c) + 1)   # deadlock
cell_update(c, fn(v) v + 1)             # v is already the current value
```

The value you need is the argument. Reaching for the cell again inside the update
is always avoidable.

## Cells and structure

A cell can hold any value, including a map or a list, so a small amount of shared
application state fits in one:

```ecko
state = cell({ users: [], connections: 0 })
cell_update(state, fn(s) insert(s, "connections", s.connections + 1))
```

For anything that must outlive the process, use [`std.sql`](../stdlib/sql.md) or
the filesystem. A cell is process memory.
