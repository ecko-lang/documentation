# Token budgeting

```ecko
n   = tokens("some prompt text")       # Int
usd = cost("gpt-4o-mini", n, 500)      # Float, estimated USD

if tokens(prompt) < 100000 { ai prompt }
```

## `tokens`

Counts with the cl100k_base tokenizer - exact for OpenAI models, close enough
elsewhere for budgeting. Use it as a guard before spending, and to decide when a
[session](./sessions.md) needs trimming.

## `cost`

Prices from a built-in table of common models and **errors on an unknown model**,
so a typo cannot silently price at zero. For a model not in the table, pass
explicit prices:

```ecko
cost(in_tokens, out_tokens, in_per_1m, out_per_1m)
```

List prices drift. Treat the result as an estimate, not an invoice.

## The hard budget

`ECKO_AI_MAX_CALLS` caps total `ai` calls per process. The call that would exceed
it fails rather than spending. **Set it in anything unattended.**

Everything counts: every vote, every retry, every tool round, and mock calls too -
so a budget is testable offline. Cache replays do not count, because they do not
call anything.

## Why the ceiling is higher than it looks

The dials multiply:

| dial | default | effect |
|---|---|---|
| Coercion retries | `ECKO_AI_MAX_RETRIES` = 3 | up to 1+3 calls per typed call |
| [Voting](./voting.md) samples | none | each sample runs its own retry loop |
| [Contract](./contracts.md) attempts | `ECKO_AI_MAX_RETRIES` = 3 | each attempt re-runs the body |
| [Tool](./tools.md) rounds | `ECKO_AI_MAX_TOOL_ROUNDS` = 8 | each round is a provider call |

So `ai[T] 5 "..."` can spend **20 calls**, and a typed `ai` body inside a failing
string contract can reach **16 calls plus verification** for one invocation.

None of this is hidden, and none of it is wrong - retrying a failed coercion is
what you want. But it is why "one `ai` call" is not one call, and why the hard
budget exists.

## Seeing where it went

[`ECKO_TRACE`](./tracing.md) records every call with its tokens, latency and retry
count. When a bill is surprising, the trace file is the answer, and it works in
mock mode too.
