# `std.llm`

The provider layer with the language machinery taken off.

```ecko
import std.llm

llm.chat({ user: "Say hello" })
llm.chat({ system: "Answer in one word.", user: "Capital of France?" })
llm.chat({ user: "Summarize this", model: "gpt-4o-mini" })
```

One prompt in, a string out. No typed coercion, no contracts, no retry loop, no
tool calls.

## Fields

`user` is required. `system` sets the system prompt. `model` overrides the
configured model **for that call only** - passed through rather than written to the
process environment, so concurrent workers under
[`pmap`](../concurrency/pmap.md) cannot clobber each other's choice.

## Offline

With no provider configured it returns a deterministic mock string rather than
failing, on the same principle as `ai` - the program still runs. A failing live call
raises a catchable error.

## Use `ai` instead, nearly always

`ai` is the same provider underneath, plus everything that makes model output usable:

| | `ai` | `llm.chat` |
|---|---|---|
| [Typed output](../ai/typed-output.md) | yes | no |
| [Contracts](../ai/contracts.md) | yes | no |
| Coercion retry | yes | no |
| [Tools](../ai/tools.md) | yes | no |
| [Sessions](../ai/sessions.md) | yes | no |
| [Streaming](../ai/streaming.md) | yes | no |
| [Caching](../ai/caching.md) | yes | no |
| [Voting](../ai/voting.md) | yes | no |

`ai "..."` is shorter *and* does more. The reason `llm.chat` exists is for the few
cases where you want the provider and nothing else: a one-off probe, a wrapper of
your own, or code that needs the raw string with no machinery in the way.

If you find yourself rebuilding retry and parsing around `llm.chat`, that is what
`ai` already is.
