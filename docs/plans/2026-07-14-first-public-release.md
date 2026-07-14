# Stop Motion First Public Release Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build and ship Stop Motion 1.0 as a reliable, offline-first Flutter application for Android and iOS that satisfies every requirement in `docs/FINAL_STATE.md`.

**Architecture:** Use a feature-first Flutter application with explicit domain, data, and presentation boundaries. Store project metadata and ordered timelines in a transactional local database, store immutable source media in project-owned directories, and journal every multi-step media operation so interruption can be recovered safely. Platform camera, media encoding, sharing, permissions, and lifecycle capabilities sit behind Dart interfaces with Android and iOS implementations where a maintained Flutter package is insufficient.

**Tech Stack:** Current stable Flutter and Dart selected at implementation kickoff; Material 3; Riverpod for dependency injection and state; go_router for typed route structure and restoration; Drift/SQLite for transactional metadata; platform file storage for media; maintained camera, audio, picker, path, permission, sharing, and playback packages selected from current official documentation; native Android/iOS media APIs or a license-approved maintained encoder selected by ADR; GitHub Actions; Flutter unit, widget, golden, and integration tests.

---

## 1. How To Use This Plan

This plan is the delivery sequence, not a loose backlog. Complete tasks in order unless a task explicitly allows parallel work. Every implementation branch follows `@feature-delivery`: create a dedicated branch, add a failing test where applicable, implement the smallest complete behavior, run validation, commit, merge to `main`, and push.

Before adopting or configuring a Flutter/Dart package, use Context7 as required by `AGENTS.md`:

1. Resolve the package's current library ID.
2. Query documentation with the full implementation question.
3. Record the selected package version, platform requirements, and relevant links in `docs/architecture/dependencies.md`.
4. Reject abandoned, license-incompatible, or platform-incomplete packages.

Do not implement around a failing test by weakening the requirement. If a final-state requirement changes, update `docs/FINAL_STATE.md`, this plan, and the affected acceptance tests together.

## 2. Delivery Rules

### Branches

- Foundation and infrastructure: `chore/<scope>`.
- User-visible behavior: `feat/<scope>`.
- Defect correction: `fix/<scope>`.
- Release hardening: `release/1.0.0`.

### Required validation per branch

Run from the repository root:

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

Also run the narrowest relevant integration, Android, iOS, or golden commands listed in each task. Expected result is exit code 0 with no analyzer warnings. If a platform command cannot run locally, CI and a named physical-device check must pass before merge.

### Commit policy

- One coherent behavior per commit.
- No generated media, signing keys, credentials, personal device IDs, or local environment files.
- Generated Dart code may be committed only if the chosen project convention requires it and CI verifies it is current.
- Every commit that changes behavior includes or updates tests.

## 3. Target Repository Structure

```text
android/
ios/
assets/
  illustrations/
  licenses/
docs/
  architecture/
  release/
  test-plans/
integration_test/
lib/
  app/
    app.dart
    bootstrap.dart
    router.dart
    theme/
  core/
    database/
    diagnostics/
    errors/
    filesystem/
    media/
    platform/
    recovery/
    widgets/
  features/
    onboarding/
    projects/
    capture/
    editor/
    audio/
    preview/
    export/
    settings/
    recovery/
test/
  fixtures/
  helpers/
tool/
```

Each feature may contain `domain/`, `data/`, and `presentation/` folders. Domain code must not import Flutter UI, database, camera, or file-picker packages. Platform and package types must not leak into domain entities.

## 4. Milestone Map

| Milestone | Outcome | Final-state groups |
| --- | --- | --- |
| M0 | Toolchain, architecture decisions, CI | `REL-OPS-*` |
| M1 | Durable projects and project library | `REL-DATA-*`, `REL-NAV-*` |
| M2 | Reliable capture and import | `REL-CAP-*`, `REL-DATA-*` |
| M3 | Timeline, image editing, and preview | `REL-EDIT-*` |
| M4 | Audio editing and synchronized playback | `REL-AUD-*` |
| M5 | MP4, GIF, image sequence, and sharing | `REL-EXP-*` |
| M6 | Recovery, accessibility, performance | `REL-DATA-*`, `REL-ACC-*`, `REL-PERF-*` |
| M7 | Store readiness and public release | `REL-OPS-*` |

## 5. Implementation Tasks

### Task 1: Establish Toolchain And Architecture Records

**Branch:** `chore/flutter-foundation`
**Requirements:** `REL-OPS-001`

**Files:**

- Create: `.fvmrc` or the selected repository-level Flutter version file
- Create: `pubspec.yaml`
- Create: `analysis_options.yaml`
- Create: `docs/architecture/0001-state-and-navigation.md`
- Create: `docs/architecture/0002-storage-and-database.md`
- Create: `docs/architecture/0003-media-encoding.md`
- Create: `docs/architecture/dependencies.md`
- Create: `.github/workflows/validate.yml`
- Modify: `.gitignore`
- Modify: `README.md`

**Steps:**

