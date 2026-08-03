# Environment variables

**Configuration is environment variables, never code.** There is no config file
to load, no `Ecko.configure(...)` call, and no way for a library to change your
provider behind your back. A program's behaviour is a function of its source and
its environment.

A project can pin its own environment in the `environment` block of
[`ecko.json`](../stdlib/defaults.md), which is applied before evaluation and
**overrides the surrounding shell** - so a checkout runs the way its author
intended rather than the way your terminal happens to be set up.

The [global flags](../cli/flags.md) `--key`, `--provider`, `--model`, `--trace`
and `--cache` are one-run overrides of the matching variable.

## AI and LLM

| variable | meaning |
|---|---|
| `ECKO_API_KEY` | Provider API key. `ECKO_LLM_API_KEY` is also accepted. Unset means [mock mode](../start/mock-mode.md). |
| `ECKO_AI_PROVIDER` | `openai` (default), `anthropic`, `ollama` |
| `ECKO_AI_MODEL` | Model name; each provider has a default |
| `ECKO_AI_BASE_URL` | Override the provider endpoint, for a proxy or a compatible server |
| `ECKO_AI_EMBED_MODEL` | Embedding model; defaults per provider |
| `ECKO_AI_MAX_RETRIES` | Retries for typed and contract calls. Default `3` |
| `ECKO_AI_MAX_CALLS` | Hard cap on total `ai` calls per process. Unset means unlimited |
| `ECKO_AI_MAX_TOOL_ROUNDS` | Tool-call rounds per `ai ... using`. Default `8` |
| `ECKO_AI_TOOL_TIMEOUT_MS` | Per-round tool timeout. Default `30000`; `0` disables |
| `ECKO_AI_CACHE` | Directory for the [prompt cache](../ai/caching.md) |
| `ECKO_TRACE` | `1` traces to stderr; a path writes [JSONL](../ai/tracing.md) |
| `ECKO_RETRY_BASE_MS` | Base backoff for `retry`. Default `50` |

`ECKO_AI_MAX_CALLS` is the one to set in anything unattended. It is a hard
budget: the call that would exceed it fails rather than spending.

## Concurrency

| variable | meaning |
|---|---|
| `ECKO_MAX_PARALLEL` | Concurrent workers in `pmap` and tool rounds. Default: all cores |
| `ECKO_MAX_TASKS` | Cap on running `async` tasks. Default `256` |

## HTTP and WebSocket server

| variable | meaning |
|---|---|
| `ECKO_HTTP_WORKERS` | How many `http.serve` handler invocations run at once. Default `8` |
| `ECKO_HTTP_REQUEST_TIMEOUT_MS` | Per-request handler timeout. `0` or unset means unlimited |
| `ECKO_HTTP_MAX_BODY` | Max request body in bytes. Default 10 MiB |
| `ECKO_HTTP_READ_TIMEOUT_MS` | How long a connection may take to send request headers, the slow-client deadline. Default `30000` |
| `ECKO_MAX_WS_CONNS` | Max concurrent WebSocket connections. Default `1024` |

## Runtime limits

| variable | meaning |
|---|---|
| `ECKO_MAX_DEPTH` | Call and recursion depth. Default `2000` |
| `ECKO_MAX_PARSE_DEPTH` | Nesting depth the parser accepts. Default `128` |
| `ECKO_MAX_STEPS` | Opt-in loop and step budget. Unset means unlimited |

These exist so that adversarial or accidental input degrades into a catchable
error instead of exhausting the machine - see
[Resource limits](../language/limits.md).

## Logging and terminal

| variable | meaning |
|---|---|
| `ECKO_LOG` | Level filter for the default `std.log` sink: `debug` < `info` < `warn` < `error`. Default `info` |
| `NO_COLOR` | Any value disables terminal colour ([the convention](https://no-color.org)) |
| `CLICOLOR_FORCE` | Force colour on even when stdout is not a TTY |

## Packages

| variable | meaning |
|---|---|
| `ECKO_PKG_MAX_BYTES` | Max download size for a package. Default 50 MiB |
| `ECKO_PKG_MAX_UNPACKED` | Max unpacked size. Default 200 MiB |
| `ECKO_ALLOW_HTTP` | `1` or `true` permits plain-http package sources from non-loopback hosts |
| `ECKO_GIT_BASE` | Override the forge base URL, for a private mirror |
| `ECKO_NET_TOKEN` | Bearer token attached to package fetches, for a private repository |

The two size caps and the https default are there because fetching a package is
the moment a program trusts something it did not write. `ECKO_ALLOW_HTTP` exists
for a local registry; needing it against a real host is a warning sign.

## Secrets

Nothing here should hold a secret except `ECKO_API_KEY` and `ECKO_NET_TOKEN`,
and neither belongs in a committed file. Put them in your shell, your CI secret
store, or a secret manager. Inside a program, wrap sensitive values in
[`secret`](../language/secrets.md) so they cannot be printed or logged by
accident, and reach for [`std.config`](../stdlib/config.md) when you want layered
configuration with declared secret fields.
