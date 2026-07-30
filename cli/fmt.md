# `ecko fmt`

```bash
ecko fmt file.ecko            # format in place
ecko fmt src/ tests/          # several paths
ecko fmt --check file.ecko    # exit non-zero if it would change
```

One canonical style, zero configuration. There are no options to argue about
because there are no options.

## Why it is not configurable

Formatting arguments are pure cost. More than that, Ecko treats the canonical
form as part of the language contract: **any new syntax must round-trip through
the formatter byte-identically**, and the compiler's own test suite formats every
example twice and asserts the output is unchanged. A style knob would multiply
that guarantee by the number of settings.

There is a second reason, particular to this language. Ecko is written to be read
by models as well as people. One canonical form means a model sees the same shape
for the same construct every time, in every codebase.

## `--check`

Formats nothing, exits non-zero if any file is not already canonical, and names
the files. This is the CI form:

```bash
ecko fmt --check *.ecko
```

## What it does not change

Comments keep their text, and `##` [doc comments](../language/comments.md) keep
their marker. Blank lines between top-level definitions are preserved as
paragraph structure - the formatter normalizes indentation, spacing, wrapping and
delimiters, not your intent about what belongs together.

## Deprecated syntax

The formatter migrates syntax that has been superseded. The old zero-argument
lambda `|| expr` becomes `fn() expr`, and `ecko check` reports the old form as a
`deprecated-syntax` warning pointing here. Running `ecko fmt` is the fix.
