# A file is a program

There is no project to create. A `.ecko` file is a complete, runnable program.

```ecko
# hello.ecko
print("Hello, AI World!")
```

```bash
ecko hello.ecko
```

No `package.json`, no `Cargo.toml`, no `requirements.txt`, no build step, no
`main` function to declare, no module to register. The file is the unit.

## Why this matters

Most scripting languages start you with ceremony, and the ceremony is where
ideas die. Ecko's wager is that the distance between "I wonder if" and "it ran"
should be one file and one command - especially when the thing you are trying is
an AI call, where the interesting part is the prompt, not the plumbing.

The same property holds all the way up. A single file can serve HTTP, query
SQLite, call three model providers and run a test suite, because the standard
library is already in the binary.

## When you do want a project

You never need one, but two things are worth having as a program grows.

**A manifest.** `ecko init` writes an `ecko.json`. It gives the program a name
and version, and its fields are readable as [`std.defaults`](../stdlib/defaults.md)
without any parsing:

```bash
ecko init
```

**Dependencies.** [`ecko get`](../packages/commands.md) vendors a package into
`vendor/` and records a hash. Both of these are additive: the file still runs the
same way with `ecko file.ecko`.

## Multiple files

Import a sibling by path. The binding name comes from the file stem:

```ecko
import "./helpers.ecko"       # binds `helpers`
import "./helpers.ecko" as h  # or choose the name

helpers.clean(text)
```

Only definitions marked `export` are visible to the importer - see
[Modules & imports](../language/modules.md). A directory of files with an
`ecko.json` is a [package](../packages/concepts.md), which is the same mechanism
pointed at someone else's code.

## What runs before your first line

`ecko file.ecko` type-checks nothing (Ecko is dynamically typed) but does run
[`ecko check`](../cli/check.md) over your program first, and refuses to start on
an error-level finding - an undefined name, a wrong arity, a non-exhaustive
match. That turns a class of crash-on-line-400 into a message before anything
executes.
