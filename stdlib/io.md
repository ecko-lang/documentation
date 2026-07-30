# `std.io`

One function.

```ecko
import std.io

io.print("hello")        # identical to the global print("hello")
```

`io.print(value)` behaves exactly like the global `print`.

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
