# `std.db`

An in-process vector store, for semantic search and retrieval.

```ecko
import std.db

db.add("doc1", "The moon is made of rock.")
db.add("doc2", "Cheese is a dairy product.")

hits = db.search("what is the moon made of?", limit: 3)
# [{ id: "doc1", text: "...", score: 0.83 }, ...]

db.save("knowledge.json")
db.load("knowledge.json")
db.remove("doc2")
db.count()
db.clear()
```

`net` to embed, `fs` to persist.

## How it works

`add` embeds the text and keeps the vector. `search` embeds the query and scores by
**cosine similarity over a full scan**.

A full scan is the honest choice at this scale: for the document counts a RAG
pipeline actually holds - hundreds to tens of thousands - it is fast, exact, and has
no index to build, tune or invalidate. It is not a distributed vector database and
does not pretend to be.

## Process-global

There is one store per process. `save` and `load` persist it as JSON.

That means it is **not durable and not shared**. Two processes have two stores; a
restart loses everything not saved. For a persistent shared index, use a real
database, or save and load around your process lifecycle.

## Offline

Embeddings come from the configured provider (`ECKO_AI_EMBED_MODEL`). Without a
key, **deterministic mock embeddings** keep similarity search working - so the
retrieval path is testable in CI with no network.

Mock vectors are stable but not semantically meaningful: offline, "moon" and
"cheese" have an arbitrary similarity. Structure is testable; retrieval *quality*
needs a real model. See [Embeddings & RAG](../ai/embeddings.md).

## Higher level

[`std.rag`](./rag.md) wraps chunking, indexing, retrieval and grounded answering
into a pipeline. Reach for `db` when you want to manage the store yourself, and
`rag` when you want the usual arrangement.
