# `ecko dev`

```bash
ecko dev server.ecko
```

Runs the file and re-runs it whenever it changes on disk. Built for two cases:
an HTTP server you are editing, and a script you are iterating on.

## Servers

A server started with `http.serve` blocks. `ecko dev` stops the old process and
starts the new one on each save, so a route change is live without a manual
restart:

```ecko
# server.ecko
import std.http
import std.web

routes = [
    { method: "GET", path: "/", handler: fn(req) http.text("hello") },
]

http.serve(8080, web.router(routes))
```

```bash
ecko dev server.ecko
```

Because the process restarts, in-memory state does not survive a reload. That is
a feature while developing - it means you are always looking at the behaviour of
the code as written, not of the code plus whatever the last version left in a
`cell`.

## Scripts

For a non-blocking script, each save prints a fresh run. It is a tight loop for
working on a transformation or a prompt.

## What it watches

The file you named and the files it imports, including `vendor/`. A change to a
sibling module triggers the same reload as a change to the entrypoint.

## When not to use it

Not a supervisor. It does not restart on crash, back off, or keep anything
alive - it reacts to file changes and nothing else. Use a real process manager
in production, and see [Docker](../packages/docker.md) for deploying.
