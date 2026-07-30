# `std.config`

Layered configuration: **environment wins over file, file wins over default.**

```ecko
import std.config

cfg = config.load({
    file: "config.toml",
    defaults: { port: 8080, host: "127.0.0.1" },
    env_prefix: "APP_",
    secrets: ["db_password"],
})

print(cfg.port)                 # APP_PORT, else the file, else 8080
sql.connect("...{reveal(cfg.db_password)}...")
```

Needs `env` and `fs:read` for [package](../packages/capabilities.md) code.

## The precedence, and why this way round

Environment beats file because a deployment must be able to override what a
checked-in file says without editing it. That is the standard shape for a service.

**This is the opposite of [`std.defaults`](./defaults.md)**, where the `environment`
block in `ecko.json` overrides the shell. The two answer different questions:

| | precedence | for |
|---|---|---|
| `std.config` | env > file > default | a deployed service reading its settings |
| `std.defaults` | file > env | a project pinning the environment its code needs |

Use `config` for runtime settings that vary by environment; use `defaults` for
project facts that should be the same everywhere.

## Secret fields

Names listed in `secrets` arrive already wrapped in
[`secret`](../language/secrets.md), so they render as `[secret]` through printing,
logging and tracing, and need `reveal` to use. Declaring them is one line and it
removes a whole class of accidental credential leak.

## Environment names

`env_prefix` plus the uppercased key: `port` reads `APP_PORT` with the prefix
above. A prefix is worth setting - it stops a generic name like `PORT` from being
picked up from an unrelated part of the environment.

## Types come from the defaults

A value from the environment is text. The defaults map tells `config` what type to
coerce to, so `port` is an `int` because `8080` is. A default is therefore worth
providing for every key, even where you expect it always to be set.

## Errors

A missing file is an error unless a default covers everything; a malformed one
raises `{ kind: "parse" }` with the format and path. Validate at startup and fail
loudly - a service that starts with half its configuration is worse than one that
refuses to start.
