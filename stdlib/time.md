# `std.time`

```ecko fragment
import std.time

time.now()            # Unix milliseconds
time.now_iso()        # "2026-07-30T09:12:44Z"
time.monotonic()      # for measuring elapsed time
time.format(ms, "%Y-%m-%d")
time.parse("2026-07-30T09:12:44Z")
time.parse_format("30/07/2026", "%d/%m/%Y")
```

## Two clocks, and they are not interchangeable

**`now()` is the wall clock** - Unix milliseconds. Use it for timestamps: when
something happened, what to store, what to show a person. It can jump backwards
when the system clock is corrected or adjusted by NTP.

**`monotonic()` never goes backwards.** Use it for durations:

```ecko fragment
start = time.monotonic()
do_work()
elapsed = time.monotonic() - start
```

Measuring with `now()` can produce a negative duration, which is a bug that
appears rarely and confusingly. Measure with `monotonic`, timestamp with `now`.

## Formatting and parsing

`format(ms, pattern)` and `parse_format(text, pattern)` use `strftime`-style
patterns. `parse` reads ISO 8601, and `now_iso()` produces it.

Prefer ISO 8601 for anything stored or transmitted: it sorts lexicographically,
carries its timezone, and is unambiguous - unlike `30/07/2026`, which means two
different dates depending on the reader.

## Determinism

Wall-clock values in program output make it untestable. Where output is asserted -
tests, examples, anything compared - either avoid a timestamp or inject it, so the
comparison does not depend on when it ran.

`std.log` deliberately adds no automatic timestamp for the same reason. Add
`time.now()` as a field when you want one.

## Calendars

This module is timestamps, formatting and monotonic timing. For calendar
arithmetic - adding months, weekday names, date components, durations - use the
[`datetime` package](../packages/datetime.md).
