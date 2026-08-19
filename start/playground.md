# Playground

**Try Ecko in the browser with no install**: [ecko.sh/play](https://ecko.sh/play)
runs the real kernel, compiled to WebAssembly, entirely client-side.

```ecko
# This runs exactly the same in the playground as it does on your machine,
# in mock mode
count = ai[Int] "Count the words in this sentence"
print(count)   # 42
```

The page fetches one WebAssembly module and runs your program in place -
there is no server, no account and no API key. Edit the code, click Run, and
the output appears below it. **Copy link** encodes the program into the URL,
so sharing a playground link is sharing the program itself.

## What runs

The core language, unmodified: pattern matching, pipelines, contracts, and
typed `ai` output, all evaluated by the same kernel that ships in the `ecko`
binary rather than a reimplementation. Every `ai` call answers from
deterministic mock mode - see [Mock mode](./mock-mode.md) for what each type
produces.

## What does not run

The playground is the language kernel with nothing installed around it:

- **No standard library.** The module links only the kernel, not `std`, so
  `import std.fs`, `import std.net`, `import std.sql` - any `std.*` module -
  fails with "no module found". There is no filesystem to read and no
  network to reach either way.
- **No package imports.** A playground program is a single file; there is no
  `vendor/` directory to resolve an import against.
- **`ai` is mock only.** There is no key to configure and no live provider to
  reach. Every call answers the same way `ecko test` does.
- **No `async fn`, no streaming `ai` (`-> stream`), and no channels.** The
  browser build has no threads, so the primitives that depend on one return a
  clear error instead of running.
- **`pmap` runs, but sequentially.** `pmap`'s contract is share-nothing, so a
  sequential pass produces the same result - only the parallelism is lost.
- **Contract-checked recursion is capped at 256 levels.** A function using
  `@requires` or `@ensures` recurses on the browser's own call stack, which
  is far smaller than a native one. Plain recursion is unaffected and keeps
  the usual 2000-level limit.

If the page reports that the runtime could not be loaded, the module itself
is temporarily missing rather than the page being broken - install Ecko
locally instead:

```bash
curl -fsSL https://ecko.sh/install | sh
```
