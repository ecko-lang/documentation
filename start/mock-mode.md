# Mock mode

**Every `ai` call works without an API key.** With no provider configured, Ecko
answers from a deterministic mock instead of failing.

```ecko
print(ai "Summarize this")        # [AI Mock] Summarize this
print(ai[Int] "How many?")        # 42
print(ai[Bool] "Is this spam?")   # true
```

This is not a stub that returns null. Mock answers are **schema-valid** and go
through the same coercion path a real response takes, so a typed call in mock
mode returns exactly the shape your program will get in production.

## What each type produces

| call | mock result |
|---|---|
| `ai "..."` | `[AI Mock] <prompt>` |
| `ai[Int] "..."` | `42` |
| `ai[Float] "..."` | `42.0` |
| `ai[Bool] "..."` | `true` |
| `ai[String] "..."` | `[AI Mock] <prompt>` |
| `ai[Enum] "..."` | the first variant |
| `ai[Struct] "..."` | every field filled with its type's mock |
| `ai[json<...>] "..."` | a value matching the shape |

Deterministic means deterministic: the same program produces the same output
every run, which is what lets a test suite assert on it.

## Why it exists

Three reasons, in order of how much they matter.

**Tests.** An AI pipeline you cannot test offline is a pipeline you cannot
refactor. `ecko test` forces mock mode, so the whole suite runs in CI with no
secret, no network, and no per-run cost.

**Trying things.** Installing a language and immediately hitting "set these
three environment variables" is where most people stop. Everything in this
documentation runs as written.

**Structure over content.** Most bugs in an AI program are in the plumbing - the
schema, the tool wiring, the retry, the branch you forgot. Mock mode exercises
all of it. What it cannot check is whether the model's *answer* is any good,
which is what [contracts](../ai/contracts.md) and real runs are for.

## What still runs for real

Mock mode replaces the provider call, not the language. Tools are still invoked,
contracts are still evaluated, retries still happen, budgets are still counted,
and traces are still written. A `@tool` function called during a mock `ai` call
executes your actual code.

## Turning it off

Configure a provider:

```bash
export ECKO_API_KEY=sk-...
export ECKO_AI_PROVIDER=openai      # or anthropic, ollama
```

Any configured provider takes over; unset the key and you are back in mock mode.
`ecko test` ignores the key by design - a test run never spends money. See
[Providers & configuration](../ai/providers.md).
