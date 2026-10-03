# Source provenance and verification limits

**Audience:** Maintainers, reviewers, architects. **Implementation status:** Implemented.

**Prerequisites:** Read the platform overview and have access to the relevant organization or source checkout.

The implementation baseline is **9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4**, inspected on 2026-10-03. A fetched Git archive of that commit was reviewed separately from the user's older working checkout; uncommitted product/website work was not used as platform evidence or changed.

## Repository evidence

| Repository | Inspected evidence | Interpretation |
| --- | --- | --- |
| employee-agent-platform | Application source; contracts; catalog definitions; policy engine; migration registry/SQL; tests; package scripts; CI; sandbox Dockerfile; Tauri config; existing docs/38 ADRs | Authority for current executable behavior |
| employee-agent-website | Commit 4cc111021cf60b5a4b676a26659fbc51431a5ef3; README/package; public-build.mjs/site-config.mjs; Pages workflow | Static marketing/deployment responsibility; no runtime/security authority |
| employee-agent-platform-docs | Initially empty private repository; organization permissions; this review branch | Documentation and checks; does not deploy product services |

`source-inventory.json` records normalized SHA-256 hashes of relevant text files. Indexing a file is not a claim that every line received a manual security audit. Authored pages cite the specific inspected files; generated reference pages enumerate source declarations.

## Generation and validation

Routes are extracted from Express registration syntax, including prefixes/constants/aliases, plus the execution server's three node:http routes. The generator rejects unresolved route paths. Validators and contract declarations are reproduced with pinned source links; these excerpts are not complete service-level authorization proofs or an invented OpenAPI contract.

The PostgreSQL dictionary is a static reconstruction from 15 registered migrations, including later type changes. It is not a live production schema inspection. SQL constraints/triggers and the source migration stream remain authoritative. Execution SQLite has a separate ownership/state guide.

Manifest examples are built by the real catalog resolver, manifest builder and policy engine, then signed with an ephemeral demonstration key. Source validation checks the actual Zod parsers, catalog digest, canonical input digest and signature verification, including tamper rejection. It does not contact Anthropic, Jira, GitHub, Vault or S3 and does not qualify a production installation.

Link checks verify local target paths/anchors and pinned platform source targets against the inventory. External availability of third-party URLs is not asserted. Mermaid is syntax-parsed; documentation checks do not replace visual review in the consuming renderer.

## Conflicts with historical documentation

Older README/architecture/gap documents describe SQLite or static earlier phases; the current control plane uses PostgreSQL and implements generic runtime, leases, checkpoints, credentials, artifacts and spending. Historical ADR-0034 overstates existing desktop credential storage; the current Tauri shell does not implement the advertised OS key integration. ADR originals are preserved with a current correction. Some original guides are adapted with explicit present-day boundaries.

ApprovalRequest's older type omits EXPIRED although newer summaries support it. Migration comments suggest per-migration transactions while the runner wraps the pending batch in one transaction. These are code/documentation inconsistencies recorded in the backlog; this documentation PR does not change product behavior.

ADR-0025's local trend command omits its required workspace selector. The archive now includes the source-supported root invocation without changing the historical decision.

Pin updates require regeneration plus review of runtime/authorization behavior, not just replacing the SHA in page headers. Follow the [release policy](../contributing/release-documentation.md).

## Source provenance

Reviewed against platform commit `9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4`. These references support the behavior described; types alone are not evidence that a capability executes.

- [package.json](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/package.json)
- [.github/workflows/ci.yml](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/.github/workflows/ci.yml)
- [docs/architecture-v2.md](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/docs/architecture-v2.md)
- [docs/architecture-v2-gap-analysis.md](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/docs/architecture-v2-gap-analysis.md)

## Related documentation

[Documentation index](../README.md) · [Implementation status](implementation-status.md)
