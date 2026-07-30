# The pipeline

How a program gets from text to output.

```
source -> lexer -> parser -> bytecode compiler -> stack VM
```

## Lexing

Source becomes tokens, each carrying a **span** - the line and column it came
from. Spans are why an error message can point at the expression that caused it,
and why an [`ai` trace](../ai/tracing.md) record names the source position of the
call.

Comments are collected rather than discarded, which is how
[`ecko fmt`](../cli/fmt.md) preserves them and how [`ecko doc`](../cli/doc.md)
finds `##` blocks by line number.

## Parsing

Recursive descent with precedence climbing. `|>` binds loosest, which is what
makes a pipeline read as a sequence rather than a nest.

Parse depth is bounded by `ECKO_MAX_PARSE_DEPTH` (default 128), so deeply nested
input from an untrusted source is a catchable error rather than a stack overflow.
See [Resource limits](../language/limits.md).

## Analysis

Before anything executes, [`ecko check`](../cli/check.md) walks the tree:
undefined names, arity, use-before-definition,
[match exhaustiveness](../language/pattern-matching.md), unwrapped
[credentials](../language/secrets.md). An error-level finding stops the run.

This is a deliberate insertion between parsing and execution. A dynamically typed
language usually discovers a typo on line 400 after doing 399 lines of work, some
of it irreversible.

## Compilation and execution

The whole language compiles to bytecode and runs on a
[stack VM](./vm.md). That is the shipped engine behind running a file, the REPL
and the embedding API.

One part of the language runs on a second engine - see
[Two execution tiers](./tiers.md).

## Formatting is part of the contract

Any new syntax must round-trip through the formatter **byte-identically**, and the
test suite enforces that across every example in the repository, twice, comparing
output. A syntax that cannot be printed canonically does not ship.

## What this means for you

Three observable consequences worth knowing:

- **Errors carry positions**, including inside pipelines and parallel maps.
- **A whole class of mistake is found before execution**, not during it.
- **Formatting is deterministic**, so `ecko fmt` is safe in a pre-commit hook.
