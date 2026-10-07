# Organization administrator setup journey

**Audience:** Organization administrators, operators. **Implementation status:** Partially Implemented.

**Prerequisites:** Read the platform overview and have access to the relevant organization or source checkout.

The supported password-mode path starts with operator-created customer membership and manually delivered activation links. A self-service signup portal, automatic invitation delivery and one-click setup wizard are not implemented. Follow this sequence so assignments refer to valid organization data.

1. Operator provisions the initial organization administrator using the documented customer CLI. Deliver the single-use activation URL privately. Activate and sign in using the admin application.
2. Complete the organization profile: name/legal name, code/slug and relevant locale/timezone settings. Re-fetch after a version conflict rather than overwriting another administrator's change.
3. Create hierarchical organizational units. Define departments/teams through `unitType`; avoid cycles. Create job families, disciplines, roles, levels and positions, then choose unit heads as positions.
4. Record employees before invitations. Link positions and organizational memberships separately. Invite a recorded employee using the API or UI; returned delivery is `MANUAL`. Suspend access through membership status, not a cosmetic job-role change.
5. Register an optional domain, publish the required DNS proof and invoke verification. Set a verified primary domain if needed. Domain verification does not provision DNS, certificates or reverse proxies for you.
6. Choose a catalog version and create an organization installation using shared questionnaire answers. Retrieve the bundle to distinguish INSTALLATION and AGENT questions.
7. Configure live connector connections, repository checkout connections and organization model credentials through their APIs. Put actual secrets into Vault (or the development file), and store only `secret://` references in connection metadata.
8. Configure model spending limits, explicit prices if enforcing cost limits, optional alert thresholds/webhooks and stricter organization action policies. Policy overrides can require approval or deny; they cannot weaken platform defaults.
9. Create assigned agents for active employees, using per-agent answers and ORGANIZATION_MANAGED credentials. Enable v2 issuance before creating agents intended for the generic runtime. Each assignment gets its own manifest; changing an installation does not update existing agents.
10. Have the employee verify/select an assigned agent. Submit a controlled workflow, inspect approvals, approve only the intended payload and retrieve evidence through the API. Run the pilot checklist before broader access.

## Setup progress

`GET /api/organization/setup-progress` returns checks for profile, structure, positions, people, assignments, employee access and domain. It reports stored configuration; it does not certify a working Vault, runtime, model or connector. A completed progress panel is not production readiness.

## Administration boundaries

Most organization management routes require password mode; Google sign-in does not imply these panels and mutations are enabled. Credential/lease management and artifact download have API support without full management screens. Reconciliation has an administrator screen. Refer to the [API index](../api/README.md) for each route's actual guard and schema.

## Resolve uncertain writes

Use **Writes to reconcile** in the administrator application. Inspect the external system before recording **Verified applied** or **Verified not applied**. The choice is final and does not retry the write. Follow [failure handling](../operations/failure-handling.md).

## Source provenance

Reviewed against platform commit `d2bc8d7fa3fc185cc4f487bdaa1f11611844763f`. These references support the behavior described; types alone are not evidence that a capability executes.

- [apps/control-plane-api/src/create-customer.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/create-customer.ts)
- [apps/control-plane-api/src/organization/tenancy-routes.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/tenancy-routes.ts)
- [apps/control-plane-web/src/app/organization/setup-progress.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-web/src/app/organization/setup-progress.ts)
- [apps/control-plane-web/src/app/agent-installations.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-web/src/app/agent-installations.ts)
- [apps/control-plane-web/src/app/agent-admin.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-web/src/app/agent-admin.ts)

## Related documentation

[Documentation index](../README.md) · [Implementation status](../reference/implementation-status.md)
