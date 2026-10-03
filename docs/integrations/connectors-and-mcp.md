# Connector capabilities, tools and MCP boundaries

**Audience:** Integration developers, administrators. **Implementation status:** Partially Implemented.

**Prerequisites:** Read the platform overview and have access to the relevant organization or source checkout.

A catalog **skill** is guidance with requirements and activation metadata. A **tool definition** describes an invocable capability. A **runtime tool implementation** validates input and either creates a local artifact or requests a governed action. A **connector** translates an authorized control-plane action into a provider request. An **MCP server identifier** is currently declarative metadata, without an MCP client.

| Capability | Current implementation | Not implied |
| --- | --- | --- |
| Issue-tracker read/create | Jira Cloud REST v3 via Action Gateway; bounded plain-text work-item snapshot, approved issue creation | Azure DevOps/Linear support merely because QA questionnaire lists them |
| Source-control publish | GitHub draft PR with approved, completed workspace change-set digest | PR merge, production deploy, GitLab or Bitbucket PR publishing |
| Source-control checkout | HTTPS git through execution runtime; GitHub/Bitbucket source-control connection and static-token/GitHub-App issuer | A generic GitHub connector giving unlimited git or API access |
| Browser | Installed Playwright through signed execution grant and sandbox | MCP transport simply because `mcp: ["playwright"]` exists |
| MCP | Manifest/catalog selection fields only | Server discovery, MCP auth, tool enumeration, invocation or lifecycle support |

## Connector administration

Jira/GitHub API connections use `/api/organization/connector-connections`. Request data includes name, provider, validated baseUrl, `secretRef` and provider-specific settings (allowed Jira projects or GitHub repositories). One active connection per provider/organization is enforced; disable using its current version. Changes can tighten organization action policy but cannot grant an unknown action.

Repository authentication is a different connection type at `/api/organization/source-control-connections`, allowing a git host and exact repositories. Its credential leases are redeemed only by execution-role workloads, never an agent/model. Do not confuse connector publishing credentials with checkout credential policy.

The control plane validates connector URLs and refuses redirects. Container and git egress enforcement lives in the execution runtime; do not claim the same proxy intercepts every control-plane connector request. DNS rebinding and host-route protection for connectors require deployment review.

## Adding an integration

Implement the typed provider interface, add an explicit action registry entry, strict parameter validation, scope/summary logic, deterministic policy and payload-bound execution. Tests must cover wrong tenant, manifest/tool mismatch, scope, unavailable secret, duplicate dispatch and unknown write outcome. Do not expose a raw provider call as an ungated runtime tool.

## Implementation Status / Architecture Gap

No MCP installation/connection tables or management APIs were found. Do not create documentation pages for invented MCP lifecycle endpoints. External role loading, broader provider adapters and executable skills belong in the backlog until implemented.

## Source provenance

Reviewed against platform commit `9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4`. These references support the behavior described; types alone are not evidence that a capability executes.

- [apps/control-plane-api/src/actions/action-registry.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/actions/action-registry.ts)
- [apps/control-plane-api/src/actions/connector-service.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/actions/connector-service.ts)
- [apps/control-plane-api/src/actions/connectors/jira.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/actions/connectors/jira.ts)
- [apps/control-plane-api/src/actions/connectors/github.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/actions/connectors/github.ts)
- [apps/agent-runtime/src/tools/runtime-tool.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/agent-runtime/src/tools/runtime-tool.ts)
- [packages/contracts/src/manifest-v2.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/contracts/src/manifest-v2.ts)

## Related documentation

[Documentation index](../README.md) · [Implementation status](../reference/implementation-status.md)
