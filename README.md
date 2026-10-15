# caddy-coraza

The stock [Caddy](https://caddyserver.com/) image rebuilt with the [OWASP Coraza](https://coraza.io/)
WAF module baked in ([`coraza-caddy`](https://github.com/corazawaf/coraza-caddy)). It is a drop-in
replacement for the official `caddy` image — same runtime, plus the `coraza_waf` directive and the
embedded OWASP Core Rule Set.

Published for `linux/amd64` and `linux/arm64` as `:<caddy-version>` and `:latest` to:

- `ghcr.io/f213/caddy-coraza`
- `docker.io/f213/caddy-coraza`

## Usage

```yaml
services:
  caddy:
    image: ghcr.io/f213/caddy-coraza:2.11.2
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
docker build --build-arg CADDY_VERSION=2.11.2 -t caddy-coraza .
```
