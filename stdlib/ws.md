# `std.ws`

WebSocket client.

```ecko fragment
import std.ws

conn = ws.connect("wss://example.com/socket")
ws.send(conn, "hello")
msg = ws.recv(conn)          # blocks
ws.close(conn)
```

Needs `net`.

## Receiving

`recv` blocks until a message arrives, and returns `null` when the connection
closes. So the idiomatic loop ends on close:

```ecko fragment
loop {
    msg = ws.recv(conn)
    if msg == null { break }
    handle(msg)
}
```

## Server side

The upgrade lives in [`std.http`](./http.md), which can turn a request into a
WebSocket connection. `ECKO_MAX_WS_CONNS` (default 1024) bounds concurrent
connections - a bound that matters, since each one holds resources for as long as
the client keeps it open.

## Concurrency

A connection is not a value you copy - do not use one from several tasks at once.
The usual arrangement is one task reading and a [channel](../concurrency/channels.md)
carrying messages to whatever processes them, which also gives you backpressure.

## Errors

Failures raise `{ kind: "net" }`. Network connections drop, so a long-lived client
needs reconnection logic - `ws.recv` returning `null` is where you notice.

## When SSE is the better choice

For **one-directional** streaming from server to client, server-sent events over
plain HTTP are simpler: no upgrade, no framing, no separate protocol for proxies to
handle, and browsers reconnect automatically. See
[Streaming responses & SSE](../concurrency/streaming.md).

Use WebSockets when the client genuinely needs to send messages mid-stream - a chat,
a collaborative editor, a game.

## Higher level

For a Redis-style protocol client written over raw sockets, see
[`std.net`](./net.md) and the client packages built on it.
