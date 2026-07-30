# Global flags

These apply to any command that can make an `ai` call - `run`, `repl`, `test`,
`explain`, `fix`.

| flag | effect |
|---|---|
| `--key <key>` | API key for this invocation |
| `--provider <name>` | `openai` (default), `anthropic`, `ollama` |
| `--model <name>` | Model name; the provider's default otherwise |
| `--trace` | Trace every `ai` call to stderr |
| `--cache` | Cache `ai` responses in `.ecko-cache/` |

Each maps onto the matching environment variable, so a flag is a one-run
override of your configuration:

```bash
ecko report.ecko --provider anthropic --model claude-sonnet-4-5
```

The full set of settings is environment variables only - see
[Environment variables](../config/environment.md). Configuration never lives in
code.

## `--trace`

Prints provider, model, token counts, latency and retries for each call. For a
durable record set `ECKO_TRACE` to a path and get JSONL instead - see
[Tracing](../ai/tracing.md).

## `--cache`

Content-addressed: identical prompt, model and parameters return the stored
response without a call, and without counting against a budget. Useful when
iterating on the code around a prompt rather than the prompt itself. See
[Caching](../ai/caching.md).

## A note on `--key`

Convenient for a one-off, but a key on the command line goes into your shell
history and into the process list. Prefer `ECKO_API_KEY` in the environment, or
an `environment` block in [`ecko.json`](../stdlib/defaults.md) for a
non-secret setting like the model.
