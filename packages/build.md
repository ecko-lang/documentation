# Building an executable

```bash
ecko build app.ecko            # -> ./app
ecko build app.ecko -o server  # choose the name
```

Produces a single self-contained executable: the interpreter and your program in
one file, with no Ecko installation required on the target.

## What ends up inside

Your program, the modules it imports, its `vendor/` tree, and the runtime. The
standard library is already part of the binary, so a program that serves HTTP and
queries SQLite has no external dependency to install.

## What it is for

Handing someone a tool. A colleague, a container, a machine you do not control:
one file, `chmod +x`, run. No language to install, no version to match, no
`pip install` step that fails in six months.

## What it is not

Not a compiler to native code. The program is still interpreted by the bundled
runtime, so `ecko build` changes distribution, not performance. A program does
not get faster by being built.

Not a cross-compiler either. The output runs on the platform you built it on.
Build on Linux for Linux, on macOS for macOS - which for CI means a job per
target.

## Size

The runtime is the floor, so a five-line program and a five-thousand-line program
produce executables of similar size. If size matters more than convenience, ship
the script and install `ecko` once.

## Containers

For a server, a container is usually the better unit than a bare executable -
same self-containment, plus the surrounding environment. See
[Docker](./docker.md).
