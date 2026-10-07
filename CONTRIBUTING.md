# Contributing to platform documentation

Use current code as the authority for executable behavior. A contract field, catalog selection, historical ADR or marketing claim does not prove a backing engine exists. Use Implemented, Partially Implemented, Planned, Experimental or an explicitly evidenced Deprecated status.

## Validate an edit

Prerequisites: Node 24, npm, Git and access to the pinned product repository. This repository's package is private documentation tooling, not an npm distribution.

```bash
npm ci
npm run check
git clone https://github.com/Agents-Foundry/employee-agent-platform.git .sources/platform
git -C .sources/platform checkout d2bc8d7fa3fc185cc4f487bdaa1f11611844763f
npm run check:source
```

`.sources`, `.validation` and `node_modules` are ignored. Never commit `.env`, real workload keys, tokens, customer checkpoints or copied production records. The committed example public key is an ephemeral fixture; no private key is retained.

## Regenerate references

```bash
npm run reference:generate
npm run schema:generate
```

Regeneration uses the checked-out source, but the generators currently carry the pinned SHA explicitly. For a baseline update, update all generator pins, source inventory, workflow checkout and authored provenance together, review the diff, then run checks. Do not publish mismatched generated content with an old provenance header.

```bash
npm run examples:generate
npm run check:source
npm run check
```

Example generation creates a new demonstration signature/key pair; it is normally unnecessary for prose edits. Intentional fixture changes must be committed together.

## Writing and review

Give each guide a purpose, audience, prerequisites, implementation status, source evidence and related links. Prefer one substantive guide covering connected concepts to many empty files. Explain outcomes and failure boundaries. Include copyable commands only when actual scripts or schemas support them; distinguish source excerpts from executable examples.

Use relative links for documents, pinned GitHub links for product evidence and Mermaid for bounded diagrams. Keep generated API/schema/type declarations out of manually maintained prose. Historical ADR context/date/status is preserved; propose new decisions rather than retroactively labeling recommendations as accepted.

For website changes, run `npm run site:build` and `npm run site:check`, then review desktop/mobile layouts, search and Mermaid rendering with `npm run site:preview`. The [hosting guide](SITE_HOSTING.md) documents deployment; validated main-branch changes publish automatically to GitHub Pages.

Every architecture/API/schema/security/runtime change requires a [documentation impact review](docs/contributing/release-documentation.md). Reviewers should inspect code-backed claims, affected audiences, examples, diagram syntax and missing operational evidence. Unknowns belong in [DOCUMENTATION_BACKLOG](DOCUMENTATION_BACKLOG.md), with investigation and priority.
