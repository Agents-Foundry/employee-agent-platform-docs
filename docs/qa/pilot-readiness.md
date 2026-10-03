# Evidence-derived pilot readiness

**Audience:** QA, operators, architects. **Implementation status:** Implemented.

**Prerequisites:** Read the platform overview and have access to the relevant organization or source checkout.

Whether the repository is ready for a first controlled organization pilot is computed, not
declared ([ADR 0038](../adr/0038-pilot-readiness-assessment.md)).

```bash
npm run test        # writes test results to .readiness/results/
npm run readiness   # writes .readiness/pilot-readiness-report.json and prints a summary
npm run check       # build, test and readiness together; this is what CI runs
```

- [`pilot-readiness/assessment.json`](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/pilot-readiness/assessment.json) lists each
  capability, the tests that prove it and the limitations that are still open.
- The report gives each capability a status. `GREEN`: every proof ran and passed and nothing
  is open. `AMBER`: proven, with an accepted limitation or a proof that could not run in this
  environment. `RED`: a proof failed, was skipped or is missing, or a limitation blocks a
  pilot.
- The build fails when a capability falls below its minimum. CI keeps the report as the
  `pilot-readiness` artifact.

To add a capability or change a proof, edit the assessment file. A proof is a test file and
the exact title of a test in it; a test in the control-plane suite fails if the assessment
names a test that does not exist.

## Before a pilot

The assessment proves what the tests exercise. Each accepted limitation in the report has a
`beforePilot` step. In short:

1. Run an upload, a direct upload, a retrieval and a retention pass against the pilot's
   object store, and resolve a secret through the pilot's Vault.
2. Point the three processes at the pilot's collector and confirm one run's trace arrives
   whole; create the alerts in [observability](../operations/observability.md).
3. Use organization-managed model credentials; employee-held keys are refused.
4. Run execution runtimes with the container provider and the egress proxy, on hosts
   dedicated to the pilot organization.
5. Give administrators the runbook for approvals, reconciliation
   ([failure handling](../operations/failure-handling.md)) and artifact download, which have APIs and no
   screens yet.
6. Run the model-quality workflow for the pilot's model and review its scores.

## Source provenance

Reviewed against platform commit `9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4`. These references support the behavior described; types alone are not evidence that a capability executes.

- [docs/pilot-readiness.md](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/docs/pilot-readiness.md)
- [pilot-readiness/assessment.json](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/pilot-readiness/assessment.json)
- [packages/readiness/src/assess.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/readiness/src/assess.ts)
- [packages/readiness/src/cli.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/packages/readiness/src/cli.ts)
- [apps/control-plane-api/test/pilot-readiness.spec.ts](https://github.com/Agents-Foundry/employee-agent-platform/blob/9e7ec4eba0eeddb0fdb86c18740a1c1a610146a4/apps/control-plane-api/test/pilot-readiness.spec.ts)

## Related documentation

[Documentation index](../README.md) · [Implementation status](../reference/implementation-status.md)
