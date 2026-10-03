# PostgreSQL schema and constraints

**Audience:** Backend developers, architects and database operators. **Implementation status:** Implemented, source-derived schema.

**Prerequisites:** Read [data ownership and migrations](README.md).

The current control plane uses PostgreSQL, with 15 registered migrations. This dictionary extracts CREATE TABLE fields plus explicit ADD COLUMN and TYPE changes from actual exported migration SQL. Native conversion migration 0008 changes many ISO timestamp/JSON text fields to timestamptz/jsonb; signed or digest-pinned text remains text. This is a static reference, not a live database introspection result. No RLS policy or trigger is inferred from a TypeScript interface. Consult linked migration SQL for complete check/trigger/grant semantics.

[Exact combined migration SQL](../../reference-data/postgresql-migrations.sql) · [Machine-readable dictionary](../../reference-data/schema.json). Do not run the combined file instead of the checksum-locked migration tool.

## Tables

| Table | Ownership | Source |
| --- | --- | --- |
| [organizations](#organizations) | Global/auth/catalog or special-scope table; inspect grants/policy | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts) |
| [users](#users) | Global/auth/catalog or special-scope table; inspect grants/policy | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts) |
| [employees](#employees) | Tenant ID on row; verify FORCE RLS in migration | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts) |
| [organization_memberships](#organization_memberships) | Tenant ID on row; verify FORCE RLS in migration | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts) |
| [identities](#identities) | Global/auth/catalog or special-scope table; inspect grants/policy | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts) |
| [login_transactions](#login_transactions) | Global/auth/catalog or special-scope table; inspect grants/policy | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts) |
| [password_credentials](#password_credentials) | Global/auth/catalog or special-scope table; inspect grants/policy | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts) |
| [account_password_credentials](#account_password_credentials) | Global/auth/catalog or special-scope table; inspect grants/policy | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts) |
| [auth_sessions](#auth_sessions) | Tenant ID on row; verify FORCE RLS in migration | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts) |
| [invitations](#invitations) | Global/auth/catalog or special-scope table; inspect grants/policy | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts) |
| [password_resets](#password_resets) | Global/auth/catalog or special-scope table; inspect grants/policy | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts) |
| [account_link_invitations](#account_link_invitations) | Tenant ID on row; verify FORCE RLS in migration | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts) |
| [catalog_blueprint_versions](#catalog_blueprint_versions) | Global/auth/catalog or special-scope table; inspect grants/policy | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts) |
| [organization_agent_installations](#organization_agent_installations) | Tenant ID on row; verify FORCE RLS in migration | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts) |
| [agents](#agents) | Tenant ID on row; verify FORCE RLS in migration | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts) |
| [agent_manifests](#agent_manifests) | Tenant ID on row; verify FORCE RLS in migration | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts) |
| [agent_assignments](#agent_assignments) | Tenant ID on row; verify FORCE RLS in migration | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts) |
| [admin_agent_batches](#admin_agent_batches) | Tenant ID on row; verify FORCE RLS in migration | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts) |
| [provisioning_requests](#provisioning_requests) | Tenant ID on row; verify FORCE RLS in migration | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts) |
| [conversations](#conversations) | Tenant ID on row; verify FORCE RLS in migration | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts) |
| [messages](#messages) | Tenant ID on row; verify FORCE RLS in migration | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts) |
| [approvals](#approvals) | Tenant ID on row; verify FORCE RLS in migration | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts) |
| [qa_runs](#qa_runs) | Tenant ID on row; verify FORCE RLS in migration | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts) |
| [llm_key_bindings](#llm_key_bindings) | Tenant ID on row; verify FORCE RLS in migration | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts) |
| [audit_events](#audit_events) | Tenant ID on row; verify FORCE RLS in migration | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts) |
| [organizational_units](#organizational_units) | Tenant ID on row; verify FORCE RLS in migration | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts) |
| [organization_change_events](#organization_change_events) | Tenant ID on row; verify FORCE RLS in migration | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts) |
| [job_families](#job_families) | Tenant ID on row; verify FORCE RLS in migration | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts) |
| [job_disciplines](#job_disciplines) | Tenant ID on row; verify FORCE RLS in migration | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts) |
| [roles](#roles) | Tenant ID on row; verify FORCE RLS in migration | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts) |
| [job_levels](#job_levels) | Tenant ID on row; verify FORCE RLS in migration | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts) |
| [positions](#positions) | Tenant ID on row; verify FORCE RLS in migration | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts) |
| [organizational_unit_memberships](#organizational_unit_memberships) | Tenant ID on row; verify FORCE RLS in migration | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts) |
| [organization_domains](#organization_domains) | Tenant ID on row; verify FORCE RLS in migration | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts) |
| [employee_position_assignments](#employee_position_assignments) | Tenant ID on row; verify FORCE RLS in migration | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts) |
| [agent_threads](#agent_threads) | Tenant ID on row; verify FORCE RLS in migration | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts) |
| [agent_runs](#agent_runs) | Tenant ID on row; verify FORCE RLS in migration | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts) |
| [agent_run_steps](#agent_run_steps) | Tenant ID on row; verify FORCE RLS in migration | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts) |
| [agent_events](#agent_events) | Tenant ID on row; verify FORCE RLS in migration | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts) |
| [agent_artifacts](#agent_artifacts) | Tenant ID on row; verify FORCE RLS in migration | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts) |
| [agent_run_leases](#agent_run_leases) | Tenant ID on row; verify FORCE RLS in migration | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts) |
| [runtime_request_nonces](#runtime_request_nonces) | Global/auth/catalog or special-scope table; inspect grants/policy | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts) |
| [organization_connector_connections](#organization_connector_connections) | Tenant ID on row; verify FORCE RLS in migration | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts) |
| [agent_action_requests](#agent_action_requests) | Tenant ID on row; verify FORCE RLS in migration | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts) |
| [organization_action_policies](#organization_action_policies) | Tenant ID on row; verify FORCE RLS in migration | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts) |
| [agent_action_executions](#agent_action_executions) | Tenant ID on row; verify FORCE RLS in migration | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts) |
| [agent_execution_grants](#agent_execution_grants) | Tenant ID on row; verify FORCE RLS in migration | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts) |
| [organization_model_budgets](#organization_model_budgets) | Tenant ID on row; verify FORCE RLS in migration | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0002-model-spending.ts) |
| [model_usage_reservations](#model_usage_reservations) | Tenant ID on row; verify FORCE RLS in migration | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0002-model-spending.ts) |
| [model_prices](#model_prices) | Tenant ID on row; verify FORCE RLS in migration | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0003-model-prices.ts) |
| [model_budget_alerts](#model_budget_alerts) | Tenant ID on row; verify FORCE RLS in migration | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0004-model-budget-alerts.ts) |
| [organization_alert_webhooks](#organization_alert_webhooks) | Tenant ID on row; verify FORCE RLS in migration | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0005-alert-webhooks.ts) |
| [alert_webhook_deliveries](#alert_webhook_deliveries) | Tenant ID on row; verify FORCE RLS in migration | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0005-alert-webhooks.ts) |
| [model_quality_results](#model_quality_results) | Global/auth/catalog or special-scope table; inspect grants/policy | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0006-model-quality-results.ts) |
| [organization_source_control_connections](#organization_source_control_connections) | Tenant ID on row; verify FORCE RLS in migration | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0011-repository-credentials.ts) |
| [repository_credential_leases](#repository_credential_leases) | Tenant ID on row; verify FORCE RLS in migration | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0011-repository-credentials.ts) |
| [agent_run_checkpoints](#agent_run_checkpoints) | Tenant ID on row; verify FORCE RLS in migration | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0012-run-recovery.ts) |
| [agent_artifact_objects](#agent_artifact_objects) | Tenant ID on row; verify FORCE RLS in migration | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0013-artifact-objects.ts) |
| [organization_model_credentials](#organization_model_credentials) | Tenant ID on row; verify FORCE RLS in migration | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0014-model-credentials.ts) |
| [agent_action_reconciliations](#agent_action_reconciliations) | Tenant ID on row; verify FORCE RLS in migration | [migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0015-action-reconciliation.ts) |

## organizations

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `id` | `text` | `PRIMARY KEY` |
| `name` | `text` | `NOT NULL` |
| `slug` | `text` | `NOT NULL UNIQUE` |
| `legal_name` | `text` | `NOT NULL DEFAULT ''` |
| `code` | `text` | `` |
| `website` | `text` | `NOT NULL DEFAULT ''` |
| `industry` | `text` | `NOT NULL DEFAULT ''` |
| `country` | `text` | `NOT NULL DEFAULT ''` |
| `timezone` | `text` | `NOT NULL DEFAULT 'UTC'` |
| `locale` | `text` | `NOT NULL DEFAULT 'en'` |
| `status` | `text` | `NOT NULL DEFAULT 'active' CHECK(status IN ('active','suspended','disabled'))` |
| `version` | `bigint` | `NOT NULL DEFAULT 1` |
| `created_at` | `timestamptz` | `` |
| `updated_at` | `timestamptz` | `` |
| `updated_by` | `text` | `` |

Indexes (including partial/case-insensitive uniqueness):

```sql
CREATE UNIQUE INDEX organization_code_unique ON organizations(lower(code));
```

## users

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `id` | `text` | `PRIMARY KEY` |
| `email` | `text` | `NOT NULL` |
| `display_name` | `text` | `NOT NULL` |
| `status` | `text` | `NOT NULL DEFAULT 'active' CHECK(status IN ('active','disabled'))` |
| `created_at` | `timestamptz` | `NOT NULL` |

Indexes (including partial/case-insensitive uniqueness):

```sql
CREATE UNIQUE INDEX users_email_unique ON users(lower(email));
```

## employees

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `id` | `text` | `PRIMARY KEY` |
| `organization_id` | `text` | `NOT NULL REFERENCES organizations(id)` |
| `display_name` | `text` | `NOT NULL` |
| `email` | `text` | `NOT NULL` |
| `role` | `text` | `NOT NULL` |
| `team` | `text` | `NOT NULL` |
| `user_id` | `text` | `REFERENCES users(id)` |
| `employee_number` | `text` | `` |
| `employment_type` | `text` | `NOT NULL DEFAULT 'employee' CHECK(employment_type IN ('employee','contractor','external'))` |
| `employment_status` | `text` | `NOT NULL DEFAULT 'active' CHECK(employment_status IN ('active','inactive'))` |
| `version` | `bigint` | `NOT NULL DEFAULT 1` |

Indexes (including partial/case-insensitive uniqueness):

```sql
CREATE UNIQUE INDEX employees_tenant_id ON employees(organization_id,id);
CREATE UNIQUE INDEX employee_email_per_tenant ON employees(organization_id,lower(email));
CREATE UNIQUE INDEX employee_user_per_tenant ON employees(organization_id,user_id) WHERE user_id IS NOT NULL;
CREATE UNIQUE INDEX employee_number_per_tenant ON employees(organization_id,employee_number) WHERE employee_number IS NOT NULL;
CREATE UNIQUE INDEX employee_user_tenant_link ON employees(organization_id,id,user_id);
```

## organization_memberships

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `id` | `text` | `PRIMARY KEY` |
| `organization_id` | `text` | `NOT NULL REFERENCES organizations(id)` |
| `user_id` | `text` | `NOT NULL REFERENCES users(id)` |
| `employee_id` | `text` | `NOT NULL` |
| `security_role` | `text` | `NOT NULL CHECK(security_role IN ('ADMIN','EMPLOYEE'))` |
| `membership_status` | `text` | `NOT NULL CHECK(membership_status IN ('pending','active','suspended'))` |
| `version` | `bigint` | `NOT NULL DEFAULT 1` |
| `joined_at` | `timestamptz` | `NOT NULL` |
| `updated_at` | `timestamptz` | `NOT NULL` |
| `invited_by` | `text` | `` |

Table-level keys/checks/relationships from the CREATE statement:

```sql
UNIQUE(organization_id,user_id),
UNIQUE(organization_id,employee_id),
FOREIGN KEY(organization_id,employee_id,user_id) REFERENCES employees(organization_id,id,user_id)
```

Indexes (including partial/case-insensitive uniqueness):

```sql
CREATE INDEX memberships_user_status ON organization_memberships(user_id,membership_status);
```

## identities

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `issuer` | `text` | `NOT NULL` |
| `subject` | `text` | `NOT NULL` |
| `employee_id` | `text` | `NOT NULL REFERENCES employees(id)` |
| `enabled` | `bigint` | `NOT NULL` |
| `user_id` | `text` | `REFERENCES users(id)` |

Table-level keys/checks/relationships from the CREATE statement:

```sql
PRIMARY KEY (issuer, subject)
```

## login_transactions

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `hash` | `text` | `PRIMARY KEY` |
| `body` | `jsonb` | `NOT NULL` |
| `expires_at` | `bigint` | `NOT NULL` |

## password_credentials

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `issuer` | `text` | `NOT NULL` |
| `subject` | `text` | `NOT NULL` |
| `hash` | `text` | `NOT NULL` |

Table-level keys/checks/relationships from the CREATE statement:

```sql
PRIMARY KEY (issuer, subject),
FOREIGN KEY (issuer, subject) REFERENCES identities(issuer, subject)
```

## account_password_credentials

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `user_id` | `text` | `PRIMARY KEY REFERENCES users(id)` |
| `hash` | `text` | `NOT NULL` |
| `updated_at` | `timestamptz` | `NOT NULL` |

## auth_sessions

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `hash` | `text` | `PRIMARY KEY` |
| `issuer` | `text` | `NOT NULL` |
| `subject` | `text` | `NOT NULL` |
| `expires_at` | `bigint` | `NOT NULL` |
| `user_id` | `text` | `REFERENCES users(id)` |
| `organization_id` | `text` | `REFERENCES organizations(id)` |

Indexes (including partial/case-insensitive uniqueness):

```sql
CREATE INDEX account_sessions_by_user ON auth_sessions(user_id,organization_id);
```

## invitations

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `hash` | `text` | `PRIMARY KEY` |
| `employee_id` | `text` | `NOT NULL REFERENCES employees(id)` |
| `expires_at` | `bigint` | `NOT NULL` |
| `consumed` | `bigint` | `NOT NULL` |

## password_resets

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `hash` | `text` | `PRIMARY KEY` |
| `employee_id` | `text` | `NOT NULL REFERENCES employees(id)` |
| `expires_at` | `bigint` | `NOT NULL` |
| `consumed` | `bigint` | `NOT NULL` |

## account_link_invitations

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `hash` | `text` | `PRIMARY KEY` |
| `organization_id` | `text` | `NOT NULL REFERENCES organizations(id)` |
| `employee_id` | `text` | `NOT NULL` |
| `user_id` | `text` | `NOT NULL REFERENCES users(id)` |
| `expires_at` | `bigint` | `NOT NULL` |
| `consumed` | `bigint` | `NOT NULL DEFAULT 0 CHECK(consumed IN (0,1))` |
| `invited_by` | `text` | `` |

Table-level keys/checks/relationships from the CREATE statement:

```sql
FOREIGN KEY(organization_id,employee_id,user_id) REFERENCES employees(organization_id,id,user_id),
FOREIGN KEY(organization_id,invited_by) REFERENCES employees(organization_id,id)
```

Indexes (including partial/case-insensitive uniqueness):

```sql
CREATE INDEX account_link_pending ON account_link_invitations(organization_id,employee_id,consumed);
```

## catalog_blueprint_versions

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `blueprint_id` | `text` | `NOT NULL` |
| `version` | `text` | `NOT NULL` |
| `digest` | `text` | `NOT NULL CHECK(length(digest)=64)` |
| `content` | `text` | `NOT NULL CHECK(af_json_valid(content))` |
| `registered_at` | `timestamptz` | `NOT NULL` |
| `bundle_schema` | `text` | `NOT NULL DEFAULT 'agents-foundry.catalog-bundle/v1' CHECK (bundle_schema ~ '^[a-z0-9.-]{1,100}/v[0-9]{1,6}$')` |

Table-level keys/checks/relationships from the CREATE statement:

```sql
PRIMARY KEY(blueprint_id,version)
```

## organization_agent_installations

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `id` | `text` | `PRIMARY KEY` |
| `organization_id` | `text` | `NOT NULL REFERENCES organizations(id)` |
| `name` | `text` | `NOT NULL CHECK(length(name) BETWEEN 1 AND 120)` |
| `blueprint_id` | `text` | `NOT NULL` |
| `blueprint_version` | `text` | `NOT NULL` |
| `configuration` | `jsonb` | `NOT NULL` |
| `status` | `text` | `NOT NULL CHECK(status IN ('ACTIVE','RETIRED'))` |
| `version` | `bigint` | `NOT NULL DEFAULT 1 CHECK(version>0)` |
| `created_by` | `text` | `NOT NULL` |
| `created_at` | `timestamptz` | `NOT NULL` |
| `updated_by` | `text` | `NOT NULL` |
| `updated_at` | `timestamptz` | `NOT NULL` |

Table-level keys/checks/relationships from the CREATE statement:

```sql
UNIQUE(organization_id,id),
FOREIGN KEY(blueprint_id,blueprint_version) REFERENCES catalog_blueprint_versions(blueprint_id,version),
FOREIGN KEY(organization_id,created_by) REFERENCES employees(organization_id,id),
FOREIGN KEY(organization_id,updated_by) REFERENCES employees(organization_id,id)
```

Indexes (including partial/case-insensitive uniqueness):

```sql
CREATE UNIQUE INDEX installation_active_name ON organization_agent_installations(organization_id,lower(name))
 WHERE status='ACTIVE';
```

## agents

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `id` | `text` | `PRIMARY KEY` |
| `organization_id` | `text` | `NOT NULL REFERENCES organizations(id)` |
| `name` | `text` | `NOT NULL` |
| `department` | `text` | `NOT NULL` |
| `team` | `text` | `NOT NULL` |
| `status` | `text` | `NOT NULL` |
| `capabilities` | `text` | `NOT NULL` |
| `installation_id` | `text` | `` |
| `seq` | `bigint` | `GENERATED ALWAYS AS IDENTITY UNIQUE` |

Indexes (including partial/case-insensitive uniqueness):

```sql
CREATE UNIQUE INDEX agents_tenant_id ON agents(organization_id,id);
CREATE INDEX agents_installation ON agents(organization_id,installation_id) WHERE installation_id IS NOT NULL;
```

## agent_manifests

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `agent_id` | `text` | `PRIMARY KEY REFERENCES agents(id)` |
| `organization_id` | `text` | `NOT NULL REFERENCES organizations(id)` |
| `employee_id` | `text` | `NOT NULL REFERENCES employees(id)` |
| `body` | `text` | `NOT NULL` |

## agent_assignments

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `agent_id` | `text` | `PRIMARY KEY` |
| `organization_id` | `text` | `NOT NULL REFERENCES organizations(id)` |
| `created_by` | `text` | `NOT NULL` |
| `created_at` | `timestamptz` | `NOT NULL` |

Table-level keys/checks/relationships from the CREATE statement:

```sql
FOREIGN KEY (organization_id, agent_id) REFERENCES agents(organization_id, id),
FOREIGN KEY (organization_id, created_by) REFERENCES employees(organization_id, id)
```

## admin_agent_batches

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `organization_id` | `text` | `NOT NULL REFERENCES organizations(id)` |
| `request_id` | `text` | `NOT NULL` |
| `body_hash` | `text` | `NOT NULL` |
| `result` | `jsonb` | `NOT NULL` |

Table-level keys/checks/relationships from the CREATE statement:

```sql
PRIMARY KEY (organization_id, request_id)
```

## provisioning_requests

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `id` | `text` | `PRIMARY KEY` |
| `organization_id` | `text` | `NOT NULL REFERENCES organizations(id)` |
| `employee_id` | `text` | `NOT NULL REFERENCES employees(id)` |
| `body` | `jsonb` | `NOT NULL` |
| `seq` | `bigint` | `GENERATED ALWAYS AS IDENTITY UNIQUE` |

## conversations

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `id` | `text` | `PRIMARY KEY` |
| `organization_id` | `text` | `NOT NULL REFERENCES organizations(id)` |
| `employee_id` | `text` | `NOT NULL REFERENCES employees(id)` |
| `agent_id` | `text` | `NOT NULL REFERENCES agents(id)` |
| `title` | `text` | `NOT NULL` |
| `created_at` | `timestamptz` | `NOT NULL` |
| `updated_at` | `timestamptz` | `NOT NULL` |

Indexes (including partial/case-insensitive uniqueness):

```sql
CREATE INDEX idx_conversations_employee ON conversations(employee_id, updated_at);
CREATE UNIQUE INDEX conversations_tenant_id ON conversations(organization_id,id);
```

## messages

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `id` | `text` | `PRIMARY KEY` |
| `organization_id` | `text` | `NOT NULL REFERENCES organizations(id)` |
| `conversation_id` | `text` | `NOT NULL` |
| `author` | `text` | `NOT NULL` |
| `content` | `text` | `NOT NULL` |
| `created_at` | `timestamptz` | `NOT NULL` |
| `seq` | `bigint` | `GENERATED ALWAYS AS IDENTITY UNIQUE` |

Table-level keys/checks/relationships from the CREATE statement:

```sql
FOREIGN KEY (organization_id, conversation_id) REFERENCES conversations(organization_id, id)
```

Indexes (including partial/case-insensitive uniqueness):

```sql
CREATE INDEX messages_conversation ON messages(organization_id, conversation_id, created_at);
```

## approvals

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `id` | `text` | `PRIMARY KEY` |
| `organization_id` | `text` | `NOT NULL REFERENCES organizations(id)` |
| `requested_by` | `text` | `NOT NULL` |
| `action` | `text` | `NOT NULL` |
| `resource_type` | `text` | `NOT NULL` |
| `resource_id` | `text` | `NOT NULL` |
| `risk` | `text` | `NOT NULL` |
| `summary` | `text` | `NOT NULL` |
| `status` | `text` | `NOT NULL` |
| `decided_by` | `text` | `` |
| `decided_at` | `timestamptz` | `` |
| `created_at` | `timestamptz` | `NOT NULL` |
| `run_id` | `text` | `` |
| `step_id` | `text` | `` |
| `expires_at` | `timestamptz` | `` |
| `seq` | `bigint` | `GENERATED ALWAYS AS IDENTITY UNIQUE` |

Indexes (including partial/case-insensitive uniqueness):

```sql
CREATE INDEX idx_approvals_status ON approvals(status, created_at);
CREATE INDEX approvals_run ON approvals(organization_id,run_id) WHERE run_id IS NOT NULL;
CREATE INDEX approvals_expiry ON approvals(status,expires_at) WHERE expires_at IS NOT NULL;
```

## qa_runs

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `id` | `text` | `PRIMARY KEY` |
| `organization_id` | `text` | `NOT NULL` |
| `employee_id` | `text` | `NOT NULL` |
| `conversation_id` | `text` | `NOT NULL REFERENCES conversations(id)` |
| `story_key` | `text` | `NOT NULL` |
| `target_url` | `text` | `NOT NULL` |
| `status` | `text` | `NOT NULL` |
| `plan` | `text` | `NOT NULL` |
| `approval_id` | `text` | `NOT NULL UNIQUE REFERENCES approvals(id)` |
| `created_at` | `timestamptz` | `NOT NULL` |

## llm_key_bindings

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `id` | `text` | `PRIMARY KEY` |
| `organization_id` | `text` | `NOT NULL` |
| `employee_id` | `text` | `` |
| `provider` | `text` | `NOT NULL` |
| `key_source` | `text` | `NOT NULL` |
| `secret_ref` | `text` | `NOT NULL` |
| `created_at` | `timestamptz` | `NOT NULL` |

Table-level keys/checks/relationships from the CREATE statement:

```sql
CHECK (length(secret_ref) > 0)
```

## audit_events

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `id` | `text` | `PRIMARY KEY` |
| `organization_id` | `text` | `NOT NULL` |
| `actor_id` | `text` | `NOT NULL` |
| `event_type` | `text` | `NOT NULL` |
| `resource_type` | `text` | `NOT NULL` |
| `resource_id` | `text` | `NOT NULL` |
| `metadata` | `jsonb` | `NOT NULL` |
| `created_at` | `timestamptz` | `NOT NULL` |
| `seq` | `bigint` | `GENERATED ALWAYS AS IDENTITY UNIQUE` |

Indexes (including partial/case-insensitive uniqueness):

```sql
CREATE INDEX idx_audit_resource ON audit_events(resource_type, resource_id);
CREATE INDEX audit_events_tenant ON audit_events(organization_id, seq);
```

## organizational_units

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `id` | `text` | `PRIMARY KEY` |
| `organization_id` | `text` | `NOT NULL REFERENCES organizations(id)` |
| `parent_id` | `text` | `` |
| `name` | `text` | `NOT NULL CHECK(length(trim(name)) BETWEEN 1 AND 160)` |
| `code` | `text` | `NOT NULL CHECK(length(code) BETWEEN 1 AND 40)` |
| `unit_type` | `text` | `NOT NULL CHECK(unit_type IN ('business_unit','division','department','sub_department','team','squad','pod','chapter','guild','other'))` |
| `description` | `text` | `NOT NULL DEFAULT ''` |
| `status` | `text` | `NOT NULL DEFAULT 'active' CHECK(status IN ('active','archived'))` |
| `version` | `bigint` | `NOT NULL DEFAULT 1` |
| `created_at` | `timestamptz` | `NOT NULL` |
| `updated_at` | `timestamptz` | `NOT NULL` |
| `created_by` | `text` | `NOT NULL` |
| `updated_by` | `text` | `NOT NULL` |
| `head_position_id` | `text` | `` |

Table-level keys/checks/relationships from the CREATE statement:

```sql
UNIQUE(organization_id,id),
UNIQUE(organization_id,code),
FOREIGN KEY(organization_id,parent_id) REFERENCES organizational_units(organization_id,id),
FOREIGN KEY(organization_id,created_by) REFERENCES employees(organization_id,id),
FOREIGN KEY(organization_id,updated_by) REFERENCES employees(organization_id,id),
CHECK(parent_id IS NULL OR parent_id <> id)
```

Indexes (including partial/case-insensitive uniqueness):

```sql
CREATE INDEX units_parent ON organizational_units(organization_id,parent_id,status);
CREATE INDEX units_name ON organizational_units(organization_id,status,name,id);
CREATE UNIQUE INDEX one_unit_per_head_position ON organizational_units(organization_id,head_position_id) WHERE head_position_id IS NOT NULL;
```

## organization_change_events

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `id` | `text` | `PRIMARY KEY` |
| `organization_id` | `text` | `NOT NULL REFERENCES organizations(id)` |
| `actor_id` | `text` | `NOT NULL` |
| `action` | `text` | `NOT NULL` |
| `resource_type` | `text` | `NOT NULL` |
| `resource_id` | `text` | `NOT NULL` |
| `before_json` | `jsonb` | `` |
| `after_json` | `jsonb` | `` |
| `request_id` | `text` | `NOT NULL` |
| `created_at` | `timestamptz` | `NOT NULL` |

Table-level keys/checks/relationships from the CREATE statement:

```sql
FOREIGN KEY(organization_id,actor_id) REFERENCES employees(organization_id,id)
```

Indexes (including partial/case-insensitive uniqueness):

```sql
CREATE INDEX organization_changes_time ON organization_change_events(organization_id,created_at,id);
```

## job_families

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `id` | `text` | `PRIMARY KEY` |
| `organization_id` | `text` | `NOT NULL REFERENCES organizations(id)` |
| `name` | `text` | `NOT NULL CHECK(length(trim(name)) BETWEEN 1 AND 160)` |
| `code` | `text` | `NOT NULL CHECK(length(code) BETWEEN 1 AND 40)` |
| `description` | `text` | `NOT NULL DEFAULT ''` |
| `status` | `text` | `NOT NULL DEFAULT 'active' CHECK(status IN ('active','archived'))` |
| `version` | `bigint` | `NOT NULL DEFAULT 1` |
| `created_at` | `timestamptz` | `NOT NULL` |
| `updated_at` | `timestamptz` | `NOT NULL` |
| `created_by` | `text` | `NOT NULL` |
| `updated_by` | `text` | `NOT NULL` |

Table-level keys/checks/relationships from the CREATE statement:

```sql
UNIQUE(organization_id,id),
UNIQUE(organization_id,code),
FOREIGN KEY(organization_id,created_by) REFERENCES employees(organization_id,id),
FOREIGN KEY(organization_id,updated_by) REFERENCES employees(organization_id,id)
```

## job_disciplines

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `job_family_id` | `text` | `NOT NULL` |
| `id` | `text` | `PRIMARY KEY` |
| `organization_id` | `text` | `NOT NULL REFERENCES organizations(id)` |
| `name` | `text` | `NOT NULL CHECK(length(trim(name)) BETWEEN 1 AND 160)` |
| `code` | `text` | `NOT NULL CHECK(length(code) BETWEEN 1 AND 40)` |
| `description` | `text` | `NOT NULL DEFAULT ''` |
| `status` | `text` | `NOT NULL DEFAULT 'active' CHECK(status IN ('active','archived'))` |
| `version` | `bigint` | `NOT NULL DEFAULT 1` |
| `created_at` | `timestamptz` | `NOT NULL` |
| `updated_at` | `timestamptz` | `NOT NULL` |
| `created_by` | `text` | `NOT NULL` |
| `updated_by` | `text` | `NOT NULL` |

Table-level keys/checks/relationships from the CREATE statement:

```sql
UNIQUE(organization_id,id),
UNIQUE(organization_id,code),
FOREIGN KEY(organization_id,created_by) REFERENCES employees(organization_id,id),
FOREIGN KEY(organization_id,updated_by) REFERENCES employees(organization_id,id),
FOREIGN KEY(organization_id,job_family_id) REFERENCES job_families(organization_id,id)
```

Indexes (including partial/case-insensitive uniqueness):

```sql
CREATE INDEX disciplines_family ON job_disciplines(organization_id,job_family_id,status);
```

## roles

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `job_family_id` | `text` | `NOT NULL` |
| `discipline_id` | `text` | `NOT NULL` |
| `id` | `text` | `PRIMARY KEY` |
| `organization_id` | `text` | `NOT NULL REFERENCES organizations(id)` |
| `name` | `text` | `NOT NULL CHECK(length(trim(name)) BETWEEN 1 AND 160)` |
| `code` | `text` | `NOT NULL CHECK(length(code) BETWEEN 1 AND 40)` |
| `description` | `text` | `NOT NULL DEFAULT ''` |
| `status` | `text` | `NOT NULL DEFAULT 'active' CHECK(status IN ('active','archived'))` |
| `version` | `bigint` | `NOT NULL DEFAULT 1` |
| `created_at` | `timestamptz` | `NOT NULL` |
| `updated_at` | `timestamptz` | `NOT NULL` |
| `created_by` | `text` | `NOT NULL` |
| `updated_by` | `text` | `NOT NULL` |

Table-level keys/checks/relationships from the CREATE statement:

```sql
UNIQUE(organization_id,id),
UNIQUE(organization_id,code),
FOREIGN KEY(organization_id,created_by) REFERENCES employees(organization_id,id),
FOREIGN KEY(organization_id,updated_by) REFERENCES employees(organization_id,id),
FOREIGN KEY(organization_id,job_family_id) REFERENCES job_families(organization_id,id),
FOREIGN KEY(organization_id,discipline_id) REFERENCES job_disciplines(organization_id,id)
```

Indexes (including partial/case-insensitive uniqueness):

```sql
CREATE INDEX roles_discipline ON roles(organization_id,discipline_id,status);
```

## job_levels

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `rank` | `bigint` | `NOT NULL CHECK(rank>=0)` |
| `id` | `text` | `PRIMARY KEY` |
| `organization_id` | `text` | `NOT NULL REFERENCES organizations(id)` |
| `name` | `text` | `NOT NULL CHECK(length(trim(name)) BETWEEN 1 AND 160)` |
| `code` | `text` | `NOT NULL CHECK(length(code) BETWEEN 1 AND 40)` |
| `description` | `text` | `NOT NULL DEFAULT ''` |
| `status` | `text` | `NOT NULL DEFAULT 'active' CHECK(status IN ('active','archived'))` |
| `version` | `bigint` | `NOT NULL DEFAULT 1` |
| `created_at` | `timestamptz` | `NOT NULL` |
| `updated_at` | `timestamptz` | `NOT NULL` |
| `created_by` | `text` | `NOT NULL` |
| `updated_by` | `text` | `NOT NULL` |

Table-level keys/checks/relationships from the CREATE statement:

```sql
UNIQUE(organization_id,id),
UNIQUE(organization_id,code),
FOREIGN KEY(organization_id,created_by) REFERENCES employees(organization_id,id),
FOREIGN KEY(organization_id,updated_by) REFERENCES employees(organization_id,id)
```

## positions

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `organizational_unit_id` | `text` | `NOT NULL` |
| `role_id` | `text` | `NOT NULL` |
| `job_level_id` | `text` | `NOT NULL` |
| `reports_to_position_id` | `text` | `` |
| `id` | `text` | `PRIMARY KEY` |
| `organization_id` | `text` | `NOT NULL REFERENCES organizations(id)` |
| `name` | `text` | `NOT NULL CHECK(length(trim(name)) BETWEEN 1 AND 160)` |
| `code` | `text` | `NOT NULL CHECK(length(code) BETWEEN 1 AND 40)` |
| `description` | `text` | `NOT NULL DEFAULT ''` |
| `status` | `text` | `NOT NULL DEFAULT 'active' CHECK(status IN ('active','archived'))` |
| `version` | `bigint` | `NOT NULL DEFAULT 1` |
| `created_at` | `timestamptz` | `NOT NULL` |
| `updated_at` | `timestamptz` | `NOT NULL` |
| `created_by` | `text` | `NOT NULL` |
| `updated_by` | `text` | `NOT NULL` |

Table-level keys/checks/relationships from the CREATE statement:

```sql
UNIQUE(organization_id,id),
UNIQUE(organization_id,code),
FOREIGN KEY(organization_id,created_by) REFERENCES employees(organization_id,id),
FOREIGN KEY(organization_id,updated_by) REFERENCES employees(organization_id,id),
FOREIGN KEY(organization_id,organizational_unit_id) REFERENCES organizational_units(organization_id,id),
FOREIGN KEY(organization_id,role_id) REFERENCES roles(organization_id,id),
FOREIGN KEY(organization_id,job_level_id) REFERENCES job_levels(organization_id,id),
FOREIGN KEY(organization_id,reports_to_position_id) REFERENCES positions(organization_id,id),
CHECK(reports_to_position_id IS NULL OR reports_to_position_id<>id)
```

Indexes (including partial/case-insensitive uniqueness):

```sql
CREATE INDEX positions_unit ON positions(organization_id,organizational_unit_id,status);
CREATE INDEX positions_role ON positions(organization_id,role_id,status);
```

## organizational_unit_memberships

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `id` | `text` | `PRIMARY KEY` |
| `organization_id` | `text` | `NOT NULL REFERENCES organizations(id)` |
| `organizational_unit_id` | `text` | `NOT NULL` |
| `employee_id` | `text` | `NOT NULL` |
| `membership_type` | `text` | `NOT NULL CHECK(membership_type IN ('member','lead','manager','owner','contributor'))` |
| `is_primary` | `bigint` | `NOT NULL DEFAULT 0 CHECK(is_primary IN (0,1))` |
| `created_at` | `timestamptz` | `NOT NULL` |
| `created_by` | `text` | `NOT NULL` |
| `started_at` | `timestamptz` | `NOT NULL` |
| `ended_at` | `timestamptz` | `` |
| `version` | `bigint` | `NOT NULL DEFAULT 1` |

Table-level keys/checks/relationships from the CREATE statement:

```sql
FOREIGN KEY(organization_id,organizational_unit_id) REFERENCES organizational_units(organization_id,id),
FOREIGN KEY(organization_id,employee_id) REFERENCES employees(organization_id,id),
FOREIGN KEY(organization_id,created_by) REFERENCES employees(organization_id,id),
CHECK(ended_at IS NULL OR ended_at>=started_at)
```

Indexes (including partial/case-insensitive uniqueness):

```sql
CREATE UNIQUE INDEX current_unit_member ON organizational_unit_memberships(organization_id,organizational_unit_id,employee_id) WHERE ended_at IS NULL;
CREATE UNIQUE INDEX one_primary_unit ON organizational_unit_memberships(organization_id,employee_id) WHERE is_primary=1 AND ended_at IS NULL;
CREATE INDEX unit_membership_history ON organizational_unit_memberships(organization_id,organizational_unit_id,ended_at,started_at);
```

## organization_domains

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `id` | `text` | `PRIMARY KEY` |
| `organization_id` | `text` | `NOT NULL REFERENCES organizations(id)` |
| `domain` | `text` | `NOT NULL` |
| `domain_type` | `text` | `NOT NULL CHECK(domain_type IN ('custom_domain','platform_subdomain','internal'))` |
| `is_primary` | `bigint` | `NOT NULL DEFAULT 0 CHECK(is_primary IN (0,1))` |
| `verification_status` | `text` | `NOT NULL DEFAULT 'pending' CHECK(verification_status IN ('pending','verified','disabled'))` |
| `verification_token` | `text` | `NOT NULL` |
| `verified_at` | `timestamptz` | `` |
| `created_at` | `timestamptz` | `NOT NULL` |
| `updated_at` | `timestamptz` | `NOT NULL` |
| `created_by` | `text` | `NOT NULL` |
| `version` | `bigint` | `NOT NULL DEFAULT 1` |

Table-level keys/checks/relationships from the CREATE statement:

```sql
FOREIGN KEY(organization_id,created_by) REFERENCES employees(organization_id,id),
CHECK(is_primary=0 OR verification_status='verified')
```

Indexes (including partial/case-insensitive uniqueness):

```sql
CREATE UNIQUE INDEX organization_domain_unique ON organization_domains(lower(domain));
CREATE UNIQUE INDEX primary_domain_per_tenant ON organization_domains(organization_id) WHERE is_primary=1;
CREATE INDEX domain_tenant ON organization_domains(organization_id,verification_status);
```

## employee_position_assignments

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `id` | `text` | `PRIMARY KEY` |
| `organization_id` | `text` | `NOT NULL REFERENCES organizations(id)` |
| `employee_id` | `text` | `NOT NULL` |
| `position_id` | `text` | `NOT NULL` |
| `started_at` | `timestamptz` | `NOT NULL` |
| `ended_at` | `timestamptz` | `` |
| `created_by` | `text` | `NOT NULL` |

Table-level keys/checks/relationships from the CREATE statement:

```sql
FOREIGN KEY(organization_id,employee_id) REFERENCES employees(organization_id,id),
FOREIGN KEY(organization_id,position_id) REFERENCES positions(organization_id,id),
FOREIGN KEY(organization_id,created_by) REFERENCES employees(organization_id,id)
```

Indexes (including partial/case-insensitive uniqueness):

```sql
CREATE UNIQUE INDEX employee_current_position ON employee_position_assignments(organization_id,employee_id) WHERE ended_at IS NULL;
CREATE UNIQUE INDEX position_current_occupant ON employee_position_assignments(organization_id,position_id) WHERE ended_at IS NULL;
```

## agent_threads

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `id` | `text` | `PRIMARY KEY` |
| `organization_id` | `text` | `NOT NULL REFERENCES organizations(id)` |
| `employee_id` | `text` | `NOT NULL` |
| `agent_id` | `text` | `NOT NULL` |
| `conversation_id` | `text` | `` |
| `title` | `text` | `NOT NULL CHECK(length(title) BETWEEN 1 AND 200)` |
| `status` | `text` | `NOT NULL CHECK(status IN ('ACTIVE','ARCHIVED'))` |
| `created_at` | `timestamptz` | `NOT NULL` |
| `updated_at` | `timestamptz` | `NOT NULL` |
| `seq` | `bigint` | `GENERATED ALWAYS AS IDENTITY UNIQUE` |

Table-level keys/checks/relationships from the CREATE statement:

```sql
UNIQUE(organization_id,id),
FOREIGN KEY(organization_id,employee_id) REFERENCES employees(organization_id,id),
FOREIGN KEY(organization_id,agent_id) REFERENCES agents(organization_id,id),
FOREIGN KEY(organization_id,conversation_id) REFERENCES conversations(organization_id,id)
```

Indexes (including partial/case-insensitive uniqueness):

```sql
CREATE INDEX agent_threads_conversation ON agent_threads(organization_id,conversation_id,agent_id,status);
```

## agent_runs

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `id` | `text` | `PRIMARY KEY` |
| `organization_id` | `text` | `NOT NULL REFERENCES organizations(id)` |
| `thread_id` | `text` | `NOT NULL` |
| `employee_id` | `text` | `NOT NULL` |
| `agent_id` | `text` | `NOT NULL` |
| `manifest_id` | `text` | `` |
| `manifest_api_version` | `text` | `CHECK(manifest_api_version IN ('agents-foundry/v1','agents-foundry/v2'))` |
| `manifest_key_id` | `text` | `` |
| `task` | `jsonb` | `NOT NULL` |
| `runtime_profile` | `text` | `NOT NULL` |
| `status` | `text` | `NOT NULL CHECK(status IN ('QUEUED','RUNNING','WAITING_FOR_APPROVAL','COMPLETED','FAILED','CANCELLED'))` |
| `status_reason` | `text` | `` |
| `legacy_qa_run_id` | `text` | `UNIQUE REFERENCES qa_runs(id)` |
| `runtime_sequence` | `bigint` | `NOT NULL DEFAULT 0 CHECK(runtime_sequence>=0)` |
| `created_at` | `timestamptz` | `NOT NULL` |
| `updated_at` | `timestamptz` | `NOT NULL` |
| `started_at` | `timestamptz` | `` |
| `completed_at` | `timestamptz` | `` |
| `seq` | `bigint` | `GENERATED ALWAYS AS IDENTITY UNIQUE` |

Table-level keys/checks/relationships from the CREATE statement:

```sql
UNIQUE(organization_id,id),
FOREIGN KEY(organization_id,thread_id) REFERENCES agent_threads(organization_id,id),
FOREIGN KEY(organization_id,employee_id) REFERENCES employees(organization_id,id),
FOREIGN KEY(organization_id,agent_id) REFERENCES agents(organization_id,id),
CHECK((manifest_id IS NULL) = (manifest_api_version IS NULL) AND (manifest_id IS NULL) = (manifest_key_id IS NULL))
```

Indexes (including partial/case-insensitive uniqueness):

```sql
CREATE UNIQUE INDEX one_active_run_per_thread ON agent_runs(organization_id,thread_id)
 WHERE status IN ('QUEUED','RUNNING','WAITING_FOR_APPROVAL');
CREATE INDEX agent_runs_employee ON agent_runs(organization_id,employee_id,created_at);
CREATE INDEX agent_runs_queue ON agent_runs(status, created_at);
```

## agent_run_steps

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `id` | `text` | `PRIMARY KEY` |
| `organization_id` | `text` | `NOT NULL REFERENCES organizations(id)` |
| `run_id` | `text` | `NOT NULL` |
| `sequence` | `bigint` | `NOT NULL CHECK(sequence>0)` |
| `kind` | `text` | `NOT NULL CHECK(kind IN ('PLAN','MODEL','TOOL','ACTION','MESSAGE'))` |
| `title` | `text` | `NOT NULL CHECK(length(title) BETWEEN 1 AND 200)` |
| `status` | `text` | `NOT NULL CHECK(status IN ('PENDING','RUNNING','WAITING_FOR_APPROVAL','COMPLETED','FAILED','SKIPPED','CANCELLED'))` |
| `detail` | `jsonb` | `NOT NULL DEFAULT '{}'::jsonb` |
| `created_at` | `timestamptz` | `NOT NULL` |
| `started_at` | `timestamptz` | `` |
| `completed_at` | `timestamptz` | `` |

Table-level keys/checks/relationships from the CREATE statement:

```sql
UNIQUE(organization_id,id),
UNIQUE(run_id,sequence),
FOREIGN KEY(organization_id,run_id) REFERENCES agent_runs(organization_id,id)
```

## agent_events

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `id` | `text` | `PRIMARY KEY` |
| `organization_id` | `text` | `NOT NULL REFERENCES organizations(id)` |
| `thread_id` | `text` | `NOT NULL` |
| `run_id` | `text` | `NOT NULL` |
| `step_id` | `text` | `` |
| `sequence` | `bigint` | `NOT NULL CHECK(sequence>0)` |
| `runtime_sequence` | `bigint` | `CHECK(runtime_sequence>0)` |
| `event_type` | `text` | `NOT NULL` |
| `source` | `text` | `NOT NULL CHECK(source IN ('CONTROL_PLANE','RUNTIME'))` |
| `actor_id` | `text` | `` |
| `payload` | `jsonb` | `NOT NULL` |
| `payload_hash` | `text` | `NOT NULL CHECK(length(payload_hash)=64)` |
| `occurred_at` | `timestamptz` | `NOT NULL` |
| `recorded_at` | `timestamptz` | `NOT NULL` |

Table-level keys/checks/relationships from the CREATE statement:

```sql
UNIQUE(run_id,sequence),
UNIQUE(run_id,runtime_sequence),
CHECK((source='RUNTIME') = (runtime_sequence IS NOT NULL)),
FOREIGN KEY(organization_id,run_id) REFERENCES agent_runs(organization_id,id),
FOREIGN KEY(organization_id,thread_id) REFERENCES agent_threads(organization_id,id),
FOREIGN KEY(organization_id,step_id) REFERENCES agent_run_steps(organization_id,id)
```

## agent_artifacts

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `id` | `text` | `PRIMARY KEY` |
| `organization_id` | `text` | `NOT NULL REFERENCES organizations(id)` |
| `thread_id` | `text` | `NOT NULL` |
| `run_id` | `text` | `NOT NULL` |
| `step_id` | `text` | `` |
| `artifact_type` | `text` | `NOT NULL` |
| `media_type` | `text` | `NOT NULL` |
| `name` | `text` | `NOT NULL CHECK(length(name) BETWEEN 1 AND 255)` |
| `storage_reference` | `text` | `NOT NULL UNIQUE CHECK(storage_reference LIKE 'artifact://%')` |
| `checksum_sha256` | `text` | `NOT NULL CHECK(length(checksum_sha256)=64)` |
| `size_bytes` | `bigint` | `NOT NULL CHECK(size_bytes>=0)` |
| `retention_policy` | `text` | `NOT NULL CHECK(retention_policy IN ('EPHEMERAL','STANDARD_30D','EXTENDED_365D','LEGAL_HOLD'))` |
| `created_at` | `timestamptz` | `NOT NULL` |
| `created_by` | `text` | `NOT NULL` |
| `seq` | `bigint` | `GENERATED ALWAYS AS IDENTITY UNIQUE` |

Table-level keys/checks/relationships from the CREATE statement:

```sql
FOREIGN KEY(organization_id,run_id) REFERENCES agent_runs(organization_id,id),
FOREIGN KEY(organization_id,thread_id) REFERENCES agent_threads(organization_id,id),
FOREIGN KEY(organization_id,step_id) REFERENCES agent_run_steps(organization_id,id)
```

Indexes (including partial/case-insensitive uniqueness):

```sql
CREATE INDEX agent_artifacts_run ON agent_artifacts(organization_id,run_id,created_at);
```

## agent_run_leases

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `run_id` | `text` | `PRIMARY KEY` |
| `organization_id` | `text` | `NOT NULL REFERENCES organizations(id)` |
| `session_id` | `text` | `NOT NULL UNIQUE` |
| `runtime_id` | `text` | `NOT NULL CHECK(length(runtime_id) BETWEEN 1 AND 120)` |
| `state` | `text` | `NOT NULL CHECK(state IN ('ACTIVE','CLOSED'))` |
| `last_command` | `text` | `` |
| `claimed_at` | `timestamptz` | `NOT NULL` |
| `heartbeat_at` | `timestamptz` | `NOT NULL` |
| `lease_expires_at` | `timestamptz` | `NOT NULL` |
| `closed_at` | `timestamptz` | `` |
| `seq` | `bigint` | `GENERATED ALWAYS AS IDENTITY UNIQUE` |
| `recoveries` | `integer` | `NOT NULL DEFAULT 0 CHECK(recoveries>=0)` |

Table-level keys/checks/relationships from the CREATE statement:

```sql
FOREIGN KEY(organization_id,run_id) REFERENCES agent_runs(organization_id,id)
```

Indexes (including partial/case-insensitive uniqueness):

```sql
CREATE INDEX agent_run_leases_runtime ON agent_run_leases(runtime_id,state);
CREATE INDEX agent_run_leases_expiry ON agent_run_leases(lease_expires_at) WHERE state='ACTIVE';
```

## runtime_request_nonces

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `runtime_id` | `text` | `NOT NULL` |
| `nonce` | `text` | `NOT NULL` |
| `expires_at` | `bigint` | `NOT NULL` |

Table-level keys/checks/relationships from the CREATE statement:

```sql
PRIMARY KEY(runtime_id,nonce)
```

Indexes (including partial/case-insensitive uniqueness):

```sql
CREATE INDEX runtime_request_nonces_expiry ON runtime_request_nonces(expires_at);
```

## organization_connector_connections

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `id` | `text` | `PRIMARY KEY` |
| `organization_id` | `text` | `NOT NULL REFERENCES organizations(id)` |
| `provider` | `text` | `NOT NULL CHECK(provider IN ('jira','github'))` |
| `name` | `text` | `NOT NULL CHECK(length(name) BETWEEN 1 AND 120)` |
| `base_url` | `text` | `NOT NULL CHECK(base_url LIKE 'http%')` |
| `secret_ref` | `text` | `NOT NULL CHECK(secret_ref LIKE 'secret://%')` |
| `settings` | `jsonb` | `NOT NULL` |
| `status` | `text` | `NOT NULL CHECK(status IN ('ACTIVE','DISABLED'))` |
| `version` | `bigint` | `NOT NULL DEFAULT 1 CHECK(version>0)` |
| `created_by` | `text` | `NOT NULL` |
| `created_at` | `timestamptz` | `NOT NULL` |
| `updated_by` | `text` | `NOT NULL` |
| `updated_at` | `timestamptz` | `NOT NULL` |

Table-level keys/checks/relationships from the CREATE statement:

```sql
UNIQUE(organization_id,id),
FOREIGN KEY(organization_id,created_by) REFERENCES employees(organization_id,id),
FOREIGN KEY(organization_id,updated_by) REFERENCES employees(organization_id,id)
```

Indexes (including partial/case-insensitive uniqueness):

```sql
CREATE UNIQUE INDEX connector_one_active_per_provider ON organization_connector_connections(organization_id,provider)
 WHERE status='ACTIVE';
```

## agent_action_requests

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `id` | `text` | `PRIMARY KEY` |
| `organization_id` | `text` | `NOT NULL REFERENCES organizations(id)` |
| `run_id` | `text` | `NOT NULL` |
| `step_id` | `text` | `NOT NULL` |
| `runtime_id` | `text` | `NOT NULL` |
| `action` | `text` | `NOT NULL` |
| `tool_id` | `text` | `NOT NULL` |
| `request_hash` | `text` | `NOT NULL CHECK(length(request_hash)=64)` |
| `decision` | `text` | `NOT NULL CHECK(decision IN ('ALLOWED','DENIED','APPROVAL_REQUIRED'))` |
| `risk` | `text` | `NOT NULL CHECK(risk IN ('LOW','MEDIUM','HIGH','CRITICAL'))` |
| `reason` | `text` | `NOT NULL` |
| `approval_id` | `text` | `REFERENCES approvals(id)` |
| `created_at` | `timestamptz` | `NOT NULL` |
| `parameters` | `jsonb` | `` |
| `policy_id` | `text` | `` |
| `policy_version` | `text` | `` |
| `change_set` | `jsonb` | `` |
| `seq` | `bigint` | `GENERATED ALWAYS AS IDENTITY UNIQUE` |

Table-level keys/checks/relationships from the CREATE statement:

```sql
CHECK((decision='APPROVAL_REQUIRED') = (approval_id IS NOT NULL)),
FOREIGN KEY(organization_id,run_id) REFERENCES agent_runs(organization_id,id),
FOREIGN KEY(organization_id,step_id) REFERENCES agent_run_steps(organization_id,id)
```

Indexes (including partial/case-insensitive uniqueness):

```sql
CREATE INDEX agent_action_requests_run ON agent_action_requests(organization_id,run_id,created_at);
```

## organization_action_policies

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `organization_id` | `text` | `NOT NULL REFERENCES organizations(id)` |
| `action` | `text` | `NOT NULL CHECK(length(action) BETWEEN 3 AND 120)` |
| `outcome` | `text` | `NOT NULL CHECK(outcome IN ('REQUIRE_APPROVAL','DENY'))` |
| `reason` | `text` | `NOT NULL CHECK(length(reason) BETWEEN 1 AND 500)` |
| `updated_by` | `text` | `NOT NULL` |
| `updated_at` | `timestamptz` | `NOT NULL` |

Table-level keys/checks/relationships from the CREATE statement:

```sql
PRIMARY KEY(organization_id,action),
FOREIGN KEY(organization_id,updated_by) REFERENCES employees(organization_id,id)
```

## agent_action_executions

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `request_id` | `text` | `PRIMARY KEY REFERENCES agent_action_requests(id)` |
| `organization_id` | `text` | `NOT NULL REFERENCES organizations(id)` |
| `run_id` | `text` | `NOT NULL` |
| `connection_id` | `text` | `` |
| `status` | `text` | `NOT NULL CHECK(status IN ('DISPATCHING','SUCCEEDED','FAILED'))` |
| `result` | `jsonb` | `` |
| `error_code` | `text` | `` |
| `started_at` | `timestamptz` | `NOT NULL` |
| `completed_at` | `timestamptz` | `` |

Table-level keys/checks/relationships from the CREATE statement:

```sql
FOREIGN KEY(organization_id,run_id) REFERENCES agent_runs(organization_id,id),
FOREIGN KEY(organization_id,connection_id) REFERENCES organization_connector_connections(organization_id,id)
```

## agent_execution_grants

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0001-baseline.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `grant_id` | `text` | `PRIMARY KEY` |
| `request_id` | `text` | `NOT NULL UNIQUE REFERENCES agent_action_requests(id)` |
| `organization_id` | `text` | `NOT NULL REFERENCES organizations(id)` |
| `run_id` | `text` | `NOT NULL` |
| `operation_kind` | `text` | `NOT NULL` |
| `signed_grant` | `text` | `NOT NULL CHECK(af_json_valid(signed_grant))` |
| `issued_at` | `timestamptz` | `NOT NULL` |
| `expires_at` | `timestamptz` | `NOT NULL` |
| `seq` | `bigint` | `GENERATED ALWAYS AS IDENTITY UNIQUE` |

Table-level keys/checks/relationships from the CREATE statement:

```sql
FOREIGN KEY(organization_id,run_id) REFERENCES agent_runs(organization_id,id)
```

## organization_model_budgets

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0002-model-spending.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `organization_id` | `text` | `PRIMARY KEY REFERENCES organizations(id)` |
| `monthly_token_limit` | `bigint` | `CHECK(monthly_token_limit IS NULL OR monthly_token_limit>0)` |
| `run_token_limit` | `bigint` | `CHECK(run_token_limit IS NULL OR run_token_limit>0)` |
| `version` | `bigint` | `NOT NULL DEFAULT 1 CHECK(version>0)` |
| `updated_by` | `text` | `NOT NULL` |
| `updated_at` | `timestamptz` | `NOT NULL` |
| `currency` | `text` | `NOT NULL DEFAULT 'USD' CHECK(currency ~ '^[A-Z]{3}$')` |
| `monthly_cost_limit_micros` | `bigint` | `CHECK(monthly_cost_limit_micros IS NULL OR monthly_cost_limit_micros>0)` |
| `run_cost_limit_micros` | `bigint` | `CHECK(run_cost_limit_micros IS NULL OR run_cost_limit_micros>0)` |
| `alert_thresholds` | `smallint` | `[] NOT NULL DEFAULT '{80}' CHECK(cardinality(alert_thresholds) <= 5 AND array_position(alert_thresholds, NULL) IS NULL AND 1 <= ALL(alert_thresholds) AND 99 >= ALL(alert_thresholds))` |

Table-level keys/checks/relationships from the CREATE statement:

```sql
FOREIGN KEY(organization_id,updated_by) REFERENCES employees(organization_id,id)
```

## model_usage_reservations

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0002-model-spending.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `id` | `text` | `PRIMARY KEY` |
| `organization_id` | `text` | `NOT NULL REFERENCES organizations(id)` |
| `run_id` | `text` | `NOT NULL` |
| `employee_id` | `text` | `NOT NULL` |
| `agent_id` | `text` | `NOT NULL` |
| `runtime_id` | `text` | `NOT NULL` |
| `provider` | `text` | `NOT NULL` |
| `model` | `text` | `NOT NULL` |
| `period` | `text` | `NOT NULL CHECK(period ~ '^[0-9]{4}-[0-9]{2}$')` |
| `reserved_tokens` | `bigint` | `NOT NULL CHECK(reserved_tokens>0)` |
| `max_output_tokens` | `bigint` | `NOT NULL CHECK(max_output_tokens>0)` |
| `status` | `text` | `NOT NULL CHECK(status IN ('RESERVED','SETTLED'))` |
| `input_tokens` | `bigint` | `CHECK(input_tokens>=0)` |
| `output_tokens` | `bigint` | `CHECK(output_tokens>=0)` |
| `request_hash` | `text` | `NOT NULL` |
| `created_at` | `timestamptz` | `NOT NULL` |
| `settled_at` | `timestamptz` | `` |
| `seq` | `bigint` | `GENERATED ALWAYS AS IDENTITY UNIQUE` |
| `price_id` | `text` | `` |
| `currency` | `text` | `` |
| `reserved_cost_micros` | `bigint` | `CHECK(reserved_cost_micros>=0)` |
| `cost_micros` | `bigint` | `CHECK(cost_micros>=0)` |

Table-level keys/checks/relationships from the CREATE statement:

```sql
CHECK((status='SETTLED') = (input_tokens IS NOT NULL AND output_tokens IS NOT NULL AND settled_at IS NOT NULL)),
FOREIGN KEY(organization_id,run_id) REFERENCES agent_runs(organization_id,id),
FOREIGN KEY(organization_id,employee_id) REFERENCES employees(organization_id,id),
FOREIGN KEY(organization_id,agent_id) REFERENCES agents(organization_id,id)
```

Indexes (including partial/case-insensitive uniqueness):

```sql
CREATE INDEX model_usage_period ON model_usage_reservations(organization_id,period);
CREATE INDEX model_usage_run ON model_usage_reservations(organization_id,run_id);
```

## model_prices

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0003-model-prices.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `id` | `text` | `PRIMARY KEY` |
| `organization_id` | `text` | `NOT NULL REFERENCES organizations(id)` |
| `provider` | `text` | `NOT NULL` |
| `model` | `text` | `NOT NULL` |
| `currency` | `text` | `NOT NULL CHECK(currency ~ '^[A-Z]{3}$')` |
| `input_micros_per_million` | `bigint` | `CHECK(input_micros_per_million BETWEEN 0 AND 10000000000)` |
| `output_micros_per_million` | `bigint` | `CHECK(output_micros_per_million BETWEEN 0 AND 10000000000)` |
| `supersedes` | `text` | `` |
| `set_by` | `text` | `NOT NULL` |
| `set_at` | `timestamptz` | `NOT NULL` |
| `seq` | `bigint` | `GENERATED ALWAYS AS IDENTITY UNIQUE` |

Table-level keys/checks/relationships from the CREATE statement:

```sql
CHECK((input_micros_per_million IS NULL) = (output_micros_per_million IS NULL)),
UNIQUE(organization_id,id),
UNIQUE(organization_id,supersedes),
FOREIGN KEY(organization_id,supersedes) REFERENCES model_prices(organization_id,id),
FOREIGN KEY(organization_id,set_by) REFERENCES employees(organization_id,id)
```

Indexes (including partial/case-insensitive uniqueness):

```sql
CREATE INDEX model_prices_model ON model_prices(organization_id,provider,model,seq);
CREATE UNIQUE INDEX model_prices_first ON model_prices(organization_id,provider,model)
 WHERE supersedes IS NULL;
```

## model_budget_alerts

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0004-model-budget-alerts.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `id` | `text` | `PRIMARY KEY` |
| `organization_id` | `text` | `NOT NULL REFERENCES organizations(id)` |
| `period` | `text` | `NOT NULL CHECK(period ~ '^[0-9]{4}-[0-9]{2}$')` |
| `scope` | `text` | `NOT NULL CHECK(scope IN ('MONTHLY_TOKENS','MONTHLY_COST'))` |
| `threshold_percent` | `smallint` | `NOT NULL CHECK(threshold_percent BETWEEN 1 AND 100)` |
| `limit_value` | `bigint` | `NOT NULL CHECK(limit_value>0)` |
| `charged_value` | `bigint` | `NOT NULL CHECK(charged_value>=0)` |
| `currency` | `text` | `CHECK(currency ~ '^[A-Z]{3}$')` |
| `created_at` | `timestamptz` | `NOT NULL` |
| `acknowledged_by` | `text` | `` |
| `acknowledged_at` | `timestamptz` | `` |
| `seq` | `bigint` | `GENERATED ALWAYS AS IDENTITY UNIQUE` |

Table-level keys/checks/relationships from the CREATE statement:

```sql
UNIQUE(organization_id,period,scope,threshold_percent),
CHECK((scope='MONTHLY_COST') = (currency IS NOT NULL)),
CHECK((acknowledged_by IS NULL) = (acknowledged_at IS NULL)),
FOREIGN KEY(organization_id,acknowledged_by) REFERENCES employees(organization_id,id)
```

Indexes (including partial/case-insensitive uniqueness):

```sql
CREATE INDEX model_budget_alerts_period ON model_budget_alerts(organization_id,period);
```

## organization_alert_webhooks

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0005-alert-webhooks.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `id` | `text` | `PRIMARY KEY` |
| `organization_id` | `text` | `NOT NULL REFERENCES organizations(id)` |
| `url` | `text` | `NOT NULL CHECK(url ~ '^https?://' AND length(url) <= 500)` |
| `description` | `text` | `NOT NULL CHECK(length(description) <= 200)` |
| `status` | `text` | `NOT NULL CHECK(status IN ('ACTIVE','DISABLED'))` |
| `version` | `bigint` | `NOT NULL DEFAULT 1 CHECK(version>0)` |
| `created_by` | `text` | `NOT NULL` |
| `created_at` | `timestamptz` | `NOT NULL` |
| `updated_by` | `text` | `NOT NULL` |
| `updated_at` | `timestamptz` | `NOT NULL` |

Table-level keys/checks/relationships from the CREATE statement:

```sql
UNIQUE(organization_id,id),
FOREIGN KEY(organization_id,created_by) REFERENCES employees(organization_id,id),
FOREIGN KEY(organization_id,updated_by) REFERENCES employees(organization_id,id)
```

## alert_webhook_deliveries

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0005-alert-webhooks.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `id` | `text` | `PRIMARY KEY` |
| `organization_id` | `text` | `NOT NULL REFERENCES organizations(id)` |
| `webhook_id` | `text` | `NOT NULL` |
| `event_type` | `text` | `NOT NULL CHECK(event_type IN ('model.budget.alert','webhook.test'))` |
| `alert_id` | `text` | `REFERENCES model_budget_alerts(id)` |
| `body` | `text` | `NOT NULL` |
| `status` | `text` | `NOT NULL CHECK(status IN ('PENDING','DELIVERED','FAILED'))` |
| `attempts` | `integer` | `NOT NULL DEFAULT 0 CHECK(attempts BETWEEN 0 AND 10)` |
| `next_attempt_at` | `timestamptz` | `` |
| `last_attempt_at` | `timestamptz` | `` |
| `last_status_code` | `integer` | `CHECK(last_status_code BETWEEN 100 AND 599)` |
| `last_error` | `text` | `CHECK(length(last_error) <= 80)` |
| `delivered_at` | `timestamptz` | `` |
| `created_at` | `timestamptz` | `NOT NULL` |
| `seq` | `bigint` | `GENERATED ALWAYS AS IDENTITY UNIQUE` |

Table-level keys/checks/relationships from the CREATE statement:

```sql
UNIQUE(webhook_id,alert_id),
CHECK((event_type='model.budget.alert') = (alert_id IS NOT NULL)),
CHECK((status='PENDING') = (next_attempt_at IS NOT NULL)),
CHECK((status='DELIVERED') = (delivered_at IS NOT NULL)),
FOREIGN KEY(organization_id,webhook_id) REFERENCES organization_alert_webhooks(organization_id,id)
```

Indexes (including partial/case-insensitive uniqueness):

```sql
CREATE INDEX alert_webhook_deliveries_due ON alert_webhook_deliveries(next_attempt_at)
 WHERE status='PENDING';
CREATE INDEX alert_webhook_deliveries_recent ON alert_webhook_deliveries(organization_id,seq);
```

## model_quality_results

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0006-model-quality-results.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `run_id` | `text` | `NOT NULL CHECK(length(run_id) BETWEEN 1 AND 200)` |
| `run_at` | `timestamptz` | `NOT NULL` |
| `commit_sha` | `text` | `CHECK(length(commit_sha) <= 64)` |
| `provider` | `text` | `NOT NULL CHECK(length(provider) BETWEEN 1 AND 200)` |
| `model` | `text` | `NOT NULL CHECK(length(model) BETWEEN 1 AND 200)` |
| `judge_model` | `text` | `NOT NULL CHECK(length(judge_model) BETWEEN 1 AND 200)` |
| `blueprint` | `text` | `NOT NULL CHECK(length(blueprint) BETWEEN 1 AND 200)` |
| `suite` | `text` | `NOT NULL CHECK(length(suite) BETWEEN 1 AND 200)` |
| `task` | `text` | `NOT NULL CHECK(length(task) BETWEEN 1 AND 200)` |
| `trial` | `integer` | `NOT NULL CHECK(trial BETWEEN 1 AND 100)` |
| `passed` | `boolean` | `NOT NULL` |
| `score` | `double precision` | `NOT NULL CHECK(score BETWEEN 0 AND 1)` |
| `pass_threshold` | `double precision` | `NOT NULL CHECK(pass_threshold BETWEEN 0 AND 1)` |
| `failed_gates` | `jsonb` | `NOT NULL` |
| `run_status` | `text` | `NOT NULL CHECK(length(run_status) BETWEEN 1 AND 200)` |
| `tokens` | `bigint` | `NOT NULL CHECK(tokens >= 0)` |
| `estimated_cost_usd` | `double precision` | `CHECK(estimated_cost_usd >= 0)` |
| `imported_at` | `timestamptz` | `NOT NULL` |

Table-level keys/checks/relationships from the CREATE statement:

```sql
PRIMARY KEY(run_id, provider, model, judge_model, blueprint, task, trial)
```

Indexes (including partial/case-insensitive uniqueness):

```sql
CREATE INDEX model_quality_results_run_at ON model_quality_results(run_at);
```

## organization_source_control_connections

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0011-repository-credentials.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `id` | `text` | `PRIMARY KEY` |
| `organization_id` | `text` | `NOT NULL REFERENCES organizations(id)` |
| `provider` | `text` | `NOT NULL CHECK(provider IN ('github','bitbucket'))` |
| `name` | `text` | `NOT NULL CHECK(length(name) BETWEEN 1 AND 120)` |
| `git_host` | `text` | `NOT NULL CHECK(git_host ~ '^[a-z0-9]([a-z0-9.-]{0,251}[a-z0-9])?$')` |
| `api_base_url` | `text` | `NOT NULL CHECK(api_base_url ~ '^https?://' AND length(api_base_url) <= 300)` |
| `credential_mode` | `text` | `NOT NULL CHECK(credential_mode IN ('static_token','github_app'))` |
| `secret_ref` | `text` | `NOT NULL CHECK(secret_ref ~ '^secret://[a-z0-9][a-z0-9._-]{0,63}$')` |
| `app_id` | `text` | `CHECK(app_id ~ '^[0-9]{1,20}$')` |
| `installation_id` | `text` | `CHECK(installation_id ~ '^[0-9]{1,20}$')` |
| `allowed_repositories` | `jsonb` | `NOT NULL CHECK(jsonb_typeof(allowed_repositories)='array')` |
| `status` | `text` | `NOT NULL CHECK(status IN ('ACTIVE','DISABLED'))` |
| `version` | `bigint` | `NOT NULL DEFAULT 1 CHECK(version>0)` |
| `created_by` | `text` | `NOT NULL` |
| `created_at` | `timestamptz` | `NOT NULL` |
| `updated_by` | `text` | `NOT NULL` |
| `updated_at` | `timestamptz` | `NOT NULL` |

Table-level keys/checks/relationships from the CREATE statement:

```sql
UNIQUE(organization_id,id),
CHECK((credential_mode='github_app') = (app_id IS NOT NULL AND installation_id IS NOT NULL)),
CHECK(credential_mode<>'github_app' OR provider='github'),
FOREIGN KEY(organization_id,created_by) REFERENCES employees(organization_id,id),
FOREIGN KEY(organization_id,updated_by) REFERENCES employees(organization_id,id)
```

Indexes (including partial/case-insensitive uniqueness):

```sql
CREATE UNIQUE INDEX source_control_one_active_per_host
 ON organization_source_control_connections(organization_id,git_host) WHERE status='ACTIVE';
```

## repository_credential_leases

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0011-repository-credentials.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `id` | `text` | `PRIMARY KEY` |
| `organization_id` | `text` | `NOT NULL REFERENCES organizations(id)` |
| `connection_id` | `text` | `NOT NULL` |
| `provider` | `text` | `NOT NULL CHECK(provider IN ('github','bitbucket'))` |
| `repository` | `text` | `NOT NULL CHECK(repository ~ '^[A-Za-z0-9][A-Za-z0-9_.-]{0,99}/[A-Za-z0-9_.-]{1,100}$')` |
| `repository_url` | `text` | `NOT NULL CHECK(repository_url ~ '^https://' AND length(repository_url) <= 2048)` |
| `ref` | `text` | `NOT NULL CHECK(length(ref) BETWEEN 1 AND 200)` |
| `operation_kind` | `text` | `NOT NULL CHECK(operation_kind='git.checkout')` |
| `operation_digest` | `text` | `NOT NULL CHECK(operation_digest ~ '^[a-f0-9]{64}$')` |
| `grant_id` | `text` | `NOT NULL UNIQUE` |
| `request_id` | `text` | `NOT NULL` |
| `run_id` | `text` | `NOT NULL` |
| `employee_id` | `text` | `NOT NULL` |
| `agent_id` | `text` | `NOT NULL` |
| `issued_to_runtime` | `text` | `NOT NULL` |
| `status` | `text` | `NOT NULL CHECK(status IN ('ISSUED','REDEEMED','RELEASED','REVOKED','EXPIRED'))` |
| `issued_at` | `timestamptz` | `NOT NULL` |
| `expires_at` | `timestamptz` | `NOT NULL` |
| `redeemed_at` | `timestamptz` | `` |
| `redeemed_by` | `text` | `` |
| `released_at` | `timestamptz` | `` |
| `revoked_at` | `timestamptz` | `` |
| `revoked_by` | `text` | `` |
| `revoke_reason` | `text` | `CHECK(revoke_reason ~ '^[A-Z][A-Z0-9_]{1,63}$')` |
| `outcome` | `text` | `CHECK(outcome IN ('SUCCEEDED','FAILED','TIMED_OUT','CANCELLED','INTERRUPTED'))` |
| `seq` | `bigint` | `GENERATED ALWAYS AS IDENTITY UNIQUE` |

Table-level keys/checks/relationships from the CREATE statement:

```sql
CHECK(expires_at > issued_at),
CHECK(status<>'ISSUED' OR (redeemed_at IS NULL AND released_at IS NULL AND revoked_at IS NULL)),
CHECK((redeemed_at IS NULL) = (redeemed_by IS NULL)),
CHECK(status<>'REDEEMED' OR redeemed_at IS NOT NULL),
CHECK(status<>'RELEASED' OR (redeemed_at IS NOT NULL AND released_at IS NOT NULL)),
CHECK(status<>'REVOKED' OR (revoked_at IS NOT NULL AND revoke_reason IS NOT NULL)),
FOREIGN KEY(organization_id,connection_id)
  REFERENCES organization_source_control_connections(organization_id,id),
FOREIGN KEY(request_id) REFERENCES agent_action_requests(id),
FOREIGN KEY(organization_id,run_id) REFERENCES agent_runs(organization_id,id)
```

Indexes (including partial/case-insensitive uniqueness):

```sql
CREATE INDEX repository_credential_leases_live ON repository_credential_leases(expires_at)
 WHERE status IN ('ISSUED','REDEEMED');
CREATE INDEX repository_credential_leases_run ON repository_credential_leases(organization_id,run_id);
CREATE INDEX repository_credential_leases_recent ON repository_credential_leases(organization_id,seq);
```

## agent_run_checkpoints

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0012-run-recovery.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `organization_id` | `text` | `NOT NULL REFERENCES organizations(id)` |
| `run_id` | `text` | `NOT NULL` |
| `version` | `integer` | `NOT NULL CHECK(version>0)` |
| `thread_id` | `text` | `NOT NULL` |
| `session_id` | `text` | `NOT NULL` |
| `runtime_id` | `text` | `NOT NULL CHECK(length(runtime_id) BETWEEN 1 AND 120)` |
| `manifest_id` | `text` | `NOT NULL` |
| `manifest_digest` | `text` | `NOT NULL CHECK(manifest_digest ~ '^[a-f0-9]{64}$')` |
| `workflow` | `text` | `` |
| `step_id` | `text` | `` |
| `approval_id` | `text` | `` |
| `kernel_id` | `text` | `NOT NULL CHECK(length(kernel_id) BETWEEN 1 AND 100)` |
| `runtime_sequence` | `bigint` | `NOT NULL CHECK(runtime_sequence>=0)` |
| `body_sha256` | `text` | `NOT NULL CHECK(body_sha256 ~ '^[a-f0-9]{64}$')` |
| `body_bytes` | `integer` | `NOT NULL CHECK(body_bytes BETWEEN 2 AND 8388608)` |
| `body` | `text` | `NOT NULL` |
| `created_at` | `timestamptz` | `NOT NULL` |

Table-level keys/checks/relationships from the CREATE statement:

```sql
PRIMARY KEY(run_id,version),
FOREIGN KEY(organization_id,run_id) REFERENCES agent_runs(organization_id,id),
FOREIGN KEY(organization_id,thread_id) REFERENCES agent_threads(organization_id,id),
FOREIGN KEY(organization_id,step_id) REFERENCES agent_run_steps(organization_id,id)
```

## agent_artifact_objects

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0013-artifact-objects.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `artifact_id` | `text` | `PRIMARY KEY` |
| `organization_id` | `text` | `NOT NULL REFERENCES organizations(id)` |
| `thread_id` | `text` | `NOT NULL` |
| `run_id` | `text` | `NOT NULL` |
| `step_id` | `text` | `NOT NULL` |
| `tool_call_id` | `text` | `` |
| `store` | `text` | `NOT NULL CHECK(store ~ '^[a-z0-9][a-z0-9-]{0,62}$')` |
| `storage_key` | `text` | `NOT NULL UNIQUE CHECK(storage_key ~ '^[A-Za-z0-9._/-]+$' AND length(storage_key) <= 512)` |
| `media_type` | `text` | `NOT NULL CHECK(length(media_type) BETWEEN 3 AND 129)` |
| `size_bytes` | `bigint` | `NOT NULL CHECK(size_bytes>=0)` |
| `sha256` | `text` | `NOT NULL CHECK(sha256 ~ '^[a-f0-9]{64}$')` |
| `retention_class` | `text` | `NOT NULL CHECK(retention_class IN ('EPHEMERAL','STANDARD_30D','EXTENDED_365D','LEGAL_HOLD'))` |
| `state` | `text` | `NOT NULL CHECK(state IN ('PENDING','STORED','REGISTERED','DELETED'))` |
| `uploaded_by` | `text` | `NOT NULL CHECK(length(uploaded_by) BETWEEN 1 AND 120)` |
| `created_at` | `timestamptz` | `NOT NULL` |
| `registered_at` | `timestamptz` | `` |
| `expires_at` | `timestamptz` | `` |
| `deleted_at` | `timestamptz` | `` |
| `deletion_reason` | `text` | `CHECK(deletion_reason ~ '^[A-Z][A-Z0-9_]{1,63}$')` |
| `seq` | `bigint` | `GENERATED ALWAYS AS IDENTITY UNIQUE` |

Table-level keys/checks/relationships from the CREATE statement:

```sql
CHECK((retention_class='LEGAL_HOLD') = (expires_at IS NULL)),
CHECK(state<>'REGISTERED' OR registered_at IS NOT NULL),
CHECK((state='DELETED') = (deleted_at IS NOT NULL)),
CHECK((deleted_at IS NULL) = (deletion_reason IS NULL)),
FOREIGN KEY(organization_id,run_id) REFERENCES agent_runs(organization_id,id),
FOREIGN KEY(organization_id,thread_id) REFERENCES agent_threads(organization_id,id),
FOREIGN KEY(organization_id,step_id) REFERENCES agent_run_steps(organization_id,id)
```

Indexes (including partial/case-insensitive uniqueness):

```sql
CREATE INDEX agent_artifact_objects_run ON agent_artifact_objects(organization_id,run_id);
CREATE INDEX agent_artifact_objects_due ON agent_artifact_objects(expires_at)
 WHERE state='REGISTERED';
CREATE INDEX agent_artifact_objects_unregistered ON agent_artifact_objects(created_at)
 WHERE state IN ('PENDING','STORED');
```

## organization_model_credentials

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0014-model-credentials.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `organization_id` | `text` | `NOT NULL REFERENCES organizations(id)` |
| `provider` | `text` | `NOT NULL CHECK(provider ~ '^[a-zA-Z0-9._-]{1,80}$')` |
| `secret_ref` | `text` | `NOT NULL CHECK(secret_ref ~ '^secret://[a-z0-9][a-z0-9._-]{0,63}$')` |
| `status` | `text` | `NOT NULL CHECK(status IN ('ACTIVE','DISABLED'))` |
| `version` | `bigint` | `NOT NULL DEFAULT 1 CHECK(version>0)` |
| `created_by` | `text` | `NOT NULL` |
| `created_at` | `timestamptz` | `NOT NULL` |
| `updated_by` | `text` | `NOT NULL` |
| `updated_at` | `timestamptz` | `NOT NULL` |

Table-level keys/checks/relationships from the CREATE statement:

```sql
PRIMARY KEY(organization_id,provider),
FOREIGN KEY(organization_id,created_by) REFERENCES employees(organization_id,id),
FOREIGN KEY(organization_id,updated_by) REFERENCES employees(organization_id,id)
```

## agent_action_reconciliations

[Defining migration](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrations/0015-action-reconciliation.ts).

| Field | Current declared type | Declaration / constraint |
| --- | --- | --- |
| `request_id` | `text` | `PRIMARY KEY REFERENCES agent_action_executions(request_id)` |
| `organization_id` | `text` | `NOT NULL REFERENCES organizations(id)` |
| `thread_id` | `text` | `NOT NULL` |
| `run_id` | `text` | `NOT NULL` |
| `action` | `text` | `NOT NULL CHECK(action ~ '^[a-z][a-z0-9_.]+$' AND length(action) <= 120)` |
| `payload_digest` | `text` | `NOT NULL CHECK(payload_digest ~ '^[a-f0-9]{64}$')` |
| `reason` | `text` | `NOT NULL CHECK(reason IN ('CONNECTOR_OUTCOME_UNKNOWN','DISPATCH_INTERRUPTED'))` |
| `state` | `text` | `NOT NULL CHECK(state IN ('REQUIRED','APPLIED','NOT_APPLIED'))` |
| `created_at` | `timestamptz` | `NOT NULL` |
| `resolved_by` | `text` | `` |
| `resolved_at` | `timestamptz` | `` |
| `note` | `text` | `CHECK(note IS NULL OR length(note) <= 500)` |
| `seq` | `bigint` | `GENERATED ALWAYS AS IDENTITY UNIQUE` |

Table-level keys/checks/relationships from the CREATE statement:

```sql
CHECK((state='REQUIRED') = (resolved_at IS NULL)),
CHECK((resolved_at IS NULL) = (resolved_by IS NULL)),
FOREIGN KEY(organization_id,run_id) REFERENCES agent_runs(organization_id,id),
FOREIGN KEY(organization_id,thread_id) REFERENCES agent_threads(organization_id,id),
FOREIGN KEY(organization_id,resolved_by) REFERENCES employees(organization_id,id)
```

Indexes (including partial/case-insensitive uniqueness):

```sql
CREATE INDEX agent_action_reconciliations_payload
 ON agent_action_reconciliations(organization_id,action,payload_digest) WHERE state='REQUIRED';
CREATE INDEX agent_action_reconciliations_thread
 ON agent_action_reconciliations(organization_id,thread_id,action) WHERE state='REQUIRED';
```

## Migration ledger

`schema_migrations` is created by `db/migrate.ts`, outside the baseline table SQL: version, name, checksum and applied_at. It records the checksum-normalized ordered migration history.

## Related documentation

[Domain ownership](../architecture/domain-model.md) · [Authorization](../security/authorization.md) · [Migration procedures](README.md)
