# `std.hash`

```ecko
import std.hash

hash.sha256("abc")                  # hex digest
hash.hmac_sha256(key, message)      # hex
hash.sha256_bytes(data)             # raw 32 bytes
hash.hmac_sha256_bytes(key, msg)

hash.password("pw")                 # Argon2id PHC string
hash.verify("pw", stored)           # constant-time -> Bool
```

Inputs are a string or [bytes](../language/bytes.md), either way.

## Passwords: use `password` and `verify`

```ecko
stored = hash.password(reveal(plain))     # store this
ok = hash.verify(reveal(attempt), stored)
```

**Argon2id with a per-call random salt**, producing a self-describing PHC string
that carries its own parameters - so verification keeps working when you change the
cost settings later.

`verify` is constant-time and returns `false` rather than raising on a malformed
stored hash, so a login path cannot be crashed by bad data in the database.

**Never hash a password with `sha256`.** A digest is designed to be fast, which is
exactly wrong for a password: fast means a stolen table can be brute-forced at
enormous rates. Argon2id is deliberately slow and memory-hard. Salting a sha256
yourself does not close that gap.

## HMAC for authentication

`hmac_sha256(key, message)` proves a message was produced by someone holding the
key. This is what signs a cookie or a webhook:

```ecko
mac = hash.hmac_sha256(reveal(secret_key), payload)
```

**Compare MACs in constant time.** A comparison that returns on the first
differing byte leaks how much of a forged MAC was correct, which is enough to
forge one byte at a time. `hash.verify` does this for passwords; for a MAC, use a
length-then-full-scan compare rather than `==` on the hex strings, or use the
[`webkit`](../packages/webkit.md) signing functions, which handle it.

## `sha1` is legacy only

`hash.sha1` and `hash.sha1_bytes` exist for **legacy protocols** that require it -
the MySQL authentication scramble, for instance. SHA-1 is broken for collision
resistance. Do not choose it for anything new.

## Not encryption

Hashing is one-way. There is no `decrypt`. For confidentiality use TLS in transit
([`std.net`](./net.md), [`std.http`](./http.md)) and your platform's facilities at
rest.
