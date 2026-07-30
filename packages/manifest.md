# The `ecko.json` manifest

```bash
ecko init      # scaffold one
```

```json
{
  "module": "github.com/ecko-lang/url",
  "version": "0.9.4",
  "entrypoint": "main.ecko",
  "description": "URL parsing, query strings, and reference resolution.",
  "license": "MIT",
  "capabilities": [],
  "dependencies": {}
}
```

## Fields

| field | meaning |
|---|---|
| `module` | The package's identity, normally its forge path. This is what `ecko get` resolves. |
| `version` | Semantic version. A release workflow asserts the git tag matches it. |
| `entrypoint` | The file loaded on import. Defaults to `main.ecko`. |
| `description` | One line. It appears in generated documentation. |
| `author`, `license` | Metadata. |
| `capabilities` | What the package expects to need. **Advisory** - see below. |
| `dependencies` | What it imports, and what each is granted. |
| `environment` | Environment variables to apply before the program runs. |

Any other field is yours. The whole manifest is readable from the program as
[`std.defaults`](../stdlib/defaults.md), which is why an app manifest often
carries `port`, `db_path` and similar - configuration with no parsing code.

Keys must be valid identifiers, because they are read as `defaults.<key>`. A key
with a dash is an error rather than a value you cannot reach.

## `capabilities` is advisory

The list documents intent. **What a package actually gets is the `grant` its
importer gives it**, and nothing else. A manifest asking for `net` in a project
that grants nothing gets nothing.

Keep it honest anyway: it is what a reader checks first, and `[]` is a genuine
claim worth making - it says this package cannot touch the network, the
filesystem or the environment.

## Dependencies

```json
{
  "dependencies": {
    "url": "github.com/ecko-lang/url@v0.9.4",
    "mysql": {
      "path": "github.com/ecko-lang/mysql-client",
      "version": "v0.9.4",
      "grant": ["net"]
    }
  }
}
```

The short form is a string. The long form adds `grant`, and is also how you
choose the **import name**: the key is what `import` binds. That matters when a
repository name is not a valid identifier - `mysql-client` cannot be an Ecko
identifier, so it is aliased to `mysql`.

## Name and directory must agree

`import foo` reads `vendor/.../foo/ecko.json` and errors if the manifest
disagrees with the directory it was found in. This is why a repository named for
its forge slug declares the import name its users will type.

A malformed manifest is a hard error, not a silent zero-grant. Failing loudly
was a deliberate change: a typo used to produce a package that mysteriously could
not do anything.

## `environment`

```json
{ "environment": { "ECKO_AI_PROVIDER": "ollama", "ECKO_MAX_DEPTH": "5000" } }
```

Applied before evaluation, and it **overrides the surrounding shell** - the
opposite precedence to `std.config`. The reason is that this block exists so a
project can pin the environment its code expects, which it cannot do if whatever
happens to be exported wins. Machine-specific values belong in the shell, not
here. Never put a secret in it.
