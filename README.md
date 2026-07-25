# medical-caddy

Caddy edge image for the zoya infrastructure, rebuilt with the [OWASP Coraza](https://coraza.io/)
WAF module baked in ([`coraza-caddy`](https://github.com/corazawaf/coraza-caddy)). It is a drop-in
replacement for the stock `caddy` image — same runtime, plus the `coraza_waf` directive and the
embedded OWASP Core Rule Set.

Published to `cr.selcloud.ru/zoya/medical-caddy:<caddy-version>` (and `:latest`).

## Usage

In the infrastructure `caddy` service, swap the image:

```yaml
services:
  caddy:
    image: cr.selcloud.ru/zoya/medical-caddy:2.11.2
```

Enable the WAF per site in the Caddyfile (requires the global option `order coraza_waf first`):

```caddyfile
{
  order coraza_waf first
}

example.com {
  coraza_waf {
    load_owasp_crs
    directives `
      Include @coraza.conf-recommended
      Include @crs-setup.conf.example
      Include @owasp_crs/*.conf
      SecRuleEngine On
    `
  }
  reverse_proxy backend:8000
}
```

`load_owasp_crs` loads the CRS embedded in the binary — no rule files need to be mounted.

## Build locally

```bash
docker build --build-arg CADDY_VERSION=2.11.2 -t medical-caddy .
```

## Release / versioning

Pushing to `master` triggers `.github/workflows/ci.yml`, which builds an image for every version in
the `caddy_version` matrix and pushes it to `cr.selcloud.ru`. To support a new upstream Caddy
release, add its version to that matrix — image tags come from the matrix values (there are no git
tags). Requires the `ZOYA_CR_TOKEN` repository secret (the Selcloud registry token, same one the
backend repo uses).
