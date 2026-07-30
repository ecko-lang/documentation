# Mock mode

With no provider configured, `ai` answers from a deterministic mock instead of
failing. See [Mock mode](../start/mock-mode.md) in Getting Started for the
introduction; this page is the detail that matters once you are building.

## What mock mode replaces

The provider call. Nothing else.

| still runs for real | replaced by a mock |
|---|---|
| `@tool` functions - your actual code | the provider's choice of tool |
| Boolean [contracts](./contracts.md) | string contracts (they always pass) |
| Coercion to the requested type | the model's reply |
| [Retry](./retry.md) and backoff | |
| [Budget](./budgeting.md) counting | |
| [Tracing](./tracing.md) | |

That split is why mock mode is worth trusting: the machinery around the call is
exercised exactly as it will be in production, so a schema mistake, a broken tool
signature or a missing branch fails offline.

## Determinism

The same program produces the same bytes every run. This is what makes an `ai`
pipeline testable at all - `ecko test` forces mock mode, so a test can assert on
output.

| call | mock result |
|---|---|
| `ai "..."` | `[AI Mock] <prompt>` |
| `ai[Int]` / `ai[Float]` | `42` / `42.0` |
| `ai[Bool]` | `true` |
| `ai[Enum]` | the first variant |
| `ai[Struct]` | each field's mock |
| `ai[json<List<T>>]` | a one-element list |
| `ai "..." on img` | `[AI Mock] <prompt> [image WxH]` with the real dimensions |

## Tools in mock mode

The loop is deterministic rather than absent: it invokes every tool named in the
prompt, passes the prompt as the argument, and returns the last tool's result.
Enough to prove the wiring works.

One deliberate difference: **a failing tool throws offline**, where live mode
feeds the error back to the model. Live, the model is the recovery mechanism;
offline, you are, so the failure surfaces instead of being swallowed.

## What it cannot tell you

Whether the answer is any good. Mock mode validates structure, not content. A
prompt that produces confident nonsense from a real model produces a
schema-perfect `42` offline.

Two things close that gap: boolean [contracts](./contracts.md), which are real
checks that run identically on and offline, and running against a provider before
you ship. Mock mode makes the *program* trustworthy; it says nothing about the
model.

## Turning it off

Set `ECKO_API_KEY`. `ecko test` ignores it by design - a test run never spends
money.
