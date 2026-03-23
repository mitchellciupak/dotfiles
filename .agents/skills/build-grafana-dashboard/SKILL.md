---
name: build-grafana-dashboard
description: Create grafana dashboard
---

## When to Invoke
Load this skill for any request to create, review, improve, or explain a Grafana dasboard.

## Step 1 — Scope the Dashboard

Before writing any query or JSON, establish:

| Question | Options |
|----------|---------|
| **Subject** | Single service, namespace, node, cluster-wide? |
| **Audience** | On-call (operational), team lead (trend), exec (SLO)? |
| **Method** | RED for services; USE for infrastructure; SLO for product |
| **Signals** | Metrics only, or also logs (Loki), traces (Tempo)? |

## Step 2 — Dashboard Structure

Organize every dashboard into labeled rows in this order:

```
Row: Overview    → SLO burn rate, error rate, p99 latency (stat/gauge panels)
Row: Traffic     → Request rate by endpoint/method, ingress throughput
Row: Errors      → Error rate %, breakdown by status code / exception type
Row: Latency     → p50 / p95 / p99 time series or heatmap
Row: Saturation  → CPU throttling %, memory pressure, queue depth
Row: Kubernetes  → Pod restarts, OOMKills, HPA replica count
Row: Logs        → Loki log panel filtered to $namespace + $deployment
Row: Traces      → Tempo search panel with exemplar linking
```

Omit rows that have no data — do not leave empty rows.

## Step 3 — Variable Templates

Dashboards for apis or services should likely include these template variables:

| Variable | Type | Query | Refresh |
|----------|------|-------|---------|
| `$namespace` | Query | `label_values(kube_pod_info, namespace)` | On time range |
| `$deployment` | Query | `label_values(kube_deployment_status_replicas{namespace="$namespace"}, deployment)` | On `$namespace` change |
| `$pod` | Query | `label_values(kube_pod_info{namespace="$namespace"}, pod)` | On `$namespace` change |
| `$interval` | Interval | `1m,5m,10m,30m` | — |

## Step 4 — Panel Recipes

### RED — Request Rate
```promql
sum by (deployment) (
  rate(http_server_request_duration_seconds_count{
    namespace="$namespace",
    deployment=~"$deployment"
  }[$interval])
)
```

### RED — Error Rate (%)
```promql
100 * (
  sum(rate(http_server_request_duration_seconds_count{
    namespace="$namespace",
    http_response_status_code=~"5.."
  }[$interval]))
  /
  sum(rate(http_server_request_duration_seconds_count{
    namespace="$namespace"
  }[$interval]))
)
```

### RED — p99 Latency
```promql
histogram_quantile(0.99,
  sum by (le) (
    rate(http_server_request_duration_seconds_bucket{
      namespace="$namespace",
      deployment=~"$deployment"
    }[$interval])
  )
)
```

### USE — CPU Utilization (cores)
```promql
sum by (pod) (
  rate(container_cpu_usage_seconds_total{
    namespace="$namespace",
    container!=""
  }[$interval])
)
```

### USE — Memory Saturation (% of limit)
```promql
sum by (pod) (container_memory_working_set_bytes{namespace="$namespace", container!=""})
/
sum by (pod) (kube_pod_container_resource_limits{namespace="$namespace", resource="memory"})
```

### SLO — Error Budget Remaining (%)
```promql
# Replace 0.001 with (1 - your SLO target), e.g. 0.001 = 99.9%
100 * (1 - (
  sum(increase(http_server_request_duration_seconds_count{http_response_status_code=~"5.."}[30d]))
  / sum(increase(http_server_request_duration_seconds_count[30d]))
) / 0.001)
```

## Step 5 — Deployment Annotations

Add an annotation query to mark deployments on every time series panel:

```promql
changes(
  kube_deployment_status_observed_generation{
    namespace="$namespace",
    deployment=~"$deployment"
  }[$__interval]
) > 0
```

## Step 6 — Quality Checklist

- [ ] Every panel has a clear title and correct unit (s, %, bytes, req/s)
- [ ] No hardcoded namespace or pod values — all parametrized via variables
- [ ] Stat/gauge panels have thresholds (green → yellow → red)
- [ ] Dashboard has a stable UID, and tags: `team:`, `service:`, `method:red` or `method:use`
- [ ] Key stats visible in top row without scrolling (mobile-friendly)
- [ ] Refresh interval ≤ 1 m for operational dashboards
- [ ] Loki and Tempo panels are linked to the same `$namespace`/`$deployment` scope
- [ ] Verified queries return data against live or recent time range
