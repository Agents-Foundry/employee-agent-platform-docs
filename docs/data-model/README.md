# Database migrations, RLS and data ownership

**Audience:** Database operators, backend developers. **Implementation status:** Implemented.

**Prerequisites:** Read the platform overview and have access to the relevant organization or source checkout.

The control plane uses PostgreSQL 16 in local/CI configuration. Its current schema registry has migrations 0001–0015. Legacy SQLite migration files are retained for import/compatibility and are not the active control-plane migration engine. The execution process separately keeps grant/workspace state in SQLite.

[Full schema dictionary](schema.md) · [Domain relationships](../architecture/domain-model.md) · [Exact migration SQL](../../reference-data/postgresql-migrations.sql).

## Connection roles

Bootstrap establishes a schema owner (migration login), a tenant login inheriting af_tenant without BYPASSRLS, and a platform login inheriting af_platform with BYPASSRLS for cross-tenant authentication/catalog/runtime operations. The owner is not a superuser, and forced RLS applies to it. Bootstrap itself needs DATABASE_ADMIN_URL with superuser authority to create the appropriate role attributes and database.

Tenant queries run in `PgStore.tenant` with transaction-local app.organization_id. Nested scope mismatch fails; tenant isolation combines RLS, grants and composite foreign keys. Global/auth/catalog tables have specialized grants/policies. Runtime claims start in platform scope before switching to a validated stored run's tenant scope.

## Applying and upgrading

```bash
npm run db:bootstrap
npm run db:migrate
```

These run from the platform root. A deployment supplying DATABASE_MIGRATION_URL applies migrations during API startup; a least-privileged API without it needs a separate migration step. Checksums normalize line endings and compare exact registered SQL. MIGRATION_CHECKSUM_MISMATCH, SCHEMA_NEWER_THAN_RELEASE or DATABASE_SCHEMA_MISMATCH stop startup; never edit a released migration or delete ledger records to suppress them.

The implementation holds one advisory transaction lock and applies the pending batch within the surrounding BEGIN/COMMIT. An old source comment says 'one transaction each', but the code uses the shared transaction. Failed migration rolls back. No down-migration engine is shipped. Schema/code rollback requires explicit compatibility review or tested backup restoration.

## Types and immutable bytes

Migration 0008 changes ordinary timestamps to timestamptz and parsed JSON to jsonb. Exact signed/pinned text (manifests, grants, catalog content, webhook bodies) stays text. PostgreSQL parsers return ISO strings and JSON text to preserve API behavior; bigint parsing refuses values outside JavaScript safe integer range.

Unique/partial indexes enforce tenant codes, active names and connections. Composite keys prevent foreign-tenant references; triggers protect ownership, approved effects and immutable or append-only history. Use the linked source SQL for each table's guarantees instead of treating every audit-related table as equally immutable.

## Imports, backup and restore

`npm run db:import-sqlite -- /absolute/path/to/legacy.db` imports into an empty PostgreSQL target after its required migration/bootstrap path. Quality history imports through `db:import-quality`. These are operator tools, not browser upload APIs.

No backup scheduler or restore automation ships. Back up PostgreSQL plus the manifest/grant signing key, managed artifact bytes/metadata and execution host state as required by active grants. Test restore in isolation, verify schema and key continuity and forbid duplicate external writes; see the production checklist. Signing-key loss cannot be fixed by merely regenerating a key without invalidating trust in existing manifests.

## Source provenance

Reviewed against platform commit `d2bc8d7fa3fc185cc4f487bdaa1f11611844763f`. These references support the behavior described; types alone are not evidence that a capability executes.

- [apps/control-plane-api/src/db/migrate.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/db/migrate.ts)
- [apps/control-plane-api/src/db/bootstrap.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/db/bootstrap.ts)
- [apps/control-plane-api/src/db/pg-store.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/db/pg-store.ts)
- [apps/control-plane-api/src/db/import-sqlite.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/db/import-sqlite.ts)
- [apps/control-plane-api/src/db/migrations/0008-native-column-types.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/apps/control-plane-api/src/db/migrations/0008-native-column-types.ts)

## Related documentation

[Documentation index](../README.md) · [Implementation status](../reference/implementation-status.md)
