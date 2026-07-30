# Ecko

**The language where `ai` is a keyword, not an import.**

Ecko is a programming language for the AI era - built in Rust, designed for
human-AI collaboration. It pairs expression-oriented syntax with first-class LLM
primitives, pattern matching, pipelines, contracts, and share-nothing
concurrency, all in one static binary.

```ecko
# Call an LLM directly - no imports, no setup
result = ai "What is the capital of France?"
print(result)

# Typed output maps straight to your types
count = ai[Int] "Count the words in this text"
print(count)

# Pipe data through LLM calls
text = "Meet me on 12 March and again on 4 April."
dates = text |> ai "Extract all dates" |> ai "Format as ISO 8601"
print(dates)
```

Every `ai` call above runs offline in deterministic **mock mode** with no API
key - so the whole program is runnable and testable before you configure a
single provider.

> **It just works - one step, zero config, offline.** Installing drops in a
> single binary with nothing to configure. Running is just `ecko file.ecko` -
> no project to set up, no `package.json`, no `Cargo.toml`. A file is a program.
> Without an API key, everything still runs in mock mode: typed calls return
> schema-valid values (`ai[Int]` -> `42`), so your pipelines, contracts, and
> tool calls all keep working. The standard library is already there -
> `import std.http` gives you an HTTP server, `import std.sql` gives you SQLite -
> with no `apt install`, no `pip install`, no `cargo add`.

---

## Quick start

Install Ecko - one command, a single binary, nothing to configure:

```bash
curl -fsSL https://ecko.sh/install | sh
```

The installer picks the right build for your machine, checks its checksum, and
puts `ecko` on your `PATH`. Prebuilt binaries ship for:

| platform | |
|---|---|
| Linux | x86-64, arm64 |
| macOS | Apple Silicon |
| Windows | x86-64 |

Intel Macs are not supported - an Apple Silicon binary cannot run on one.

Prefer a manual install? Download the archive for your platform and put the
binary on your `PATH`:

```
https://ecko.sh/dl/latest/ecko-x86_64-linux.tar.gz
https://ecko.sh/dl/latest/ecko-aarch64-linux.tar.gz
https://ecko.sh/dl/latest/ecko-aarch64-macos.tar.gz
https://ecko.sh/dl/latest/ecko-x86_64-windows.zip
```

Each has a `.sha256` beside it, so you can verify before unpacking:

```bash
curl -fsSLO https://ecko.sh/dl/latest/ecko-x86_64-linux.tar.gz
curl -fsSLO https://ecko.sh/dl/latest/ecko-x86_64-linux.tar.gz.sha256
shasum -a 256 -c ecko-x86_64-linux.tar.gz.sha256
```

To pin a version, swap `latest` for the tag - `https://ecko.sh/dl/v0.9.4/...`;
`https://ecko.sh/dl/latest.txt` says which tag `latest` currently is.

Run a file, or start the REPL:

```bash
ecko examples/hello.ecko   # run a file
ecko                       # start the REPL (or `ecko repl`)
```

Your first program is one line:

```ecko
print("Hello, AI World!")   # Hello, AI World!
```

And the `ai` keyword needs no setup - it runs in mock mode until you add a key:

```ecko
# Typed output; runs offline in mock mode (a real key returns a real answer)
count = ai[Int] "Count the words in this sentence"
print(count)   # 42
```

Set `ECKO_API_KEY` for real responses, and `ECKO_AI_PROVIDER` to switch between
`openai` (default), `anthropic`, and `ollama`. Configuration is always through
## Start here

