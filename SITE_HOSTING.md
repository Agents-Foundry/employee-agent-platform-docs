# Documentation website and GitHub Pages

**Audience:** Documentation maintainers. **Status:** Static documentation site and GitHub Actions deployment.

The website publishes the Markdown knowledge base at [Agents Foundry Docs](https://agents-foundry.github.io/employee-agent-platform-docs/). It adds responsive navigation, browser-local full-text search, a page contents panel, light/dark themes, code-copy controls and rendered Mermaid diagrams. The Markdown repository remains the source of truth; do not edit generated HTML.

## Build and preview

Prerequisites: Node 24 and npm. From this repository:

```bash
npm ci
npm run site:build
npm run site:check
npm run site:preview
```

Open http://127.0.0.1:4412/employee-agent-platform-docs/. Stop the preview with Ctrl+C. The build output is the ignored .site directory. SITE_BASE defaults to /employee-agent-platform-docs/; it can be changed to another slash-delimited path for a different deployment. The preview uses the same base and an optional PORT setting.

The builder publishes top-level Markdown, docs and examples Markdown, sanitized JSON/SQL references, the source inventory and explicitly selected site assets. It does not copy private source snapshots, credentials, dependencies, validation scratch data or arbitrary working-directory files. Mermaid modules are hosted locally from the pinned npm package; no diagram or search request is sent to a third-party service. Search loads its local index when opened.

## Deployment

.github/workflows/pages.yml validates documentation, builds the site, checks generated links/anchors/resources and uploads a Pages artifact. Pull requests build and check without production deployment. A push to main or a manual workflow dispatch deploys through GitHub Actions with pages:write and id-token:write permissions.

The repository's Pages source must be GitHub Actions. The repository is public: GitHub Free supports Pages for public repositories. Hosting from a private repository requires a supported paid plan. The Pages site is a public static knowledge base and has no employee session, platform backend, secret input or model execution.

## Checks and recovery

`npm run check` verifies Markdown and pinned documentation references. `npm run site:check` verifies every generated article, local link/anchor, asset and searchable page, including the repository base path. It also checks that referenced Mermaid modules are present. Diagram rendering, search/theme/menu interactions and small-screen layout should be reviewed in a browser after changes to site assets.

For a failed deployment, inspect the Publish documentation workflow, its build/deploy steps and Pages settings. Fix the source/build and redeploy; do not commit .site or manually overwrite the Pages artifact. To roll back site presentation, revert the relevant commit on main and allow the workflow to publish the previous source. Preserve the separate pinned product implementation baseline when changing website presentation.

[Documentation index](docs/README.md) · [Contributor commands](CONTRIBUTING.md) · [Release policy](docs/contributing/release-documentation.md)
