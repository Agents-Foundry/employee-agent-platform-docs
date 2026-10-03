# Validated examples and an API walkthrough

**Audience:** Developers and API consumers. **Implementation status:** Implemented schemas and fixture validation; real runs need provisioned identities, credentials and feature flags.

Prerequisites: Read [local setup](../docs/developer/local-development.md), [HTTP conventions](../docs/api/README.md) and [runtime deployment](../docs/deployment/runtime-processes.md). Commands below are Bash with curl and Node 24, issued from this documentation checkout. PowerShell users should invoke curl.exe and adapt the shell variables or use their HTTP client. Never send a demonstration signature to a live workload.

## Fixtures

| File | Validation / use |
| --- | --- |
| [QA payload](manifest-v2/qa-agent.payload.json) | Complete V2 generated from QA 1.2.0 catalog resolution and current policy |
| [Signed QA manifest](manifest-v2/qa-agent.signed.json) | Real Ed25519 demonstration signature; not a provisioned employee |
| [Verification key](manifest-v2/verification-key.json) | Public fixture key only; private signing key was never retained |
| [Start run](api/start-run.json) | Strict browser start-run schema; replace agentId with your own V2 assignment |
| [Run submission](runtime/run-submit.json) | Runtime protocol parser and signed manifest binding |
| [Run-started event](runtime/run-started.json) | Runtime event parser; fictional correlation/session IDs |
| [Action request](runtime/action-request.json) | Issue-tracker read parameters, action envelope and canonical input digest |

All IDs, organizations, repository targets and model identifiers are fictional. `example-model-id` is not a supported real model claim. The public key verifies this fixture only. `npm run check:source` imports the pinned source parsers/resolver/verifier and checks these fixtures plus invalid-signature/unknown-field rejection.

## Session and assignment

Sign in through the employee application first. For a password-mode development environment, supply an existing employee's login in a temporary, private login.json with fields email, password and client="employee". Use the actual auth schema; remove this local secret file immediately after login. It is not a committed fixture. API is localhost:4100 and the configured employee Origin is localhost:4300 by default.

```bash
AF_API='http://localhost:4100'
AF_ORIGIN='http://localhost:4300'
curl --fail-with-body --cookie-jar .validation/employee.cookies   -H "Origin: $AF_ORIGIN" -H 'Content-Type: application/json'   --data-binary @login.json "$AF_API/api/auth/password"
curl --fail-with-body --cookie .validation/employee.cookies "$AF_API/api/bootstrap"
curl --fail-with-body --cookie .validation/employee.cookies "$AF_API/api/catalog/v1/blueprints"
```

The bootstrap response supplies the signed-in actor and available assignments. Choose an agent you own and retrieve its manifest via `/api/agents/:id/manifest`; verify the actual issued key/signature before use. An arbitrary agent ID, an administrator assignment list or this demo fixture cannot confer ownership.

## Start and observe

Copy api/start-run.json to .validation/start-run.json and replace agentId with the actual assigned V2 ID. Set AF_RUN to the id returned by this POST; the fixture's correlation IDs are not the live run's IDs.

```bash
curl --fail-with-body --cookie .validation/employee.cookies   -H "Origin: $AF_ORIGIN" -H 'Content-Type: application/json'   --data-binary @.validation/start-run.json "$AF_API/api/execution/v1/runs"
AF_RUN='set-to-returned-run-uuid'
curl --fail-with-body --cookie .validation/employee.cookies "$AF_API/api/execution/v1/runs/$AF_RUN"
curl --fail-with-body --cookie .validation/employee.cookies   "$AF_API/api/execution/v1/runs/$AF_RUN/events?afterSequence=0&limit=100"
```

POST returns 202, not completion. Advance afterSequence from the events you have received. Queued work requires a matching registered runtime profile. WAITING_FOR_APPROVAL requires a separate eligible administrator session: fetch `/api/approvals`, review scope/payload/expiry, then POST decision APPROVED or REJECTED to `/api/approvals/:id/decision`. The requester cannot approve their own action. Do not reuse the employee cookie as administrator authorization.

To cancel owned work:

```bash
curl --fail-with-body --cookie .validation/employee.cookies   -X POST -H "Origin: $AF_ORIGIN" "$AF_API/api/execution/v1/runs/$AF_RUN/cancel"
```

## Evidence and safety

Run detail includes artifact metadata. To download, POST `/api/execution/v1/artifacts/:id/retrievals` with the authorized session and Origin, then fetch the returned download URL with that same session within its 60-second validity. Treat the URL as a short-lived credential; do not paste it into a ticket or log. Content is downloaded with nosniff/attachment headers, not rendered on the application origin.

Workload endpoints require a registered Ed25519 identity, raw-byte digest, timestamp and nonce, not the browser cookie. Use the real RuntimeClient instead of inventing signature headers. See [protocol](../docs/runtime/protocol.md), [manifest](../docs/agents/manifest-v2.md) and [source provenance](../docs/reference/provenance.md).
