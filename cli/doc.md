# `ecko doc`

Generate markdown documentation from [`##` comments](../language/comments.md).

```bash
ecko doc main.ecko                # markdown to stdout
ecko doc src/ -o docs/            # one .md per source file
```

## Output

Without `-o` the markdown goes to stdout, so it pipes:

```bash
ecko doc main.ecko > API.md
ecko doc main.ecko | glow -
```

With `-o`, one `.md` is written per source file, **mirroring the source
layout**. That matters: `app.ecko` and `demo/app.ecko` would otherwise both want
to be `app.md`, and one would quietly overwrite the other.

```
src/app.ecko        ->  docs/app.md
src/demo/app.ecko   ->  docs/demo/app.md
```

`vendor/` is skipped - those are someone else's packages, and their
documentation belongs with them.

## What it produces

```ecko
## Temperature conversion helpers.

## Convert celsius to fahrenheit.
##
## example:
##   to_fahrenheit(100.0)   # 212.0
export fn to_fahrenheit(c) = c * 9.0 / 5.0 + 32.0

export fn to_celsius(f) = (f - 32.0) * 5.0 / 9.0
```

becomes:

````markdown
# temps

Temperature conversion helpers.

## `to_fahrenheit(c)`

Convert celsius to fahrenheit.

```ecko fragment
to_fahrenheit(100.0)   # 212.0
```

## `to_celsius(f)`

*Undocumented.*
````

Note `to_celsius`. It is exported but has no documentation, so it is listed and
marked - the gap in the public surface is visible rather than hidden. Signatures
include parameter defaults and an `async` prefix where they apply.

## Multi-file packages

A package that keeps its implementation in siblings and curates the public API
in its entrypoint is documented as one surface: `ecko doc main.ecko` follows
`export ... from` into those files.

```ecko
export { with_headers } from "./util.ecko"
export * from "./responses.ecko"
```

The curation is respected, because it is the whole point of writing it. `export
*` documents everything the module exports; `export { with_headers }` documents
that one function and leaves its siblings private, even though they are exported
where they are defined. An `as` alias is documented under the new name.

Private helpers never cross the boundary, and a cycle between modules
terminates rather than recursing.

## Exit status

Non-zero if any file fails to parse or cannot be read or written, with the
offending file named. Files that do parse are still generated, so one broken
file does not cost you the whole run.

## Not yet

HTML output. Markdown first, deliberately: it renders on GitHub, feeds a docs
site, and diffs cleanly in review.
