# `std.dns`

```ecko
import std.dns

dns.resolve("ecko.sh")              # A/AAAA addresses
dns.resolve("ecko.sh", "MX")        # a record type
dns.reverse("93.184.216.34")        # PTR
dns.lookup("ecko.sh")               # the system resolver
```

Needs `net`. Record types: `A`, `AAAA`, `CNAME`, `MX`, `TXT`.

## `resolve` or `lookup`

`lookup` uses the **system resolver**, so it honours `/etc/hosts`, your search
domains and any local DNS configuration. That is what you want to answer "what would
this machine connect to?"

`resolve` queries DNS for a specific record type, which is what you want to inspect a
domain's actual records - `MX` before sending mail, `TXT` for a verification token.

## MX records

```ecko
for mx in dns.resolve("example.com", "MX") {
    print("{mx.priority} {mx.host}")
}
```

Sorted by priority, lowest first - which is delivery order. Pair with
[`smtp`](../packages/smtp.md).

## Errors

A name that does not resolve raises `{ kind: "net", host }` rather than returning an
empty list, so a typo does not read as "no records". Catch it where the name came
from outside:

```ecko
try { addrs = dns.resolve(domain) } catch (e) { reject("unknown host") }
```

## DNS is not validation

Two habits worth having:

- **Resolving a domain does not mean an address is deliverable.** A valid MX record
  says nothing about whether the mailbox exists. Only sending finds that out.
- **DNS answers change.** They are cached, they vary by resolver, and they are
  attacker-influenceable on a hostile network. Do not use a DNS result as an
  authorization decision.

## Not for connecting

You do not need to resolve before connecting - [`std.net`](./net.md) and
[`std.http`](./http.md) take a hostname and resolve it themselves. Resolving first
and connecting to the address means you lose TLS hostname verification unless you
are careful, so pass the name.
