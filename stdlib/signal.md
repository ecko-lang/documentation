# `std.signal`

OS signal handlers: catch `SIGTERM` and `SIGINT` so a process can finish what it
started instead of dying wherever it happened to be.

```ecko fragment
import std.signal

shutdown = signal.on()               # the default set: ["term", "int"]

loop {
    caught = signal.next(shutdown, 0)    # 0 polls and returns immediately
    unless is_null(caught) {
        print("caught {caught} - draining")
        break
    }
    process_one_item()
}

flush_leases()
signal.close(shutdown)
```

The case this exists for is a rolling deploy. The orchestrator sends `SIGTERM`
and then waits. A process that cannot see it dies mid-write, still holding a
queue lease, with the run's cost unrecorded. Catching it turns that into an
orderly exit.

## Capability

Installing a handler needs **`exec`**. A signal disposition is process-global,
so a package that can install one can swallow the operator's Ctrl-C, or stop an
orchestrator's `SIGTERM` from ever being seen. That is process control, the same
authority `os.exit` needs. See
[capabilities](../packages/capabilities.md).

## Names

Lowercase, without the `SIG` prefix. `signal.names()` returns what this platform
can actually deliver.

| name | signal | typical meaning |
|---|---|---|
| `term` | SIGTERM | an orchestrator is rolling you; drain and exit |
| `int` | SIGINT | an operator pressed Ctrl-C |
| `hup` | SIGHUP | conventionally "reload your config" |
| `quit` | SIGQUIT | quit, traditionally with a core dump |
| `usr1`, `usr2` | SIGUSR1/2 | whatever your service defines |

`SIGKILL` is not in the list because nothing can catch it. Offering it would be
a lie.

**Windows has no POSIX signals.** The console control handler provides Ctrl-C,
which is what `int` means there. The others are refused by name rather than
accepted and never fired, so a handler that will never run fails at the point
you write it rather than in production.

## API

| call | result |
|---|---|
| `signal.names()` | The signal names this platform can deliver. |
| `signal.on(names?)` | Subscribe. Defaults to `["term", "int"]`, the two that actually arrive. Returns a handle. |
| `signal.next(handle, timeout_ms?)` | The signal name, or `null` once the deadline passes. `0` polls. |
| `signal.close(handle)` | Stop delivering to this subscription. |
| `signal.raise(name)` | Send a signal to this process. |

## Notes

**`next` takes a deadline, and a timeout is `null` rather than an error.** A
drain loop checks between units of work with an ordinary `if` - no callbacks, no
separate control flow, and no way for a quiet process to hang with no way out.

**Handlers compose.** Several subscriptions to the same signal all fire, and
`std.http`'s graceful shutdown subscribes through the same registry rather than
installing its own. A disposition is process-global, so without a single owner
whichever installed last would silently win and the other would stop firing.

**`signal.close` leaves the process handler installed.** Removing it would
restore the default disposition, so a later Ctrl-C would kill the process
outright rather than reaching another live subscription.

**`signal.raise(name)`** is how to exercise a handler without a second terminal
and a `kill`.

## With a server

`http.serve` already drains on Ctrl-C. Subscribe to `term` when the thing
stopping you is an orchestrator rather than a person:

```ecko fragment
import std.http
import std.signal

rolling = signal.on(["term"])

async fn drain() {
    signal.next(rolling, null)       # null = wait as long as it takes
    http.stop()
}

drain()
http.serve(8080, handler)
flush_leases()
```
