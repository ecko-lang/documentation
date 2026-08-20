# Error handling & the error dialect

```ecko fragment
try {
    risky()
} catch (error) {
    print("Error: {error}")
} finally {
    cleanup()               # always runs
}
```

`try`/`catch` catches runtime errors only. `return`, `break` and `continue`
unwind through it.

## One dialect, four rules

Ecko has exactly one story per failure class, so you can predict what any API
does:

**1. Absence returns `null`** - but only from the lookups documented as nullable:
`get(xs, i)`, `get(m, k)`, `os.env(...)`. Everything else is strict, so `xs[9]`
and `m.missing` raise at the site of the mistake.

**2. Operational failures throw `{ kind, message, ... }` maps.** Anything that
fails because of the world - malformed data, a missing file, network trouble, a
closed channel, an exhausted budget - throws a map with a stable `kind`, a
human-readable `message`, and context fields.

**3. Programmer mistakes throw prose strings.** Wrong argument types, arity
errors, out-of-bounds indexing, undefined names. You fix these rather than
dispatch on them, and [`ecko check`](../cli/check.md) catches most before the
program starts.

**4. `Ok`/`Err` and `Some`/`None` are ordinary data types** for your own
match-based modelling. They are **not** the error channel; nothing in the standard
library returns them.

## The standard library's kinds

| kind | meaning | extra fields |
|---|---|---|
| `parse` | malformed JSON, CSV, TOML, YAML, regex | `format`, `path` |
| `fs` | file IO | `path` |
| `net` | HTTP, socket, WebSocket | `url`, `host` |
| `sql` | database errors | |
| `closed` | send on a closed channel | |
| `budget` | `ECKO_AI_MAX_CALLS` exhausted | `calls`, `max` |
| `capability` | package denied a gated operation | `capability`, `package` |
| `cancelled` | task cancellation | |

## Dispatching

```ecko fragment
try {
    data = json.decode(body)
} catch (e) {
    match get(e, "kind") {
        "parse" => print("bad {e.format} payload: {e.message}")
        "net"   => print("offline: {e.message}")
        _       => error(e)      # a panic or unknown kind: re-throw
    }
}
```

Use `get(e, "kind")` rather than `e.kind`. `get` is total, so the same match also
handles a plain-string error, where `kind` is `null`.

Re-throwing the default case is the important habit: a handler that swallows
everything turns a programmer mistake into silence.

## Errors are first-class values

`error(v)` throws **any** value, and `catch (e)` binds it. For your own
recoverable failures, throw a `{ kind, message }` map so callers dispatch on your
kinds exactly like the standard library's:

```ecko
fn find_user(id) {
    if id == 0 { error({ kind: "not_found", message: "no user 0" }) }
    id
}
```

A plain `error("boom")` is caught as the string `"boom"`. Uncaught errors render
`Runtime error: <message>`, using a map's `message` field when present.

## Secrets in errors

`error(secret(x))` renders redacted while `catch` still binds the wrapped value -
so an error path cannot leak a credential into a log. See
[Secrets](./secrets.md).
