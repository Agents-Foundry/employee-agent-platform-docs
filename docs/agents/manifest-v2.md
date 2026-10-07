# Agent Manifest V2: resolution, integrity and interpretation

**Audience:** Architects, runtime developers, security reviewers. **Implementation status:** Partially Implemented.

**Prerequisites:** Read the platform overview and have access to the relevant organization or source checkout.

A manifest is the fully resolved, signed configuration of **one employee-assigned agent**, not a reusable blueprint or an authorization policy editable by a model. `apiVersion` is `agents-foundry/v2` and `kind` is `AgentManifest`. Structural validation, cryptographic verification, assignment ownership and current action authorization are separate checks; all must pass where applicable.

## Resolution and issuance

Resolve the exact blueprint version and its pinned skills/tools/workflows from the catalog of record. Validate installation and agent answers against their questionnaire scopes. Merge validated configuration; connector selections map answer options to provider IDs and conditional MCP IDs. Resolve policy outcomes through the deterministic policy engine. Fill identity/model/ownership fields, preserve the bundle digest and optional installation ID, then sign an immutable snapshot.

`AGENT_MANIFEST_V2_ISSUANCE_ENABLED=true` opts newly issued agents into V2; default is false. Existing V1 manifests are not mutated or re-signed. Both server and desktop understand V1/V2, while generic `run.submit` and the runtime verifier require V2. Turning issuance off creates V1 again but does not permit removing V2 verification while issued V2 agents remain.

## Payload sections

| Section | Required content and meaning | Implemented interpretation / boundary |
| --- | --- | --- |
| apiVersion / kind | Exact V2 literals | Unknown versions fail closed |
| metadata | manifestId UUID; agentId, organizationId, employeeId; issuedAt; blueprint id/version, optional digest; optional installationId UUID | Subject checked against assignment/run; current catalog manifests include SHA-256 bundle digest |
| identity | name, role, department | Kernel identity prompt; does not grant security role |
| persona | profile | Declarative profile; no independent persona engine |
| runtime | profile, isolation sandboxed/local | Workload profile matching; execution provider must satisfy isolation |
| model | profile, provider, model, credentialMode | Supported adapter required; server refuses EMPLOYEE_BYOK |
| skills | Exact id/version references | Catalog guidance; kernel currently names IDs, not executable skill packages |
| tools | Tool IDs resolved from pinned definitions | Intersection with registered runtime implementations; catalog verifies exact tool version on action requests |
| connectors | Provider IDs and semantic capability IDs | Action Gateway checks active scoped connections/capability; selection alone never grants a write |
| mcp | Server IDs | Declarative only; no MCP client exists |
| memory | profile | No implemented memory provider or vector backend |
| knowledge | sources | Declarative source names, not proof of ingestion/retrieval |
| policies | profile, policyVersion, capabilities of action/outcome | Exact allowed actions plus tighten-only contextual policy; production.deploy denied |
| workflows | Workflow IDs | Task must name a listed workflow; resolved workflow guidance accompanies submit |
| evaluations | suite | Role governance/model-quality suite reference, not an evaluation executed on every task |
| configuration | Validated string or string-array questionnaire answers | Installation and agent scopes; no raw secret values |
| conversationSync | REQUIRED | Central conversation behavior; no optional unsynced branch |

## Structural constraints

The strict Zod schema rejects unknown fields. Record IDs match `[A-Za-z0-9_.:-]{1,120}`; short labels are trimmed 1–200 characters; profile/tool/workflow IDs are bounded lowercase slugs; versions are explicit semver strings; hashes are lowercase SHA-256 hex. `metadata.installationId` and manifestId are UUIDs. Datetimes require offsets.

Array caps: skills/tools/workflows/policy capabilities 100 each, connectors/MCP/knowledge sources 50 each; each connector has at most 50 bounded capability identifiers. Configuration keys are at most 80 characters, string values 2048 characters, arrays at most 50 strings of 200 characters. Structural acceptance is not sufficient business validation: catalog resolution also checks exact references, consistency, selections and known actions.

See [literal request schemas](../api/request-schemas.md) and [domain contracts](../api/contracts.md) for the exact validator declarations, rather than treating this prose as a second schema implementation.

## Signing and trust

The envelope contains payload, `algorithm: Ed25519`, base64 signature and keyId. The signer canonicalizes JSON by ordinally sorting object keys recursively while preserving array order, then signs the canonical payload bytes. keyId is SHA-256 of the public DER SPKI. API version is within the signed payload: relabeling V1 as V2 invalidates the signature.

The runtime uses a pinned SPKI, validates the structure, verifies signature/keyId, compares organization/employee/agent subject with run correlation, and verifies runtime profile. The server additionally verifies the stored manifest subject belongs to the row/employee requested. The desktop verifies before selecting an agent. Do not obtain public keys from an untrusted fresh response and assume a signature establishes identity.

Manifest keys persist in a protected file; automated rotation, multi-key verification and a vault-backed signing service are not implemented. Grants share the key but use a domain-separated signing input; a grant is not a manifest. Catalog upgrades produce a new version/assignment, not an edited signed payload.

## Complete validated examples

- [Resolved QA payload](../../examples/manifest-v2/qa-agent.payload.json): all sections from QA 1.2.0 and the actual resolver/policy, with fictional subject/configuration.
- [Signed example envelope](../../examples/manifest-v2/qa-agent.signed.json) and [demonstration public key](../../examples/manifest-v2/verification-key.json): cryptographically matched using an ephemeral key; no private key is committed.
- [run.submit command](../../examples/runtime/run-submit.json): schema-valid protocol example using that same manifest.

`example-model-id` is a schema-valid illustrative identifier, not a promised provider model. These records authorize nothing in a real tenant. The checker parses them with the source schema, re-resolves the pinned bundle/digest, verifies the actual signature and rejects a tampered payload. Editing only the payload breaks the example signature.

## Implementation Status / Architecture Gap

V2 structure/resolution/issuance/verification and governed execution are implemented. MCP, memory, executable skills, desktop BYOK and broad model routing are not implemented merely because their configuration fields exist. Do not add imaginary permissions, credentials or capability sections outside the actual schema.

## Source provenance

Reviewed against platform commit `d2bc8d7fa3fc185cc4f487bdaa1f11611844763f`. These references support the behavior described; types alone are not evidence that a capability executes.

- [packages/contracts/src/manifest-v2.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/manifest-v2.ts)
- [packages/contracts/src/runtime/v1/schemas.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/runtime/v1/schemas.ts)
- [apps/control-plane-api/src/agents/manifest-v2.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/agents/manifest-v2.ts)
- [apps/control-plane-api/src/manifest-signing.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/manifest-signing.ts)
- [apps/agent-runtime/src/manifest-verifier.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/agent-runtime/src/manifest-verifier.ts)
- [apps/employee-desktop/src/app/verify-manifest.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/employee-desktop/src/app/verify-manifest.ts)

## Related documentation

[Documentation index](../README.md) · [Implementation status](../reference/implementation-status.md)
