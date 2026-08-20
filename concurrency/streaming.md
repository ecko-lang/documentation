# Streaming responses & SSE

Two kinds of streaming meet here: a model streaming tokens to you, and your
server streaming bytes to a client. They compose - a channel joins them.

## Streaming from a model

```ecko
s = ai "write a poem" -> stream

for chunk in s {
    print_no_newline(chunk)  # incremental
}
```

Or block for the whole thing by using the stream as a value:

```ecko fragment
full = string(s)
```

With a live provider, an untyped stream delivers the model's tokens as they
arrive - real server-sent events across OpenAI, Anthropic and Ollama. Offline the
chunks are the mock text split into pieces, so the consuming code is exercised
either way.

A **typed** stream (`ai[T] ... -> stream`) resolves through the normal
coercion-and-retry path first and then chunks the completed result, because a
schema cannot be validated against half an answer. Use an untyped stream when
what you want is the appearance of progress.

See [Streaming](../ai/streaming.md) for the `ai` side in full.

## Streaming from a handler

An HTTP handler can return a body fed by a [channel](./channels.md), which lets
you send the first byte before the last one exists:

```ecko fragment
import std.http

fn handler(req) {
    out = channel(16)

    async fn fill() {
        for chunk in ai "explain quicksort" -> stream {
            send(out, "data: {chunk}\n\n")
        }
        close(out)
    }
    fill()

    http.stream(out, { "content-type": "text/event-stream" })
}

http.serve(8080, handler)
```

The bounded channel matters: it is the backpressure between the model's pace and
the client's. Sixteen chunks in flight, not sixteen thousand.

## Why SSE rather than WebSockets

For one-directional token streaming, server-sent events are plain HTTP: no
upgrade handshake, no framing, no separate protocol to proxy, and reconnection is
built into the browser's `EventSource`. Reach for
[`std.ws`](../stdlib/ws.md) when the client needs to talk back mid-stream.

## Closing

Close the channel when the producer is done, and close it exactly once. An
unclosed channel leaves the connection open and the client waiting; a double
close raises. Putting the `close` in the same function as the loop that fills the
channel is the pattern that keeps this straight.
