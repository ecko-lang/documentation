# html

A tolerant HTML parser for Ecko: parse to a node tree, extract text, and find elements. Great for feeding web content to ai. Pure - no capabilities.

```bash
ecko get github.com/ecko-sh/html
```

```ecko
import html
```

Pure computation: it declares no capabilities, so it cannot touch the network, the filesystem or the environment.

Version 0.9.4 - [source](https://github.com/ecko-sh/html) - MIT.

---


## `parse(src)`

Parse an HTML document into a node tree. The root is a `#root` node whose
children are the top-level elements. Tolerant of unclosed void elements.

## `text(node)`

text(node) -> all descendant text concatenated, tags stripped.

## `find(node, tag)`

find(node, tag) -> every descendant element with that tag (case-insensitive).

## `attr(node, name)`

attr(node, name) -> the attribute value, or null.
