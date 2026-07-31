# Install

One command, one binary, nothing to configure.

```bash
curl -fsSL https://ecko.sh/install | sh
```

The installer detects your platform, downloads the matching archive, **verifies
its SHA-256 before unpacking**, and puts `ecko` on your `PATH`. It makes no API
calls and needs no account.

## What you get

A single static binary. No runtime to install, no package manager, no
`node_modules`, no virtualenv. The standard library is compiled in: `import
std.http` gives you an HTTP server, `import std.sql` gives you SQLite.

## Supported platforms

| platform | architectures |
|---|---|
| Linux | x86-64, arm64 |
| macOS | Apple Silicon |
| Windows | x86-64 |

Intel Macs are not supported. An Apple Silicon binary cannot run on one, and
Rosetta translates the other direction, so there is nothing to fall back to.

The Linux builds link OpenSSL statically and are compiled against an old glibc,
so they run on distributions considerably older than the build machine.

## Manual install

If you would rather not pipe a script to a shell, the archives are plain
downloads:

```
https://ecko.sh/dl/latest/ecko-x86_64-linux.tar.gz
https://ecko.sh/dl/latest/ecko-aarch64-linux.tar.gz
https://ecko.sh/dl/latest/ecko-aarch64-macos.tar.gz
https://ecko.sh/dl/latest/ecko-x86_64-windows.zip
```

Each has a `.sha256` beside it:

```bash
curl -fsSLO https://ecko.sh/dl/latest/ecko-x86_64-linux.tar.gz
curl -fsSLO https://ecko.sh/dl/latest/ecko-x86_64-linux.tar.gz.sha256
shasum -a 256 -c ecko-x86_64-linux.tar.gz.sha256
tar -xzf ecko-x86_64-linux.tar.gz
sudo install -m 0755 ecko /usr/local/bin/ecko
```

On Windows, unzip and move `ecko.exe` somewhere on your `PATH`.

## Pinning a version

Swap `latest` for a tag:

```
https://ecko.sh/dl/v0.9.5/ecko-x86_64-linux.tar.gz
```

`https://ecko.sh/dl/latest.txt` names the tag that `latest` currently points at,
which is what to read from a script that wants to detect upgrades.

## Check it worked

```bash
ecko --version
```

Then [write your first program](./first-program.md).

## Upgrading and removing

Re-run the install command to upgrade; it overwrites in place. To remove Ecko,
delete the binary. There is nothing else on disk: no registry, no cache
directory, no configuration file. A project's `vendor/` directory belongs to the
project, not the toolchain.
