# `std.toml`

```ecko fragment
import std.toml

config = toml.parse(text)
text   = toml.stringify(value)
config = toml.read("config.toml")
toml.write("config.toml", value)
```

Identical in shape to [`std.yaml`](./yaml.md) and
[`std.json`](./json.md) - `parse`, `stringify`, `read`, `write` - so switching
format is switching the module name.

## What it maps to

TOML tables become maps, arrays become lists, and TOML's date-time types arrive as
strings.

**A top-level map is required** for `stringify`, because TOML has no non-table
root. Serializing a bare list or number is an error rather than something invented.

## When to use it

TOML is a good fit for **configuration a person edits**: comments survive, the
syntax is unambiguous, and its strictness catches typos that YAML would silently
accept as a different value.

| you want | reach for |
|---|---|
| Human-edited config | TOML |
| Data interchange, an API body | [JSON](./json.md) |
| Existing YAML you must read | [YAML](./yaml.md) |
| Your own project's settings | [`std.defaults`](./defaults.md) - no parsing at all |

That last row matters: `ecko.json` beside your script is loaded automatically and
readable as `defaults.<key>`, which for a project's own configuration is less work
than any of these.

## Errors

Malformed input raises `{ kind: "parse", format: "toml" }`, with `path` from
`toml.read`. Catch it around any file a user can edit, and report the message - it
names the line.

## Comments

Parsing discards comments, so a read-modify-write cycle loses them. For a config
file a person maintains, prefer writing it by hand and only reading it in code.
