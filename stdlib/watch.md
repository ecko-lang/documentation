# `std.watch`

Filesystem events: `inotify` on Linux, FSEvents on macOS,
`ReadDirectoryChangesW` on Windows - one surface over all three.

```ecko fragment
import std.watch

w = watch.open("./inbox", { recursive: true })

loop {
    e = watch.next(w, 5000)          # { kind, path }, or null on timeout
    if is_null(e) { continue }
    if e.kind == "create" {
        print("ingesting {e.path}")
    }
}
watch.close(w)
```

## Capability

Watching needs **`fs:read`**. Seeing what appears in a directory is reading it,
so a package granted nothing cannot sidestep `fs:read` by watching instead of
listing. See [capabilities](../packages/capabilities.md).

## The handle

`watch.open(path, opts?)` returns a map:

| field | what it is |
|---|---|
| `events` | a [channel](../concurrency/channels.md) of events |
| `path` | the directory being watched |
| `recursive` | whether subdirectories are included |
| `id` | the watch's identity, used by `close` |

`opts` takes `{ recursive: true }`; the default is non-recursive.

## Events

Each event is `{ kind, path }`. `kind` is one of `"create"`, `"modify"` or
`"remove"` - `watch.kinds()` returns that list.

Platform-specific *access* events are dropped. They fire whenever anything reads
a file, which would drown the signal you actually asked for.

## Reading events

`watch.next(w, timeout_ms)` returns the next event, or `null` once the deadline
passes. `0` polls and returns immediately.

The deadline is not optional by accident: a watch on a quiet directory must not
be able to hang the program with no way out.

Because `w.events` is a real channel, a watch composes with everything else that
speaks channels - drain it from a spawned task, or feed it straight into an
[SSE response](../concurrency/streaming.md):

```ecko fragment
async fn ingest(w, out) {
    loop {
        e = watch.next(w, 1000)
        unless is_null(e) { send(out, "data: {e.path}\n\n") }
    }
}
```

## Closing

`watch.close(w)` stops the OS watch and closes the channel, so a reader parked on
`recv` sees the end rather than waiting forever. Closing twice is harmless, which
matters because a `finally` block will do exactly that.

## Notes

**Events are queued without bound.** Blocking the notifier thread would drop
events for every other watch in the process, so a burst is buffered rather than
back-pressured. A consumer that never drains a busy directory will grow memory.

**One logical change can produce several events.** Writing a file often shows up
as a create followed by one or more modifies, and editors that write atomically
produce a rename. Match on what you care about rather than expecting one event
per action.
