# `std.uuid`

```ecko
import std.uuid

uuid.v4()  # "e3b0c442-98fc-1c14-9afb-4c8996fb9242"  random
uuid.v7()  # time-ordered
```

## Which to use

**`v7` for anything stored in a database.** It is time-ordered, so generated ids
sort chronologically and index inserts land at the end of a B-tree rather than
scattered through it. On a table with millions of rows that difference is
measurable.

**`v4` for anything else** - a correlation id, a temporary filename, a cache key.
Purely random, no ordering, and no information about when it was made.

The trade-off: `v7` embeds a timestamp, so an id reveals roughly when it was
created. That is usually fine and occasionally not - for an opaque public
identifier where creation time should not leak, use `v4`.

## Not a token

Neither is a secret. A `v4` uuid has 122 random bits, which is plenty of entropy,
but uuids are conventionally treated as public identifiers - they appear in URLs,
logs and error messages.

For a session token, a password-reset link or an API key, use
[`std.random`](./random.md):

```ecko
import std.random
token = random.token(32)  # url-safe, from OS entropy
```

That draws from the CSPRNG and is not affected by `random.seed`, which is the
property a token needs.