1. Install or select the current stable Flutter SDK and record `flutter --version` output in the dependency document.
2. Query current official package documentation through Context7 for state, routing, database, camera, audio, picking, permissions, playback, sharing, and storage candidates.
3. Write ADRs that document alternatives, licensing, platform support, maintenance status, and the chosen direction.
4. Run `flutter create --org com.iotaasce --platforms android,ios .` and preserve repository documentation.
5. Configure strict analysis, package metadata, Android namespace, iOS bundle ID placeholder, minimum OS versions, and deterministic dependency constraints.
6. Add CI jobs for formatting, analysis, tests, Android debug build, and an iOS no-codesign build on macOS.
7. Add a smoke test that pumps the root app and verifies the Projects destination renders.
8. Run the required validation and both platform debug builds.
9. Commit `chore: establish Flutter project foundation`, merge, and push.

**Exit criteria:** A clean checkout can resolve dependencies, analyze, test, and build Android and iOS debug artifacts in CI.

### Task 2: Build App Shell, Theme, And Route Contract

**Branch:** `feat/app-shell`
**Requirements:** `REL-NAV-001` through `REL-NAV-010`, visual system sections 4 and 5

**Files:**

- Create: `lib/app/app.dart`
- Create: `lib/app/bootstrap.dart`
- Create: `lib/app/router.dart`
- Create: `lib/app/theme/app_colors.dart`
- Create: `lib/app/theme/app_theme.dart`
- Create: `lib/app/theme/app_spacing.dart`
- Create: `lib/core/widgets/app_scaffold.dart`
- Create: `lib/features/projects/presentation/projects_page.dart`
- Create: `lib/features/settings/presentation/settings_page.dart`
- Test: `test/app/router_test.dart`
- Test: `test/app/theme_test.dart`
- Test: `test/goldens/app_shell_golden_test.dart`

**Steps:**

1. Write route tests for `/projects`, `/settings`, project workspaces, invalid project IDs, and system back behavior.
2. Run the route tests and confirm they fail because the router is absent.
3. Implement the app bootstrap, provider scope, restoration scope, router, top-level navigation, and placeholder workspace boundaries.
4. Write theme tests for light/dark semantic colors, 48-pixel targets, text scaling, and reduced motion.
5. Implement exact semantic tokens from `docs/FINAL_STATE.md` with Material 3 components.
6. Add phone and tablet shell goldens in portrait, landscape, light, dark, and 200% text scale.
7. Run widget, route, accessibility-semantics, and golden tests.
8. Commit `feat: add application shell and navigation`, merge, and push.

**Exit criteria:** Every declared route resolves to a stable loading, content, not-found, or error screen, and top-level navigation adapts between bottom bar and rail.

### Task 3: Define Domain Models And Database Schema

**Branch:** `feat/project-domain`
**Requirements:** `REL-DATA-001` through `REL-DATA-010`, `REL-EDIT-001`

**Files:**

- Create: `lib/features/projects/domain/project.dart`
- Create: `lib/features/editor/domain/frame.dart`
- Create: `lib/features/audio/domain/audio_clip.dart`
- Create: `lib/features/export/domain/export_record.dart`
- Create: `lib/core/database/app_database.dart`
- Create: `lib/core/database/tables/*.dart`
- Create: `lib/core/database/migrations.dart`
- Test: `test/core/database/app_database_test.dart`
- Test: `test/core/database/migrations_test.dart`
- Test: `test/features/projects/domain/project_test.dart`

**Steps:**

1. Write immutable model tests for identifiers, fps range, aspect ratios, frame holds, timeline ordering, edit parameters, and calculated duration.
2. Write schema tests for projects, frames, timeline entries, audio clips, exports, operation journals, trash, and settings.
3. Write a migration fixture for schema version 1 and a failing forward-migration test template.
4. Implement models with validated constructors/value objects and no package-specific types.
5. Implement the Drift schema, foreign keys, indexes, transactions, and migration runner.
6. Add tests proving source media cannot be orphan-deleted while referenced and timeline positions remain unique per project.
7. Run database tests on an in-memory and temporary-file database.
8. Commit `feat: define project domain and local database`, merge, and push.

**Exit criteria:** The schema represents every 1.0 project concept, enforces referential integrity, and has a tested migration baseline.

### Task 4: Implement Project Filesystem And Operation Journal

**Branch:** `feat/durable-storage`
**Requirements:** `REL-DATA-011` through `REL-DATA-025`

**Files:**

- Create: `lib/core/filesystem/project_paths.dart`
- Create: `lib/core/filesystem/atomic_file_store.dart`
- Create: `lib/core/recovery/operation_journal.dart`
- Create: `lib/core/recovery/recovery_service.dart`
- Create: `lib/features/projects/data/project_repository.dart`
- Create: `test/helpers/fake_file_store.dart`
- Test: `test/core/filesystem/atomic_file_store_test.dart`
- Test: `test/core/recovery/operation_journal_test.dart`
- Test: `test/features/projects/data/project_repository_test.dart`

**Steps:**

