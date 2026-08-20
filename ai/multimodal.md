# Multimodal / vision

```ecko fragment
import std.image
img = image.load("chart.png")

ai "what does this chart show?" on img
```

The `on` clause attaches image input. The image is a
[`std.image`](../stdlib/image.md) handle, so a resize or crop pipeline flows
straight into the call:

```ecko fragment
small = image.resize(image.load("photo.jpg"), 512, 512)
ai "describe this" on small
```

## Typed and multiple

```ecko fragment
type Kind = Chart | Photo | Diagram | Screenshot

ai[Kind] "classify this image" on img            # typed vision output
ai "spot the differences" on [before, after]     # several images
```

`on` composes with `[T]`, so vision output is coerced and retried like any other
typed call.

## One program, either provider

The handle serializes into whatever the configured provider expects - OpenAI
`image_url` data URLs, Anthropic base64 `image` blocks. The same source runs on
both; switching is an environment variable.

## Offline

A vision call in mock mode echoes the prompt plus **each image's real
dimensions**:

```
[AI Mock] describe [image 4x2]
```

The dimensions are read from the actual file, so the mock proves the image was
loaded, decoded and passed correctly - the part of the wiring that actually breaks
- while staying deterministic. Typed vision calls return their schema-valid mock
as usual.

## Restrictions

`on` composes with `[T]`. Combining it with `using` (tools), `with` (a session),
voting, or `-> stream` is not supported yet and is a clear parse error rather than
a runtime surprise.

## Size and cost

Images are tokens, often a lot of them. Resize before sending: a 4000-pixel
photograph rarely answers a question better than a 1000-pixel one, and costs
several times more.

```ecko fragment
ai "read the label" on image.resize(photo, 1024, 1024)
```
