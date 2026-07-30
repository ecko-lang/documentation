# Tool calling

Give a model functions it can call.

```ecko
@tool("look up the current weather for a city")
fn weather(city) = http.get("https://api.example/w?q={city}").body

@tool("search internal docs")
fn docs(query) = db.search(query)

answer = ai[Report] "Compare weather in Cairo and Oslo" using [weather, docs]
```

The runtime drives the loop: the model requests a tool, Ecko invokes your
function, feeds the result back, and repeats until there is a final answer - which
is still coerced to `ai[T]` and still checked by any
[`@ensures`](./contracts.md).

## `@tool` and `using`

Every function in a `using` list must carry a `@tool("description")`. The
description is what the model sees, so it is part of the interface: write it for a
reader who cannot see the body. Parameters default to string type.

`using` resolves names in the lexical scope of the `ai` expression. A local tool
can capture its defining scope and shadow an outer tool of the same name.

## Concurrency and bounds

With a live provider, **the tools requested in one round run concurrently** - at
most `ECKO_MAX_PARALLEL` at a time - each bounded by
`ECKO_AI_TOOL_TIMEOUT_MS` (default 30000; `0` disables).

A tool that errors, times out, or names nothing known yields an error string fed
back to the model, so one slow or broken tool never stalls the loop. The whole
loop is capped at `ECKO_AI_MAX_TOOL_ROUNDS` rounds (default 8) - a backstop
against a model that never stops calling tools.

Concurrent tools follow the usual [share-nothing](../concurrency/pmap.md) model.
Coordinate through a [`cell`](../concurrency/cell.md) if they must share state.

## Offline

The loop is deterministic in mock mode: it invokes every tool named in the prompt,
passes the prompt as the argument, and returns the last tool's result. Enough to
test that the wiring is right.

**A failing tool throws offline**, unlike live mode where the error is fed back.
Live, the model recovers; offline, you are the recovery mechanism, so the failure
surfaces with its `kind` preserved and catchable.

## Security

A tool is your code running on a model's decision, with your program's authority.
Two consequences worth internalizing:

- **A tool that writes, deletes, sends or pays should validate its own
  arguments.** The model is not a trusted caller. Treat a tool boundary the way
  you would treat an HTTP handler.
- **A tool result is untrusted input.** It flows back into a prompt, so a
  compromised or hostile source can attempt injection. Mark it
  [`@untrusted`](../language/templates.md) and render it through `{input}` in a
  template.

## Restrictions

Cannot combine with [voting](./voting.md) or [`-> stream`](./streaming.md).
