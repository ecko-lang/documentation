# Background tasks (`std.bg`)

Fire-and-forget work, with a handle to check on it.

```ecko fragment
import std.bg

t = bg.spawn(fn() expensive())
bg.status(t)          # "running" | "completed" | "failed"
bg.result(t)          # block for the value; raises if it failed
bg.cancel(t)
```

Built on the same machinery as [`async fn`](./async.md) - the handle is the same
task value that `await` accepts.

## The surface

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

## Timers

```ecko fragment
bg.after(1000, fn() cleanup())
beat = bg.every(30000, fn() heartbeat())
# ...later
bg.cancel(beat)
```

Both sleep cancellably, so `bg.cancel` wakes them promptly rather than after the
remaining delay. `every` stops on cancel, and also stops if an iteration errors -
that error becomes the task's result, so a broken heartbeat does not silently
keep firing.

## Bounds and failure

Bounded by the same `ECKO_MAX_TASKS` running-slot semaphore as async tasks. A
task that panics surfaces as a failed result rather than leaking its slot.

One difference from `await`: `bg.result` and `bg.join_all` render a failed task's
error as a **message string** rather than re-raising the original error value. A
native function cannot re-raise a first-class error the way `await` does. When you
need the structured error - its `kind`, its fields - use an `async fn` and
`await` it inside `try`.

## `bg` or `async`?

`async fn` is the default: it is the language construct, and `await` gives you
real error propagation.

Reach for `bg` when you want the *lifecycle* - a handle you can poll with
`status`, cancel from elsewhere, or hand to another part of the program - or when
you want a timer. A background job whose result nobody awaits is exactly what
`bg.spawn` is for, and exactly what `async` handles badly, since an unawaited
task's error is never seen.
