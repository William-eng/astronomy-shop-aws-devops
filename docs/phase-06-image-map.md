# Rendered image mapping

Generated from the locked chart plus values.yaml. Upstream tags are versioned but remain mutable; only frontend is digest-pinned. Registry availability and architecture were not queried.

| Workload | Container | Type | Image |
|---|---|---|---|
| otel-collector-agent | opentelemetry-collector | containers | `otel/opentelemetry-collector-contrib:0.160.0` |
| grafana | grafana-sc-alerts | containers | `quay.io/kiwigrid/k8s-sidecar:2.11.2` |
| grafana | grafana-sc-dashboard | containers | `quay.io/kiwigrid/k8s-sidecar:2.11.2` |
| grafana | grafana-sc-datasources | containers | `quay.io/kiwigrid/k8s-sidecar:2.11.2` |
| grafana | grafana | containers | `docker.io/grafana/grafana:13.2.2-distroless` |
| jaeger | jaeger | containers | `jaegertracing/jaeger:2.20.0` |
| prometheus | prometheus-server | containers | `quay.io/prometheus/prometheus:v3.14.0` |
| accounting | wait-for-kafka | initContainers | `busybox:1.37.0` |
| accounting | accounting | containers | `ghcr.io/open-telemetry/demo:3.1.0-accounting` |
| ad | ad | containers | `ghcr.io/open-telemetry/demo:3.1.0-ad` |
| agent | agent | containers | `ghcr.io/open-telemetry/demo:3.1.0-agent` |
| astronomy-db | astronomy-db | containers | `postgres:18.4` |
| cart | wait-for-valkey-cart | initContainers | `busybox:1.37.0` |
| cart | cart | containers | `ghcr.io/open-telemetry/demo:3.1.0-cart` |
| chatbot | chatbot | containers | `ghcr.io/open-telemetry/demo:3.1.0-chatbot` |
| checkout | wait-for-kafka | initContainers | `busybox:1.37.0` |
| checkout | checkout | containers | `ghcr.io/open-telemetry/demo:3.1.0-checkout` |
| currency | currency | containers | `ghcr.io/open-telemetry/demo:3.1.0-currency` |
| email | email | containers | `ghcr.io/open-telemetry/demo:3.1.0-email` |
| flagd | init-config | initContainers | `busybox:1.37.0` |
| flagd | flagd | containers | `ghcr.io/open-feature/flagd:v0.16.0` |
| flagd | flagd-ui | containers | `ghcr.io/open-telemetry/demo:3.1.0-flagd-ui` |
| fraud-detection | wait-for-kafka | initContainers | `busybox:1.37.0` |
| fraud-detection | fraud-detection | containers | `ghcr.io/open-telemetry/demo:3.1.0-fraud-detection` |
| frontend | frontend | containers | `975050251876.dkr.ecr.us-east-1.amazonaws.com/astronomy-shop/frontend:a7da32eafe17bc72a9cfca69f1230dcfc23a73e0@sha256:abfa1fee95bcee4da40f78865026312714f533c009ed9fab479d1a575e6d3c89` |
| frontend-proxy | frontend-proxy | containers | `ghcr.io/open-telemetry/demo:3.1.0-frontend-proxy` |
| image-provider | image-provider | containers | `ghcr.io/open-telemetry/demo:3.1.0-image-provider` |
| kafka | kafka | containers | `ghcr.io/open-telemetry/demo:3.1.0-kafka` |
| load-generator | load-generator | containers | `ghcr.io/open-telemetry/demo:3.1.0-load-generator` |
| mcp | mcp | containers | `ghcr.io/open-telemetry/demo:3.1.0-mcp` |
| opamp-server | opamp-server | containers | `ghcr.io/open-telemetry/demo:3.1.0-opamp-server` |
| payment | payment | containers | `ghcr.io/open-telemetry/demo:3.1.0-payment` |
| product-catalog | wait-for-astronomy-db | initContainers | `busybox:1.37.0` |
| product-catalog | product-catalog | containers | `ghcr.io/open-telemetry/demo:3.1.0-product-catalog` |
| quote | quote | containers | `ghcr.io/open-telemetry/demo:3.1.0-quote` |
| recommendation | recommendation | containers | `ghcr.io/open-telemetry/demo:3.1.0-recommendation` |
| shipping | wait-for-flagd | initContainers | `busybox:1.37.0` |
| shipping | shipping | containers | `ghcr.io/open-telemetry/demo:3.1.0-shipping` |
| telemetry-docs | telemetry-docs | containers | `ghcr.io/open-telemetry/demo:3.1.0-telemetry-docs` |
| valkey-cart | valkey-cart | containers | `ghcr.io/valkey-io/valkey:9.0.4-alpine3.23` |
| opensearch | configfile | initContainers | `opensearchproject/opensearch:3.8.0` |
| opensearch | opensearch | containers | `opensearchproject/opensearch:3.8.0` |
