# `std.archive`

zip and tar containers: create, list, extract.

```ecko fragment
import std.archive

archive.zip_create("out.zip", ["src/", "README.md"])
archive.zip_extract("out.zip", "dest/")

for e in archive.zip_list("out.zip") {
    print("{e.name} ({e.size} bytes)")
}

archive.tar_create("out.tar.gz", ["src/"])    # gzip follows the filename
archive.tar_extract("out.tar.gz", "dest/")
```

[`std.zlib`](./zlib.md) compresses a byte string. This bundles a directory
tree into a container and takes it apart again.

## Capability

Reading an archive or the files going into one needs **`fs:read`**. Writing an
archive, or the tree an extraction produces, needs **`fs:write`**. See
[capabilities](../packages/capabilities.md).

`zip_create` and `tar_create` take a *list* of inputs, so the read check happens
against each one: a package scoped to `fs:read:./assets` cannot archive files
outside that directory.

## API

| call | result |
|---|---|
| `archive.zip_create(dest, inputs)` | Number of files written. `inputs` is a path or a list of them. |
| `archive.zip_extract(src, dest)` | Number of files extracted. |
| `archive.zip_list(src)` | `[{ name, size, dir }]` |
| `archive.tar_create(dest, inputs, opts?)` | Number of files written. |
| `archive.tar_extract(src, dest, opts?)` | Number of files extracted. |
| `archive.tar_list(src, opts?)` | `[{ name, size, dir }]` |

`opts` is `{ gzip: true }` or `{ gzip: false }`. Left out, gzip follows the
filename: `.tar.gz` and `.tgz` compress, anything else does not.

## Extraction refuses hostile entries

An archive entry name is chosen by whoever made the archive, and an entry named
`../../../.ssh/authorized_keys` writes outside the destination unless something
stops it. Extraction refuses:

- any `..` component,
- absolute paths,
- Windows drive prefixes.

These are **refused, not sanitised**. Quietly rewriting a hostile path to a safe
one still extracts an archive that lied about where its contents would go, and
leaves the caller believing it got what the archive claimed.

A tar can also carry symlinks and hard links, whose targets are paths that get
followed later by something that is not us. Those entries are skipped.

Extraction is capped at `ECKO_ARCHIVE_MAX_UNPACKED` bytes (default 1 GiB) on the
running total. Deflate amplifies roughly 1000:1, so a few-KB archive can expand
until the disk or the OOM killer stops it, and the cheap version of that attack
is a million small files rather than one big one.

## Entry names

Names inside the archive are relative, rooted at the input's last component:

```ecko fragment
archive.zip_create("out.zip", ["/srv/app/src"])   # entries: src/...
archive.zip_create("out.zip", ["src/"])           # entries: src/...
```

Both produce the same archive. Storing the absolute path would put a name in the
archive that extraction then refuses, so the archive would be unextractable by
the tool that wrote it. `tar` and `zip` on the command line strip the leading
`/` for the same reason.

Entries are sorted, so the same tree produces the same archive rather than
depending on directory iteration order.
