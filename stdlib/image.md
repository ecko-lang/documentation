# `std.image`

Decode, transform and encode PNG and JPEG. This is also what backs
[image input to `ai`](../ai/multimodal.md).

```ecko fragment
import std.image

img = image.load("photo.jpg")
print(image.width(img))
print(image.height(img))
print(image.dimensions(img))

small = image.resize(img, 512, 512)
part  = image.crop(img, 10, 10, 100, 100)

image.save(small, "thumb.png")
data = image.encode(small, "png")
img2 = image.decode(bytes_from_somewhere)

image.free(img)
```

## Handles

An image is a handle, not a value you copy around - which is why `free` exists. A
handle holds decoded pixels, and a large photograph is a lot of memory: a
4000×3000 image is tens of megabytes decoded regardless of how small the JPEG was.

Free handles you are finished with in a loop over many files, and be conscious of
how many you hold at once.

## Feeding `ai`

```ecko fragment
ai "what does this chart show?" on image.load("chart.png")
```

A transform pipeline flows straight in, and **resizing first is usually the right
move**:

```ecko fragment
ai "read the label" on image.resize(photo, 1024, 1024)
```

Images are tokens, often a great many. A 4000-pixel photograph rarely answers a
question better than a 1000-pixel one and costs several times more. See
[Multimodal](../ai/multimodal.md).

## Formats

PNG and JPEG, in and out. PNG is lossless and right for screenshots, charts and
anything with text or sharp edges; JPEG is lossy and right for photographs.
Re-encoding a JPEG loses quality each time, so transform from the original where
you can.

## Untrusted images

Decoding attacker-supplied image data means running a decoder over hostile input,
and a small file can decode to an enormous bitmap. **Check dimensions before
resizing**, and bound what you accept:

```ecko fragment
img = image.decode(upload)
d = image.dimensions(img)
if d.width * d.height > 40000000 { image.free(img) ; reject("too large") }
```
