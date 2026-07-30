# Resource limits

Adversarial or accidental input should degrade into a **catchable error**, not
exhaust the machine. Three bounds do that.

| variable | bounds | default |
|---|---|---|
| `ECKO_MAX_DEPTH` | call and recursion depth | 2000 |
| `ECKO_MAX_PARSE_DEPTH` | nesting the parser accepts | 128 |
| `ECKO_MAX_STEPS` | loop and step budget | unlimited (opt in) |

## Recursion

```
maximum call depth exceeded - a function may be calling itself
without a base case (raise ECKO_MAX_DEPTH if this is intended)
```

The message names the likely cause, because the likely cause is a missing base
case. Genuinely deep recursion is legitimate, and raising the limit is the right
answer there - but a runaway recursion is far more common, and a stack overflow
that kills the process gives you nothing to debug.

## Parse depth

`ECKO_MAX_PARSE_DEPTH` (default 128) bounds nesting **at parse time**, which
matters for input you did not write. Deeply nested JSON is a standard way to make
a recursive-descent parser blow the stack; here it is a catchable error before
evaluation starts.

128 is far beyond anything hand-written. If you hit it on your own source, the
code is telling you something.

## Step budget

`ECKO_MAX_STEPS` is **opt-in** and unlimited by default, because a step cap on
ordinary work would be a surprise. Set it where a program processes untrusted
input or runs unattended:

```bash
ECKO_MAX_STEPS=100000000 ecko handler.ecko
```

An infinite loop then becomes an error you can catch, log and recover from,
instead of a process that has to be killed.

## Concurrency and IO bounds

Not resource limits in the same sense, but the same instinct - see
[Environment variables](../config/environment.md):

- `ECKO_MAX_TASKS` (256) - running async tasks
- `ECKO_MAX_PARALLEL` (all cores) - `pmap` and tool-round workers
- `ECKO_HTTP_MAX_BODY` (10 MiB), `ECKO_MAX_WS_CONNS` (1024)
- `ECKO_PKG_MAX_BYTES` (50 MiB), `ECKO_PKG_MAX_UNPACKED` (200 MiB)

## The AI budget

`ECKO_AI_MAX_CALLS` is the same idea applied to spending, and the one to set in
production - see [Token budgeting](../ai/budgeting.md). Exhausting it raises
`{ kind: "budget", calls, max }`, which is catchable like any other operational
failure.

## Catching a limit

```ecko
try {
    risky_parse(untrusted)
} catch (e) {
    match get(e, "kind") {
        "budget" => degrade()
        _ => error(e)
    }
}
```

The point of a limit that raises rather than aborts is that a server can survive
one bad request. See [Error handling](./error-handling.md).
