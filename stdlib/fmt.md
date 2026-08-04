# `std.fmt`

```ecko
import std.fmt

fmt.format(r"{} of {}", 3, 10)     # "3 of 10"
fmt.pad_left("7", 4)                # "   7"
fmt.pad_right("ab", 5)              # "ab   "
fmt.truncate(long, 40)
fmt.repeat("-", 20)
fmt.fixed(3.14159, 2)               # "3.14"
```

## `format` needs a raw string

```ecko
fmt.format(r"{} of {}", 3, 10)     # correct
fmt.format("{} of {}", 3, 10)      # parse error
```

**A normal string triggers Ecko's own `{expr}` interpolation at parse time**, so
`{}` would be read as an empty expression. The `r"..."` prefix suppresses
interpolation and hands the placeholders to `format`.

This trips everyone once. If you get a parse error pointing at a `format` call,
that is why.

## When to use which

Most of the time you do not need `format` at all - interpolation is built into the
language and reads better:

```ecko
"{count} of {total}"                # idiomatic
fmt.format(r"{} of {}", count, total)
```

Reach for `format` when the **template is data**: read from a config file, chosen
from a table, or reused across call sites with different arguments.

## Fixed decimal places

`fmt.fixed(value, places)` renders a number to a set number of decimals, padding
with zeroes rather than trimming the text:

```ecko
fmt.fixed(1.5, 3)                   # "1.500"
fmt.fixed(2.5, 0)                   # "3"
fmt.fixed(decimal("0.07"), 2)       # "0.07"
```

Two details worth knowing. Halves go **away from zero**, so `2.5` at zero places
is `"3"` - not the half-to-even most languages' formatters use. And a
[`decimal`](../language/numbers.md) is rounded *in decimal*, never through a
float, so an exact `0.07` stays `0.07` instead of picking up a binary artefact.
That makes it the one to reach for when formatting money.

## Padding and truncating

For aligned terminal output, `pad_left`, `pad_right` and `truncate` are the
essentials. [`std.string`](./string.md) has the fuller set - `pad_start`,
`pad_end`, `center`, `zfill` - and those are character-aware, which matters for
non-ASCII text.

For terminal tables where display width differs from character count, the `tui`
package handles width properly.
