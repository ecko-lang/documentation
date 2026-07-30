# `std.fmt`

```ecko
import std.fmt

fmt.format(r"{} of {}", 3, 10)     # "3 of 10"
fmt.pad_left("7", 4)                # "   7"
fmt.pad_right("ab", 5)              # "ab   "
fmt.truncate(long, 40)
fmt.repeat("-", 20)
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

## Padding and truncating

For aligned terminal output, `pad_left`, `pad_right` and `truncate` are the
essentials. [`std.string`](./string.md) has the fuller set - `pad_start`,
`pad_end`, `center`, `zfill` - and those are character-aware, which matters for
non-ASCII text.

For terminal tables where display width differs from character count, the `tui`
package handles width properly.
