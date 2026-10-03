# Developer setup and verification

**Audience:** Developers, QA engineers. **Implementation status:** Implemented.

**Prerequisites:** Node 24, npm 11, Git and Docker. Read this entire setup before provisioning a database.

Use the platform repository, not this docs repository, for these commands. Source scripts specify npm 11.9.0; CI uses Node 24. PostgreSQL 16 and Docker support the development database and sandbox/test operations. Rust/Tauri prerequisites are needed only for the native shell.

```bash
git clone https://github.com/Agents-Foundry/employee-agent-platform.git
cd employee-agent-platform
git checkout 9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4
npm ci
```

Copy `.env.example` to `.env` (`cp` on POSIX or `Copy-Item .env.example .env` in PowerShell). It contains development-only PostgreSQL URLs. Keep these local; do not carry their passwords into a pilot. The default sign-in mode is Google and requires explicit configuration. The demo command opts in only locally.

```bash
npm run db:dev
npm run db:bootstrap
npm run dev:api:demo
```

In separate terminals at the repository root:

```bash
npm run start:admin
npm run start:employee
```

Ports: API 4100, admin 4200, employee 4300, local PostgreSQL host 55433. The API applies migrations at startup when `DATABASE_MIGRATION_URL` is set; otherwise run `npm run db:migrate` and provide a schema matching this release. `db:bootstrap` can reset existing login-role passwords/attributes: run against the intended development server only.

## Generic runtime setup

Enable `AGENT_MANIFEST_V2_ISSUANCE_ENABLED=true` and `GENERIC_AGENT_RUNTIME_ENABLED=true` on the API. Register separate agent/execution workload public keys, pin the manifest verification key on both runtimes, and follow the [runtime deployment](../deployment/runtime-processes.md) guide. Enable `QA_GENERIC_RUNTIME_ENABLED=true` only when exercising the upgraded QA route. Provision an ORGANIZATION_MANAGED v2 agent with a supported provider; v1 agents cannot start generic runs.

## Build and test gates

```bash
npm run build
npm run test
npm run readiness
npm run check
```

`check` runs build, web/API/agent/execution tests and evidence-derived readiness. API tests start a disposable PostgreSQL container unless `TEST_DATABASE_ADMIN_URL` supplies a test superuser. They create/drop isolated test databases; never point that setting at production. Docker-dependent operational tests can skip when infrastructure is unavailable; skipped tests are not passes.

Use `npm run test:api`, `npm run test:runtime`, `npm run test:execution` or `npm run test:evals` for targeted suites. Live `eval:quality` spends provider tokens and is separate from `check`. See the [QA strategy](../qa/test-strategy.md).

## Debugging

Use each workspace's `dev` script (tsx watch) for the Node processes. Source maps and TypeScript paths are configured by the supplied tsconfig files. Start with health responses, workload identity registration, feature flags, source schema version and run error codes; do not log credential responses or checkpoint bodies.

## Source provenance

Reviewed against platform commit `9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4`. These references support the behavior described; types alone are not evidence that a capability executes.

- [package.json](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/package.json)
- [package-lock.json](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/package-lock.json)
- [apps/control-plane-api/package.json](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/package.json)
- [.env.example](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/.env.example)
- [.github/workflows/ci.yml](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/.github/workflows/ci.yml)
- [apps/control-plane-api/src/db/cli.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/src/db/cli.ts)

## Related documentation

[Documentation index](../README.md) · [Implementation status](../reference/implementation-status.md)
