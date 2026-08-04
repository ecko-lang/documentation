# `std.sql`

Embedded SQLite, compiled into the binary. Nothing to install.

```ecko
import std.sql

db = sql.open("app.db")             # or ":memory:"

sql.exec(db, "create table if not exists users (id integer primary key, name text)")
sql.exec(db, "insert into users (name) values (?)", ["Ada"])

rows = sql.query(db, "select * from users where name = ?", ["Ada"])
one  = sql.query_one(db, "select count(*) as n from users")

sql.transaction(db, fn() {
    sql.exec(db, "insert into users (name) values (?)", ["Bob"])
    sql.exec(db, "insert into users (name) values (?)", ["Cy"])
})

sql.close(db)
```

`:memory:` is pure; a file database needs `fs:write` covering its path (a
scoped grant confines which databases a package can open).

## Always use parameters

```ecko
sql.query(db, "select * from users where name = ?", [name])   # correct
sql.query(db, "select * from users where name = '{name}'")    # injection
```

**The second form is a SQL injection**, and interpolation makes it easy to write by
accident precisely because interpolation is so natural in this language. A parameter
is never parsed as SQL, whatever it contains.

## Results

`query` returns a list of maps keyed by column name. `query_one` returns the first
row, or `null` - so it is one of the nullable lookups, and absence is expected:

```ecko
row = sql.query_one(db, "select * from users where id = ?", [id])
if row == null { return not_found() }
```

## Transactions

`sql.transaction(db, fn)` commits when the function returns and **rolls back if it
raises**. That is the whole reason to use it rather than issuing `begin` and
`commit` yourself: an error between the two would otherwise leave the transaction
open.

## `sql { ... }` blocks

A block form for literal SQL, so multi-statement schema setup reads as SQL rather
than as a string.

## Concurrency

SQLite is a single file with a writer lock. Handlers running on the
[HTTP worker pool](./http.md) will contend for writes, and a long-held write
transaction blocks others.

Keep write transactions short. For read-heavy work SQLite is excellent; for
write-heavy multi-process work, it is the wrong shape - use
[`postgres`](../packages/postgres.md) or [`mysql`](../packages/mysql.md).

## Errors

Failures raise `{ kind: "sql", message }` - constraint violations included, which is
often the useful signal:

```ecko
try { sql.exec(db, "insert into users (email) values (?)", [e]) }
catch (err) { match get(err, "kind") { "sql" => already_taken() _ => error(err) } }
```

## Why it is embedded

One binary, no service, no connection string, no `apt install`. A program that needs
a database has one, which is the same reasoning as
[a file being a program](../start/a-file-is-a-program.md).
