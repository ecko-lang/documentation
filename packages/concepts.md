# Package concepts

A package is a directory of Ecko source with an `ecko.json` manifest. There is no
central registry to publish to, no build step, and nothing native to compile: a
package is code you can read.

```ecko fragment
import url                    # resolves to ./vendor/.../url
```

## Vendored, not installed

`ecko get` copies a package into `vendor/` in your project and records a hash.
Nothing is installed globally, so:

- Two projects on one machine can use different versions with no interaction.
- Commit `vendor/` and your project builds forever, offline, with no network and
  no registry. That is the recommended default.
- Deleting `vendor/` and running `ecko install` reproduces it exactly from the
  lockfile.

There is no cache directory in your home folder that can drift out of step with
what you committed.

## Resolution

A bare `import name` looks for a dependency named `name` in your `ecko.json` and
loads the vendored directory it points at, reading that directory's own
`ecko.json` for its entrypoint. A quoted `import "./file.ecko"` is a plain
relative path and never touches `vendor/`.

Fetching resolves straight from the forge - `ecko get github.com/owner/repo` -
so there is no index to be up or down, and no name to squat.

## Capabilities

A package cannot decide what it is allowed to do. **The importer grants
capabilities, and a package can only pass on what it already holds:**

```json
{
  "dependencies": {
    "mysql": { "path": "github.com/ecko-lang/mysql-client", "grant": ["net"] }
  }
}
```

Without `"grant": ["net"]`, that client cannot open a socket, no matter what its
own manifest claims. Root code - the program you ran - holds full authority. See
[Capabilities & gating](./capabilities.md).

## The three layers

Ecko is deliberate about where new functionality goes.

| layer | what it is | how it changes |
|---|---|---|
| **Kernel** | The language: lexer, parser, VM, `ai`, contracts | Frozen. Additions need language-change rigour. |
| **`std.*`** | Native primitives that need a syscall or FFI: sockets, files, SQLite, TLS | Only with a syscall or FFI justification. |
| **Packages** | Everything else, written in Ecko | Freely. Portable, capability-gated, deletable. |

Most new capability belongs in the third layer, and the official packages are
that layer made concrete: a MySQL client written in Ecko over raw sockets, a
validator library, a web framework. They are ordinary packages with no privileged
access - you could have written any of them, and you can replace any of them.

## What a package looks like

```
url/
  ecko.json          manifest
  main.ecko          entrypoint
  example.ecko       runnable demonstration
  README.md
  LICENSE
  tests/url_test.ecko
```

Only `export`-marked definitions are public. A multi-file package curates its
surface in the entrypoint by re-exporting from siblings - see
[Modules & imports](../language/modules.md).

## Next

- [The `ecko.json` manifest](./manifest.md)
- [Capabilities & gating](./capabilities.md)
- [Lockfile & integrity](./lockfile.md)
- [Package commands](./commands.md)
