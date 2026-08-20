# `pmap`

Map over a list in parallel, on a bounded worker pool.

```ecko fragment
summaries = pmap(docs, fn(d) ai "Summarize in one line: {d}")
```

Same shape as `map`, same result order. The difference is that the calls overlap,
which for I/O-bound work - model calls, HTTP, SQL - is the whole cost of the
program.

## Share-nothing by construction

Each worker gets a **snapshot** of the arguments and captured variables it needs.
Mutating an ordinary `mut` from inside a parallel closure changes only that
worker's copy:

```ecko fragment
mut count = 0
pmap(items, fn(i) { count = count + 1 })   # count is still 0
print(count)                                # 0
```

This is not a bug to work around, it is the design. Parallel work cannot corrupt
shared state because there is no shared state unless you ask for it. When workers
genuinely need to share, use a [`cell`](./cell.md) - explicit, atomic, and the one
place locking is intentional.

The practical effect is that data races are not a category of bug you debug in
Ecko. The default is isolation, and sharing is a visible construct in the source.

## The pool

Bounded by `ECKO_MAX_PARALLEL`, defaulting to the number of cores. A list of
10,000 items does not create 10,000 threads; it queues onto the pool.

The same pool backs parallel `ai` calls and tool rounds, so one setting bounds
the machine's total concurrency for CPU-adjacent work.

## Errors

An error in one worker surfaces from the `pmap` call. Wrap the body when you want
partial results instead of an abort:

```ecko fragment
results = pmap(urls, fn(u) try { fetch(u) } catch (e) { null })
ok = filter(results, fn(r) r != null)
```

## `pmap` or `async`?

| use | when |
|---|---|
| [`pmap`](./pmap.md) | A list, one operation per item, all results needed. Fork-join. |
| [`async` / `await`](./async.md) | Independent operations of different kinds, or overlapping work with other work. |
| [Channels](./channels.md) | Producers and consumers, backpressure, streaming between stages. |
| [`std.bg`](./background.md) | Fire-and-forget, timers, intervals. |

`pmap` is the right default for the common case: you have a list and each item
needs the same expensive thing done to it.
