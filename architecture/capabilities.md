# Capability enforcement

How the three-layer model is actually enforced. The user-facing view is
[Capabilities & gating](../packages/capabilities.md).

## The three layers

| layer | what it is | authority |
|---|---|---|
| **Kernel** | the language, `ai`, contracts | frozen; no IO of its own |
| **`std.*`** | native primitives needing a syscall or FFI | gated |
| **Packages** | Ecko code | only what they are granted |

The kernel deliberately contains no network, SQL or heavy dependencies. Every
capability that can reach outside the process lives in the standard library layer,
behind a gate.

## The mechanism

Every package function carries its **effective capability set** - what its
importer granted, intersected with what the importer itself held. A gated native
function checks the set belonging to the call currently in progress, which the
evaluator swaps as it crosses a package boundary.

Two properties follow:

- **The check is in the primitive**, not in a wrapper. There is no way to reach a
  gated operation that skips it, because the gate is the operation.
- **Grants only narrow.** A package passes on a subset of what it holds, never
  more. A dependency three levels deep cannot acquire `net` by asking.

Root code - the program you ran - holds full authority. Your own code is not
sandboxed from itself; everything you did not write is.

## Failure

A denied operation raises `{ kind: "capability", capability, package }` -
catchable, and specific enough to act on:

```ecko
try {
    thing.fetch()
} catch (e) {
    match get(e, "kind") {
        "capability" => print("{e.package} needs {e.capability}")
        _ => error(e)
    }
}
```

It raises at the **call**, not at import. A package that never exercises a
capability never needs it granted, so the failure tells you what the code actually
tried to do rather than what its manifest speculated about.

## Manifest versus grant

A manifest's `capabilities` list is **advisory** - the author's statement of
intent. Enforcement uses only the importer's `grant`. Keeping the two in step is a
courtesy to readers, and the registry design verifies the manifest against the
index entry, but a lying manifest gains nothing.

## What this does not do

It is not a sandbox against a hostile *host*, and it does not isolate memory or
CPU. A pure package cannot exfiltrate data because it has no way to reach out; it
can still loop forever. `ECKO_MAX_STEPS` bounds that separately - see
[Resource limits](../language/limits.md).
