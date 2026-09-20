# ============================================================
# Parham themed PasarGuard panel
# - Admin dashboard: red/black "Parham" theme (default), sounds,
#   animations, Parham branding; donate/support/ads removed.
# - Subscription page: same theme, support link removed.
#
# VERSION PINS (bump these THREE together):
#   UPSTREAM_TAG  <->  base image tag  <->  dashboard overlay source
#   SUBTPL_REF    (subscription-template commit)
# ============================================================
ARG UPSTREAM_TAG=v5.4.1
ARG SUBTPL_REF=ba2d786

# ---------- stage 1: themed admin dashboard ----------
FROM oven/bun:1 AS dashboard-builder
ARG UPSTREAM_TAG
RUN apt-get update && apt-get install -y --no-install-recommends git ca-certificates \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /src
RUN git clone --depth 1 --branch ${UPSTREAM_TAG} https://github.com/PasarGuard/panel.git . \
 && rm -f dashboard/src/components/common/donation-popup.tsx \
         dashboard/src/components/common/github-star.tsx \
         dashboard/src/components/common/topbar-ad.tsx \
         dashboard/src/components/layout/github-star.tsx \
         dashboard/src/components/layout/goal-progress.tsx \
         dashboard/src/utils/docs-url.ts \
         dashboard/src/constants/Project.ts
# Parham overlay (mirrors dashboard/ paths)
COPY theme/dashboard-overlay/ ./dashboard/
WORKDIR /src/dashboard
RUN bun install --frozen-lockfile && /src/build_dashboard.sh
# -> /src/dashboard/build/ (+ 404.html)

# ---------- stage 2: themed subscription page (single index.html) ----------
FROM oven/bun:1 AS subtpl-builder
ARG SUBTPL_REF
RUN apt-get update && apt-get install -y --no-install-recommends git ca-certificates \
    && rm -rf /var/lib/apt/lists/*
ARG VITE_PANEL_DOMAIN=https://example.com
ARG VITE_FALLBACK_LANGUAGE=en
ARG VITE_PRIMARY_COLOR_LIGHT=oklch(0.55 0.22 25)
ARG VITE_PRIMARY_COLOR_DARK=oklch(0.65 0.22 25)
WORKDIR /src
RUN git clone https://github.com/PasarGuard/subscription-template.git . \
 && git checkout ${SUBTPL_REF}
COPY theme/subtpl-overlay/src/ ./src/
RUN bun install --frozen-lockfile \
 && VITE_PANEL_DOMAIN=${VITE_PANEL_DOMAIN} \
    VITE_FALLBACK_LANGUAGE=${VITE_FALLBACK_LANGUAGE} \
    VITE_PRIMARY_COLOR_LIGHT="${VITE_PRIMARY_COLOR_LIGHT}" \
    VITE_PRIMARY_COLOR_DARK="${VITE_PRIMARY_COLOR_DARK}" \
    bun run build \
 && mkdir -p /out/subscription \
 && cp dist/index.html /out/subscription/index.html

# ---------- stage 3: final image ----------
FROM pasarguard/panel:v5.4.1

# openssl برای ساخت خودکار گواهی SSL لازمه (بدونش پنل فقط روی localhost بایند میشه)
RUN apt-get update && apt-get install -y --no-install-recommends openssl \
    && rm -rf /var/lib/apt/lists/*

# Themed builds over the stock ones
COPY --from=dashboard-builder /src/dashboard/build/ /code/dashboard/build/
COPY --from=subtpl-builder /out/subscription/ /var/lib/pasarguard/templates/subscription/

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV UVICORN_HOST=0.0.0.0 \
    UVICORN_PORT=8000 \
    UVICORN_SSL_CERTFILE=/var/lib/pasarguard/certs/ssl_cert.pem \
    UVICORN_SSL_KEYFILE=/var/lib/pasarguard/certs/ssl_key.pem \
    UVICORN_SSL_CA_TYPE=private \
    ALLOWED_ORIGINS=* \
    ENABLE_RECORDING_NODES_STATS=True \
    CUSTOM_TEMPLATES_DIRECTORY=/var/lib/pasarguard/templates/

ENTRYPOINT ["/entrypoint.sh"]
