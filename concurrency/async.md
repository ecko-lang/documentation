# Async tasks

**Calling an `async fn` spawns a task and returns a handle immediately.** `await`
blocks until it finishes and yields the result.

```ecko fragment
async fn summarize(doc) {
    ai "Summarize in one line: {doc}"
}

tasks = map(docs, fn(d) summarize(d))    # all in flight at once
out = map(tasks, fn(t) await t)          # then join
```

There is no event loop and no colouring of the call site: an async function is
called like any other function. What differs is that it returns a task rather
than a value.

## Anonymous form

```ecko fragment
t = (async fn(x) heavy(x))(5)
```

`async |x| ...` is the deprecated spelling; `ecko check` warns and
[`ecko fmt`](../cli/fmt.md) rewrites it. Semantics are identical.

## The rules

**Spawn on call, join on `await`.** `await` on a non-task returns it unchanged,
so `await 7` is `7`. That makes it safe to await something that may or may not be
a task.

**Errors surface at `await`.** An error raised inside a task - including a
structured `error({ kind, message })` - arrives intact where it is awaited:

```ecko fragment
try { result = await t } catch (e) { print(e.message) }
```

An error in a task you never await is never seen. Await your tasks.

**Share-nothing, same as [`pmap`](./pmap.md).** Each call snapshots its arguments
and captured variables. Mutating a captured `mut` changes only that task's copy;
use a [`cell`](./cell.md) to share.

**Bounded.** At most `ECKO_MAX_TASKS` tasks *run* at once (default 256); the rest
queue. A task parked on `await` releases its slot and reclaims one when it
resumes, so nested awaits cannot deadlock the pool.

## Cancellation

```ecko fragment
t = slow_thing()
cancel(t)
```

Cooperative. The task unwinds at its next loop or call checkpoint, and
runtime-managed waits - `await`, channel receive, `select`, stream waits - are
interrupted promptly. A task blocked in an external syscall, such as a slow HTTP
read, stops only when that call returns; nothing in the runtime can safely
interrupt a syscall mid-flight.

Cancelling a parent parked on `await` propagates to the child. Awaiting a
cancelled task raises `{ kind: "cancelled" }`.

## Where async callbacks are refused

Higher-order built-ins that need each result immediately - predicates, key
functions, folds, `retry`, `cell_update` - reject an async callback rather than
silently comparing task handles:

```ecko fragment
filter(xs, async fn(x) check(x))         # error
tasks = map(xs, async fn(x) check(x))    # map to tasks...
keep  = filter(zip(xs, map(tasks, fn(t) await t)), fn(p) p[1])
```

`map` and `pmap` do accept them, which is how you get a list of tasks.

## Choosing

`pmap` for one operation over a list. `async`/`await` for independent operations
of different kinds, or to start work now and need it later.
[Channels](./channels.md) when stages need to hand values to each other.
