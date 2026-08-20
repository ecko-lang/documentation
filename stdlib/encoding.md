# `std.encoding`

```ecko fragment
import std.encoding

encoding.base64_encode(data)        # data: bytes, or a string's UTF-8 bytes
encoding.base64_decode(s)           # -> bytes
encoding.base64_decode_text(s)      # -> string; errors on invalid UTF-8

encoding.hex_encode(data)
encoding.hex_decode(s)              # -> bytes
encoding.hex_decode_text(s)

encoding.url_encode(s)              # text only
encoding.url_decode(s)
```

## Decoders return bytes

`base64_decode` and `hex_decode` return [bytes](../language/bytes.md), not a
string. Decoding produces **binary data**, and the older string-returning
behaviour silently corrupted anything that was not valid UTF-8 - which is most of
what gets base64-encoded.

The `*_decode_text` forms are the explicit "this is text" variants: identical on
valid UTF-8, and a loud error otherwise.

```ecko fragment
img = encoding.base64_decode(payload)          # bytes, correct for a PNG
name = encoding.base64_decode_text(payload)    # string, errors if not UTF-8
```

Choosing between them is choosing what you believe the data is. That is the point:
the old behaviour made the choice for you and got it wrong quietly.

## Migrating

```bash
ecko fix --migrate-bytes src/
```

Rewrites `*_decode` to `*_decode_text` and `net.recv` to `net.recv_text` for code
written against the older behaviour.

## URL encoding is text only

`url_encode` and `url_decode` work on strings, because percent-encoding is defined
over text. For binary in a URL, base64-encode first, then url-encode - or use the
url-safe token from [`std.random`](./random.md), which needs neither.

Note that `url_encode` encodes a **component**, not a whole URL: it escapes `/`
and `?`. To build a URL, use the [`url` package](../packages/url.md), which
handles the parts separately.

## Not encryption, and not a checksum

Base64 and hex are **encodings**. They provide no confidentiality and no integrity
- anyone can decode them. For a digest use [`std.hash`](./hash.md); for
confidentiality use TLS.
