# Admin agent assignment transactions

**Audience:** Organization administrators, developers. **Implementation status:** Implemented.

**Prerequisites:** Read the platform overview and have access to the relevant organization or source checkout.

The transaction and idempotency behavior below originated with QA assignment. Current route validation resolves any supported catalog blueprint/version and optional organization installation; the sample QA form is not the only supported role.

In password-only customer deployments, the admin app now includes **Create and assign agents**. Activate employee accounts first, then refresh the setup panel to load eligible recipients.

## Workflow

1. Enter an agent name and select one to 25 active employees in the current organization.
2. Complete the selected versioned blueprint questionnaire, model/provider identifiers, and credential-source preference. The admin UI is still QA-focused; use the catalog and assignment APIs for the other supported role packages.
3. Review the enforced capabilities and choose **Create and assign**.
4. Each selected employee receives a distinct agent instance with a signed, employee-bound manifest. The admin assignment list records its recipient, creator, and creation time.
5. Employees open **Your assigned agents**, refresh, and choose **Verify and use agent**. Signature, key fingerprint, agent ID, employee ID and organization ID are verified before selection.

Agent creation is an explicit admin action, not an employee request impersonated by the admin. It does not add fabricated employee provisioning requests or bypass runtime policy: browser execution and external writes still require the existing approvals, and production deployment remains denied. Existing employee-request/admin-approval workflows continue unchanged.

## Isolation and retries

The server requires an authenticated organization admin, a valid write Origin, a current blueprint version, valid answers, and active employee identities from that same organization. Pending invites, disabled employees, admins, foreign users and duplicate recipients are rejected. Role, tenant and capabilities cannot be supplied by the browser.

Creation is one transaction, including all manifests, assignments, batch records, and audit entries. A recipient or signing failure rolls the entire batch back. The client supplies a UUID request ID and reuses it for unchanged retries. Server-side idempotency is scoped to the organization and includes the acting admin and validated payload: unchanged retries return the original result; conflicting reuse returns 409. Do not discard the request ID after an uncertain network response. A page reload currently loses the in-memory client retry ID; inspect the assignment list before resubmitting after a reload.

Each employee owns a separate instance and conversation history. An assignment is immutable in this slice: changing recipients requires creating new instances, not moving another employee's conversations or re-signing existing history. The admin list shows admin-created assignments; the existing catalog also includes agents from approved employee requests.

## Boundaries

- The catalog contains five engineering role identities and seven immutable versions. The assignment UI does not expose every generic-runtime capability.
- Model/provider fields select the runtime configuration; live Anthropic execution requires organization-managed credentials and V2/generic-runtime flags. This form does not collect secrets; configure the model credential through the separate administrator API.
- The new admin workflow targets database-managed password-mode organizations, not the legacy file-managed Google pilot.
- Reassignment, individual agent retirement, configuration editing/version rollout, seat limits and bulk operations beyond 25 recipients are not implemented.
- Disabling an employee still revokes their sessions and prevents further access to their agents. It does not delete retained conversations or assignments.

Audit events `agent.admin_created`, `agent.assigned`, and `agent.manifest.issued` identify the real admin and organization. Existing tenant and conversation ownership checks protect the employee workflow.

## Source provenance

Reviewed against platform commit `d2bc8d7fa3fc185cc4f487bdaa1f11611844763f`. These references support the behavior described; types alone are not evidence that a capability executes.

- [docs/admin-agent-assignments.md](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/docs/admin-agent-assignments.md)
- [apps/control-plane-api/src/app.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/app.ts)
- [apps/control-plane-api/src/database.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/database.ts)
- [apps/control-plane-api/test/admin-agents.spec.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/test/admin-agents.spec.ts)

## Related documentation

[Documentation index](../README.md) · [Implementation status](../reference/implementation-status.md)
