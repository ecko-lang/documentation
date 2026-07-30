# `std.log`

Leveled logging with pluggable sinks.

```ecko
import std.log

log.info("started", { port: 8080 })
log.warn("retrying", { attempt: 2 })
log.error("failed", { err: e.message })
log.debug("cache hit", { key: k })
```

Output goes to **stderr** by default, so it does not mix into your program's
stdout - which is what keeps a program's actual output pipeable and testable.

## Levels

`debug` < `info` < `warn` < `error`. `ECKO_LOG` sets the filter, default `info`:

```bash
ECKO_LOG=debug ecko app.ecko
```

## Structured fields

The second argument is a map, and **fields print in sorted order** - so log lines
are stable and greppable:

```
[INFO] started port=8080
```

Fields beat interpolation for anything you will later search or aggregate: `port=8080`
is findable in a way that "started on port 8080" is not.

## Sinks

```ecko
log.to_file("app.log", { level: "warn", json: true, max_bytes: 1000000, keep: 5 })
log.to_stderr({ json: true })

log.configure({ sinks: [
    { target: "stderr", level: "info" },
    { target: "file", path: "app.log", json: true },
]})

log.reset()      # back to the single default stderr sink
```

Each sink has its own `level`, its own format (`json` gives one JSON object per
line instead of `[LEVEL] msg k=v`), and size-based rotation via `max_bytes` and
`keep` - rolling `app.log` to `app.log.1` and so on.

A common shape: human-readable at `info` on stderr, JSON at `warn` to a file for
whatever collects it. File sinks need `fs:write` for
[package](../packages/capabilities.md) code.

## No automatic timestamp

Deliberate, so log output is deterministic and a test can assert on it. Add one
when you want it:

```ecko
log.info("started", { at: time.now_iso() })
```

In production, whatever collects your logs almost certainly stamps them on
arrival anyway.

## Secrets are redacted

A [`secret`](../language/secrets.md) renders as `[secret]` through log sinks like
everywhere else, so a credential in a field map cannot land in a log file. A
`reveal`ed value will.
