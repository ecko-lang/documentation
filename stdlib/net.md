# `std.net`

Raw TCP and TLS sockets. Needs `net`.

```ecko fragment
import std.net

c = net.connect("example.com", 80)
net.send(c, bytes("GET / HTTP/1.0\r\n\r\n"))
data = net.recv(c)                    # bytes
net.close(c)

c = net.connect_tls("example.com", 443)
c = net.starttls(c)                   # upgrade an open connection
```

## Reading

| call | |
|---|---|
| `net.recv(c)` | whatever is available, as bytes |
| `net.recv_text(c)` | the same, decoded as UTF-8 |
| `net.recv_exact(c, n)` | exactly `n` bytes |
| `net.recv_until(c, delim)` | up to and including a delimiter |

**`recv` returns whatever arrived, not a whole message.** TCP is a byte stream with
no message boundaries, so a single `recv` may give you half a response or two
responses. This is the classic source of protocol bugs.

Use `recv_exact` for a length-prefixed protocol and `recv_until` for a
line-delimited one - those two cover almost everything, and both handle the framing
you would otherwise get wrong.

## `lookup`

`net.lookup(host)` resolves a hostname to a list of IP address strings via the
OS resolver - the same lookup `connect` does internally, exposed on its own for
when you want the address without opening a socket.

## `starttls`

Upgrades an established plaintext connection, which is what SMTP, IMAP and
PostgreSQL do. `connect_tls` is for a connection that is encrypted from the start.

## Why this exists

So that a protocol client can be written **in Ecko**, with no native code. The
official MySQL, PostgreSQL, Redis and SMTP clients are all built on this module -
real wire protocols, authentication scrambles and all, in the language itself.

That is the [three-layer policy](../packages/concepts.md) working: rather than
adding a database driver to the runtime, the runtime provides sockets and the driver
is an ordinary, capability-gated, replaceable package.

## Use a client, not this

For talking to a database or a mail server, use the package:

- [`mysql`](../packages/mysql.md), [`postgres`](../packages/postgres.md)
- [`redis`](../packages/redis.md), [`smtp`](../packages/smtp.md)

Reach for `net` when you are implementing a protocol that does not have a client
yet.

## Errors and timeouts

Failures raise `{ kind: "net", host }`. A read on a peer that never responds waits -
so bound your own protocol logic, and do not expose an unbounded socket loop to
untrusted peers.