- **Installing?** The one-liner is at the top of this page; the full set of
  archives and checksums is on [the download page](https://ecko.sh/download).
- **Kicking the tyres?** Every `ai` call runs offline in mock mode, so a
  program is testable before you configure a provider.
- **Looking for a package?** The [official packages](#official-packages) below
  are written in Ecko, capability-gated, and installed with `ecko get`.

---

# Reference

Every page below is written. The documentation covers the language, the
`ai` keyword, concurrency, the standard library, packages, the CLI and the
runtime's architecture.

## Getting started

- [Install](./start/install.md) - the `curl | sh` one-liner, the platform archives, and verifying a checksum
- [A file is a program](./start/a-file-is-a-program.md) - no project scaffolding, ever
- [Your first program](./start/first-program.md) - hello world to a typed `ai` call
- [The REPL](./start/repl.md) - interactive sessions, multi-line input
- [Mock mode](./start/mock-mode.md) - how Ecko runs fully offline with no API key
- [Editor support](./start/editors.md) - the VS Code grammar and the language server

## Language

- [Statements & syntax](./language/statements.md) - newline-terminated statements, comments, continuation rules
- [Comments & documentation](./language/comments.md) - `#` comments, `##` doc comments, the `example:` convention
- [Variables & mutability](./language/variables.md) - `let` / `const` / `mut`, bare assignment, shadowing, no silent nulls
- [Assignment through fields & indexes](./language/assignment.md) - `user.name = ...`, `user.tags[0] = ...`
- [Destructuring bindings](./language/destructuring.md) - `let (a, b) = pair`, `mut (x, y) = ...`, the `(x, y) = [y, x]` swap
- [Values & types](./language/types.md) - `null`, `bool`, `int`, `float`, `decimal`, `string`, `bytes`, `list`, `map`, `struct`
- [Numbers](./language/numbers.md) - checked-overflow `int`, IEEE-754 `float`, exact `decimal` (`19.99m`)
- [Bytes](./language/bytes.md) - `b"..."` literals, the text-to-bytes boundary, JSON base64
- [Type definitions](./language/type-definitions.md) - `type Shape = Circle { r: Int } | Square { ... }`, call-style constructors
- [Bitwise & word operators](./language/bitwise.md) - `band`, `bor`, `bxor`, `shl`, `shr`, `bnot`
- [Functions & lambdas](./language/functions.md) - `fn`, `|x| ...`, defaults, named arguments, closures, `async` lambdas
- [Pipelines](./language/pipelines.md) - `|>`, the loosest-binding operator, feeding data through calls
- [Control flow](./language/control-flow.md) - `if` / `unless`, `for ... in`, ranges, `while`, `loop`, `break` / `continue`, for-destructuring
- [Pattern matching](./language/pattern-matching.md) - literals, guards (`when`), variant and map/struct patterns, `_`
- [Error handling & the error dialect](./language/error-handling.md) - `try` / `catch` / `finally`, `error(v)`, the four rules, error `kind`s
- [Strings & interpolation](./language/strings.md) - `"{expr}"`, triple-quoted, raw strings `r"..."`
- [Templates](./language/templates.md) - `template name(...) = """..."""`, `{for}` / `{if}` / `{input}` directives
- [Structured data access](./language/data-access.md) - strict `xs[i]` / `m.key` vs nullable `get(m, k)`, slices, negative indices
- [Secrets](./language/secrets.md) - `secret(v)`, `reveal(v)`, `is_secret(v)`, structural redaction
- [Modules & imports](./language/modules.md) - `import std.*`, `import "./util"`, the `export` modifier (private by default), re-export (`export * from`, `export import`), circular-import detection
- [Resource limits](./language/limits.md) - recursion, parse depth, step budgets; adversarial input degrades to a catchable error

## The `ai` keyword

- [`ai` and typed output](./ai/typed-output.md) - `ai "..."`, `ai[Int]` / `ai[Bool]` / `ai[Enum]` / `ai[Struct]` / `ai[json<...>]`, schema coercion
- [Mock mode](./ai/mock-mode.md) - deterministic schema-valid values with no key; how tests stay offline
- [Contracts](./ai/contracts.md) - `@requires` / `@ensures`, boolean *and* natural-language, self-correcting retries
- [Majority voting](./ai/voting.md) - `ai[T] n "..."` runs `n` samples and takes the mode
- [Tool calling](./ai/tools.md) - `@tool("...")` functions, `ai[T] "..." using [f, g]`, the runtime tool loop
- [Sessions](./ai/sessions.md) - `session()` and `ai "..." with chat` for multi-turn conversations
- [Multimodal / vision](./ai/multimodal.md) - `ai "..." on img`, image handles, provider serialization
- [Embeddings & RAG](./ai/embeddings.md) - `embed`, `embed_all`, `cosine`; `std.db` and `std.rag`
- [Streaming](./ai/streaming.md) - `ai "..." -> stream`, live SSE tokens, consuming a stream
- [Token budgeting](./ai/budgeting.md) - `tokens(text)`, `cost(model, in, out)`, hard call caps
- [Retry](./ai/retry.md) - `retry(n, f)` with exponential backoff for any failing operation
- [Providers & configuration](./ai/providers.md) - OpenAI / Anthropic / Ollama, swap with one env var
- [Caching](./ai/caching.md) - content-addressed prompt cache, replayable, budget-free
- [Tracing](./ai/tracing.md) - `ECKO_TRACE` JSONL: every call's provider, model, tokens, latency, retries

## Concurrency and async

- [`pmap`](./concurrency/pmap.md) - data-parallel map over a bounded worker pool
- [`cell` - shared state](./concurrency/cell.md) - `cell`, `cell_get`, `cell_set`, `cell_update` (atomic read-modify-write)
- [Async tasks](./concurrency/async.md) - `async fn` / `await`, spawning tasks, error propagation, `cancel`
- [Channels](./concurrency/channels.md) - `channel` (bounded/unbounded), `send`, `recv`, `try_recv`, `close`, `select`
- [Streaming responses & SSE](./concurrency/streaming.md) - HTTP handlers that stream from a channel
- [Background tasks](./concurrency/background.md) - `std.bg`: `spawn`, `status`, `result`, `after`, `every`, `join_all`

## Standard library

- [`std.string`](./stdlib/string.md) - the full UTF-8 string toolkit (`upper`, `split`, `replace`, `pad_*`, `trim`, ...)
- [`std.math`](./stdlib/math.md) - constants (`pi`, `e`, `tau`) and float functions (`sin`, `sqrt`, `log`, `clamp`, ...)
- [`std.io`](./stdlib/io.md) - `print` and basic I/O
- [`std.fmt`](./stdlib/fmt.md) - `format` (raw-string `{}` placeholders), `pad_left`, `pad_right`, `truncate`
- [`std.uuid`](./stdlib/uuid.md) - `v4` (random) and `v7` (time-ordered) UUIDs
- [`std.cli`](./stdlib/cli.md) - declarative arg parsing: `parse(spec, argv)`, `help(spec)`
- [`std.random`](./stdlib/random.md) - seedable RNG plus a CSPRNG (`bytes`, `token`)
- [`std.test`](./stdlib/test.md) - `case`, `eq`, `ok`, `err`, `fail` for the test runner
- [`std.time`](./stdlib/time.md) - `now`, `now_iso`, `monotonic`, `format`, `parse`
- [`std.re`](./stdlib/re.md) - regex: `test`, `find`, `find_all`, `captures`, `split`, `replace`
- [`std.hash`](./stdlib/hash.md) - `sha256`, `hmac_sha256`, `sha1`, and Argon2id `password` / `verify`
- [`std.encoding`](./stdlib/encoding.md) - base64, hex, and URL encode/decode (`*_decode_text` variants)
- [`std.term`](./stdlib/term.md) - colors, styles, cursor control, TTY info, key input (honors `NO_COLOR`)
- [`std.debug`](./stdlib/debug.md) - `inspect` (secret-safe), `type`, `timer`, `elapsed`
- [`std.humanize`](./stdlib/humanize.md) - `duration`, `size`, `relative`, `ordinal`, `plural`
- [`std.zlib`](./stdlib/zlib.md) - `gzip`, `gunzip`, `deflate`, `inflate` over bytes
- [`std.fs`](./stdlib/fs.md) - files and directories (`read`, `write`, `list_dir`, `copy`, `rename`, ...) - `fs:read` / `fs:write`
- [`std.os`](./stdlib/os.md) - host environment and process: `env`, `env_or`, `set_env`, `args`, `cwd`, `platform`, `exec`, `exit` (`env` / `exec` gated)
- [`std.json`](./stdlib/json.md) - `encode`, `decode`, `read`, `write`
- [`std.csv`](./stdlib/csv.md) - `parse`, `stringify`, `read`, `write` (rows as column-keyed maps)
- [`std.toml`](./stdlib/toml.md) - `parse`, `stringify`, `read`, `write`
- [`std.yaml`](./stdlib/yaml.md) - `parse`, `stringify`, `read`, `write`
- [`std.log`](./stdlib/log.md) - leveled logging with text/JSON sinks and file rotation (`fs:write` for file sinks)
- [`std.image`](./stdlib/image.md) - decode / resize / crop / encode PNG & JPEG; backs `ai ... on <image>`
- [`std.config`](./stdlib/config.md) - layered config (env > file > default), with `secret` fields - `env` + `fs:read`
- [`std.defaults`](./stdlib/defaults.md) - the project's `ecko.json`, loaded automatically: `defaults.<key>` plus an `environment` block applied to the process - ungated
- [`std.db`](./stdlib/db.md) - in-process vector store: `add`, `search`, `save`, `load` (`net` to embed, `fs` to persist)
- [`std.http`](./stdlib/http.md) - HTTP client and server, streaming/SSE, TLS, WebSocket upgrade
- [`std.web`](./stdlib/web.md) - a router over `http.serve`: routes, `:params`, middleware, static files (GET routes also answer HEAD)
- [`std.ws`](./stdlib/ws.md) - WebSocket client (`connect`, `send`, `recv`, `close`)
- [`std.net`](./stdlib/net.md) - raw TCP/TLS sockets and DNS (`connect`, `connect_tls`, `starttls`, `send`, `recv`)
- [`std.dns`](./stdlib/dns.md) - DNS resolver (`resolve`, `reverse`, `lookup`; A/AAAA/CNAME/MX/TXT)
- [`std.llm`](./stdlib/llm.md) - low-level `chat` access to the provider layer
- [`std.rag`](./stdlib/rag.md) - retrieval-augmented generation: `chunk`, `index`, `retrieve`, `answer`
- [`std.sql`](./stdlib/sql.md) - embedded SQLite: `open`, `exec`, `query`, `query_one`, `transaction`; `sql { ... }` blocks (`:memory:` is pure, a file db needs `fs:write`)
- [Global builtins reference](./stdlib/builtins.md) - the ~95 functions always in scope: collections (`map`, `filter`, `reduce`, `sort`, `group_by`, ...), conversions (`int`, `string`, `bytes`, ...), `json_encode` / `json_decode`, `embed` / `tokens` / `cost` / `retry`, `secret` / `reveal`, `error` / `assert`, `cell` / `channel`, and `py(...)` (Python FFI)

## Packages

- [Concepts](./packages/concepts.md) - bare imports, `vendor/`, and the three-layer model (kernel / std / packages)
- [The `ecko.json` manifest](./packages/manifest.md) - `name`, `version`, `entrypoint`, `capabilities`, `dependencies`
- [Capabilities & gating](./packages/capabilities.md) - `net`, `fs:read`, `fs:write`, `env`, `exec`; granted by the importer, attenuated down the tree
- [Lockfile & integrity](./packages/lockfile.md) - `ecko.lock` sha256 pins; commit `vendor/` for offline clones
- [Package commands](./packages/commands.md) - `init`, `add`, `install`, `remove`, `update`, `pack`
- [Building an executable](./packages/build.md) - `ecko build` bundles the interpreter + program into one file
- [Docker](./packages/docker.md) - a ~22 MB distroless image, no shell or package manager inside

## CLI and tooling

- [`ecko run` / a file](./cli/run.md) - run a program (a bare `ecko file.ecko` works too)
- [`ecko repl`](./cli/repl.md) - the interactive REPL
- [`ecko dev`](./cli/dev.md) - hot-reload for servers and scripts
- [`ecko fmt`](./cli/fmt.md) - the canonical formatter (one style, zero config; `--check`)
- [`ecko check`](./cli/check.md) - static analysis: undefined names, arity, use-before-def, exhaustiveness, unwrapped credentials
- [`ecko test`](./cli/test.md) - the test runner (mock mode forced); `--generate` scaffolds tests
- [`ecko explain` / `lint` / `fix`](./cli/explain-lint-fix.md) - explain a program, lint dead code, AI-assisted fixes (`--migrate-bytes`)
- [`ecko doc`](./cli/doc.md) - markdown documentation from `##` comments
- [`ecko lsp`](./cli/lsp.md) - the stdio language server for editors
- [Package commands](./packages/commands.md) - `init` / `add` / `install` / `remove` / `update` / `pack` / `build`
- [Global flags](./cli/flags.md) - `--model`, `--provider`, `--key`, `--cache`, `--trace`

## Configuration

- [Environment variables](./config/environment.md) - the complete reference. Grouped:
  - **AI / LLM** - `ECKO_API_KEY`, `ECKO_AI_PROVIDER`, `ECKO_AI_MODEL`, `ECKO_AI_BASE_URL`, `ECKO_AI_EMBED_MODEL`, `ECKO_AI_MAX_RETRIES`, `ECKO_AI_MAX_CALLS`, `ECKO_AI_MAX_TOOL_ROUNDS`, `ECKO_AI_TOOL_TIMEOUT_MS`, `ECKO_AI_CACHE`, `ECKO_TRACE`, `ECKO_RETRY_BASE_MS`
  - **Concurrency** - `ECKO_MAX_PARALLEL`, `ECKO_MAX_TASKS`
  - **HTTP / WebSocket server** - `ECKO_HTTP_WORKERS`, `ECKO_HTTP_REQUEST_TIMEOUT_MS`, `ECKO_HTTP_MAX_BODY`, `ECKO_MAX_WS_CONNS`
  - **Runtime limits** - `ECKO_MAX_DEPTH`, `ECKO_MAX_PARSE_DEPTH`, `ECKO_MAX_STEPS`
  - **Logging** - `ECKO_LOG`
  - **Packages** - `ECKO_PKG_MAX_BYTES`, `ECKO_PKG_MAX_UNPACKED`
  - **Terminal** - `NO_COLOR`, `CLICOLOR_FORCE`

## Architecture

- [The pipeline](./architecture/pipeline.md) - source -> lexer -> parser -> bytecode -> stack VM
- [Two execution tiers](./architecture/tiers.md) - the bytecode VM and the AST tier (AI, contracts, `async`), and the bridge between them
- [The stack VM](./architecture/vm.md) - chunks, frames, superinstructions, try/catch
- [The value model](./architecture/values.md) - one `Value` enum, Arc-backed copy-on-write collections
- [Capability enforcement](./architecture/capabilities.md) - the three layers and how gating is enforced
- [Code map](./architecture/code-map.md) - how the runtime is organized

## Official packages

Batteries that live outside the binary: each one is written in Ecko, versioned
on its own, and deletable. `ecko get` vendors a package under `vendor/` and pins
a hash; what it is allowed to do is the `grant` you give it at the import, not
what its manifest asks for.

Every reference below is generated from the `##` comments in the package's own
source, so it says what the code says.

- [`cache`](./packages/cache.md) - A general-purpose cache written in Ecko: in-memory LRU with TTL over an optional disk store. get/set/remember(key, ttl, fn).
- [`cli`](./packages/cli.md) - Command-line argument parsing for Ecko: typed flags, options, positionals, defaults, and generated usage. Pure - no capabilities.
- [`cookies`](./packages/cookies.md) - Parse and serialize HTTP cookies for client sessions: read Set-Cookie headers into a jar, build the Cookie request header. Pure - no capabilities.
- [`datetime`](./packages/datetime.md) - Calendar dates, times, and durations for Ecko: components, arithmetic, and formatting over Unix-ms timestamps. Pure - no capabilities.
- [`deque`](./packages/deque.md) - A double-ended queue for Ecko: push/pop/peek at both ends, amortized O(1). Immutable two-stack deque. Pure - no capabilities.
- [`heap`](./packages/heap.md) - A priority queue (min-heap) for Ecko: push/pop/peek, heapify, and top-k. Immutable skew heap. Pure - no capabilities.
- [`html`](./packages/html.md) - A tolerant HTML parser for Ecko: parse to a node tree, extract text, and find elements. Great for feeding web content to ai. Pure - no capabilities.
- [`ip`](./packages/ip.md) - IPv4/IPv6 address parsing, validation, CIDR membership, and private-range checks for Ecko. Pure - no capabilities.
- [`mysql`](./packages/mysql.md) - A MySQL/MariaDB client written in Ecko: classic protocol + mysql_native_password over std.net.
- [`perf`](./packages/perf.md) - Measure the performance of your own Ecko code: time, measure, and bench (best-of-N stats)
- [`postgres`](./packages/postgres.md) - A PostgreSQL client written in Ecko: v3 wire protocol + SCRAM-SHA-256 over std.net.
- [`redact`](./packages/redact.md) - Sensitive-key detection and masking for safe logging: is_sensitive_key, mask, and recursive map_of. Pure - no capabilities.
- [`redis`](./packages/redis.md) - A Redis client (RESP2) written in Ecko, over std.net raw sockets + TLS.
- [`smtp`](./packages/smtp.md) - An SMTP client (RFC 5321) written in Ecko, over std.net raw sockets + STARTTLS.
- [`stats`](./packages/stats.md) - Descriptive statistics for Ecko: mean, median, mode, variance, stdev, quantiles. Pure - no capabilities.
- [`struct`](./packages/struct.md) - Pack and unpack binary data with a struct-style format string, over the bytes type. Pure - no capabilities.
- [`textwrap`](./packages/textwrap.md) - Wrap, fill, indent, dedent, and shorten text for Ecko - prompt building and terminal output. Pure - no capabilities.
- [`tui`](./packages/tui.md) - Terminal UI composition for Ecko: width-aware pad/center/truncate, bordered boxes, and aligned tables over std.term.
- [`url`](./packages/url.md) - URL parsing, query strings, and reference resolution for Ecko.
- [`validate`](./packages/validate.md) - A data/input validation library written in Ecko: composable validator functions, whole-object schemas, collect-all errors. Pure - no capabilities.
- [`webkit`](./packages/webkit.md) - SaaS web-app batteries for Ecko: auto-escaping HTML templates, signed cookies, sessions, and CORS/security middleware.
- [`xml`](./packages/xml.md) - An XML parser for Ecko: parse to a node tree, query by tag or path, extract text, and rebuild. Pure - no capabilities.

---

*Ecko v0.9 - built in Rust, runs everywhere. Home at
[ecko.sh](https://ecko.sh); licensing at [ecko.sh/enterprise](https://ecko.sh/enterprise).*
