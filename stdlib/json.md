# `std.json`

```ecko
import std.json

json.encode(value)          # value -> string
json.decode(text)           # string -> value
json.read(path)             # a file -> value
json.write(path, value)
```

The globals `json_encode` and `json_decode` do the same encoding and decoding
without an import; this module adds the file forms.

## Deterministic output

**Maps encode with sorted keys.** The same value always produces the same bytes, so
encoded JSON can be compared, hashed, checked into a repository, or asserted on in
a test without normalizing it first.

## Type mapping

| Ecko | JSON |
|---|---|
| `null`, `bool`, `string` | as-is |
| `int`, `float` | number |
| `decimal` | number in canonical text - **round trip is float-precision** |
| `bytes` | base64 **string** |
| `list`, `map` | array, object |
| `struct` | object |

Two lossy edges worth knowing, both because JSON has no such type:

- **`decimal`** encodes as a number and decodes as a float. If exactness must
  survive transport, send a string and rebuild with `decimal("...")`. See
  [Numbers](../language/numbers.md).
- **`bytes`** encodes as base64 and decodes as a *string*. Decode it back
  explicitly with [`encoding.base64_decode`](./encoding.md).

## Errors

Malformed input raises `{ kind: "parse", format: "json" }`, and `json.read` adds
`path`. Always catch around anything decoded from outside:

```ecko
try {
    data = json.decode(body)
} catch (e) {
    match get(e, "kind") { "parse" => bad_request() _ => error(e) }
}
```

## Decoded data is uncertain in shape

A decoded value is a map whose keys you hope are there. `data.user.email` raises if
any level is missing. Two better tools:

- [`get`](../language/data-access.md) for expected absence: `get(data, "email")`.
- [`match`](../language/pattern-matching.md), which tests rather than accesses, so
  a missing key is a non-match rather than an error.

For validating a whole payload with all errors collected, use the
[`validate` package](../packages/validate.md).

## Typed model output

`ai[json<List<Int>>]` asks a model for a shaped JSON value and coerces the reply
through the schema, which is usually better than decoding a string yourself - see
[typed output](../ai/typed-output.md).
