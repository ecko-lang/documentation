# `std.rag`

Chunking, embedding, retrieval and grounded answering as one pipeline.

```ecko
import std.rag

passages = rag.chunk(long_text, size: 120, overlap: 20)
index    = rag.index(passages)
hits     = rag.retrieve(index, "how does Ecko verify output?", k: 3)
answer   = rag.answer(hits, "how does Ecko verify output?")
```

Runs fully offline in [mock mode](../ai/mock-mode.md).

## `chunk`

Splits into overlapping word passages. `size` and `overlap` are in words.

Overlap exists so a sentence split across a boundary is still findable from either
side. Chunks that are too large dilute the match; too small and they lose the
context that made them meaningful. 100 to 200 words with 10 to 20% overlap is a
reasonable start, worth tuning against your own results.

## `index`

Takes strings, or `{ id, text }` maps when you need to trace a passage back to its
source. Returns entries with `id`, `text` and `vec`.

## `retrieve`

Scores **hybrid**: dense cosine similarity blended with a lexical word-overlap
signal.

That blend is why results stay sensible offline with mock embeddings, and why they
sharpen rather than change character when a real model is configured. It also helps
with the classic dense-retrieval weakness - an exact identifier, error code or proper
noun that embeddings smooth over but a lexical signal catches.

## `answer`

Generates from the retrieved passages, so the model answers from **what you gave
it** rather than from what it recalls. That is the entire point of RAG.

For a stronger guarantee, add a [contract](../ai/contracts.md):

```ecko
@ensures("the answer only uses facts from the provided passages")
fn grounded(hits, q) = rag.answer(hits, q)
```

Bearing in mind that a string contract is a probabilistic judgment and always passes
offline.

## Offline behaviour

Deterministic mock embeddings and a mock `ai`, so the whole pipeline is testable in
CI. Retrieval *ordering* is stable but arbitrary - structure is testable, quality
needs a real model.

## Lower level

[`std.db`](./db.md) is the vector store on its own, when you want to manage the index
yourself. `embed`, `embed_all` and `cosine` are global built-ins.
