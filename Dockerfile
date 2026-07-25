# check=skip=SecretsUsedInArgOrEnv
ARG CADDY_VERSION=2.11.2
ARG CORAZA_VERSION=v2.5.0

FROM caddy:${CADDY_VERSION}-builder AS builder
ARG CORAZA_VERSION
# The -builder image pins the Caddy core via its CADDY_VERSION env, which xcaddy uses by
# default. load_owasp_crs uses the OWASP CRS embedded in coraza-caddy, so no rule files are
# mounted. Do NOT use `caddy add-package` — it resolves the stale coraza-caddy v1.2.2.
# coraza-caddy needs a newer Go than the builder ships; GOTOOLCHAIN=auto fetches it.
ENV GOTOOLCHAIN=auto
RUN xcaddy build --with github.com/corazawaf/coraza-caddy/v2@${CORAZA_VERSION}

FROM caddy:${CADDY_VERSION}
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
