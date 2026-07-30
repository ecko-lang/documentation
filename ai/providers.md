# Providers & configuration

Three providers, one program. Switching is an environment variable, not a code
change.

```bash
export ECKO_API_KEY=sk-...
export ECKO_AI_PROVIDER=openai        # or anthropic, ollama
export ECKO_AI_MODEL=gpt-4o-mini      # optional; each provider has a default
```

Or per run:

```bash
ecko report.ecko --provider anthropic --model claude-sonnet-4-5
```

## The providers

| provider | notes |
|---|---|
| `openai` | The default. |
| `anthropic` | Claude models. |
| `ollama` | Local models. No key needed; runs against your own machine. |

`ECKO_AI_BASE_URL` overrides the endpoint, which is how you point at a proxy, a
gateway, or an OpenAI-compatible server.

## What the runtime normalizes

The differences between providers are real - message shapes, tool-call
serialization, streaming frame formats, image encodings, error bodies - and all of
them are handled underneath. One `ai` expression with tools and a session works
across all three, and a provider swap does not touch your source.

Errors are parsed per provider, so a failure reports what the provider actually
said rather than an empty string.

## Configuration is never code

There is no `configure()` call and no config file the runtime reads. A program's
behaviour is a function of its source and its environment, which means a library
cannot change your provider behind your back and a code review shows you
everything the program decides.

For a project-level default, use the `environment` block in
[`ecko.json`](../stdlib/defaults.md) - applied before evaluation and overriding
the shell, so a checkout runs the way its author intended:

```json
{ "environment": { "ECKO_AI_PROVIDER": "ollama", "ECKO_AI_MODEL": "llama3" } }
```

Never put a key in it. That file is committed.

## Local models

`ollama` is the zero-cost, zero-egress option, and worth reaching for when the
data should not leave the machine. Quality differs from a frontier model, so it is
a real choice rather than a drop-in - but the code is identical, so trying it
costs one variable.

## No key at all

Everything still runs. See [Mock mode](./mock-mode.md).

## The full list

Every setting is in [Environment variables](../config/environment.md).
