# Comments & documentation

`#` begins a comment and runs to the end of the line. There is no block comment
form.

```ecko
# a note to whoever reads this next
x = 1  # comments can trail code too
```

## `##` is documentation

Doubling the marker makes a comment into **documentation**, which
[`ecko doc`](../cli/doc.md) turns into markdown.

```ecko fragment
## Fetch a user by id.
##
## Returns null when no such user exists.
export fn fetch(id) = db.get(id)
```

There is only one comment character to remember. Everything after a `#` is a
comment; a doubled one is *also* documentation. A third `#` is content rather
than marker, so a banner keeps its shape:

```ecko fragment
### ------------------------------
### Section: request handling
### ------------------------------
```

## What a block attaches to

A `##` block documents **the declaration on the line directly below it**.

```ecko
## Documents `parse`.
export fn parse(s) = s
```

A blank line detaches it. An unattached block at the top of a file documents
the **module** instead - which is what you want for a file header, and why the
rule exists: without it, a header comment would silently become the first
function's documentation.

```ecko
## This module parses configuration files.
##
## Nothing here touches the network.

## Documents `parse`, not the module.
export fn parse(s) = s
```

An ordinary `#` line inside the run does *not* break it, so implementation notes
can sit between the documentation and the code:

```ecko
## Documents `parse`.
# TODO: handle CRLF
export fn parse(s) = s
```

## The `example:` convention

A line reading `example:`, followed by indented lines, becomes a fenced code
block in the generated markdown. It reads as prose in the source and as a
runnable snippet in the output.

```ecko
## Convert celsius to fahrenheit.
##
## example:
##   to_fahrenheit(100.0)   # 212.0
export fn to_fahrenheit(c) = c * 9.0 / 5.0 + 32.0
```

renders as:

> Convert celsius to fahrenheit.
>
> ```ecko
> to_fahrenheit(100.0)   # 212.0
> ```

## What gets documented

Top-level `fn`, `type` and value declarations.

**Exported declarations are always listed**, documented or not - an
undocumented export is a real gap in your public surface, and listing it is how
you see it. Undocumented private helpers are omitted, since listing every one
would bury the parts that matter. A documented private helper *is* listed, and
marked as not exported.

Declarations nested inside a function body are never documented; only the top
level is public surface.

See [`ecko doc`](../cli/doc.md) for generating the output.
