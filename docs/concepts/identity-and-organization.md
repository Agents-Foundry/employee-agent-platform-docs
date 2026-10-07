# Identity, employment and organizational roles

**Audience:** Administrators, security reviewers, developers. **Implementation status:** Implemented.

**Prerequisites:** Read the platform overview and have access to the relevant organization or source checkout.

The platform separates authentication, employment, structure and access. A global `users` row identifies a sign-in principal. `employees` records are owned by an organization and can exist before the person has an account. `organization_memberships` joins the global user to that tenant's employment record and assigns the security role.

| Concept | Implementation | Meaning |
| --- | --- | --- |
| Organization | `organizations` / `OrganizationProfile` | Tenant profile, active/suspended/disabled lifecycle |
| User | `users` plus issuer/subject identities | Global principal, active/disabled; can join multiple organizations |
| Employee | `employees` / `EmploymentRecord` | Employment inside one tenant; active/inactive, optional linked user |
| Membership | `organization_memberships` | ADMIN or EMPLOYEE; pending/active/suspended |
| Department or team | `organizational_units` / `OrganizationUnit` | Same hierarchical entity, distinguished by `unitType` |
| Job role and level | `roles`, `job_levels` | Organizational job architecture, not security permissions |
| Position | `positions`, `employee_position_assignments` | A seat in a unit with a job role, level and reporting relationship |
| Agent role | Catalog blueprint `role` | Declarative specialization of an assigned agent |

Supported unit types include business unit, division, department, sub-department, team, squad, pod, chapter, guild and other. These are not separate tables. Structure writes reject cycles and cross-tenant parent/head/member references; changes use optimistic versions and immutable before/after events.

An organizational head, job title or unit membership never grants ADMIN access. Services re-check live organization, employee and membership records rather than trusting a cached browser role. Account switching selects an active membership; a tenant domain resolves the host but does not itself authorize the visitor.

## Source provenance

Reviewed against platform commit `d2bc8d7fa3fc185cc4f487bdaa1f11611844763f`. These references support the behavior described; types alone are not evidence that a capability executes.

- [packages/contracts/src/tenancy.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/tenancy.ts)
- [packages/contracts/src/organization.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/organization.ts)
- [packages/contracts/src/jobs.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/packages/contracts/src/jobs.ts)
- [apps/control-plane-api/src/organization/tenancy-service.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/organization/tenancy-service.ts)
- [apps/control-plane-api/src/db/migrations/0001-baseline.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/db/migrations/0001-baseline.ts)

## Related documentation

[Documentation index](../README.md) · [Implementation status](../reference/implementation-status.md)
