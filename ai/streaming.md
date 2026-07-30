# Streaming

```ecko
story = ai "Write a short story" -> stream

for chunk in story { print_no_newline(chunk) }   # incrementally
```

The call runs in the background and returns a stream. Consume it chunk by chunk,
or use it as a value to block for the whole result:

```ecko
full = string(story)
```

## Untyped streams are real tokens

With a live provider, an untyped stream delivers the model's tokens as they
arrive - genuine server-sent events, across OpenAI, Anthropic and Ollama. One
piece of code, three wire formats handled underneath.

## Typed streams are not incremental

`ai[T] "..." -> stream` resolves through the normal coercion-and-retry path first
and **then** chunks the completed result.

This is not a limitation to work around, it is the only correct behaviour: a
schema cannot be validated against half an answer, and streaming a partial value
that later fails coercion would mean emitting output you have to retract. If what
you want is the *appearance* of progress on a typed call, that is what this gives
you. If you want genuine incremental output, use an untyped stream.

## Offline

Chunks are the mock text split into pieces. The consuming loop is exercised
identically, so a streaming UI is testable with no key.

## To a client

A stream pairs with a [channel](../concurrency/channels.md) to push tokens out
over HTTP as they arrive - see
[Streaming responses & SSE](../concurrency/streaming.md) for the server side.

## Restrictions

Cannot combine with [voting](./voting.md) (no partial majority),
[tools](./tools.md), or [sessions](./sessions.md).
