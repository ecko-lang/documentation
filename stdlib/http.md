# `std.http`

Client and server in one module.

## Client

```ecko fragment
import std.http

r = http.get(url)
print(r.status)
print(r.body)
print(r.headers)

http.post(url, body, headers)
data = http.get(url).body_bytes        # bytes, for binary
```

`http.put(url, opts)`, `http.patch(url, opts)` and `http.delete(url, opts)`
cover the rest of the verbs. `opts` is the same options map every client call
takes: `body`, `json`, `headers`, `timeout`, `stream`.

## Server

```ecko fragment
fn handler(req) {
    if req.path == "/" { http.text("hello") } else { http.not_found() }
}

http.serve(8080, handler)
```

`serve` blocks. A handler takes a request map and returns a response.
`http.stop()` requests a graceful shutdown from elsewhere - in-flight requests
drain, then `serve` returns. Ctrl-C does the same thing.

## Responses

```ecko fragment
http.text(s)
http.html(body)
http.json(value)
http.response(status, body, headers)
http.not_found()
```

Or build one as a map - `{ status, headers, body }` - which is all a response is.

## Requests

A request map carries `method`, `path`, `params`, `headers`, `body`, `body_bytes`,
`form`, `files`. `http.form(req)` parses a submitted form and `http.files(req)`
gives uploads with `filename` and `content_type`.

## Routing

`serve` takes one handler. For routes, `:params`, middleware and static files, use
[`std.web`](./web.md), which is a router over this:

```ecko fragment
import std.web
http.serve(8080, web.router(routes))
```

## Concurrency

Handlers run on a worker pool (`ECKO_HTTP_WORKERS`, default 8), and each handler
gets a **snapshot** of captured state - the usual
[share-nothing](../concurrency/pmap.md) model. To share across requests, use a
[`cell`](../concurrency/cell.md):

```ecko fragment
hits = cell(0)
fn handler(req) {
    n = cell_update(hits, fn(v) v + 1)
    http.text("request #{n}")
}
```

## Limits

`ECKO_HTTP_MAX_BODY` (10 MiB) bounds request bodies and
`ECKO_HTTP_REQUEST_TIMEOUT_MS` bounds a handler. Both matter on a public port: an
unbounded body is a memory exhaustion, and an unbounded handler is a worker held
forever.

`ECKO_HTTP_READ_TIMEOUT_MS` (default 30000) bounds how long a connection may take
to send its request headers, so a client that opens a socket and dribbles bytes is
dropped rather than holding a connection. That is a different limit from the
handler timeout, which only starts once a request has fully arrived.

## Protocols

HTTP/1.0 and 1.1, with keep-alive honoured and advertised in both directions.
Chunked request and response bodies, `100-continue`, trailers and pipelining all
work. HTTP/2 is negotiated over TLS through ALPN, falling back to HTTP/1.1 for
clients that cannot speak it; cleartext h2c is not offered.

## Compression

Buffered responses over 1 KiB are compressed when the client asks for it with
`Accept-Encoding: gzip` or `deflate`, gzip preferred. The response gains
`Content-Encoding` and `Vary: Accept-Encoding`.

Three things are left alone: already-compressed content types (`image/*`,
`video/*`, `audio/*`, zip), any response whose handler set its own
`Content-Encoding`, and streaming responses. Streams are never compressed because
buffering one to compress it would defeat the point of streaming.

## Streaming and WebSockets

`http.stream` sends a body fed by a [channel](../concurrency/channels.md), which is
how you push tokens as they arrive - see
[Streaming responses & SSE](../concurrency/streaming.md). For a WebSocket upgrade,
see [`std.ws`](./ws.md).

## TLS

Client requests to `https://` verify certificates. The Linux builds link OpenSSL
statically, so there is nothing to install.

## Errors

Client failures raise `{ kind: "net", url, message }`. Wrap calls to anything you do
not control, and consider [`retry`](../ai/retry.md) for transient failure:

```ecko fragment
body = retry(3, fn() http.get(url).body)
```
