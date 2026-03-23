---
name: build-grafana-alert
description: Create grafana alerts
---

## When to Invoke
Load this skill for any request to create, review, improve, or explain grafana alerting.

## Clarify Before Writing

Answer these before writing any YAML:

| Question | Why it matters |
|----------|---------------|
| What is the SLO? (e.g. 99.9% availability, p99 < 300 ms) | Determines burn rate multipliers and error budget |
| What is the consequence of a breach? | Drives severity: `critical` (page) vs `warning` (ticket) |
| What should the on-call do? | Required for `runbook_url` annotation |
| Are there existing recording rules? | Avoid duplicating expensive range queries |

Anwser by inspecting the codebase or listing the grafana alerts via mcp first if possible


## Determine Severity Tiers

| Severity | Meaning | Default Routing |
|----------|---------|-----------------|
| `critical` | SLO breach imminent or in progress; wake someone up | PagerDuty |
| `warning` | Elevated risk; investigate before next business hour | Slack |
| `info` | Notable event, no human action needed | Log only |

## Common Kubernetes Alert Patterns

- Pod Crash Looping
- Container CPU Throttling > 25%
- OOMKill
- Persistent Volume Near Full

## Alert Quality Checklist

- [ ] Alert fires **only when human action is required** — no noise that auto-resolves
- [ ] `for` duration avoids flapping (minimum 2 m for critical, 5 m for warning)
- [ ] `runbook_url` annotation is present and resolves to a real, up-to-date page
- [ ] Templated routing labels (`team`, `service`, `env`) are present
- [ ] Rules are validated
- [ ] Recording rules are defined in a separate group, evaluated before alert groups
- [ ] Inhibition rules considered: suppress symptom alerts when the root-cause alert is already firing
- [ ] If the alert is based on an api or service hosted in the cluster, strongly consider configuring `no_data_state: Normal` to reduce noise when the service may be down for other reasons. Alerts based on kuberentes metrics should take care of alerting to the fact that the service is down
- [ ] Check that a notification policy exists already for the alert, Slack is the perfered contact option.