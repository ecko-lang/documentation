# `std.bg`

Fire-and-forget background work, with a handle to check on it. See
[Background tasks](../concurrency/background.md) for the full guide - this page
is the function reference.

```ecko fragment
import std.bg

t = bg.spawn(fn() expensive())
bg.status(t)          # "running" | "completed" | "failed"
bg.result(t)          # block for the value; raises if it failed
bg.cancel(t)
```

## Functions

| call | effect |
|---|---|
| `bg.spawn(f)` | Start `f()` in the background |
| `bg.spawn(f, args)` | Start `f` with a list of arguments |
| `bg.status(t)` | `"running"`, `"completed"` or `"failed"` |
| `bg.result(t)` | Block for the value |
| `bg.cancel(t)` | Cooperative cancellation |
| `bg.after(ms, f)` | Run `f` once after a delay |
| `bg.every(ms, f)` | Run `f` on an interval until cancelled |
| `bg.join_all(ts)` | Block for all, returning a list of values |

Built on the same machinery as [`async fn`](../concurrency/async.md) - the
handle is the same task value that `await` accepts.
