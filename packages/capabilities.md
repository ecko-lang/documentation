# Capabilities & gating

A package cannot decide what it is allowed to do. The importer decides.

```json
{
  "dependencies": {
    "mysql": { "path": "github.com/ecko-lang/mysql-client", "grant": ["net"] }
  }
}
```

Without that grant, every gated call in the package fails - not silently, and not
at import time, but at the call, with a message naming the missing capability.

## The capabilities

| capability | permits |
|---|---|
| `net` | Sockets, HTTP, DNS, TLS, provider calls |
| `fs:read` | Reading files and listing directories |
| `fs:write` | Creating, writing, renaming and deleting |
| `env` | Reading and setting environment variables |
| `exec` | Running other programs |

`[]` means pure computation: string handling, maths, parsing, data structures.
Most of the official packages are pure, which is a meaningful claim - a pure
package cannot exfiltrate anything, because it has no way to reach out.

## Confining a package to one directory

`fs:read` and `fs:write` take an optional path scope - everything after the
second colon:

```json
{
  "dependencies": {
    "logger": { "path": "github.com/acme/logger", "grant": ["fs:write:./logs"] }
  }
}
```

That package can write `./logs`. It cannot write anywhere else, and "anywhere
else" is a longer list than it first appears: an unscoped `fs:write` also covers
`~/.ssh/authorized_keys`, and on a Linux box it covers `/sys/class/gpio/export`,
which is how you close a relay. A capability that cannot tell a log file from a
piece of hardware is not saying much.

Reach for a scope whenever you know where a package should be working, which is
most of the time.

- A relative scope resolves against the directory holding the `ecko.json` that
  wrote it, so `./logs` means the same thing however the program is launched.
  Absolute scopes work too.
- Two directories are two entries:
  `["fs:read:/etc/myapp", "fs:read:/var/lib/myapp"]`.
- Scopes compare by path component, so `./data` does not cover `./data-backup`.
- Neither `..` nor a symlink inside an allowed directory escapes a scope: the
  path is made absolute and symlink-resolved before it is checked.
- A glob is checked against its literal prefix, so `fs.glob("/etc/**/*.conf")`
  needs read on `/etc`.
- `net`, `env` and `exec` take no scope. `net:example.com` is an error rather
  than a grant that quietly does nothing.

Two things to expect once a package is scoped. `fs.copy(src, dst)` needs read on
the source as well as write on the target, and `fs.rename` needs write on both
ends. `fs.temp_file` and `fs.temp_dir` write into the system temp directory, so a
scoped package that makes temp files needs `fs:write` covering it.

## Attenuation

Grants only ever narrow going down the tree. A package holds the set its importer
gave it, and what it passes on is **clamped to that set** - never more. A
dependency three levels deep cannot acquire `net` because it asked nicely; the
chain from your program down to it must grant `net` at every step.

Clamping is what makes path scopes work more than one level down. A package in
`vendor/` cannot know the absolute paths you chose, so it writes the plain
`"grant": ["fs:read"]` - "this dependency reads files" - and its dependency
receives whatever *you* allowed, narrowed to your scope. Naming a directory it
was never granted is still an error, raised at import rather than at the call.

Root code - the program you ran - holds full authority. That asymmetry is the
point: your own code is not sandboxed from itself, and everything you did not
write is.

## How it is enforced

Every package function carries its effective capability set. Gated native
functions check the set of the call currently in progress, which the evaluator
swaps per call. There is no way to reach a gated primitive that does not go
through that check, because the check is in the primitive rather than in a
wrapper a package could route around.

When a scope is involved, the check also sees the path. A denial then names it:

```
package 'logger' attempted fs.write on '/etc/passwd' outside its
granted scope (fs:write:/srv/app/logs)
```

Caught as an Ecko error, that is `{ kind: "capability", capability, package,
path }`.

## Reading a package's claims

A manifest's `capabilities` list is advisory - it says what the author expects to
need. It is still the first thing to read, because a mismatch between the claim
and the grant a package asks you for is worth a second look. A text-formatting
library that wants `net` deserves a question.

Generated API references for the official packages state the declared set at the
top of the page.

## Practical shape

Grant the minimum that makes the package work, and grant it per dependency
rather than globally:

```json
{
  "dependencies": {
    "textwrap": "github.com/ecko-lang/textwrap",
    "smtp": { "path": "github.com/ecko-lang/smtp-client", "grant": ["net"] }
  }
}
```

Here the formatter cannot open a socket and the mail client cannot read your
files. Neither restriction requires trusting either package.

Where a package needs the filesystem, say where:

```json
{
  "dependencies": {
    "cache": { "path": "github.com/acme/cache", "grant": ["fs:write:./var/cache"] }
  }
}
```
