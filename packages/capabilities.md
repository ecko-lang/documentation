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

## Attenuation

Grants only ever narrow going down the tree. A package holds the set its importer
gave it, and can pass on **a subset** of what it holds - never more. A dependency
three levels deep cannot acquire `net` because it asked nicely; the chain from
your program down to it must grant `net` at every step.

Root code - the program you ran - holds full authority. That asymmetry is the
point: your own code is not sandboxed from itself, and everything you did not
write is.

## How it is enforced

Every package function carries its effective capability set. Gated native
functions check the set of the call currently in progress, which the evaluator
swaps per call. There is no way to reach a gated primitive that does not go
through that check, because the check is in the primitive rather than in a
wrapper a package could route around.

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
