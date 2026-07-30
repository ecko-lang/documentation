# `std.fs`

Files and directories. Gated on `fs:read` and `fs:write` for
[package](../packages/capabilities.md) code; root code has full authority.

```ecko
import std.fs

fs.read("notes.txt")            # string
fs.read_bytes("logo.png")       # bytes
fs.write("out.txt", text)
fs.append("log.txt", line)

fs.exists(p)  fs.is_file(p)  fs.is_dir(p)
fs.list_dir(dir)                # names
fs.walk(dir)                    # recursive entries
fs.glob("src/**/*.ecko")

fs.mkdir(p)  fs.copy(a, b)  fs.rename(a, b)  fs.remove(p)
```

## Text or bytes

`read` returns a string and **errors on invalid UTF-8**. `read_bytes` returns
[bytes](../language/bytes.md) and always works. Use `read_bytes` for anything that
is not certainly text - the strict default is what stops a binary file from
becoming a string full of replacement characters.

## Paths

`fs.join(a, b)`, `fs.basename(p)`, `fs.dirname(p)`, `fs.extension(p)` - and
`fs.path(...)` for building one. Use these rather than concatenating with `"/"`, so
the code works on Windows too.

## Walking and matching

`list_dir` is one level; `walk` recurses and yields entries with `path` and
`is_dir`. `glob` takes a pattern with `*` and `**`, and `fs.match(pattern, path)`
tests one path against a pattern.

```ecko
for entry in fs.walk("src") {
    if not entry.is_dir and fs.extension(entry.path) == "ecko" { check(entry.path) }
}
```

## Temporary files

```ecko
dir = fs.temp_dir()
f = fs.temp_file()
```

`temp_file` gives a unique path in the system temporary directory. Nothing cleans
up after you - remove what you create.

## Errors

Everything raises `{ kind: "fs", path, message }` on failure. The `path` field is
there so a handler can report *which* file, which is the thing you always want and
often lose:

```ecko
try { data = fs.read(p) } catch (e) {
    match get(e, "kind") { "fs" => print("cannot read {e.path}") _ => error(e) }
}
```

## Paths from untrusted input

**A path built from user input can escape the directory you meant.** `../../etc/passwd`
is a path. If a request names a file, validate it - or better, do not use
`fs` for it at all: [`web.static`](./web.md) resolves safely and is the right tool
for serving files.

Capabilities help but are not a path sandbox: `fs:read` grants reading, not reading
*within a directory*.
