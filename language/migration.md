# Migrating off deprecated syntax

Deprecated syntax keeps working. It always leaves in three stages: deprecated,
migrated, removed - never straight to removed.

```bash
ecko fix --migrate --check src/    # report what needs it, write nothing
ecko fix --migrate src/            # rewrite in place
```

## The three stages

1. **Deprecated.** The old form still parses and runs. [`ecko check`](../cli/check.md)
   warns on it, and [`ecko fmt`](../cli/fmt.md) rewrites it to the current form as
   part of an ordinary format pass.
2. **Migrate.** Run `ecko fix --migrate` (or just `ecko fmt`) before the version
   that removes the old form ships. Both do the same rewrite; `--migrate` touches
   only the deprecated constructs, so the diff is the migration and nothing else -
   useful on a project that is not kept formatted with `fmt`.
3. **Removed.** A later version deletes parser support for the old form.
   Unmigrated code stops parsing at that point, not before - there is no silent
   behaviour change in between.

## Today's deprecations

| deprecated | current form | identical behaviour |
|---|---|---|
| `const x = 1` | `let x = 1` | yes - `const` is only ever a spelling of `let` |
| `\|x\| x * 2` | `fn(x) x * 2` | yes |

### `const` to `let`

```ecko fragment
const limit = 100   # deprecated: identical to `let`
print(limit)
```

`const` was an early alias for `let`. There is no behavioural difference to
reason about - the migration is a rename:

```ecko
let limit = 100
print(limit)
```

### Pipe lambdas to `fn(params) body`

```ecko fragment
double = |x| x * 2   # deprecated pipe-lambda form
print(double(21))
```

`fn(params) body` is the canonical anonymous form and is what `ecko fmt`
produces from the pipe form:

```ecko
double = fn(x) x * 2
print(double(21))
```

See [Functions & lambdas](./functions.md) for the full lambda syntax.

## One-time codemods are different from `--migrate`

Two rewrites belong to specific past breaking releases and are **not** run by
plain `--migrate`, because they are reinterpretations rather than
canonicalisations - running one twice on already-migrated code would corrupt it
(see [`ecko fix`](../cli/explain-lint-fix.md#one-time-codemods) for why):

```bash
ecko fix --migrate --only=bytes src/     # *_decode -> *_decode_text, net.recv -> recv_text
ecko fix --migrate --only=exports src/   # the old `export { ... }` block to inline `export`
```

Run each once, on code you know has not already been through it.

## Checking without changing anything

`ecko fix --migrate --check src/` reports which files need a rewrite and exits
non-zero if any do, without touching a byte - the shape you want in CI, ahead of
the version that removes the old form:

```bash
ecko fix --migrate --check src/
```

See [`ecko check`](../cli/check.md) for the warnings that surface deprecated
syntax during ordinary development, and [`ecko fmt`](../cli/fmt.md) for the
formatter that rewrites it as a side effect of formatting.
