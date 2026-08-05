# `ecko explain`, `lint` and `fix`

Three tools that read a program and tell you something about it. `lint` is
mechanical; the other two use a model.

## `ecko lint`

```bash
ecko lint file.ecko
```

Reports code that is present but doing nothing:

- dead code after a `return`, `break` or `continue`
- unused imports
- unused variables
- unreachable branches

No model involved, no network. This overlaps [`ecko check`](./check.md) - the
split is that `check` answers "is this wrong?" and gates the run, while `lint`
answers "is this needed?" and never does.

## `ecko explain`

```bash
ecko explain file.ecko
```

Static analysis plus a model, producing prose: what the program does, how it is
structured, what stands out. Useful on code you did not write, or wrote long
enough ago that it counts.

It reads the program. It does not run it, so it cannot tell you what the program
actually did with real input.

## `ecko fix`

```bash
ecko fix file.ecko
```

Takes the errors in a file and suggests a repair. It prints the suggestion; it
does not edit your file.

`fix` also carries mechanical migrations, which do rewrite files and are worth
knowing about because they are exact rather than suggested.

### `ecko fix --migrate`

Rewrites deprecated syntax to the form that replaced it.

```bash
ecko fix --migrate --list          # what can be migrated, and what runs by default
ecko fix --migrate --check src/    # report, write nothing (exit 2 if any file needs it)
ecko fix --migrate src/            # rewrite in place
ecko fix --migrate --only=const src/
```

Today that means `const` to `let`, and `|x| ...` lambdas to `fn(x) ...`. Both
still parse and run; `ecko check` warns about them, and a future major version
removes them.

[`ecko fmt`](./fmt.md) canonicalises the same forms while it formats. Reach for
`--migrate` when the project is not formatted with `fmt`: it touches only the
deprecated constructs, so the diff is the migration rather than a whole-file
reflow.

### One-time codemods

```bash
ecko fix --migrate --only=bytes src/     # *_decode -> *_decode_text, net.recv -> recv_text
ecko fix --migrate --only=exports src/   # the old `export { ... }` block to inline `export`
```

(The older `--migrate-bytes` and `--migrate-exports` spellings still work.)

These belong to specific past breaking releases, and they are **not** run by
plain `--migrate`. A deprecation rewrite is a canonicalisation, so running it on
already-canonical code changes nothing. A codemod is a reinterpretation: it
cannot tell code that has already been migrated from code that never needed it.
Run the bytes codemod twice and it rewrites a correct `base64_decode` - which
wants bytes - into `base64_decode_text`, which does not.

## Which to reach for

| question | command |
|---|---|
| Is anything definitely wrong? | [`check`](./check.md) |
| Is anything unnecessary? | `lint` |
| What does this code do? | `explain` |
| How do I repair this error? | `fix` |
| Is it formatted? | [`fmt`](./fmt.md) |

`check`, `lint` and `fmt` need no key. `explain` and `fix` produce mock output
without one.