1. Write failing tests for project-directory creation, relative paths, temporary names, atomic replacement, cleanup, and independent duplication.
2. Write fault-injection tests for interruption before copy, after copy, before database commit, and after database commit.
3. Implement a filesystem interface and real/fake adapters.
4. Implement atomic media acceptance using temp file, validation, flush, rename, database transaction, and read-back verification.
5. Implement operation journal states and idempotent recovery actions.
6. Implement project create, rename, duplicate, trash, restore, and permanent delete repositories.
7. Run tests repeatedly with randomized failure points and verify no phantom database rows or deleted valid source files.
8. Commit `feat: add durable project storage and journaling`, merge, and push.

**Exit criteria:** Every multi-step media operation can be completed or rolled back after interruption without silently losing the only valid media copy.

### Task 5: Deliver Onboarding And Projects Library

**Branch:** `feat/projects-library`
**Requirements:** `REL-NAV-*`, Projects sections 6 and 7

**Files:**

- Create: `lib/features/onboarding/presentation/onboarding_page.dart`
- Create: `lib/features/onboarding/data/onboarding_repository.dart`
- Create: `lib/features/projects/presentation/projects_controller.dart`
- Create: `lib/features/projects/presentation/project_tile.dart`
- Create: `lib/features/projects/presentation/create_project_sheet.dart`
- Create: `lib/features/projects/presentation/project_details_sheet.dart`
- Test: `test/features/onboarding/onboarding_test.dart`
- Test: `test/features/projects/projects_page_test.dart`
- Test: `test/features/projects/create_project_test.dart`
- Test: `integration_test/project_lifecycle_test.dart`

**Steps:**

1. Write widget tests for first launch, skipped permissions, empty library, search, sort, filter, grid/list mode, damaged project, and low-storage states.
2. Write create-project validation tests for title collision, aspect ratio, fps, resolution, and cancellation.
3. Implement onboarding without requesting permissions prematurely.
4. Implement paged/streamed project queries and progressive thumbnail loading.
5. Implement create, rename, duplicate, details, trash, undo, restore, and permanent delete UI.
6. Add semantics and 200% text-scale tests for every project command.
7. Run the project lifecycle integration test across app restart.
8. Commit `feat: deliver onboarding and project library`, merge, and push.

**Exit criteria:** A user can manage persistent projects from first launch through trash recovery, including all empty and error states.

### Task 6: Prove Camera And Lifecycle Capabilities

**Branch:** `chore/camera-spike`
**Requirements:** `REL-CAP-001` through `REL-CAP-015`

**Files:**

- Create: `docs/architecture/0004-camera-and-lifecycle.md`
- Create: `lib/core/media/camera_service.dart`
- Create: `lib/core/media/camera_capabilities.dart`
- Create: `lib/core/media/package_camera_service.dart`
- Create: `test/core/media/camera_service_contract_test.dart`
- Create: `integration_test/camera_capabilities_test.dart`

**Steps:**

1. Define a package-independent camera contract for initialize, capture, zoom, focus/exposure, flash, camera switch, lifecycle pause/resume, and errors.
2. Use Context7 to verify the selected camera package's current APIs and platform limitations.
3. Implement a thin adapter and a fake that can inject capture and lifecycle failures.
4. Build a temporary test route available only in debug/integration builds.
5. Verify preview orientation, source EXIF orientation, lifecycle resume, and rapid-tap suppression on the physical-device matrix.
6. Record unsupported controls by platform/device in the ADR and define UI fallback rules.
7. Remove any unneeded spike UI while retaining contract tests and adapters.
8. Commit `chore: validate camera and lifecycle integration`, merge, and push.

**Exit criteria:** Physical-device evidence proves the selected camera path can satisfy the capture contract or the ADR selects a native fallback before UI work begins.

### Task 7: Implement Durable Single-Frame Capture

**Branch:** `feat/frame-capture`
**Requirements:** `REL-CAP-016` through `REL-CAP-030`, `REL-DATA-*`

**Files:**

- Create: `lib/features/capture/domain/capture_frame.dart`
- Create: `lib/features/capture/data/capture_repository.dart`
- Create: `lib/features/capture/presentation/capture_controller.dart`
- Create: `lib/features/capture/presentation/capture_page.dart`
- Create: `lib/features/capture/presentation/camera_preview_surface.dart`
- Test: `test/features/capture/capture_repository_test.dart`
- Test: `test/features/capture/capture_controller_test.dart`
- Test: `test/features/capture/capture_page_test.dart`
- Test: `integration_test/capture_persistence_test.dart`

**Steps:**

1. Encode the nine-step frame capture guarantee from `docs/FINAL_STATE.md` as repository contract tests.
2. Add failure tests for undecodable source, copy failure, rename failure, database failure, app backgrounding, low storage, and duplicate shutter taps.
3. Implement the capture transaction through the durable storage and journal services.
4. Implement the camera-first page with stable shutter, count, recent filmstrip, loading, denied, unavailable, and failure states.
5. Ensure success feedback and frame count occur only after file and record read-back verification.
6. Run an integration test that captures, force-stops, reopens, and verifies frame bytes, record, ordering, and thumbnail.
7. Run the physical-device capture loop for at least 100 frames per supported platform.
8. Commit `feat: implement durable frame capture`, merge, and push.

