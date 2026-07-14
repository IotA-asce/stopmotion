# ADR 0001: State And Navigation

**Status:** Accepted

## Decision

Use Riverpod 3 for dependency injection and state ownership. Put `ProviderScope` at the application root, inject repositories through providers, use synchronous `Notifier` for local UI settings, and use `AsyncNotifier` for repository-backed controllers. Tests override providers rather than invoking plugins.

Use go_router 17 with `StatefulShellRoute.indexedStack` for the persistent Projects and Settings destinations. Project workspaces live above the shell so they receive the full viewport. Every route has an explicit loading, content, not-found, or error surface and declares restoration scope identifiers.

## Rationale

These choices provide testable dependency boundaries, persistent top-level branch state, path-based workspace navigation, deep-link compatibility, and an explicit error route without a custom navigation framework.

## Consequences

- Domain and repository interfaces cannot depend on Riverpod or go_router.
- Controllers must be overrideable in unit and widget tests.
- Workspace routes accept immutable IDs in path parameters and must handle deleted IDs.
- Route redirects for onboarding and recovery are added when their persistent state exists in Phase 2.

## Sources

- Context7 `/websites/pub_dev_flutter_riverpod_3_3_0`, queried 2026-07-14.
- Context7 `/websites/pub_dev_packages_go_router`, queried 2026-07-14.
