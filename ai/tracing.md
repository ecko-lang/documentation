# Tracing

```bash
ecko run app.ecko --trace           # to stderr
export ECKO_TRACE=1                 # same
export ECKO_TRACE=calls.jsonl       # one JSON object per call
```

Every `ai` call emits a record - including streamed, piped and parallel-mapped
calls.

## What is recorded

| field | |
|---|---|
| call id | sequential |
| source | line and column of the `ai` expression |
| provider, model | |
| mock | whether it was a mock call |
| prompt | verbatim, plus a stable content hash |
| response | verbatim |
| latency | wall clock |
| retries | how many attempts it took |
| tokens | when the provider reports them |
| cached | whether it was a [cache](./caching.md) replay |
| error | the failure reason, if it failed |

The source position is what makes this usable in a program with many calls: a
trace line points at the expression that produced it.

## Mock calls are traced too

So a CI run is observable, and so a budget or a retry storm is visible before it
reaches a provider. This is the cheapest way to answer "how many calls does this
program actually make?" - run it offline with tracing on and count.

## JSONL

A path makes the trace a file with one JSON object per line, which is a shape
every log tool already reads:

```bash
ECKO_TRACE=calls.jsonl ecko run app.ecko
```

```bash
# total latency by model
cat calls.jsonl | jq -r '[.model, .latency_ms] | @tsv' \
  | awk '{s[$1]+=$2} END {for (m in s) print m, s[m]}'
```

## It never changes behaviour

Tracing is observation only, and sink errors are swallowed - an unwritable trace
path does not fail your program. That is deliberate: diagnostics that can break
the thing they diagnose get turned off, and then are not there when you need them.

## Treat the trace as a log

**The trace records prompts and responses verbatim.** An unrevealed
[`secret`](../language/secrets.md) renders redacted, as it does everywhere. But a
`reveal`ed value interpolated into a prompt lands in the trace file in the clear,
as does any personal data in the prompt or the reply.

So: keep trace files out of version control, apply the same retention you apply to
application logs, and think before enabling tracing on a path that handles user
data.
