# Docker

An Ecko program in a container is a small image, because there is nothing to
install beside the binary.

```dockerfile
FROM debian:stable-slim AS build
RUN apt-get update && apt-get install -y curl ca-certificates
RUN curl -fsSL https://ecko.sh/install | sh

FROM gcr.io/distroless/base-debian12
COPY --from=build /usr/local/bin/ecko /usr/local/bin/ecko
COPY . /app
WORKDIR /app
EXPOSE 8080
CMD ["ecko", "server.ecko"]
```

Around 22 MB, and the runtime layer has **no shell and no package manager** -
distroless. There is nothing in the image to pivot to, because there is nothing
in the image.

## Why it comes out small

One static binary, standard library included. No interpreter to install, no
`node_modules` to copy, no build toolchain in the final layer, no system packages
for TLS or SQLite - the Linux builds link OpenSSL statically and SQLite is
compiled in.

## Committing `vendor/`

Commit it and `COPY . /app` is the whole dependency step: no network at build
time, no registry to be down, and the image contains exactly what you reviewed.
Otherwise add `RUN ecko install` and accept a network dependency in the build.

## Configuration

Environment variables, as everywhere else:

```dockerfile
ENV ECKO_HTTP_WORKERS=16
ENV ECKO_AI_MAX_CALLS=1000
```

Secrets are injected at runtime by the platform, never baked into a layer - an
image layer is readable by anyone who can pull the image. See
[Environment variables](../config/environment.md).

## A server that stays up

`http.serve` blocks, so the container's main process is the server and the
platform's restart policy is the supervisor. `ecko dev` is for development only:
it reloads on file change and does not restart on crash.

## Alternative: a built executable

[`ecko build`](./build.md) produces one file, which can go into `scratch` with
only CA certificates beside it. That trades the ability to read the source in the
image for a slightly smaller result.
