# The stack VM

The engine that runs the language.

## Shape

A **chunk** of bytecode per compiled unit, executed against a value stack, with a
**frame** per call recording where to return and where its locals live.

Ecko's VM is not trying to be a JIT. It is a straightforward, carefully
tuned bytecode interpreter, on the reasoning that most Ecko programs are dominated
by IO - model calls, HTTP, SQL - and that a predictable interpreter is worth more
than a complicated compiler.

## Spans and call stacks

Instructions carry source positions, so a runtime error reports the expression
that raised it and the chain of calls that reached it. This survives through
pipelines, `pmap` and spawned tasks.

## try/catch frames

[`try`](../language/error-handling.md) pushes a handler frame. Raising unwinds to
the nearest one, running `finally` blocks on the way out. `return`, `break` and
`continue` unwind through a `try` without being caught, because they are not
errors.

## Superinstructions

Common instruction sequences are fused into single operations. This is the main
structural optimization: it removes dispatch overhead from the hot paths that
appear in every program - field access, comparison-and-branch, local arithmetic.

The lesson from tuning it, worth passing on: **micro-optimizations were noise and
structural changes were real.** Removing an allocation from a hot loop, or a whole
layer of indirection from a call path, moved the numbers; shaving instructions did
not.

## Bounds

`ECKO_MAX_DEPTH` (default 2000) caps call depth, so runaway recursion is a
catchable error rather than a process death. `ECKO_MAX_STEPS` is an opt-in step
budget. See [Resource limits](../language/limits.md).

## Parity

Every VM change is checked against the [AST evaluator](./tiers.md) on the same
programs, and a **compat suite** of frozen programs with golden output guards
against behaviour drift between releases. A golden file changes only through a
deliberate, documented breaking decision.
