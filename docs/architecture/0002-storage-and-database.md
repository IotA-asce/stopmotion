# ADR 0002: Storage And Database

**Status:** Accepted for Phase 2 implementation

## Decision

Use Drift on SQLite for transactional metadata, ordering, journals, migrations, and reactive project queries. Use `NativeDatabase.createInBackground` against an application-support database file. Enable foreign keys before use and validate them after migrations.

Store immutable source media in project-owned directories beneath application support. Database paths are relative to the storage root. Temporary captures/imports, journals, and final atomic renames belong to the same filesystem volume. Thumbnails and waveforms are disposable cache files.

## Rationale

The product contract requires atomic media acceptance, relational integrity, migration safety, reactive library updates, and interruption recovery. Shared preferences and unstructured JSON cannot satisfy those requirements reliably.

## Consequences

- Multi-step filesystem and database work uses an operation journal and idempotent recovery.
- Before a file-backed database opens, retain a last-known snapshot alongside it. Launch verifies integrity, restores that snapshot only when the active database cannot be opened safely, and never resets project data silently.
- Repository tests use `NativeDatabase.memory()` with synchronous stream closure.
- Migration tests retain versioned schema fixtures.
- Source files are never deleted while referenced by a frame or pending journal.

## Sources

- Context7 `/websites/drift_simonbinder_eu`, queried 2026-07-14.
- Context7 `/flutter/packages` path_provider documentation, queried 2026-07-14.
