# The REPL

```bash
ecko            # or: ecko repl
```

An interactive session. Bindings persist across lines, so you can build up
state:

```
ecko v0.9.5 // REPL on Linux // ecko.sh
> xs = [3, 1, 2]
> sort(xs)
[1, 2, 3]
> fn double(n) = n * 2
> map(xs, double)
[6, 2, 4]
```

The value of each expression is printed. Statements that produce nothing print
nothing.

## Multi-line input

A line that cannot yet be a complete program continues:

```
> fn classify(n) {
    if n > 0 { "positive" } else { "not positive" }
  }
> classify(5)
"positive"
```

## Imports and `ai`

Everything the language has is available, including the standard library and the
`ai` keyword:

```
> import std.time
> time.now_iso()
"2026-07-30T09:12:44Z"
> ai[Int] "How many continents?"
42
```

`42` is the [mock mode](./mock-mode.md) answer for `ai[Int]` - schema-valid and
deterministic, because no provider is configured. Set `ECKO_API_KEY` before
starting the REPL for real responses.

## Session state

REPL globals live for the session. Redefining a name shadows the old value, and
`mut` is not needed for a rebind at the top level.

State does not survive restarting. When you want something durable, put it in a
file and run it - or use `ecko dev`, which re-runs a file every time you save
it.

## Leaving

`Ctrl-D` exits. `Ctrl-C` cancels the line you are typing without exiting.
