# Lockfile & integrity

`ecko get` writes two things: the package into `vendor/`, and a hash into the
lockfile.

```bash
ecko get github.com/ecko-sh/url
```

## What is pinned

A SHA-256 over the fetched file tree, per dependency, with the resolved version.
`ecko install` rebuilds `vendor/` from those pins and **fails if what it fetches
does not match**. A dependency cannot change under you without the lockfile
changing, and a lockfile change is a diff in a review.

## Commit `vendor/`

The recommended default, and the reason the design vendors rather than installs:
a project with `vendor/` committed builds with no network, no registry, and no
resolution step, indefinitely. There is no service whose outage stops your build
and no version that can be yanked out from under you.

The cost is repository size. For pure-Ecko packages, which is what these are,
that cost is small - they are source files.

If you would rather not commit it, commit the lockfile and run `ecko install`.
You then depend on the forge being reachable at build time.

## Commands

| command | effect |
|---|---|
| `ecko get <path>[@version]` | Fetch, vendor, pin |
| `ecko install` | Rebuild `vendor/` from the lockfile, verifying hashes |
| `ecko update [name...]` | Re-fetch, re-pin, refresh the lockfile |
| `ecko remove <name>` | Unvendor and unpin |

`update` is the only one that changes what a pin means, which is why it is
separate from `install`.

## Fetch safety

Fetching is where a program first trusts something it did not write, so the
defaults are conservative:

- **https only.** A plain-http source from a non-loopback host is refused.
  `ECKO_ALLOW_HTTP=1` opts out, and exists for a local registry.
- **Size caps** before unpacking: 50 MiB downloaded, 200 MiB unpacked
  (`ECKO_PKG_MAX_BYTES`, `ECKO_PKG_MAX_UNPACKED`). An archive that expands
  without bound is refused rather than filling the disk.
- **Hash before use.** The tree is verified against the pin before anything is
  imported.
- **Private sources** via `ECKO_NET_TOKEN` for the bearer token and
  `ECKO_GIT_BASE` to point at a mirror.

## What a lockfile does not do

It pins bytes, not behaviour. A package that has permission to reach the network
can behave differently on different days regardless of its hash, which is what
[capabilities](./capabilities.md) are for. Pinning and granting answer different
questions, and you want both.
