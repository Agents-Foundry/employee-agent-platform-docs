# Authorization and tenant isolation

**Audience:** Security reviewers, backend developers. **Implementation status:** Implemented.

**Prerequisites:** Read the platform overview and have access to the relevant organization or source checkout.

Authorization combines server-derived identity, live membership, ownership and database row-level security. The implemented security roles are ADMIN and EMPLOYEE. Job roles and agent roles are separate domain concepts.

| Boundary | Enforcement |
| --- | --- |
| Tenant API work | `PgStore.tenant(organizationId)` sets transaction-local `app.organization_id` |
| Tenant database role | Cannot be superuser or BYPASSRLS; connect fails with `TENANT_ROLE_BYPASSES_ROW_SECURITY` |
| Tenant tables | ENABLE and FORCE ROW LEVEL SECURITY, tenant policies and composite tenant foreign keys |
| Cross-tenant operations | Explicit `PgStore.platform` using a separate BYPASSRLS login: authentication, catalog registration, runtime claims |
| Organization mutations | Password-mode route gates and service authorization against live records |
| Employee conversations, threads and events | Owning employee; tenant and employee filtering |
| Run governance and evidence | Owning employee or same-organization administrator |
| Runtime actions | Workload role, organization/profile registration, current lease, signed manifest and tool/action scope |

`organizations` uses its own ID in its tenant policy. Global authentication/catalog tables use different grants; do not assert every PostgreSQL table is tenant-scoped. The [schema reference](../data-model/schema.md) lists actual tables and policy source.

The platform login intentionally bypasses RLS for tightly scoped operations. Its connection secret and code paths are therefore a sensitive trust boundary. Database RLS cannot compensate for an incorrectly authorized platform-scoped query. Keep schema-owner, platform and tenant URLs separate; never give browser clients database credentials.

## Implementation Status / Architecture Gap

There is no general configurable permission catalog or granular security-role editor. The runtime uses explicit manifest capabilities and contextual action policy; the web administrator role is coarse. Do not map an organizational manager title to privileged API access.

## Source provenance

Reviewed against platform commit `9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4`. These references support the behavior described; types alone are not evidence that a capability executes.

- [apps/control-plane-api/src/db/pg-store.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/pg-store.ts)
- [apps/control-plane-api/src/db/bootstrap.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/bootstrap.ts)
- [apps/control-plane-api/src/db/migrations/0001-baseline.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts)
- [apps/control-plane-api/src/organization/structure-service.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/organization/structure-service.ts)
- [apps/control-plane-api/test/row-level-security.spec.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/test/row-level-security.spec.ts)

## Related documentation

[Documentation index](../README.md) · [Implementation status](../reference/implementation-status.md)