**Exit criteria:** No tested interruption creates a missing frame, phantom frame, duplicate acceptance, or false success indication.

### Task 8: Add Capture Tools, Interval Mode, And Import

**Branch:** `feat/capture-tools`
**Requirements:** Capture sections 8.3 through 8.5

**Files:**

- Create: `lib/features/capture/presentation/capture_tools.dart`
- Create: `lib/features/capture/domain/interval_capture.dart`
- Create: `lib/features/capture/data/frame_import_service.dart`
- Create: `lib/core/media/image_validation_service.dart`
- Test: `test/features/capture/interval_capture_test.dart`
- Test: `test/features/capture/frame_import_test.dart`
- Test: `integration_test/import_and_interval_test.dart`

**Steps:**

1. Write controller tests for zoom, focus/exposure, flash, camera switching, grid, onion skin, difference mode, timer, volume shutter, and unsupported capabilities.
2. Write fake-clock tests for interval start, stop, backgrounding, low storage, frame failure, and wake-lock release.
3. Write batch-import tests for picker order, orientation, cancellation, partial failure, restart, and permanent project-owned copies.
4. Implement capability-driven controls, overlays, countdown, and explicit interval state.
5. Implement onion-skin and difference overlays without changing captured source images.
6. Implement batch import through the same journaled acceptance path as capture.
7. Add landscape, small-phone, tablet, dark, and 200% text-scale goldens.
8. Run physical-device permission, hardware control, timer, interval, and import checks.
9. Commit `feat: add capture tools and frame import`, merge, and push.

**Exit criteria:** All hardware-dependent controls degrade explicitly, interval mode cannot outlive its workspace, and every imported source remains readable after picker access is revoked.

### Task 9: Build Playback Clock And Timeline Domain

**Branch:** `feat/editor-timeline-core`
**Requirements:** `REL-EDIT-001` through `REL-EDIT-025`, Playback section 11

**Files:**

- Create: `lib/features/editor/domain/timeline.dart`
- Create: `lib/features/editor/domain/timeline_command.dart`
- Create: `lib/features/preview/domain/playback_clock.dart`
- Create: `lib/features/editor/data/editor_repository.dart`
- Create: `test/features/editor/timeline_test.dart`
- Create: `test/features/editor/timeline_commands_test.dart`
- Create: `test/features/preview/playback_clock_test.dart`

**Steps:**

1. Write property-style tests for frame order, holds, duration, fps changes, selection ranges, and playhead mapping.
2. Write command tests for insert, reorder, duplicate, delete, reverse, copy/paste, hold, and undo/redo inversion.
3. Write fake-time playback tests proving less than 40 milliseconds drift over two minutes.
4. Implement immutable timeline snapshots and reversible commands.
5. Implement an audio-clock-aware playback scheduler that can skip preview rendering without changing time.
6. Persist command results transactionally and debounce only non-critical metadata writes.
7. Run randomized command sequences and verify domain invariants after every command.
8. Commit `feat: implement timeline and playback core`, merge, and push.

**Exit criteria:** Timeline calculations are deterministic, reversible, persistable, and independent of widget frame rate.

### Task 10: Deliver Editor Workspace And Timeline UI

**Branch:** `feat/editor-workspace`
**Requirements:** Editor sections 9.1 through 9.3

**Files:**

- Create: `lib/features/editor/presentation/editor_page.dart`
- Create: `lib/features/editor/presentation/editor_controller.dart`
- Create: `lib/features/editor/presentation/preview_canvas.dart`
- Create: `lib/features/editor/presentation/transport_controls.dart`
- Create: `lib/features/editor/presentation/frame_timeline.dart`
- Create: `lib/features/editor/presentation/frame_action_menu.dart`
- Test: `test/features/editor/editor_page_test.dart`
- Test: `test/features/editor/frame_timeline_test.dart`
- Test: `integration_test/timeline_editing_test.dart`

**Steps:**

1. Write widget tests for stable layout, transport, scrub, select, multi-select, range select, reorder, zoom, and playhead visibility.
2. Write semantics and keyboard tests for every gesture-driven action.
3. Implement adaptive phone/tablet and portrait/landscape layouts.
4. Implement virtualized frame thumbnails and cache cancellation for off-screen items.
5. Wire domain commands to toolbar/menu actions, keyboard shortcuts, undo, redo, and autosave state.
6. Add golden tests across supported layout, theme, and text-scale combinations.
7. Run timeline integration tests with 1,000 generated lightweight frame fixtures.
8. Commit `feat: deliver editor workspace and timeline`, merge, and push.

**Exit criteria:** All frame commands work by touch and accessible alternatives, and a 1,000-frame timeline remains within the performance budget.

### Task 11: Add Non-Destructive Image Editing

**Branch:** `feat/image-adjustments`
**Requirements:** `REL-EDIT-026` through `REL-EDIT-045`

