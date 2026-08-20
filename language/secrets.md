# Secrets

```ecko fragment
db_pass = secret(os.env("DB_PASS"))

print(db_pass)                  # [secret]
print("pw: {db_pass}")          # pw: [secret]

sql.connect("pg://u:{reveal(db_pass)}@host/db")
```

## What `secret` does

It wraps a credential so the wrapper renders as `[secret]` through **every**
stringifying sink: `print`, interpolation, [`std.log`](../stdlib/log.md),
[`ECKO_TRACE`](../ai/tracing.md), error messages, templates, and JSON encoding.

A wrapped value cannot leak into a log line by accident. That is the whole
design goal - not to protect against an attacker with memory access, but against
the ordinary path where a credential ends up in a log because someone printed a
config map.

## `reveal` is the only way out

```ecko fragment
reveal(db_pass)      # the inner value
is_secret(v)         # test for the wrapper
```

One function, so **`grep reveal` audits every exposure point in a codebase**. That
auditability is why there is exactly one accessor and no convenience alternatives.

[`ecko check`](../cli/check.md) reports a credential used where the plain value is
required without `reveal`, at error level - so the mistake stops the program
rather than sending a literal `[secret]` to your database.

## The rules

- **`"x" + s` is a type error.** Use `reveal`. Concatenation would defeat the
  wrapper silently.
- **Secrets compare equal only to other secrets with equal contents.** `s ==
  "raw"` is always `false`, so a comparison cannot be used to probe the value.
- **`error(secret(x))` renders redacted** while `catch` still binds the wrapped
  value, so an error path keeps the guard.

## What it is not

Redaction is a leak guard for honest code paths, **not encryption**. The value
lives in memory in the clear and `reveal` is unrestricted. A program that wants
the value can have it; the point is that a program that does *not* want it cannot
get it by accident.

## Where secrets come from

The environment, and nowhere else:

```ecko
import std.os
key = secret(os.env("API_KEY"))
```

Not a committed file - including not the `environment` block of
[`ecko.json`](../stdlib/defaults.md), which is committed.
[`std.config`](../stdlib/config.md) can declare fields as secret so they arrive
wrapped.

## Tracing and prompts

A `reveal`ed value interpolated into an `ai` prompt **lands in the trace file in
the clear**, because the trace records prompts verbatim. Wrapping protects the
value until you reveal it; after that it is data like any other. Treat trace
output like any log.
