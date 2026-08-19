# stats

Descriptive statistics for Ecko: mean, median, mode, variance, stdev, quantiles. Pure - no capabilities.

```bash
ecko get github.com/ecko-lang/stats
```

```ecko
import stats
```

Pure computation: it declares no capabilities, so it cannot touch the network, the filesystem or the environment.

Version 0.10.1 - [source](https://github.com/ecko-lang/stats) - MIT.

---


## `mean(xs)`

The arithmetic mean. Raises on an empty list.

## `median(xs)`

The middle value, averaging the two middle values for an even count.
Raises on an empty list.

## `mode(xs)`

The most frequent value; on a tie, the smallest (deterministic).

## `variance(xs)`

Sample variance / standard deviation (n - 1).

## `stdev(xs)`

Sample standard deviation (n-1) - the square root of `variance`.

## `pvariance(xs)`

Population variance / standard deviation (n).

## `pstdev(xs)`

Population standard deviation (n) - the square root of `pvariance`.

## `quantile(xs, q)`

The q-th quantile (q in 0..1) by linear interpolation between order statistics.

## `range_of(xs)`

max - min.
