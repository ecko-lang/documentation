# Embeddings & RAG

An embedding turns text into a vector, so that similarity becomes arithmetic.

```ecko
v  = embed("some text")            # [Float]
vs = embed_all(["a", "b", "c"])    # [[Float]]
cosine(v, v)                       # 1.0
```

`embed`, `embed_all` and `cosine` are global built-ins - no import.

## The vector store

```ecko
import std.db

db.add("doc1", "The moon is made of rock.")
db.add("doc2", "Cheese is a dairy product.")

hits = db.search("what is the moon made of?", limit: 3)
# [{ id: "doc1", text: "...", score: 0.83 }, ...]

db.save("knowledge.json")
db.load("knowledge.json")
```

In-process and in-memory, with JSON persistence. Search is cosine similarity over
a full scan - right-sized for the document counts a RAG pipeline actually holds,
and honest about not being a distributed index.

## The pipeline

```ecko
import std.rag

passages = rag.chunk(long_text, size: 120, overlap: 20)
index    = rag.index(passages)
hits     = rag.retrieve(index, "how does Ecko verify output?", k: 3)
answer   = rag.answer(hits, "how does Ecko verify output?")
```

`retrieve` scores hybrid: dense cosine similarity blended with a lexical
word-overlap signal. That blend is why results stay sensible offline with mock
embeddings, and sharpen rather than change character when a real model is
configured.

`answer` grounds a generation in the retrieved passages, which is the whole point
of RAG - the model answers from what you gave it rather than from what it recalls.

## Offline

Mock embeddings are **deterministic vectors**, so similarity search, clustering
and the whole retrieval path work with no key and give the same answer every run.
That makes a RAG pipeline testable in CI, which is unusual and deliberate.

They are not semantically meaningful. Offline, "the moon is rock" and "cheese is
dairy" have a stable but arbitrary similarity. Structure is testable; retrieval
*quality* needs a real model.

## Configuration

`ECKO_AI_EMBED_MODEL` picks the model, defaulting per provider -
`text-embedding-3-small` for OpenAI, `nomic-embed-text` for Ollama.

## Chunking, briefly

`size` and `overlap` are in words. Overlap exists so a sentence split across a
boundary is still findable from either side. Chunks that are too large dilute the
match; too small and they lose the context that made them meaningful. 100 to 200
words with 10 to 20% overlap is a reasonable starting point, and worth tuning
against your own retrieval results.
