# Modules & imports

```ecko fragment
import std.time                # binds `time`
import std.time as t           # choose the name
import "./helpers.ecko"        # binds `helpers` by file stem
import "./helpers.ecko" as h
import url                     # a vendored package
```

Three kinds of import, one syntax. A bare name is a
[package](../packages/concepts.md); a quoted path is a file; `std.*` is built in.

## Aliasing

```ecko fragment
import std.time as t
fn time() = now_ms()           # your own `time` is free
```

Worth doing whenever a module name collides with something you want to call
yourself. `import std.string` binds `string`, which shadows the global `string()`
constructor for the rest of the scope - so either alias it or use `string.from(x)`
to convert.

## Private by default

**Only `export`-marked definitions are visible to an importer.**

```ecko
export fn clean(s) = trim(lower(s))  # public
fn internal(s) = s  # private
```

The `export` modifier is inline, on the declaration. An older `export { a, b }`
block form existed; `ecko fix --migrate-exports` rewrites it.

## Re-exporting

A multi-file package curates its public surface in its entrypoint:

```ecko fragment
export * from "./validators.ecko"          # the whole exported surface
export { with_headers } from "./util.ecko" # just this one
export { esc as escape } from "./e.ecko"   # renamed
export import "./shared.ecko"              # bind locally AND re-export
```

This is how a package presents one flat namespace over several files while keeping
helpers private - `export { with_headers }` publishes that function and leaves its
siblings internal even though they are exported where they are defined.

[`ecko doc`](../cli/doc.md) follows these statements with the same selectivity, so
the generated reference is the real public surface.

## Shadowing a built-in

Legal, and sometimes necessary - a package exporting `get`, `join` or `string`.
Reach the original through `core.*`:

```ecko fragment
export fn get(c, key) { ... }
fn internal(m, k) = core.get(m, k)      # the builtin
```

`ecko check` warns on the shadow, since it is usually accidental.

## Circular imports

Detected and reported rather than hanging or half-initializing a module.

## Capabilities

A `std.*` module's gated functions check the capability set of the calling
package. Root code holds full authority; a package holds what its importer
granted. So `import std.fs` in a package is not a permission - the grant is. See
[Capabilities & gating](../packages/capabilities.md).
