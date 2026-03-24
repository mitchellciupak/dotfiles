---
description: Multi-lens code review
agent: build
---

Analyse the current diff with `git diff main...HEAD`.
Then invoke these reviewers in parallel:
- @review-backend for any files in api/ or server/
- @review-infra for any config, yaml, or deployment files
Synthesise their findings into a single prioritised report.