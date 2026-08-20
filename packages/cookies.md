# cookies

Parse and serialize HTTP cookies for client sessions: read Set-Cookie headers into a jar, build the Cookie request header. Pure - no capabilities.

```bash
ecko get github.com/ecko-lang/cookies
```

```ecko fragment
import cookies
```

Pure computation: it declares no capabilities, so it cannot touch the network, the filesystem or the environment.

Version 0.10.1 - [source](https://github.com/ecko-lang/cookies) - MIT.

---


## `parse(set_cookie)`

parse(set_cookie) -> jar. Accepts one Set-Cookie header string or a list.

## `header(jar)`

header(jar) -> "name=value; ..." for the Cookie request header (names sorted;
attributes are response-only and not sent).

## `set(jar, name, value)`

set(jar, name, value) -> jar with a cookie added or replaced.

## `merge(jar, set_cookie)`

merge(jar, set_cookie) -> jar with cookies from a new Set-Cookie folded in
(later values win) - the session-accumulation helper.
