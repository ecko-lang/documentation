# Running a program

```bash
ecko program.ecko          # the usual form
ecko run program.ecko      # explicit, identical behaviour
```

The bare form exists because running a file is the common case and should not
need a subcommand. `run` is there for scripts and wrappers where an explicit verb
reads better.

## What happens before your code

`ecko` runs [`ecko check`](./check.md) over the program first and **refuses to
start** if there is an error-level finding: an undefined name, a call with the
wrong number of arguments, a `match` that is not exhaustive, a credential used
without `reveal`. Warnings are printed and do not stop the run.

This is deliberate. A dynamically typed language normally discovers a typo on
line 400 after doing 399 lines of work, some of it irreversible. Ecko finds it
before the first line executes.

## Arguments

Everything after the file is passed to the program, not to `ecko`:

```bash
ecko report.ecko --format json data.csv
```

Read them with `std.os`, or parse them declaratively with
[`std.cli`](../stdlib/cli.md):

```ecko
import std.os
print(os.args())        # ["--format", "json", "data.csv"]
```

## Exit status

`0` on success. Non-zero when the program raises an uncaught error, when
`check` finds an error-level problem, or when the file cannot be read. An
uncaught error prints the message with a source span and a call stack.

## Reloading on change

For a server or a script you are iterating on, [`ecko dev`](./dev.md) re-runs the
file whenever it changes.

## A note on `ai`

No configuration is required. Without a provider, `ai` runs in
[mock mode](../start/mock-mode.md), so any program in this documentation runs as
written. Add `--key`, `--provider` or `--model` (see [Global flags](./flags.md))
to use a real provider for one run without exporting anything.