**Files:**

- Create: `lib/features/editor/domain/frame_adjustments.dart`
- Create: `lib/core/media/frame_renderer.dart`
- Create: `lib/features/editor/presentation/frame_inspector.dart`
- Create: `lib/features/editor/presentation/crop_editor.dart`
- Test: `test/features/editor/frame_adjustments_test.dart`
- Test: `test/core/media/frame_renderer_test.dart`
- Test: `test/goldens/frame_adjustments_golden_test.dart`

**Steps:**

1. Write serialization and reset tests for every adjustment and transform.
2. Create deterministic fixture images and pixel-tolerance tests for crop, fit/fill, rotate, flip, exposure, contrast, highlight/shadow, temperature/tint, saturation, and sharpen.
3. Implement a renderer that accepts immutable source plus instructions and produces bounded-size previews or export frames.
4. Implement inspector controls, numeric accessible alternatives, range application, and before/after comparison.
5. Ensure preview cache keys include source revision, instructions, target dimensions, and color mode.
6. Prove editing never changes source bytes and reset reproduces the original fitted rendering.
7. Run memory profiling for repeated full-resolution edits.
8. Commit `feat: add non-destructive frame editing`, merge, and push.

**Exit criteria:** Every visual edit is reversible, reproducible in export, accessible without precise gestures, and cannot mutate immutable source media.

### Task 12: Implement Full-Screen Preview

**Branch:** `feat/project-preview`
**Requirements:** Playback section 11

**Files:**

- Create: `lib/features/preview/presentation/preview_page.dart`
- Create: `lib/features/preview/presentation/preview_controller.dart`
- Create: `lib/features/preview/presentation/preview_quality_menu.dart`
- Test: `test/features/preview/preview_page_test.dart`
- Test: `integration_test/project_preview_test.dart`

**Steps:**

1. Write tests for route entry/exit playhead, loop, scrub, start/end, orientation, and quality mode.
2. Implement full-screen rendering with control auto-hide that remains screen-reader operable.
3. Connect the deterministic playback clock and frame renderer.
4. Add performance fallback that reduces preview resolution, not timeline timing.
5. Verify a two-minute fixture against timing and memory budgets on baseline devices.
6. Commit `feat: add synchronized project preview`, merge, and push.

**Exit criteria:** Preview matches timeline timing and image edits and returns to the originating workspace without losing state.

### Task 13: Implement Audio Domain, Recording, And Import

**Branch:** `feat/audio-workspace`
**Requirements:** `REL-AUD-001` through `REL-AUD-035`

**Files:**

- Create: `lib/core/media/audio_service.dart`
- Create: `lib/features/audio/domain/audio_timeline.dart`
- Create: `lib/features/audio/data/audio_repository.dart`
- Create: `lib/features/audio/data/waveform_service.dart`
- Create: `lib/features/audio/presentation/audio_page.dart`
- Create: `lib/features/audio/presentation/audio_controller.dart`
- Test: `test/features/audio/audio_timeline_test.dart`
- Test: `test/features/audio/audio_repository_test.dart`
- Test: `integration_test/audio_record_import_test.dart`

**Steps:**

1. Use Context7 to validate current recording, decoding, and playback APIs and document platform formats.
2. Write domain tests for track limits, positioning, trim, split, duplicate, mute, volume, fades, and project duration clipping.
3. Write permission tests proving import remains available when microphone access is denied.
4. Implement journaled recording/import and project-owned audio copies.
5. Implement bounded waveform generation with cache and cancellation.
6. Implement count-in, input level, pause/resume, stop, trim handles, numeric trim controls, and clip commands.
7. Add restart and unreadable-audio recovery integration tests.
8. Commit `feat: deliver audio recording and editing`, merge, and push.

**Exit criteria:** Narration and imported tracks persist, edit non-destructively, recover from missing files, and expose accessible alternatives to timeline gestures.

### Task 14: Synchronize Mixed Audio Playback

**Branch:** `feat/audio-playback`
**Requirements:** `REL-AUD-036` through `REL-AUD-045`, `REL-PERF-*`

**Files:**

- Create: `lib/core/media/audio_mixer.dart`
- Modify: `lib/features/preview/domain/playback_clock.dart`
- Modify: `lib/features/editor/presentation/transport_controls.dart`
- Test: `test/core/media/audio_mixer_test.dart`
- Test: `integration_test/audio_sync_test.dart`

**Steps:**

1. Write sample- or timestamp-based tests for volume, fades, overlapping clips, mute, master volume, seek, pause, and loop.
2. Implement the preview mixer or platform playback graph behind an interface shared with export settings.
3. Make audio time the authoritative clock when audio is active.
4. Add lifecycle tests for interruption, headphones, audio focus, and route changes.
5. Measure and document drift over two minutes on all baseline devices.
6. Commit `feat: synchronize timeline audio playback`, merge, and push.

**Exit criteria:** Mixed preview remains within the 40-millisecond drift budget and releases all audio resources when leaving the workspace.

