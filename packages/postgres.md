# postgres

A PostgreSQL client written in Ecko: v3 wire protocol + SCRAM-SHA-256 over std.net.

```bash
ecko get github.com/ecko-lang/postgresql-client
```

```ecko
import postgres
```

`ecko get` records this under `postgresql-client`, which is not a valid Ecko identifier. Alias it to `postgres` in the `dependencies` block of your `ecko.json`.

Declares `net`. A capability is only advisory in the manifest: what the package actually gets is the `grant` you give it when you import it.

Version 0.9.5 - [source](https://github.com/ecko-lang/postgresql-client) - MIT.

---


## `pbkdf2(password, salt, iters)`

PBKDF2-HMAC-SHA256, single 32-byte block (SCRAM's dkLen).

## `connect(cfg)`

connect({ host, port, user, password, database }) -> a connection handle.

## `connect_tls(cfg)`

Connect to PostgreSQL over TLS and complete authentication. Same `cfg` as
`connect`. Needs the `net` capability.

## `close(sock)`

Close the connection.

## `pg_text(v)`

Text format for every param: the value goes out-of-band as a length-prefixed
field, NEVER spliced into the SQL, so it can't break out of its slot. That's
injection safety by construction - the same guarantee as a `?` placeholder.

## `build_bind(params)`

build_bind(params) -> the Bind ('B') message payload: unnamed portal + unnamed
statement + 0 param format codes (all text) + Int16 param count + each param
(Int32 length, then bytes; length -1 = SQL NULL) + 0 result format codes.

## `query(sock, sql, params = [])`

query(sock, sql) runs a simple text query. query(sock, sql, params) runs the
extended protocol with $1..$N placeholders bound out-of-band (injection-safe).
