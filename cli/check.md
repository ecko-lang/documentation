# `ecko check`

```bash
ecko check file.ecko
ecko check src/
```

Static analysis. It is also run automatically before every
[`ecko file.ecko`](./run.md), where an error-level finding stops the program
before its first line.

## What it finds

**Errors** (these stop a run):

- **Undefined names**, with a did-you-mean suggestion for near misses.
- **Wrong arity** - calling a function with too few or too many arguments,
  including the built-ins.
- **Use before definition** at the top level.
- **Non-exhaustive `match`** - a variant with no arm and no `_`.
- **Unknown struct or variant members**.
- **Unwrapped credentials** - a `secret` value used where the plain value is
  required, without `reveal`.

**Warnings** (reported, do not stop a run):

- Unused bindings, scope-aware, so a name used only inside a nested closure is
  not flagged.
- Unused imports.
- Shadowing a built-in, which is legal and occasionally deliberate - the
  `core.*` escape hatch exists for exactly that case.
- Deprecated syntax, with the migration ([`ecko fmt`](./fmt.md)) named.

## Why a dynamic language gates on this

Ecko has no static type system, and adding one is not the plan. But the errors
above are not type errors - they are *definitely wrong regardless of types*. A
misspelled function name is never correct. A `match` missing a variant is never
correct. Finding those before execution costs nothing and removes the most common
way a script fails halfway through doing something it cannot undo.

The same analysis backs [`ecko lsp`](./lsp.md), so an editor shows these findings
as you type.

## Exit status

`0` when there is nothing at error level. Non-zero otherwise. Warnings alone do
not change the exit status, so `ecko check` is usable as a CI gate without
forcing warning-free code.

Warnings are still printed, and a run that ends with warnings and no errors says
so, so a `0` beside printed findings does not read as something being missed.

```bash
ecko check src/*.ecko            # errors fail, warnings inform
ecko check --strict src/*.ecko   # any finding fails
```

`--strict` is for a project that controls all of its own source and wants a
clean board. Leave it off where a warning is a considered choice: a package that
exports `get`, `set` or `push` trips `shadows-builtin` by design, and there is
no way to silence a single finding.