### Task 15: Select And Prove Export Architecture

**Branch:** `chore/export-spike`
**Requirements:** `REL-EXP-001` through `REL-EXP-012`, privacy and licensing sections

**Files:**

- Modify: `docs/architecture/0003-media-encoding.md`
- Create: `lib/core/media/export_engine.dart`
- Create: `test/core/media/export_engine_contract_test.dart`
- Create: `integration_test/export_smoke_test.dart`

**Steps:**

1. Evaluate current native APIs and maintained packages through official documentation and Context7.
2. Compare H.264/AAC support, GIF support, cancellation, progress, background execution, package size, maintenance, LGPL/GPL obligations, App Store policy, and minimum OS versions.
3. Build throwaway proofs that encode ten deterministic frames plus a tone on Android and iOS.
4. Validate output with platform players and an automated media probe in CI or test tooling.
5. Select the architecture in the ADR and define the Dart engine contract for preflight, progress, cancel, cleanup, and result.
6. Retain only reusable adapters and contract tests; remove spike-only UI and binaries.
7. Commit `chore: select production export architecture`, merge, and push.

**Exit criteria:** The selected path demonstrably creates compatible H.264/AAC MP4 on both platforms and passes legal/privacy review before full export UI work.

### Task 16: Deliver Movie Export And Sharing

**Branch:** `feat/movie-export`
**Requirements:** `REL-EXP-013` through `REL-EXP-040`

**Files:**

- Create: `lib/features/export/domain/export_job.dart`
- Create: `lib/features/export/data/export_repository.dart`
- Create: `lib/features/export/presentation/export_page.dart`
- Create: `lib/features/export/presentation/export_controller.dart`
- Create: `lib/features/export/presentation/export_progress.dart`
- Test: `test/features/export/export_controller_test.dart`
- Test: `integration_test/movie_export_test.dart`

**Steps:**

1. Write preflight tests for missing source, unsupported dimensions, estimated storage, and audio availability.
2. Write export job tests for progress, cancellation, interruption journal, cleanup, history, and previous-settings reuse.
3. Implement 720p/1080p MP4 rendering from immutable sources plus current adjustments and timing.
4. Implement AAC mix, compatible pixel format, metadata redaction, and foreground/background platform behavior.
5. Implement export screen states and system share/save/open flows.
6. Validate duration, fps, dimensions, frame content, audio sync, cancellation cleanup, and app restart.
7. Commit `feat: add reliable movie export and sharing`, merge, and push.

**Exit criteria:** Movie output matches preview and survives all specified interruption paths without corrupting project or leaving untracked temporary output.

### Task 17: Add GIF And Image-Sequence Export

**Branch:** `feat/additional-export-formats`
**Requirements:** Export sections 12.3 and 12.4

**Files:**

- Create: `lib/core/media/gif_exporter.dart`
- Create: `lib/core/media/image_sequence_exporter.dart`
- Modify: `lib/features/export/presentation/export_page.dart`
- Test: `test/core/media/gif_exporter_test.dart`
- Test: `test/core/media/image_sequence_exporter_test.dart`
- Test: `integration_test/additional_export_formats_test.dart`

**Steps:**

1. Write deterministic tests for GIF dimensions, frame timing, holds, loop settings, and audio exclusion.
2. Write archive tests for zero-padded order, PNG/JPEG selection, manifest fields, holds, dimensions, and transparency constraints.
3. Implement bounded-memory streaming exporters through the common export job lifecycle.
4. Add format-specific UI, estimates, validation, and explanations.
5. Validate GIF with independent decoders and image-sequence ZIP contents in tests.
6. Commit `feat: add GIF and image-sequence export`, merge, and push.

**Exit criteria:** Both formats preserve current visual edits and timing, honor cancellation, and produce independently readable output.

### Task 18: Complete Recovery And Storage Management

**Branch:** `feat/recovery-and-storage`
**Requirements:** `REL-DATA-026` through `REL-DATA-050`

**Files:**

- Create: `lib/features/recovery/presentation/recovery_page.dart`
- Create: `lib/features/recovery/presentation/recovery_controller.dart`
- Create: `lib/features/settings/presentation/storage_settings_page.dart`
- Create: `lib/core/filesystem/storage_monitor.dart`
- Test: `test/features/recovery/recovery_page_test.dart`
- Test: `test/core/filesystem/storage_monitor_test.dart`
- Test: `integration_test/interruption_recovery_test.dart`

**Steps:**

1. Create fault fixtures for each interrupted capture, import, duplicate, delete, migration, and export stage.
2. Write recovery tests that prove actions are idempotent and never delete the only valid copy.
3. Implement launch scanning, blocking recovery routing, repair, remove missing item, keep for later, and redacted diagnostics.
4. Implement storage categories, cache clearing, trash restore/empty, expiration, and low-space thresholds.
5. Add a debug-only fault injector used by integration tests and excluded from release UI.
6. Run process-kill and disk-full tests on Android and iOS physical devices.
7. Commit `feat: complete recovery and storage management`, merge, and push.

