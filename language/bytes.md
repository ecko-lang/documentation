# Bytes

`bytes` is the home for binary data - what a UTF-8-validated `string` cannot
hold.

```ecko
magic = b"\x89PNG\r\n\x1a\n"  # 8 bytes
empty = b""  # falsy, like "" and []
```

## The literal

ASCII plus escapes. `\xNN` for arbitrary bytes; `\n \t \r \\ \" \0` as usual.
**No `{expr}` interpolation** - bytes are bytes, not text. A non-ASCII character
or an unknown escape is a lex error rather than a guess.

Printing renders bytes canonically: short forms for `\n \t \r \" \\`, other
printable ASCII verbatim, everything else lowercase `\xNN`. NUL prints as `\x00`
and never `\0`, so a following digit cannot blur into the escape.

## Operations

| operation | result |
|---|---|
| `len(b)` | byte count |
| `b[i]` | `Int` 0-255, strict, negative from the end |
| `b[i..j]` | bytes, clamped like other slices |
| `b1 + b2` | concatenation; both sides must be bytes |
| `for x in b` | iterates `Int`s |
| `==`, `<` | bytewise equality, lexicographic order |
| `contains(b, sub)`, `index_of(b, sub)` | binary-safe search |
| `b"\x01"` in `match` | a literal pattern |

## The text boundary is explicit

```ecko fragment
bytes(s)                     # string -> bytes: UTF-8 encode (always works)
bytes([137, 80, 78])         # list of Ints 0..255 -> bytes
string(b)                    # bytes -> string: ERRORS on invalid UTF-8
string.from_utf8(b)          # the same strict decode, catchable
string.from_utf8_lossy(b)    # opt-in replacement characters
list(b)                      # bytes -> list of Ints
```

`bytes + string` is a type error. Pick a side explicitly, the same stance as
[secrets](./secrets.md).

**Encoding is total; decoding can fail, and fails loudly.** The alternative -
silently substituting replacement characters - corrupts data in a way that shows
up much later, in something that is not the decoder. `from_utf8_lossy` exists for
when you genuinely want that, and its name says so.

## JSON and `ai`

JSON has no byte type, so `json_encode` emits bytes as a **base64 string**, and
`json.decode` leaves it a string for you to decode back explicitly.

`ai[bytes]` advertises a base64-string schema and decodes the reply. Mock mode
returns a deterministic blob through the same coercion path.

## Bitwise

`band`, `bor` and `bxor` work element-wise on equal-length bytes; `bnot`
complements each byte. See [Bitwise & word operators](./bitwise.md).

```ecko fragment
key = b"\x5a\x5a\x5a\x5a"
masked = message bxor key
original = masked bxor key
```

## Migrating older code

The decoders in [`std.encoding`](../stdlib/encoding.md) return bytes. Code written
against the older string-returning behaviour is rewritten mechanically:

```bash
ecko fix --migrate-bytes src/
```
