# `std.os`

The host environment and process. `env` and `exec` are gated for
[package](../packages/capabilities.md) code.

```ecko fragment
import std.os

os.env("HOME")                  # null when unset
os.env_or("PORT", "8080")
os.set_env("TZ", "UTC")

os.args()                       # arguments after the script
os.cwd()
os.platform()                   # "linux" | "macos" | "windows"
os.arch()                       # "x86_64" | "aarch64"
os.family()
os.script()                     # the running file

r = os.exec("git", ["status", "--short"])
print(r.code)  print(r.stdout)  print(r.stderr)

os.exit(1)
```

## `env` returns null

One of the three documented nullable lookups in the
[error dialect](../language/error-handling.md) - absence is expected for an
environment variable. `env_or` supplies a default in one call.

Wrap anything sensitive immediately:

```ecko fragment
key = secret(os.env("API_KEY"))
```

See [Secrets](../language/secrets.md). A credential read into a plain string can
reach a log line; wrapped, it cannot.

## `exec`

Returns `{ code, stdout, stderr }` and does **not** raise on a non-zero exit -
check `code` yourself. That is deliberate: for many commands a non-zero status is
information rather than a failure.

```ecko fragment
r = os.exec("which", ["ecko"])
if r.code != 0 { install() }
```

**Arguments are a list, and they are not shell-interpreted.** There is no shell
involved, so no quoting rules and no injection through argument values:

```ecko fragment
os.exec("git", ["log", "--grep", user_input])     # safe
```

If you route through a shell yourself - `os.exec("sh", ["-c", cmd])` - you take
that safety back off. Avoid building `cmd` from anything you did not write.

## `exit`

Ends the process with a status. `finally` blocks do not run, so close what needs
closing first. Prefer returning from `main` logic where you can, so cleanup
happens.

## Portability

Check `platform()` rather than assuming. Path separators come from
[`fs.join`](./fs.md); do not hardcode `/`.
