# geo

Geospatial basics: geohash encode/decode, great-circle distance and bearing, bounding boxes. Pure - no capabilities.

```bash
ecko get github.com/ecko-lang/geo
```

```ecko
import geo
```

Pure computation: it declares no capabilities, so it cannot touch the network, the filesystem or the environment.

Version 0.10.1 - [source](https://github.com/ecko-lang/geo) - MIT.

---


## `earth_radius()`

The IUGG mean Earth radius, in metres.

## `alphabet()`

The geohash alphabet: base 32, with a, i, l and o omitted so the encoding
cannot produce a character that is easily misread.

## `fail(message)`

The error raised for coordinates or hashes that are not valid.

## `check_coords(lat, lon)`

Reject coordinates outside the range the projection is defined on.

## `encode(lat, lon, precision)`

encode(lat, lon, precision) -> a geohash of `precision` characters.

The scheme interleaves longitude and latitude bits, longitude first, and
packs them five at a time into base 32. Each character therefore narrows the
box, which is why a shared prefix means spatial proximity - and why a prefix
match is a usable bounding-box query.

## `decode_bbox(hash)`

decode_bbox(hash) -> { min_lat, max_lat, min_lon, max_lon }: the cell the
hash names, rather than a single point. This is the honest answer - a
geohash is an area, and `decode` only picks its centre.

## `decode(hash)`

decode(hash) -> { lat, lon }: the centre of the cell. Use `decode_bbox` when
the size of the cell matters, which it usually does.

## `distance(lat1, lon1, lat2, lon2)`

The great-circle distance in metres, by the haversine formula.

Haversine rather than the law of cosines because it stays accurate for small
distances, where the cosine form loses precision to floating point.

## `km(lat1, lon1, lat2, lon2)`

`distance` in kilometres.

## `bearing(lat1, lon1, lat2, lon2)`

The initial bearing from the first point to the second, in degrees clockwise
from north. "Initial" because a great-circle course changes heading as you
travel it.

## `mod_positive(value, limit)`

`value` wrapped into 0..limit, for a value that may be negative.

## `destination(lat, lon, bearing_deg, metres)`

Where you arrive travelling `metres` from a point on a given bearing.

## `bbox(lat, lon, metres)`

A box that contains every point within `metres` of the centre.

The box is a little larger than the circle it brackets - it is the enclosing
rectangle - so it is a cheap first filter. Follow it with `distance` when
precision matters.

## `clamp(value, lo, hi)`

`value` held within `lo`..`hi`.

## `within(lat, lon, box)`

Is a point inside a box? Edges count as inside.

## `center(box)`

The centre of a box.
