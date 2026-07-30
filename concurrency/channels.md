# Channels

A channel carries values between tasks. Where [`await`](./async.md) is fork-join,
a channel is a pipeline.

```ecko
jobs = channel()

async fn produce() {
    for n in [1, 2, 3] { send(jobs, n) }
    close(jobs)                       # "no more values"
}
produce()

for job in jobs { handle(job) }       # drains until closed
```

## The operations

| call | behaviour |
|---|---|
| `channel()` | Unbounded, multi-producer, multi-consumer |
| `channel(n)` | Bounded to `n` buffered values (`n >= 1`) |
| `send(ch, v)` | Enqueue. Never blocks unbounded; blocks when a bounded buffer is full. Errors on a closed channel |
| `recv(ch)` | Next value, blocking. `null` once closed and drained |
| `try_recv(ch)` | Next value or `null` immediately, without blocking |
| `close(ch)` | Mark done; wakes blocked senders and receivers |
| `select([a, b])` | First available value across channels; `null` when all are closed and drained |

## Backpressure

`channel(n)` is the reason to prefer a bounded channel: `send` blocks while the
buffer is full, so a fast producer is throttled by a slow consumer instead of
growing a queue until memory runs out.

```ecko
work = channel(10)      # at most 10 items in flight
```

An unbounded channel is a memory leak waiting for a load spike. Reach for the
bounded form unless you know the total is small.

The blocked send is cancellation-aware: it wakes as receivers drain, and errors
if the channel closes while it waits.

## Iterating

`for v in ch` is the idiomatic consumer. It ends when the channel is closed, and
unlike `recv` it distinguishes a `null` you sent as data from the end-of-channel
sentinel - a sent `null` is yielded.

If a producer forgets to `close`, a `for` loop over its channel waits forever.
Close in the producer, and close it once.

## `select` for fan-in

```ecko
v = select([results, errors])
```

Blocks until one channel has a value; the earlier channel wins when several are
ready, and only the winner is consumed. It does not tell you which channel
produced the value, so tag values before sending if you need to know:

```ecko
send(results, { from: "worker-1", value: v })
```

## `try_recv` for polling

Use it when there is other work to do between attempts. A `null` means "nothing
right now" and also "closed and drained" - the same convention as `recv`, so
check `try_recv` in a loop that has its own termination condition rather than
treating `null` as an end marker.

## A worked pipeline

```ecko
raw = channel(100)
done = channel(100)

async fn reader() {
    for line in lines(fs.read("input.txt")) { send(raw, line) }
    close(raw)
}

async fn worker() {
    for line in raw { send(done, transform(line)) }
}

reader()
workers = map(range(0, 4), fn(_) worker())
map(workers, fn(w) await w)
close(done)

for r in done { print(r) }
```

Four workers share one input channel, and the bounded channels keep the reader
from running ahead of them.
