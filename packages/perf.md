# perf

Measure the performance of your own Ecko code: time, measure, and bench (best-of-N stats)

```bash
ecko get github.com/ecko-sh/perf
```

```ecko
import perf
```

Pure computation: it declares no capabilities, so it cannot touch the network, the filesystem or the environment.

Version 0.9.4 - [source](https://github.com/ecko-sh/perf) - MIT.

---


## `time(f)`

time(f) -> elapsed milliseconds for one call of the zero-arg lambda f.

## `measure(label, f)`

measure(label, f) -> f's result. Prints "label: <ms> ms" as a side effect, so
you can drop it transparently around any call.

## `bench(f, opts = empty_map())`

bench(f, opts?) -> timing statistics in ms. opts: { iters (100), warmup (3) }.
Runs `warmup` discarded calls, then times `iters` calls individually.
