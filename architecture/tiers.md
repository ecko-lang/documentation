# Two execution tiers

Ecko runs on two engines that share one global environment.

| tier | runs |
|---|---|
| **Bytecode VM** | the whole language |
| **AST evaluator** | `ai` internals, [contracts](../ai/contracts.md), `async` functions, `py()`, module loading |

## Why two

The VM is faster and is the shipped engine. But some of the AI machinery is
easier to get *right* as a tree walk over the source: a contract retry loop
re-runs a function body with a failure fed back, the `ai` tool loop suspends and
resumes around external calls, and both need the declaration's structure rather
than a flattened instruction stream.

Rather than complicate the VM for constructs that are dominated by network
latency anyway, those stay on the evaluator. A contract retry costs a model call;
the interpretation overhead is not measurable next to it.

## The bridge

The two directions both work, which is what makes the split invisible:

- Contracted and `async` functions are evaluator values, dispatched through a
  shared apply path that handles contracts, the retry loop and task spawning.
- The evaluator calls **VM closures** back through the same path, so
  higher-order built-ins, `@tool` functions and spawned tasks all work with
  either kind of function.

So you can pass a plain lambda to a contracted function, use an `async fn` as a
`map` callback, or hand a VM closure to a tool - and none of it needs to know
which engine produced the other.

## Why it is worth telling you

Mostly it is not: the tiers are an implementation detail and the language behaves
uniformly. Two places it becomes visible:

- **Contracted and `async` functions have different internal representations**
  from plain ones. They are still first-class values.
- **The evaluator is the parity oracle.** The test suite runs programs on both
  engines and asserts identical results, which is how a VM optimization is kept
  from quietly changing semantics.

That second point is the real reason the AST tier still exists at full fidelity:
a second independent implementation of the same semantics is the most effective
correctness check the project has.