**Exit criteria:** All documented interruption states produce an explicit, tested, non-destructive outcome.

### Task 19: Complete Settings, Help, Privacy, And Diagnostics

**Branch:** `feat/settings-and-diagnostics`
**Requirements:** Settings sections 14, 16, and 19

**Files:**

- Create: `lib/features/settings/domain/app_settings.dart`
- Create: `lib/features/settings/data/settings_repository.dart`
- Complete: `lib/features/settings/presentation/settings_page.dart`
- Create: `lib/features/settings/presentation/help_page.dart`
- Create: `lib/features/settings/presentation/privacy_page.dart`
- Create: `lib/core/diagnostics/app_logger.dart`
- Create: `lib/core/diagnostics/diagnostic_exporter.dart`
- Test: `test/features/settings/settings_test.dart`
- Test: `test/core/diagnostics/diagnostic_exporter_test.dart`

**Steps:**

1. Write serialization and default/reset tests for every setting.
2. Write redaction tests using titles, paths, and fake frame/audio content that must never appear in diagnostic output.
3. Implement settings sections and ensure defaults affect only new projects where specified.
4. Implement bounded structured logging, operation IDs, retention, and release-mode redaction.
5. Add local help and troubleshooting content with links to platform settings and support.
6. Generate and expose open-source license notices.
7. Commit `feat: add settings privacy and diagnostics`, merge, and push.

**Exit criteria:** Settings are persistent and accessible, help covers primary failures, and diagnostics are useful without exposing user content.

### Task 20: Accessibility And Adaptive UI Audit

**Branch:** `fix/accessibility-audit`
**Requirements:** `REL-ACC-*`

**Files:**

- Create: `docs/test-plans/accessibility.md`
- Create: `test/helpers/accessibility_checks.dart`
- Modify: all primary presentation files as findings require
- Test: `test/accessibility/primary_flows_test.dart`
- Test: `test/goldens/text_scale_golden_test.dart`

**Steps:**

1. Inventory every screen, modal, menu, adjustable control, drag action, status announcement, and keyboard command.
2. Add automated semantics, target-size, contrast, focus-order, and 200% text-scale checks.
3. Add menu/numeric alternatives for every precise drag interaction.
4. Run VoiceOver and TalkBack journeys A-D from `docs/FINAL_STATE.md` on physical devices.
5. Run phone/tablet, portrait/landscape, light/dark, reduced-motion, high-contrast timeline, and keyboard passes.
6. Fix all blocker and major findings and document any platform limitation with an acceptable alternative.
7. Commit `fix: complete accessibility and adaptive layout audit`, merge, and push.

**Exit criteria:** Every primary workflow is complete with screen reader, 200% text scale, reduced motion, and non-drag alternatives.

### Task 21: Performance And Reliability Hardening

**Branch:** `fix/performance-and-reliability`
**Requirements:** `REL-PERF-*`, Release quality section 20

**Files:**

- Create: `integration_test/stress_project_test.dart`
- Create: `integration_test/process_death_test.dart`
- Create: `tool/generate_test_project.dart`
- Create: `docs/test-plans/performance.md`
- Create: `docs/release/device-matrix.md`
- Modify: cache, timeline, renderer, database, and export code only where profiling identifies a bottleneck

**Steps:**

1. Define and record the four baseline devices and repeatable measurement method.
2. Generate 50-project, 500-frame, and 1,000-frame fixtures without committing source media.
3. Measure launch, project open, capture acceptance, autosave, timeline scroll, playback drift, export memory, and cancellation cleanup.
4. Add automated thresholds where device/CI stability allows and trend reports elsewhere.
5. Profile before changing code; fix only measured bottlenecks.
6. Run long capture, repeated lifecycle, repeated export/cancel, low-storage, and process-death soak tests.
7. Verify no leaked camera, codec, audio, wake-lock, file, or database resources.
8. Commit `fix: meet release performance and reliability budgets`, merge, and push.

**Exit criteria:** Every budget in section 18 of `docs/FINAL_STATE.md` passes on the recorded device matrix, with raw results linked from the test plan.

### Task 22: Security, Privacy, And Dependency Review

**Branch:** `chore/release-compliance`
**Requirements:** `REL-OPS-*`, Offline/privacy/security section 16

**Files:**

- Create: `docs/release/privacy-review.md`
- Create: `docs/release/dependency-review.md`
- Create: `docs/release/data-safety.md`
- Create: `PRIVACY.md`
- Modify: Android manifest, iOS plist, build configuration, and dependency metadata as findings require

**Steps:**

1. Inventory permissions, data created, data leaving the device, logs, diagnostics, network calls, and third-party SDK behavior.
2. Remove unused permissions and verify runtime requests occur only at the documented interaction.
3. Scan tracked files and built artifacts for secrets, signing material, private paths, and debug endpoints.
4. Review every dependency's license, maintenance, transitive native binaries, privacy behavior, and store-policy compatibility.
5. Test all primary journeys in airplane mode with clean install and upgraded data.
6. Complete privacy policy and store data-safety answers from verified behavior.
7. Commit `chore: complete release privacy and dependency review`, merge, and push.

