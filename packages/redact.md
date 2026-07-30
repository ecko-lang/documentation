# redact

Sensitive-key detection and masking for safe logging: is_sensitive_key, mask, and recursive map_of. Pure - no capabilities.

```bash
ecko get github.com/ecko-lang/redact
```

```ecko
import redact
```

Pure computation: it declares no capabilities, so it cannot touch the network, the filesystem or the environment.

Version 0.9.5 - [source](https://github.com/ecko-lang/redact) - MIT.

---


## `MASK`

What a redacted value is replaced with.

## `is_sensitive_key(key)`

Is this key name one that holds sensitive data?

## `mask(key, value)`

The value, unless its key is sensitive - then the mask.

## `map_of(m)`

A copy of the map with every sensitive key's value masked, recursing into
nested maps and lists. Non-sensitive scalars pass through untouched.
