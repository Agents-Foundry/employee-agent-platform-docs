# Secrets, model keys and repository credential leases

**Audience:** Security reviewers, operators, administrators. **Implementation status:** Partially Implemented.

**Prerequisites:** Read the platform overview and have access to the relevant organization or source checkout.

Tenant connection/model records store references matching `secret://<name>`, not raw values. `SecretBroker` resolves them per organization at the moment of use. `SecretValue` redacts string conversion, JSON and inspection; only `reveal()` hands a value to a provider. Missing references, secrets or failed providers fail closed.

## Secret providers

`SECRET_PROVIDER=development` uses the organization-scoped operator file at `CONNECTOR_SECRETS_PATH`, read at use. It is plaintext development storage. `SECRET_PROVIDER=vault` uses Vault KV v2 at mount/data/prefix/organization/name, field `value`, with a token re-read from `VAULT_TOKEN_PATH`. HTTPS and redirect refusal protect requests; namespace/prefix/mount are explicit configuration. A simulated Vault test is not a completed live deployment validation.

## Model credentials

An administrator PUTs a reference at `/api/organization/model-credentials/:provider`, with an optimistic version when replacing it. An agent runtime can request the live key only while holding a RUNNING run whose valid manifest names that provider and ORGANIZATION_MANAGED mode. Rotation/disable affects the next call. The runtime receives the provider key in memory for the call; provider-side scope still matters.

EMPLOYEE_BYOK is a stored credential-mode choice but refuses server execution. There is no implemented desktop-local model runtime or OS credential-store integration. An environment fallback requires `AGENT_RUNTIME_ENV_MODEL_KEYS=true` and is development-only.

## Checkout leases

For a permitted private checkout, the Action Gateway issues a lease atomically with the signed grant. The lease is tenant/repository/ref/operation-digest bound, one use, five minutes maximum and never beyond the grant. Redemption rechecks grant, run, connection, workload role and organization. Only the execution runtime receives the credential.

Static tokens rely on their provider-side scope and cannot be withdrawn after delivery by revoking the lease. GitHub App mode mints a one-repository `contents: read` token and attempts early provider revocation; revocation bookkeeping is in memory and cannot guarantee early revocation after a control-plane restart. Provider expiry remains a bound.

Git receives the credential as a repository-scoped child-process header, never in its URL, command line, credential helper or persisted config. Output is redacted, submodules are not fetched, and failed/interrupted clones are discarded and leases released. A grant requiring a lease never falls back to anonymous checkout.

## Source provenance

Reviewed against platform commit `d2bc8d7fa3fc185cc4f487bdaa1f11611844763f`. These references support the behavior described; types alone are not evidence that a capability executes.

- [apps/control-plane-api/src/secrets/secret-broker.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/secrets/secret-broker.ts)
- [apps/control-plane-api/src/secrets/model-credentials.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/secrets/model-credentials.ts)
- [apps/control-plane-api/src/credentials/credential-broker.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/credentials/credential-broker.ts)
- [apps/control-plane-api/src/credentials/credential-issuers.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/credentials/credential-issuers.ts)
- [apps/execution-runtime/src/credential-client.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/execution-runtime/src/credential-client.ts)
- [apps/control-plane-api/test/credential-broker.spec.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/test/credential-broker.spec.ts)

## Related documentation

[Documentation index](../README.md) · [Implementation status](../reference/implementation-status.md)
