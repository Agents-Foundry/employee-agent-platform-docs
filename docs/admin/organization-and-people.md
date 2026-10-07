# Organization, people and job administration

**Audience:** Organization administrators. **Implementation status:** Implemented.

**Prerequisites:** Read the platform overview and have access to the relevant organization or source checkout.

Use password-mode admin membership for the organization CRUD APIs. Each service verifies live administrator access. The tenant comes from the session; do not add `organizationId` to requests that reject unknown fields.

## Profile and verified domains

Profile writes retain a `version` for optimistic concurrency. Register a domain to get its verification proof, publish the required TXT record and call its verification route. Only a verified domain can become primary. Host resolution is cached with PostgreSQL change notifications and periodic recovery; domain registration is not TLS or DNS hosting automation.

## Units and membership

Departments and teams are organizational units. Assign a parent by ID, choose a `unitType`, and use a unique tenant-scoped code. Create/update checks prevent cycles and cross-tenant references. Archive rather than hard-delete units. Membership rows carry a membership type, primary flag and start/end timestamps. End a membership through the member route rather than silently rewriting history.

The unit head is a position, not an arbitrary free-text employee. Use ancestor, employee-option and head-position-option endpoints to choose a valid same-tenant reference.

## Job architecture and positions

`/api/organization/jobs/:kind` accepts families, disciplines, roles, levels or positions. Families contain disciplines; roles link to job architecture; levels have ranks; positions attach a unit, role and level with optional reporting position. These are job concepts, not security privileges. Validation rejects inactive/cross-tenant references and reporting cycles. Archive with the current version and re-fetch on conflict.

## Employment versus access

Record employee identity and employment before inviting. Position assignment and organization security membership are separate mutations. Membership suspension removes authorization; an employee record alone grants no sign-in. A global user may accept a private invitation into another organization and switch among active memberships. Invitations are single-use and manually delivered.

All significant organization changes retain before/after records in `organization_change_events`. Use API pagination rather than assuming the UI loaded every employee. Consult the generated [organization API](../api/organization.md) and [schema](../data-model/schema.md) for exact validators and constraints.

## Source provenance

Reviewed against platform commit `d2bc8d7fa3fc185cc4f487bdaa1f11611844763f`. These references support the behavior described; types alone are not evidence that a capability executes.

- [apps/control-plane-api/src/organization/tenancy-service.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/tenancy-service.ts)
- [apps/control-plane-api/src/organization/structure-service.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/structure-service.ts)
- [apps/control-plane-api/src/organization/job-service.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/job-service.ts)
- [apps/control-plane-api/test/tenancy.spec.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/test/tenancy.spec.ts)
- [apps/control-plane-api/test/jobs.spec.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/test/jobs.spec.ts)

## Related documentation

[Documentation index](../README.md) · [Implementation status](../reference/implementation-status.md)
