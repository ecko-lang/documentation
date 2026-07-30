# `std.yaml`

```ecko
import std.yaml

data = yaml.parse(text)
text = yaml.stringify(value)
data = yaml.read("compose.yaml")
yaml.write("out.yaml", value)
```

Identical in shape to [`std.toml`](./toml.md) and [`std.json`](./json.md).

## Mostly for reading other people's files

YAML is what CI configuration, Kubernetes manifests and Compose files are written
in, so this module exists so you can read them. For a file *you* control, prefer
[TOML](./toml.md) or [`std.defaults`](./defaults.md).

The reason is that YAML is a large, surprising format:

- **Unquoted scalars are typed by shape.** `yes`, `no`, `on`, `off` may read as
  booleans; `1.0` is a number; a version like `1.10` loses its trailing zero.
- **`null`, `~` and an empty value** all mean null.
- **Indentation is structure**, so a stray space changes the shape.
- A postal code or a country code like `NO` can become something other than a
  string.

None of that is a bug in this module - it is YAML. The defence is quoting anything
that must stay a string, on both sides.

## Errors

Malformed input raises `{ kind: "parse", format: "yaml" }`, with `path` from
`yaml.read`. Because indentation is significant, the message's line number is
usually the fastest route to the problem.

## Multiple documents

A stream of `---`-separated documents is not a single value. Split before parsing if
you need to handle every document.

## Untrusted YAML

Parsing produces plain Ecko data - maps, lists, strings, numbers - and nothing
executable. There is no tag mechanism that constructs objects here, so the class of
attack that plagues some YAML libraries does not apply. Deeply nested input is still
bounded by `ECKO_MAX_PARSE_DEPTH`; see [Resource limits](../language/limits.md).
