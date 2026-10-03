# Introduction and reader journeys

**Audience:** All readers. **Implementation status:** Partially Implemented.

**Prerequisites:** Read the platform overview and have access to the relevant organization or source checkout.

An employee agent is an assigned software actor with a signed configuration, scoped capabilities and recorded execution. It is not a human employee account, an organization-wide shared chat or an administrator. Organizational units, job roles and positions describe the company's structure; authenticated membership and ADMIN/EMPLOYEE determine access.

The platform addresses the coordination problem around AI work: which employee owns a run, which repository or QA environment is in scope, who approves a write, and what evidence remains afterward. Start with one organization and a bounded engineering task. Read the current implementation matrix before planning unsupported departments or integrations.

## A first deployment journey

1. Developers establish the [local environment](../developer/local-development.md), with PostgreSQL and separate workload identities.
2. Operators configure [service processes](../deployment/runtime-processes.md), origins/hosts, secrets and persistent artifact/execution storage.
3. An initial administrator completes [organization setup](../admin/setup.md), activates employees and configures organization-managed model credentials.
4. The administrator installs a catalog blueprint/version and assigns a distinct agent to an active employee; an opt-in V2 manifest is issued.
5. The employee verifies their assignment and starts bounded work. Generic APIs are opt-in and the UI remains QA-focused; see [workspace limitations](../employee/workspace.md).
6. The runtime records steps/events, asks the control plane to authorize tools, pauses for human approval and records artifacts/outcomes.
7. Operators inspect readiness, spending and failures before expanding usage. Setup progress alone does not qualify a deployment as production ready.

## Reading paths

Architects should read the repository map, architecture overview, domain model and request sequence, then compare the status matrix with historical ADRs. Security engineers should trace authentication → tenant SQL scope → manifest → action policy → approval → grant → credential → artifact boundaries.

Application developers should read the manifest and runtime lifecycle before extending a tool or connector. There is no MCP extension SDK to configure today; the extension guide records the missing client and governance work. QA should pair the five role walkthroughs with test commands and evidence-derived readiness.

Terms and related references: [glossary](../reference/glossary.md), [request lifecycle](../architecture/request-lifecycle.md), [implementation status](../reference/implementation-status.md).

## Source provenance

Reviewed against platform commit `9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4`. These references support the behavior described; types alone are not evidence that a capability executes.

- [package.json](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/package.json)
- [packages/catalog/src/index.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/catalog/src/index.ts)
- [apps/control-plane-api/src/app.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/app.ts)

## Related documentation

[Documentation index](../README.md) · [Implementation status](../reference/implementation-status.md)
