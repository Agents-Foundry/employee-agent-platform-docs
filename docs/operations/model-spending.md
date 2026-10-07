# Model spending, prices, alerts and quality history

**Audience:** Administrators, operators. **Implementation status:** Implemented.

**Prerequisites:** Read the platform overview and have access to the relevant organization or source checkout.

Model calls reserve usage before execution and settle actual input/output usage afterwards. The host supplies this meter to the gateway; kernels cannot simply omit it. Reservations are run/correlation/provider/model bound and idempotent. Unknown outcomes remain counted at the reservation rather than freeing budget unsafely.

Administrators read/update organization model budgets, inspect usage, and maintain explicit model prices through model-budget/model-usage/model-prices endpoints. Tokens and cost limits are separate; a price is an administrator-supplied rate, not a promise that the platform continuously fetches provider pricing. If required pricing or metering cannot be checked, do not call the model.

Budget alerts are persisted, tenant-scoped and acknowledged by administrators. Optional outbound alert webhooks are configured with validated URLs and signatures; the operator must enable delivery with ALERT_WEBHOOKS_ENABLED. The API process polls delivery work every 15 seconds. Do not assume a configured endpoint automatically receives mail or that webhooks are part of a self-service notification center.

The model-quality admin panel reads imported evaluation history from PostgreSQL. The weekly/manual quality workflow stores history as CI artifacts; importing it is an explicit operator command, not an automatic live dashboard feed. Quality uses real model/judge calls against a simulated world under explicit budgets; governance evaluations remain deterministic.

For exact fields, price units, query bounds, webhook configuration and response contracts use [models/alerts API](../api/models-and-alerts.md), [schemas](../api/request-schemas.md) and [contracts](../api/contracts.md). Keep provider secret values out of budget reports and alert payloads.

## Source provenance

Reviewed against platform commit `d2bc8d7fa3fc185cc4f487bdaa1f11611844763f`. These references support the behavior described; types alone are not evidence that a capability executes.

- [apps/control-plane-api/src/spending/model-spending-service.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/spending/model-spending-service.ts)
- [apps/control-plane-api/src/spending/model-prices.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/spending/model-prices.ts)
- [apps/control-plane-api/src/spending/model-budget-alerts.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/spending/model-budget-alerts.ts)
- [apps/control-plane-api/src/webhooks/alert-webhook-service.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/webhooks/alert-webhook-service.ts)
- [apps/control-plane-api/src/quality/quality-service.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/quality/quality-service.ts)
- [.github/workflows/quality.yml](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/.github/workflows/quality.yml)

## Related documentation

[Documentation index](../README.md) · [Implementation status](../reference/implementation-status.md)
