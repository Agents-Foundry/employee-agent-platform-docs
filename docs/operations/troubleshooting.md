# Troubleshooting by symptom

**Audience:** Operators, support teams, developers. **Implementation status:** Implemented.

**Prerequisites:** Read the platform overview and have access to the relevant organization or source checkout.

Use the run ID and safe error code to correlate API records, runtime logs and trace attribute af.run.id. Do not paste raw credentials, checkpoint bodies, activation links or employee message content into diagnostic logs.

| Symptom / error | Likely cause | Diagnosis | Resolution | Logs / responsible component |
| --- | --- | --- | --- | --- |
| API will not start: DATABASE_URL_REQUIRED | Tenant/platform connection missing | Check configured variable names and connectivity without printing URLs | Supply separate credentials and run migration tool | API startup, PgStore |
| TENANT_ROLE_BYPASSES_ROW_SECURITY | Tenant login is superuser/BYPASSRLS | Operator inspects pg_roles for that login | Correct role configuration; never disable the check | Database bootstrap/connect |
| DATABASE_SCHEMA_MISMATCH / MIGRATION_CHECKSUM_MISMATCH | Wrong release/schema or changed migration | Compare source SHA and schema_migrations checksum registry | Restore released SQL or deploy matching version; reviewed migration upgrade | API database startup |
| 421 UNRECOGNIZED_HOST | Host not canonical or verified | Compare proxy Host with configured auth URLs and domain verification state | Preserve recognized Host or verify proper domain; do not trust arbitrary forwarded headers | API host middleware / tenant-domain cache |
| Origin forbidden / sign-in loop | Mixed localhost/127.0.0.1 or wrong schemes/paths/cookie origin | Inspect configured URLs and actual Origin/cookie behavior | Use same host/scheme; production reverse-proxy /api correctly | Auth middleware / web-auth |
| MEMBERSHIP_REQUIRED | Verified Google subject not in directory | Confirm actual issuer/subject and approved directory entry | Operator adds approved mapping and restarts API | Auth / identity-directory |
| GENERIC_RUNTIME_DISABLED / RUNTIME_MANIFEST_V2_REQUIRED | Flag off or existing V1 agent | Read flag and assigned manifest version | Enable tested path and issue a new V2 agent; do not relabel signed V1 | Execution routes / provisioning |
| No runtime claims / run stays QUEUED | Identity/profile/organization absent or no polling runtime | Check registry, profile and signed request result | Register correct public key/profile/tenant and start runtime | Runtime transport / agent host |
| RUNTIME_UNAUTHENTICATED / RUNTIME_ROLE_FORBIDDEN | Invalid key/time/nonce/signature or wrong role | Verify clock skew within five minutes, registered public key and exact path/body signing | Correct key and role; agent/execution identities are separate | Workload transport |
| MODEL_PROVIDER_UNAVAILABLE / MODEL_CREDENTIAL_UNAVAILABLE | Unsupported provider, no active secret or BYOK | Read manifest provider/mode and model credential metadata | Supported provider plus organization-managed secret; BYOK cannot run here | Model gateway / secret broker |
| MODEL_BUDGET_EXCEEDED / MODEL_BUDGET_UNAVAILABLE | Limit reached or pricing/budget cannot be evaluated | Admin reads model budget/usage/price/alerts API | Review deliberate limits/pricing and outage; do not bypass metering | Spending service / runtime model step |
| TOOL_NOT_AVAILABLE / ACTION_DENIED | Tool not registered/manifest-granted or scope denied | Compare pinned bundle/tool version, operation digest and configured resource | Use intended supported tool/project; approved administrator tightens/reviews configuration | Kernel / Action Gateway |
| Waiting indefinitely for approval | Human decision pending or worker unavailable after approval | Read approval expiry and run status/reason; paused is not completed | Admin decides before expiry; inspect resume lease/runtime | Approvals / runtime transport |
| ISOLATION_UNAVAILABLE | local provider cannot satisfy sandboxed manifest | Read execution health provider/isolation | Use container provider and prebuilt images; development bypass is not a pilot fix | Execution provider |
| EGRESS_CONTROL_UNAVAILABLE / EGRESS_PROXY_UNAVAILABLE | Proxy disabled, unavailable image/network/start | Inspect execution error and safe egress diagnostics | Restore configured proxy/image/private network; fail closed | Container provider / egress proxy |
| RUNTIME_CHECKPOINT_INVALID / RUNTIME_CHECKPOINT_MISSING | Corrupt/bound-to-other-run or local checkpoint on lost host | Verify state mode, hash/version/session and known error; never edit body | Fail safely, investigate storage/config; start new reviewed task only when effects are known | Agent host / run checkpoints |
| ACTION_RECONCILIATION_REQUIRED | Prior write outcome unknown | GET organization action-reconciliations, verify actual issue/PR externally | Admin resolves APPLIED or NOT_APPLIED with evidence; no blind retry | Action Gateway / connector |
| ARTIFACT_STORE_UNAVAILABLE / integrity refusal | Store outage, inaccessible credentials, wrong bytes | Check safe store status, artifact object state/hash and expiry | Restore store or investigate corruption; obtain a fresh 60-second retrieval | Artifact service/store |
| RUNTIME_LOST / RUNTIME_RECOVERY_EXHAUSTED | No checkpoint, 24-hour abandonment or three handovers | Inspect lease timestamps/checkpoint metadata/worker availability | Restore workload capacity; reconcile any effects before a replacement task | Reaper / runtime host |

## Evidence to retain

Record source/deployment commit, run/step/action IDs, status reason, last liveness, approval decision/expiry and safe error code. Use immutable audit/run history to distinguish completed, refused and unknown effects. A successful HTTP response from the execution endpoint still requires checking result.status.

## Escalation boundaries

No shipped generic 'repair run' API safely rewrites event history, checkpoint binding or consumed grants. Do not directly UPDATE protected tables to fabricate completion. Documentation gaps belong in the backlog; an actual provider outage or unimplemented adapter requires engineering or operator action.

## Source provenance

Reviewed against platform commit `9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4`. These references support the behavior described; types alone are not evidence that a capability executes.

- [apps/control-plane-api/src/app.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/app.ts)
- [apps/control-plane-api/src/runtime/runtime-transport-service.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/runtime/runtime-transport-service.ts)
- [apps/execution-runtime/src/execution-service.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/execution-runtime/src/execution-service.ts)
- [apps/agent-runtime/src/errors.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/agent-runtime/src/errors.ts)
- [apps/control-plane-api/src/actions/action-reconciliation.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/actions/action-reconciliation.ts)

## Related documentation

[Documentation index](../README.md) · [Implementation status](../reference/implementation-status.md)
