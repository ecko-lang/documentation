# graph

Adjacency-list graphs: build, traverse, and answer reachability and path questions. Pure - no capabilities.

```bash
ecko get github.com/ecko-lang/graph
```

```ecko fragment
import graph
```

Pure computation: it declares no capabilities, so it cannot touch the network, the filesystem or the environment.

Version 0.10.1 - [source](https://github.com/ecko-lang/graph) - MIT.

---


## `fail(message)`

The error this package raises.

## `new(opts = {})`

An empty graph. `opts` takes `{ directed: false }` for an undirected one;
the default is directed, because the questions this package is for - who can
approve this, what depends on what - have a direction.

## `from_edges(pairs, opts = {})`

Build from a list of `[src, dst]` pairs.

## `add_node(g, node)`

Add a node with no edges. Adding one that exists changes nothing.

## `add_edge(g, src, dst)`

Add an edge, adding either endpoint that is missing. In an undirected graph
the reverse edge is added too. Adding the same edge twice changes nothing.

## `link(g, src, dst)`

Record one direction of an edge.

## `remove_edge(g, src, dst)`

Remove an edge, leaving both nodes in place.

## `unlink(g, src, dst)`

Drop one direction of an edge.

## `remove_node(g, node)`

Remove a node and every edge touching it.

## `has_node(g, node)`

Is this node in the graph?

## `has_edge(g, src, dst)`

Is there an edge from `src` to `dst`?

## `nodes(g)`

Every node, sorted.

## `neighbors(g, node)`

The nodes `node` points at, sorted. Raises if the node is unknown, because
silently returning `[]` for a typo is how a traversal quietly explores
nothing.

## `edges(g)`

Every edge as a sorted list of `[src, dst]`. An undirected edge appears once,
with its endpoints in sorted order.

## `order(g)`

How many nodes.

## `size(g)`

How many edges.

## `out_degree(g, node)`

How many edges leave this node.

## `in_degree(g, node)`

How many edges arrive at this node.

## `degree(g, node)`

Out-degree plus in-degree. On an undirected graph both count the same edges,
so this is twice the neighbour count - use `out_degree` there instead.

## `bfs(g, start)`

Breadth-first order from `start`, including `start` itself.

Layer by layer, so the order doubles as "how far away is each node" - which
is why `path` is built on this rather than on `dfs`.

## `dfs(g, start)`

Depth-first order from `start`, including `start` itself.

Iterative rather than recursive: a long chain would otherwise hit the
recursion cap, and a graph big enough to matter is exactly the one that has
long chains.

## `reachable(g, start)`

Every node reachable from `start`, sorted, excluding `start` itself.

The card's question: who can approve this spend, directly or by delegation?

## `connected(g, src, dst)`

Can `src` reach `dst`? A node always reaches itself.

## `path(g, src, dst)`

The fewest-hops path from `src` to `dst`, or null if there is none.

Breadth-first, so the first time `dst` is seen is by a shortest route. Every
edge counts as one hop: weights are a different package (`graph_algo`).

## `distance(g, src, dst)`

The number of hops on the shortest path, or null if unreachable.

## `components(g)`

Connected components, each sorted, the list sorted by first member.

Meaningful on an undirected graph. On a directed one this follows edges
forwards only, so it reports what is reachable rather than true weak
components.

## `has_cycle(g)`

Does the graph contain a directed cycle?

Depth-first with three colours: unvisited, on the current path, and finished.
An edge back to something on the current path is a cycle; an edge to
something merely finished is a diamond, which is not.

## `topo_sort(g)`

Nodes ordered so every edge points forwards. Raises on a cyclic graph rather
than returning an order that cannot exist.

Kahn's algorithm: repeatedly take a node nothing points at. Ties are broken
by sorting, so the result is stable rather than merely valid.
