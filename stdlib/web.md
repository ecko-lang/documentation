# `std.web`

A router over [`http.serve`](./http.md).

```ecko fragment
import std.http
import std.web

routes = [
    { method: "GET",  path: "/",           handler: fn(req) http.html(home()) },
    { method: "GET",  path: "/posts/:id",  handler: fn(req) show(req.params.id) },
    { method: "POST", path: "/posts",      handler: create },
    web.static("/assets", "public/assets"),
]

http.serve(8080, web.router(routes, middleware))
```

## Route constructors

The map literal above is one way to write a route. `web.get(path, handler)`,
`web.post(path, handler)`, `web.put(path, handler)`, `web.patch(path, handler)`,
`web.delete(path, handler)` and `web.head(path, handler)` build the same map -
pick whichever reads better:

```ecko fragment
routes = [
    web.get("/", fn(req) http.html(home())),
    web.get("/posts/:id", fn(req) show(req.params.id)),
    web.post("/posts", create),
    web.static("/assets", "public/assets"),
]
```

## Path parameters

`:name` segments arrive in `req.params`:

```ecko fragment
fn show(req) {
    id = req.params.id
    http.json(find(id))
}
```

## `GET` routes answer `HEAD`

A `GET` route responds to `HEAD` automatically, with the headers and no body.

This exists because it is what every client expects - health checks, link
checkers, proxies and `curl -I` all send `HEAD` - and a router that 404s them
looks broken while working perfectly for browsers.

## Middleware

A middleware is `fn(req, next)`. It can inspect the request, call `next(req)`, and
modify the response:

```ecko fragment
fn timing(req, next) {
    start = time.monotonic()
    resp = next(req)
    log.info("request", { path: req.path, ms: time.monotonic() - start })
    resp
}
```

They run outermost-first in the order given. Not calling `next` short-circuits,
which is how authentication and a preflight response work.

## Static files

```ecko fragment
web.static("/assets", "public/assets")
```

**Traversal-safe**: `..` in a request cannot escape the directory. Use this rather
than reading a request-supplied path with [`std.fs`](./fs.md), which will happily
serve `/etc/passwd` if you ask it to.

## Errors

An unmatched route gives 404. A handler that raises gives 500 and logs. For
designed error pages, per-route middleware, signed cookies, sessions, form
validation and blueprints, use the [`webkit` package](../packages/webkit.md), which
is a full framework over this module.

## Order

Routes match in order, so put specific paths before general ones. A static mount at
`/` will shadow everything after it.
