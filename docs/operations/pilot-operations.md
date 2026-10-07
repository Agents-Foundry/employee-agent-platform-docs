# Pilot operations and host validation

**Audience:** Operators and release owners. **Implementation status:** Implemented.

**Prerequisites:** A deployed environment with scoped workload identities, operator access and dedicated health-check resources.

Repository tests prove code behavior. Deployed-pilot validation checks the actual database, secret store, artifact store, collector, identities and execution host. Keep these two kinds of evidence separate.

## Before enabling a pilot

1. Configure HTTPS and authenticated organization access. Disable demo access and environment/local-provider fallbacks.
2. Use the intended PostgreSQL tenant/platform/migration roles; enforce tenant RLS and preserve the migration set.
3. Configure Vault-backed organization secrets and model credentials, a private S3-compatible artifact store and managed artifacts.
4. Register organization-scoped agent/execution identities and pin the signing/grant verification keys.
5. Configure the container execution provider, browser image and locked-down egress proxy on hosts appropriate to the pilot tenant.
6. Enable required feature flags, provision a v2 agent and review the model quality, budgets and allowed resources.
7. Configure telemetry, alerts and administrator procedures for approvals and reconciliation.

## Render monitoring definitions

```bash
npm run ops:render
npm run ops:render -- --thresholds operations/alert-thresholds.example.json --out .readiness/rendered-operations
```

The renderer produces provider-neutral `operations.json`, `prometheus-rules.yaml` and `grafana-dashboard.json` from the metric catalog. Defaults are recommendations. Deployment overrides can change threshold, hold time, severity or enabled state; unknown alerts/settings fail validation. Import the result into the actual monitoring stack separately.

## Validate each host

Run with that deployment's environment and secret-reference files. Set `PILOT_ORGANIZATION_ID`, `PILOT_MODEL_PROVIDER` and `PILOT_RELEASE_COMMIT` (the deployed commit); optionally set `PILOT_ENVIRONMENT` to identify the evidence.

```bash
npm run pilot:validate -- --scope control-plane --out .readiness/operational/control-plane.json
npm run pilot:validate -- --scope execution-host --out .readiness/operational/execution-host.json
```

Use the relevant command on its host; do not run both against an unrelated development environment and call it pilot validation. A scope of `all` is available where both sets of prerequisites are present.

Checks cover database connectivity/migrations/roles/RLS, a dedicated Vault health secret, object-store round trip, synthetic OTLP export, workload identities, signing/grant verification, model credential availability, execution health, sandbox images, proxy enforcement and feature/fallback configuration as applicable to the scope.

Database probes run in read-only transactions. Service probes make dedicated health requests and temporary object/container operations. Output is scrubbed of recorded secret values. A failed check exits nonzero; inspect the report, correct the deployment and repeat. Validation does not perform a customer task or certify every deployment property.

## Telemetry and readiness

The control plane and execution runtime expose `/metrics` only when their token file is configured. The agent runtime exports through OTLP. Monitoring definitions use closed metric catalogs.

Run both host validators and the [controlled smoke test](pilot-smoke.md), then assess their reports together with test results. Six live proof IDs cover Vault, object store, telemetry, sandbox, private checkout and the real model. Evidence must name the exact assessed release and be at most seven days old. Missing evidence remains AMBER; a failed live proof is RED. `codeProofsPassed` and `operationalProofsPassed` are separate fields; `readyForControlledPilot` requires both.

[Operator runbook](pilot-runbook.md) · [Readiness](../qa/pilot-readiness.md)

## Source provenance

- [Validator](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/operations/src/validate.ts)
- [Renderer](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/operations/src/render.ts)
- [Readiness](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/readiness/src/assess.ts)