**Exit criteria:** Declared data handling matches observed release-build behavior and all dependency obligations are documented and acceptable.

### Task 23: Release Candidate Validation

**Branch:** `release/1.0.0`
**Requirements:** All

**Files:**

- Create: `docs/release/1.0.0-checklist.md`
- Create: `docs/release/1.0.0-test-report.md`
- Create: `CHANGELOG.md`
- Modify: `pubspec.yaml`
- Modify: store metadata and platform version files

**Steps:**

1. Freeze scope and map every `REL-*` requirement to an automated test, manual test, or approved product exception.
2. Run formatting, analysis, all unit/widget/golden/integration tests, Android release build, and iOS release archive.
3. Install signed candidates on every baseline device and execute acceptance journeys A-D.
4. Validate clean install, upgrade migration from every prerelease schema fixture, backup/restore behavior, and offline operation.
5. Validate MP4, GIF, and image-sequence output independently and test system sharing targets.
6. Verify screenshots, listing text, privacy URL, support contact, licenses, content rating, signing, symbols, and release notes.
7. Resolve all blockers, criticals, data-loss risks, and release-gate failures on dedicated fix branches merged into the release branch.
8. Update version to `1.0.0`, generate final reports, and commit `chore: prepare 1.0.0 release`.
9. Merge the release branch into `main`, tag `v1.0.0`, and push branch and tag.
10. Build store artifacts from the tagged commit and record checksums and CI run links.

**Exit criteria:** Every release gate in section 20 of `docs/FINAL_STATE.md` is evidenced, no data-loss defect is open, signed artifacts come from `v1.0.0`, and the product is ready for store submission.

## 6. Test Strategy

### Unit tests

Cover value objects, duration math, timeline commands, frame adjustments, storage paths, operation journals, recovery decisions, audio math, export preflight, settings, migrations, and redaction. Use fake clocks and injected failures. Avoid real plugin channels in unit tests.

### Widget and golden tests

Cover all screens in loading, content, empty, denied, damaged, low-storage, and unexpected-error states. Golden matrices include phone/tablet, portrait/landscape, light/dark, default/200% text scale, selected/unselected, and reduced motion where visual output differs.

### Integration tests

Use real temporary application storage and a real local database. Camera/audio/picker tests use fakes in CI plus physical-device suites for plugins. Critical tests force app lifecycle transitions and process death between journal states.

### Platform tests

- Android: camera lifecycle, volume shutter, foreground export, MediaStore/share, permission denial, low storage, process death, signed APK/AAB install.
- iOS: camera interruption, audio session, Photos/Files share, background transition, permission denial, low storage, signed archive install.

### Independent media validation

Do not declare export correct because the app can replay its own file. Validate container, codecs, dimensions, frame rate, duration, pixel format, audio format, and corruption with an independent probe and native system players.

## 7. Traceability Template

Maintain `docs/release/requirement-traceability.md` during implementation:

| Requirement | Implementation | Automated evidence | Manual evidence | Status |
| --- | --- | --- | --- | --- |
| `REL-CAP-016` | Capture repository transaction | `capture_repository_test.dart` | Android/iOS interruption run | Planned |
| `REL-DATA-011` | Atomic file store | `atomic_file_store_test.dart` | Disk-full drill | Planned |
| `REL-EXP-013` | Movie export engine | `movie_export_test.dart` | Player compatibility matrix | Planned |
| `REL-ACC-001` | Semantic app shell | `primary_flows_test.dart` | VoiceOver/TalkBack journeys | Planned |

No requirement can be marked complete with an implementation link alone.

## 8. Known Planning Risks

1. **Media encoding choice:** Flutter encoder packages and licenses change. Task 15 is a blocking proof and ADR, not permission to assume a package works.
2. **Camera capability variance:** Focus, exposure lock, white balance, flash, and volume-key behavior differ by device. UI must remain capability-driven.
3. **Memory pressure:** Rendering 1080p sources, GIFs, and 1,000-frame projects requires streaming and bounded caches from the beginning.
4. **Process-death testing:** Some interruption cases require platform harnesses and debug-only fault injection; simulator-only coverage is insufficient.
5. **Audio synchronization:** Preview and export may use different backends. Shared timing fixtures and independent output validation are mandatory.
6. **Public-release scope:** Audio editing and three export formats are substantial. They are release requirements and must not be left as inactive controls or partially persisted flows.
7. **Store policy changes:** Permission declarations, background work, privacy forms, and SDK rules must be rechecked against current official guidance at release-candidate time.

## 9. Completion Definition

The plan is complete only when:

- Tasks 1-23 have been merged and pushed.
- Every final-state requirement has passing evidence.
- CI is green on the tagged release commit.
- Android and iOS signed artifacts install and complete acceptance journeys A-D.
- No data-loss defect is open.
- Release reports, privacy documentation, licenses, store metadata, and support paths are ready.
- Git tag `v1.0.0` identifies the exact source used for public artifacts.
