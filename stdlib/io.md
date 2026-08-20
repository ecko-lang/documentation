# `std.io`

Standard output, and standard input.

```ecko fragment
import std.io

io.print("hello")        # identical to the global print("hello")

line = io.read_line()    # the next line, without its terminator; null at EOF
text = io.read_all()     # everything on stdin, as one string
```

`io.print(value)` behaves exactly like the global `print`.

## Reading standard input

This is what lets an Ecko program be a pipeline stage:

```ecko fragment
import std.io

mut n = 0
loop {
    line = io.read_line()
    if is_null(line) { break }
    n = n + 1
    print("{n}: {line}")
}
```

```bash
cat access.log | ecko number.ecko
```

**End of input is `null`, not `""`.** An empty line is a real line and comes
back as `""`, so the null is what a loop terminates on. If EOF were an empty
string the loop above would spin forever on an exhausted pipe.

A trailing `\r` is stripped along with the `\n`, so a file written on Windows
compares equal to what you expect rather than failing every match by one
invisible character. A final line with no terminator is still returned.

There is no `io.lines()`. The loop above is it, and a function whose only job is
to wrap another one does not earn a place in the standard library.

## Capability

Reading standard input needs **no grant**. A pipeline stage is handed its input
by whoever started it, exactly the way it is handed its arguments - there is no
authority here to withhold, which is why [`std.cli`](./cli.md) is ungated too.

Reading a *file* is [`std.fs`](./fs.md) and does need `fs:read`.

## Why it exists

For the case where something in scope shadows `print` - a module you imported, or
a definition of your own - and for code that prefers an explicit `io.` prefix.

That is the whole module. Nothing else lives here:

| you want | use |
|---|---|
| Reading and writing files | [`std.fs`](./fs.md) |
| Formatting a string | [`std.fmt`](./fmt.md) |
| Leveled application output | [`std.log`](./log.md) |
| Printing without a newline | the global `print_no_newline` |
| Terminal colour and cursor control | [`std.term`](./term.md) |
