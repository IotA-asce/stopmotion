# Repository Instructions

## Working Style

- Always plan first for non-trivial tasks.
- Prefer small, isolated changes over broad refactors.
- Do not leave partially implemented flows without marking TODOs clearly.
- Before finishing, explain what changed, what was verified, and any remaining risks.

## Git Workflow

- For every feature or bugfix, create a dedicated branch first.
- Never implement directly on the `main` branch.
- Before committing, run the relevant validation commands for the changed area.
- Commit only after validation passes, or explicitly report what could not be run.
- After committing, merge the branch into the target branch and push to remote.

## Current Documentation

- Treat `docs/FINAL_STATE.md` as the product contract for the first public release.
- Use `docs/DEVELOPMENT_PHASES.md` as the shared progress checklist and update it in the commit that completes an item.
- Follow `docs/plans/2026-07-14-first-public-release.md` for implementation order and verification.
- Update both files when approved scope or release behavior changes.

## Context7

Use Context7 MCP to fetch current documentation whenever work concerns a library, framework, SDK, API, CLI tool, or cloud service. This includes API syntax, configuration, migrations, dependency setup, package-specific debugging, and CLI usage.

Do not use Context7 for repository refactoring, scripts written from scratch, business-logic debugging, code review, or general programming concepts.

1. Start with `resolve-library-id` using the library name and full question unless an exact `/org/project` ID is supplied.
2. Select the best exact and reputable match, preferring version-specific IDs when a version is named.
3. Call `query-docs` with the selected ID and full question.
4. Base implementation decisions on the fetched documentation and record material dependency choices in `docs/architecture/dependencies.md`.
