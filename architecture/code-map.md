# How the runtime is organized

A conceptual map, for reasoning about behaviour. **The runtime implementation is
not public** - Ecko ships as binaries - so this describes components and
responsibilities rather than files.

## Three crates, one binary

| component | holds | constraint |
|---|---|---|
| **kernel** | lexer, parser, VM, evaluator, `ai`, contracts, mock mode | no network, no SQL, no heavy dependencies |
| **standard library** | native `std.*` modules; registers itself with the module registry | where every gated capability lives |
| **facade + CLI** | the public API and every `ecko` command | installs the standard library before evaluating |

The kernel's dependency floor is a design constraint, not an accident: it is what
keeps the language layer free of the things that need gating, and it is why
[capability enforcement](./capabilities.md) has a clean boundary to sit on.

## The parts

- **Lexer and parser** - tokens with spans, recursive descent with precedence
  climbing. See [The pipeline](./pipeline.md).
- **The VM** - bytecode compiler and stack machine, the shipped engine. See
  [The stack VM](./vm.md).
- **The evaluator** - the AST tier for `ai`, contracts and `async`, and the bridge
  both engines meet at. See [Two execution tiers](./tiers.md).
- **The value model** - one value type, copy-on-write collections. See
  [The value model](./values.md).
- **Built-ins** - roughly 95 global functions, plus the AI-adjacent surface
  (`tokens`, `cost`, `retry`, `session`, `embed`) and the async surface
  (`channel`, `send`, `recv`, `cancel`).
- **The provider layer** - one abstraction over OpenAI, Anthropic and Ollama on a
  shared async runtime, with mock fallback and per-provider tool serialization.
  See [Providers](../ai/providers.md).
- **Cache, trace, Python FFI** - the content-addressed [prompt cache](../ai/caching.md),
  JSONL [tracing](../ai/tracing.md), and `py()` over a persistent worker process.
- **The formatter** - canonical printing, and a gate on new syntax.
- **The analyzer** - [`ecko check`](../cli/check.md), also driving
  [`ecko lsp`](../cli/lsp.md), so the editor and the compiler apply identical
  rules.

## One binary, one mental model

Everything above is in the single executable you installed. There is no runtime to
match, no optional native extension, no separate language-server package that can
drift out of step. That is a deliberate constraint rather than a packaging
convenience: it is what makes
[a file a program](../start/a-file-is-a-program.md) and what keeps a container
image around 22 MB.

## Where new functionality goes

The kernel is frozen. The standard library requires a syscall or FFI
justification. **Everything else is an Ecko-written
[package](../packages/concepts.md)** - portable, capability-gated, deletable. The
official packages are that layer made concrete, with no privileged access of any
kind.
