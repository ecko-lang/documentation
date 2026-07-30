# struct

Pack and unpack binary data with a struct-style format string, over the bytes type. Pure - no capabilities.

```bash
ecko get github.com/ecko-sh/struct
```

```ecko
import struct
```

Pure computation: it declares no capabilities, so it cannot touch the network, the filesystem or the environment.

Version 0.9.4 - [source](https://github.com/ecko-sh/struct) - MIT.

---


## `pack(fmt, values)`

pack(fmt, values) -> bytes.

## `unpack(fmt, data)`

unpack(fmt, data) -> [values].

## `sizeof(fmt)`

sizeof(fmt) -> total byte count.
