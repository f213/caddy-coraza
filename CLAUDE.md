# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A thin Docker wrapper that rebuilds the upstream `caddy:<version>` image with the OWASP Coraza WAF
module (`github.com/corazawaf/coraza-caddy/v2`) compiled in via `xcaddy`, so `coraza_waf` runs with
the embedded OWASP CRS while staying pinned to a specific Caddy version. Published to
`ghcr.io/f213/caddy-coraza` and `docker.io/f213/caddy-coraza` as `:latest` and `:<caddy-version>` tags.

There is no test suite, linter, or package manager — `docker build` is the only build step.

## Build & run locally

```bash
docker build --build-arg CADDY_VERSION=2.11.2 -t caddy-coraza .
```

## The non-obvious parts

- **Two-stage build.** Stage 1 is `caddy:${CADDY_VERSION}-builder` (ships `xcaddy`); it runs
  `xcaddy build "v${CADDY_VERSION}" --with github.com/corazawaf/coraza-caddy/v2@...`. Stage 2 is the
  matching stock `caddy:${CADDY_VERSION}` image with the custom binary copied over `/usr/bin/caddy`.
  Keep both `FROM` versions tied to the same `CADDY_VERSION` arg so the runtime matches the binary.
  The builder stage runs on `$BUILDPLATFORM` and cross-compiles via `GOOS`/`GOARCH`.
- **CRS is embedded.** `load_owasp_crs` + the `@coraza.conf-recommended` / `@crs-setup.conf.example`
  / `@owasp_crs/*.conf` includes resolve against the CRS compiled into the module — no rule files are
  mounted at runtime.
- **Do not** use `caddy add-package` / `caddy upgrade` to add the module — they resolve the stale
  coraza-caddy v1.2.2. Always build via `xcaddy --with .../v2`.

## Release / versioning

Pushing to `master` triggers `.github/workflows/ci.yml`, which builds a linux/amd64 + linux/arm64
image for every version in the `caddy_version` matrix and pushes to both GHCR and Docker Hub. To
support a new upstream Caddy release, add the version to that matrix — image tags come from the
matrix values; there are no git tags. GHCR auth uses `GITHUB_TOKEN`; Docker Hub uses the
`DOCKERHUB_USERNAME` repo variable and `DOCKERHUB_TOKEN` repo secret.
