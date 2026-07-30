# Sessions

A session holds conversation history, so multi-turn calls remember prior turns.

```ecko
chat = session()

ai "My name is Ada." with chat
who = ai "What is my name?" with chat     # sees the earlier turn
```

## What `with` does

It sends the session's prior turns as a **native role-separated message array** -
not a flattened transcript pasted into one prompt - and records the new prompt and
reply back into the session.

That distinction matters. A flattened transcript is one long user message, and the
model cannot reliably tell your instructions from earlier content. Real roles are
what every provider's API expects and what keeps a long conversation coherent.

## A session is a cell

```ecko
cell_get(chat)     # [{ role: "user", content: "..." }, { role: "assistant", ... }]
```

It is a [`cell`](../concurrency/cell.md) of `{ role, content }` maps, so you can
read it, log it, persist it, or trim it:

```ecko
# keep only the last 20 turns
cell_update(chat, fn(msgs) if len(msgs) > 20 { msgs[-20..] } else { msgs })
```

Being a cell also means it shares on assignment, which is what lets a session be
captured into a handler or a task and still accumulate.

## Growth is your problem

Every turn adds to what is sent on the next call, so tokens and cost grow with
conversation length. Nothing trims automatically, because only you know what
matters. The two usual strategies:

- **Window** - keep the last N turns, as above.
- **Summarize** - periodically replace old turns with a summary, which is itself
  an `ai` call.

Check the size before spending with [`tokens`](./budgeting.md):

```ecko
if tokens(json_encode(cell_get(chat))) > 50000 { chat = compact(chat) }
```

## Restrictions

Conversational turns bypass the [cache](./caching.md) - a cached reply would break
the conversation. Cannot combine with `using` tools, [voting](./voting.md), or
`-> stream`.
