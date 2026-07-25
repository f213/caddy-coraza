# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A thin Docker wrapper that rebuilds the upstream `caddy:<version>` image with the OWASP Coraza WAF
module (`github.com/corazawaf/coraza-caddy/v2`) compiled in via `xcaddy`. It exists so the zoya edge
proxy can run `coraza_waf` with the embedded OWASP CRS while staying pinned to a specific Caddy
version. Published to `cr.selcloud.ru/zoya/medical-caddy` as `:latest` and `:<caddy-version>` tags.

There is no test suite, linter, or package manager — `docker build` is the only build step.

## Build & run locally

```bash
docker build --build-arg CADDY_VERSION=2.11.2 -t medical-caddy .
```

## The non-obvious parts

- **Two-stage build.** Stage 1 is `caddy:${CADDY_VERSION}-builder` (ships `xcaddy`); it runs
  `xcaddy build "v${CADDY_VERSION}" --with github.com/corazawaf/coraza-caddy/v2@...`. Stage 2 is the
  matching stock `caddy:${CADDY_VERSION}` image with the custom binary copied over `/usr/bin/caddy`.
  Keep both `FROM` versions tied to the same `CADDY_VERSION` arg so the runtime matches the binary.
- **CRS is embedded.** `load_owasp_crs` + the `@coraza.conf-recommended` / `@crs-setup.conf.example`
  / `@owasp_crs/*.conf` includes resolve against the CRS compiled into the module — no rule files are
  mounted at runtime.
- **Do not** use `caddy add-package` / `caddy upgrade` to add the module — they resolve the stale
  coraza-caddy v1.2.2. Always build via `xcaddy --with .../v2`.

## Release / versioning

Pushing to `master` triggers `.github/workflows/ci.yml`, which builds an image (linux/amd64) for
every version in the `caddy_version` matrix and pushes to `cr.selcloud.ru/zoya/medical-caddy`. To
support a new upstream Caddy release, add the version to that matrix — image tags come from the
matrix values; there are no git tags. Auth uses the `ZOYA_CR_TOKEN` repo secret (`username: token`),
the same Selcloud registry token the backend repo uses.
