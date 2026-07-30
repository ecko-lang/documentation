# `std.zlib`

Compression over [bytes](../language/bytes.md).

```ecko
import std.zlib

packed = zlib.gzip(data)
data   = zlib.gunzip(packed)

raw    = zlib.deflate(data)
data   = zlib.inflate(raw)
```

## Which format

**`gzip` / `gunzip`** for anything crossing a boundary - a file on disk, an HTTP
body, something another tool will read. Gzip has a header and a checksum, and
everything understands it.

**`deflate` / `inflate`** for raw compressed data with no header, when a format or
protocol specifies it. Smaller by a few bytes, and not self-describing.

If you are unsure, use gzip.

## In and out are bytes

Both directions work on bytes. Compress a string by encoding it first:

```ecko
packed = zlib.gzip(bytes(text))
text   = string(zlib.gunzip(packed))
```

`string()` on the way back raises on invalid UTF-8, which is the behaviour you want
- silently substituting replacement characters would corrupt the round trip. See
[Bytes](../language/bytes.md).

## What compresses

Text, JSON, logs and source compress very well - often 5 to 10 times. Already
compressed data - JPEG, PNG, video, a zip - does not, and gzipping it wastes CPU to
produce something marginally larger.

## Errors

Corrupt or truncated input raises rather than returning partial output. Catch it
when the data came from outside:

```ecko
try { data = zlib.gunzip(body) } catch (e) { reject("bad encoding") }
```

## Decompression bombs

A small compressed input can expand enormously. When decompressing something you
did not create, check the size afterwards - or before, if the source reports it -
rather than assuming the result fits in memory. The package fetcher applies exactly
this rule, which is why `ECKO_PKG_MAX_UNPACKED` exists.
