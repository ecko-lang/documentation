# url

URL parsing, query strings, and reference resolution for Ecko.

```bash
ecko get github.com/ecko-lang/url
```

```ecko fragment
import url
```

Pure computation: it declares no capabilities, so it cannot touch the network, the filesystem or the environment.

Version 0.10.1 - [source](https://github.com/ecko-lang/url) - MIT.

---


## `encode(s)`

encode(s) -> `s` percent-encoded for use in a URL.

## `decode(s)`

decode(s) -> `s` with percent-escapes resolved, so `%20` becomes a space.

## `parse(u)`

parse(url) -> { scheme, userinfo, host, port, path, query, fragment }.

## `query_parse(q)`

query_parse(str) -> map. `+` decodes to space (form encoding), then %xx.

## `query_build(m)`

query_build(map) -> "k=v&..." with keys sorted and values percent-encoded.

## `build(parts)`

build(parts) -> a URL string (the inverse of parse).

## `join(base, ref)`

join(base, ref) -> the reference resolved against base (RFC 3986 section 5).
