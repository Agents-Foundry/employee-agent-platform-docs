# Adding roles, tools and providers

**Audience:** Platform and integration developers. **Implementation status:** Implemented.

**Prerequisites:** Read the platform overview and have access to the relevant organization or source checkout.

## Add a declarative role

1. Define a new `AgentBlueprintVersionDefinition` under `packages/catalog/src/blueprints`, using an exact version, runtime profile, model profile, persona, pinned skills/tools/workflows, policy action list and scoped questionnaire.
2. Use only existing known actions and implemented tools/connectors. Add or version shared skill/workflow definitions as necessary; do not alter a previously registered version.
3. Add its evaluation suite and at least one role-quality task. Every blueprint version must resolve its suite, workflow and dependency pins.
4. Register the new data in `builtInCatalog`, then run `npm run test:evals` and `npm run check`. The frontend role tests enforce absence of role names in platform execution code outside the legacy QA adapter.
5. Install the version for an organization, create a v2 employee assignment and exercise positive/denied/approval cases. Document new capabilities only after that implementation and evidence exist.

For a complete schema-valid data example, inspect the pinned Backend Engineer blueprint rather than a invented simplified blueprint. Role bundles currently ship in the monorepo; external role repository publishing is not implemented.

## Add a runtime tool

Implement `RuntimeTool`: id/version/description/inputSchema, `parse`, `governedAction`, `summarize`, parameter transmission and `execute`. Add the catalog tool definition with risk/execution location/side effects/actions/timeouts, then register the implementation in `apps/agent-runtime/src/main.ts`.

A new governed side effect also needs a known policy action and either a control-plane action handler or execution operation/grant support. A manifest declaration alone must never expose an ungated tool. Validate before digesting input, keep secrets out of summaries/results, and propagate AbortSignal cancellation.

## Add a model or connector provider

Model adapters implement `ModelProvider.complete`; retain the credential and spending gateway around them and discard sensitive provider error bodies. Connector adapters implement the typed interface, while the Action Gateway retains authorization, digest binding, single-use dispatch and audit. Add deterministic simulations and explicit live-provider verification separately.

## Acceptance criteria

Prove schema rejection, version immutability, catalog digest consistency, wrong tenant/employee, unavailable implementation, unknown action, denied scope, approval expiry/rejection, retry/recovery without duplicate effect and sanitized evidence. Test a new version without changing existing manifests. Record incomplete UI, adapter or deployment support in the implementation matrix.

## Source provenance

Reviewed against platform commit `9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4`. These references support the behavior described; types alone are not evidence that a capability executes.

- [packages/contracts/src/catalog-schemas.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/catalog-schemas.ts)
- [packages/catalog/src/index.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/catalog/src/index.ts)
- [apps/control-plane-api/src/catalog/catalog-registry.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/catalog/catalog-registry.ts)
- [apps/agent-runtime/src/tools/runtime-tool.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/agent-runtime/src/tools/runtime-tool.ts)
- [apps/agent-runtime/src/main.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/agent-runtime/src/main.ts)
- [apps/control-plane-api/test/frontend-engineer.spec.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/test/frontend-engineer.spec.ts)
- [apps/control-plane-api/test/evaluations.spec.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/test/evaluations.spec.ts)

## Related documentation

[Documentation index](../README.md) · [Implementation status](../reference/implementation-status.md)
