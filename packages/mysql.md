# mysql

A MySQL/MariaDB client written in Ecko: classic protocol + mysql_native_password over std.net.

```bash
ecko get github.com/ecko-lang/mysql-client
```

```ecko
import mysql
```

`ecko get` records this under `mysql-client`, which is not a valid Ecko identifier. Alias it to `mysql` in the `dependencies` block of your `ecko.json`.

Declares `net`. A capability is only advisory in the manifest: what the package actually gets is the `grant` you give it when you import it.

Version 0.9.5 - [source](https://github.com/ecko-lang/mysql-client) - MIT.

---


## `native_password(password, scramble)`

mysql_native_password: SHA1(pw) XOR SHA1(scramble + SHA1(SHA1(pw))).

## `connect(cfg)`

connect({ host, port, user, password, database }) -> a connection handle.

## `connect_tls(cfg)`

Connect to MySQL over TLS and complete authentication. Same `cfg` as
`connect`. Needs the `net` capability.

## `close(sock)`

Close the connection.

## `query(sock, sql)`

query(sock, sql) -> a list of row maps (empty for non-SELECT statements).
