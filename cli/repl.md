# `ecko repl`

```bash
ecko            # bare invocation
ecko repl       # explicit
```

Both start the interactive session. See [The REPL](../start/repl.md) for how to
use it - multi-line input, session state, imports and `ai` from the prompt.

## What is different from running a file

- The value of each expression is printed automatically.
- Bindings persist across lines for the life of the session.
- Rebinding a top-level name does not need `mut`.
- [`ecko check`](./check.md) does not gate a line, because a name you are about
  to define on the next line is not an error at the prompt.

## Flags

The [global flags](./flags.md) work here too, which is the easy way to poke at a
provider:

```bash
ecko repl --provider ollama --model llama3
```
