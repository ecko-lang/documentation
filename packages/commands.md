# Package commands

```bash
ecko init                                  # scaffold ecko.json
ecko get github.com/ecko-sh/url            # fetch, vendor, pin
ecko get github.com/ecko-sh/url@v0.9.4     # a specific version
ecko install                               # rebuild vendor/ from the lockfile
ecko update [name...]                      # re-fetch and re-pin
ecko remove url                            # unvendor and unpin
ecko pack [-o out.zip]                     # bundle for distribution
ecko build file.ecko [-o app]              # single-file executable
```

## `init`

Writes an `ecko.json` in the current directory. A program never needs one -
[a file is a program](../start/a-file-is-a-program.md) - but a manifest gives it
a name and version, a place for dependencies, and configuration readable as
[`std.defaults`](../stdlib/defaults.md).

## `get`

Resolves straight from the forge; there is no index in the way.

```bash
ecko get github.com/ecko-sh/redis-client@v0.9.4
```

It vendors under `vendor/`, records the dependency, and pins a hash. If the
repository name is not a valid Ecko identifier - `redis-client` has a dash - set
the import name yourself in the manifest, along with any grant it needs:

```json
{ "dependencies": { "redis": { "path": "github.com/ecko-sh/redis-client", "grant": ["net"] } } }
```

## `install`

Rebuilds `vendor/` from the lockfile and verifies every hash. This is the CI and
fresh-clone command. It never changes a pin.

## `update`

Re-fetches, re-pins, rewrites the lockfile. The only command that moves a
version, deliberately separate from `install` so a build cannot silently upgrade.

## `remove`

Deletes the vendored copy and its manifest and lockfile entries. Because there is
no global store, removing really removes it.

## `pack`

```bash
ecko pack -o myapp.zip
```

A deterministic archive of the project and its `vendor/` - same input, same
bytes, so it can be checksummed and compared. This is how a package is published:
a release workflow packs it and attaches the archive to a tag.

## `build`

```bash
ecko build server.ecko -o server
```

Bundles the interpreter and your program into one executable with no runtime
dependency. See [Building an executable](./build.md).

## `ecko add` no longer exists

It was renamed to `get` when resolution moved to the forge. If you find `ecko
add` in a guide, the guide is stale.
