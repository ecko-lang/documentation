# smtp

An SMTP client (RFC 5321) written in Ecko, over std.net raw sockets + STARTTLS.

```bash
ecko get github.com/ecko-sh/smtp-client
```

```ecko
import smtp
```

`ecko get` records this under `smtp-client`, which is not a valid Ecko identifier. Alias it to `smtp` in the `dependencies` block of your `ecko.json`.

Declares `net`. A capability is only advisory in the manifest: what the package actually gets is the `grant` you give it when you import it.

Version 0.9.4 - [source](https://github.com/ecko-sh/smtp-client) - MIT.

---


## `addr_of(s)`

addr_of("Ada <ada@x>") -> "ada@x"; a bare address passes through trimmed.

## `parse_reply_line(line)`

One reply line -> { code, more, text }. "250-x" continues a multiline
reply; "250 x" (or a bare "250") ends it.

## `dot_stuff(text)`

Normalize line endings to CRLF and escape leading dots (RFC 5321 §4.5.2),
so a body line of "." can't terminate the DATA phase early.

## `auth_plain(user, pass)`

The AUTH PLAIN initial response: base64("\0user\0pass").

## `build_message(msg)`

build_message(msg) -> RFC 5322 text (CRLF line endings): From / To /
Subject [/ Date] / extra headers (sorted by name) / MIME headers, a blank
line, then the body. msg: { from, to (string|list), subject, body,
date?, headers? }.

## `read_reply(sock)`

read_reply(sock) -> { code, lines }, collecting a full (possibly
multiline) server reply.

## `expect_code(sock, want, label)`

Require the next reply to carry `want`, or throw { kind: "smtp", code }.

## `command(sock, line, want)`

Send one command line and require a reply code. Errors are labelled with
the command VERB only, so AUTH credentials never appear in error text.

## `send(server, msg)`

send(server, msg) -> { accepted, reply }
  server: { host, port?, tls?, user?, pass?, verify?, helo?, mock? }
  msg:    { from, to (string|list), subject, body, date?, headers? }

The password may be a `secret` - it is revealed only for the AUTH exchange.
