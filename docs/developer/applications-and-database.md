# Application development, schema changes and debugging

**Audience:** Frontend, backend and database developers. **Implementation status:** Implemented.

**Prerequisites:** Read the platform overview and have access to the relevant organization or source checkout.

Work from the product checkout at the documented baseline. Node/npm versions, PostgreSQL setup and process order are in [local development](local-development.md). Angular applications are projects in angular.json; the three Node services are npm workspaces. Shared contracts/catalog/policy/web-auth packages use TypeScript paths or relative imports and are not independent npm installations.

## Frontend work

The admin app is under apps/control-plane-web; employee UI is under apps/employee-desktop. Shared sign-in/session behavior and assets live in packages/web-auth. Use the configured local API proxy and credentials handling; never add a client-controlled tenant or role as an authorization shortcut.

```bash
npm run start:admin
npm run start:employee
```

These commands occupy separate terminals. Validate a frontend change with the existing scripts:

```bash
npm run build:admin
npm run build:employee
npm run test:web
```

Tests use Angular's configured test builder and Vitest/jsdom. They are not proof of real Google SSO, native callback behavior or a packaged installer. Native shell configuration and current distribution gaps are in [desktop deployment](../deployment/desktop.md). Generic role/API support does not mean a corresponding management screen exists.

## Backend work

Use apps/control-plane-api/src/app.ts to trace route registration, then follow the domain service and PgStore scope. Runtime workloads use separate signed transport; browser session auth must not be reused for workload calls. Keep policy, digest/approval binding and credential revelation in the existing authorization boundary rather than inside a model-facing tool.

```bash
npm run dev:api
npm run build:api
npm run test:api
```

dev:api uses configured authentication; dev:api:demo is an explicit local-only alternative. API tests create isolated PostgreSQL databases through Docker or TEST_DATABASE_ADMIN_URL. Do not use a customer database as a test superuser target. Use domain-focused tests for input validation, tenant/owner denial, stale versions, atomic updates and audit records; broaden to npm run check before release.

## Schema changes

Add a new migration export and register it in POSTGRES_MIGRATIONS in db/migrate.ts; never edit an already-applied migration's SQL. The runner rejects a changed normalized checksum. Study existing migrations for composite tenant foreign keys, forced RLS, af_tenant grants and platform-only access. Every new tenant table needs an intentional policy and every platform query needs explicit authorization review.

```bash
npm run db:migrate
```

This command targets the configured migration URL. The runner takes an advisory lock and executes the pending batch transactionally; source comments about one transaction per migration do not describe the actual outer BEGIN/COMMIT. There is no down-migration command. Prepare and test a backup/forward-fix plan before altering a production schema. Startup checks exact registered migration IDs/checksums; an older application cannot silently accept a newer schema.

Update the contract/parser/API consumers along with the database representation. Type-only contract changes do not validate an HTTP request. Regenerate the docs dictionary against the new baseline and test the migrated database, especially global-versus-tenant access and optimistic version handling.

## Formatting and investigation

The root package contains Prettier but no lint script. Build scripts enforce TypeScript/Angular compilation and npm run check is the supplied combined gate. Follow existing code conventions rather than inventing a repository coding standard.

To debug, compare browser status/error envelope with the owning route/service, then inspect tenant-scoped records and sanitized correlation logs. For runtime failures, follow run/step/event IDs and operation outcomes; do not dump checkpoint messages or credential responses. The [troubleshooting matrix](../operations/troubleshooting.md) identifies component-specific diagnosis and recovery.

## Source provenance

Reviewed against platform commit `9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4`. These references support the behavior described; types alone are not evidence that a capability executes.

- [angular.json](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/angular.json)
- [package.json](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/package.json)
- [tsconfig.json](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/tsconfig.json)
- [apps/control-plane-api/src/app.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/app.ts)
- [apps/control-plane-api/src/db/migrate.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/migrate.ts)

## Related documentation

[Documentation index](../README.md) · [Implementation status](../reference/implementation-status.md)
