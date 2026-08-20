# `std.debug`

```ecko fragment
import std.debug

debug.inspect(value)        # a readable rendering of any value
debug.type(value)           # the type name
debug.timer("load")         # start a named timer
debug.elapsed("load")       # milliseconds since it started
```

## `inspect`

Renders any value readably, including nested maps and lists. Two things it does
that `print` does not: it shows structure clearly for deep values, and it is
**secret-safe** - a [`secret`](../language/secrets.md) renders as `[secret]`, so
inspecting a config map cannot dump a credential into your terminal or a log.

That safety is why `inspect` is the right default for debugging a value whose
contents you are unsure about.

## `type`

The type name as a string. The global `type_of` does the same thing and is always
in scope.

## Timers

```ecko fragment
debug.timer("query")
rows = sql.query(db, "select * from big")
print("took {debug.elapsed('query')}ms")
```

Named, so several can overlap. Backed by a monotonic clock, so a system clock
adjustment cannot produce a negative duration.

## This is for debugging

Timers here are for a quick "where is the time going" answer. For measurement you
intend to act on - comparing implementations, tracking a regression - use the
[`perf` package](../packages/perf.md), which does best-of-N runs and reports
statistics rather than a single sample.

A single timing is noise. That is not a limitation of this module, it is a property
of measuring anything once.

## Leaving it in

`debug` output goes to stdout, so it becomes part of your program's output.
Deterministic output matters for testable programs - see
[`ecko test`](../cli/test.md) - so remove timers before asserting on output, or use
[`std.log`](./log.md), which writes to stderr and is level-filtered.
