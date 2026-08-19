# ip

IPv4/IPv6 address parsing, validation, CIDR membership, and private-range checks for Ecko. Pure - no capabilities.

```bash
ecko get github.com/ecko-lang/ip
```

```ecko
import ip
```

Pure computation: it declares no capabilities, so it cannot touch the network, the filesystem or the environment.

Version 0.10.1 - [source](https://github.com/ecko-lang/ip) - MIT.

---


## `parse(s)`

parse(s) -> { version, groups, is_private }. Raises kind-"value" if invalid.

## `is_valid(s)`

Whether `s` parses as an IPv4 or IPv6 address. The non-raising form of
`parse` - use it when a bad address is an expected input, not an error.

```ecko
is_valid("192.168.1.1")   # true
is_valid("nope")          # false
```

## `version(s)`

4 or 6 for an address. Raises if `s` is not an IP address.

## `is_private(s)`

Whether the address is in a private range - RFC 1918 and loopback for v4,
unique-local (fc00::/7) and loopback for v6. Raises if `s` is not an address.

## `in_network(addr, cidr)`

in_network(ip, cidr) -> is `ip` inside the `cidr` block (e.g. "10.0.0.0/24")?
