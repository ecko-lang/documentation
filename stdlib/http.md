# `std.http`

Client and server in one module.

## Client

```ecko
import std.http

r = http.get(url)
print(r.status)
print(r.body)
print(r.headers)

http.post(url, body, headers)
data = http.get(url).body_bytes        # bytes, for binary
```

## Server

```ecko
fn handler(req) {
    if req.path == "/" { http.text("hello") } else { http.not_found() }
}

http.serve(8080, handler)
```

`serve` blocks. A handler takes a request map and returns a response.

## Responses

```ecko
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

```ecko
import std.web
http.serve(8080, web.router(routes))
```

## Concurrency

Handlers run on a worker pool (`ECKO_HTTP_WORKERS`, default 8), and each handler
gets a **snapshot** of captured state - the usual
[share-nothing](../concurrency/pmap.md) model. To share across requests, use a
[`cell`](../concurrency/cell.md):

```ecko
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

```ecko
body = retry(3, fn() http.get(url).body)
```
