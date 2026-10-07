# Release documentation and drift policy

**Audience:** Maintainers and release owners. **Implementation status:** Implemented.

**Prerequisites:** Read the platform overview and have access to the relevant organization or source checkout.

This repository establishes a documentation review policy; it does not claim the product repository already enforces that policy. Every product PR changing architecture, APIs, schemas, user behavior, configuration, environment variables, deployment, security, runtime, policy, integration or manifests should assess documentation impact.

## Suggested product PR checklist

- [ ] Documentation impact reviewed
- [ ] Documentation updated if required
- [ ] Implementation status and known gaps updated
- [ ] Pinned source/examples/references updated together for a baseline release

Link the corresponding documentation PR and exact product commit. Do not require the docs baseline to follow an unmerged product branch while describing it as released behavior.

## Baseline update procedure

1. Fetch the exact candidate commit into the ignored source checkout. Inspect changed code, schemas, tests, migrations, workflow and configuration.
2. Update the source pin in reference/schema/example/check scripts and CI. Regenerate inventory, API/schema/test/env references; examine added/removed routes, fields, constraints and validators.
3. Review authored state machines, policy precedence, credential boundaries and role workflows. Update all provenance headers only after the behaviors have been checked.
4. Validate fixtures against the actual resolver, parser and verifier. Run Markdown/link/source-reference/Mermaid checks.
5. Record failures, skipped product tests and live integration evidence separately. A new adapter passing mocks is not live production qualification.
6. Preserve prior ADR decisions and explicitly identify superseding records. Add unresolved evidence to the documentation backlog; new executable gaps belong to engineering recommendations.

CI in this repository checks the pinned snapshot. It prevents references and fixtures from silently drifting against that baseline, but it cannot prove a new product main commit remains covered until a deliberate pin update. Maintainers must evaluate product changes and publish a docs update with each supported release.

The review PR should explain which audiences changed, implementation limitations and validation performed. Never count a Docker-skipped test or a syntax-parsed diagram as end-to-end or visual validation.

## Source provenance

Reviewed against platform commit `d2bc8d7fa3fc185cc4f487bdaa1f11611844763f`. These references support the behavior described; types alone are not evidence that a capability executes.

- [.github/workflows/ci.yml](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/.github/workflows/ci.yml)
- [package.json](https://github.com/Agents-Foundry/employee-agent-platform/blob/d2bc8d7fa3fc185cc4f487bdaa1f11611844763f/package.json)

## Related documentation

[Documentation index](../README.md) · [Implementation status](../reference/implementation-status.md)
