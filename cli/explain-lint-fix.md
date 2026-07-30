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
knowing about because they are exact rather than suggested:

```bash
ecko fix --migrate-bytes src/       # *_decode -> *_decode_text, net.recv -> recv_text
ecko fix --migrate-exports src/     # the old `export { ... }` block to inline `export`
```

Those two exist because both changes were breaking and mechanical - the kind
where a codemod is more trustworthy than a human doing it by hand across a
codebase.

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
