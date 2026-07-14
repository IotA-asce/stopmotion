# Stop Motion 1.0 Development Phases

**Purpose:** This is the shared progress tracker for building the first public release defined in `docs/FINAL_STATE.md`.

**Detailed execution plan:** `docs/plans/2026-07-14-first-public-release.md`

## How To Update This File

- Keep a phase unchecked until every child item and its validation gate are complete.
- Check an item in the same commit that delivers and validates it.
- Do not check UI-only placeholders when persistence or platform behavior is incomplete.
- Add a clearly labeled blocker beneath the affected item if work cannot continue.
- Update `docs/FINAL_STATE.md` and the detailed implementation plan before accepting a scope change.
- Every implementation phase uses a dedicated branch, tests, merge to `main`, and push to GitHub.

## Phase 0: Repository And Release Definition

**Plan mapping:** Pre-implementation

- [x] Initialize the Git repository with `main` as the target branch.
- [x] Connect and push the repository to GitHub.
- [x] Add Flutter-oriented ignore rules and repository instructions.
- [x] Define the complete 1.0 product contract in `docs/FINAL_STATE.md`.
- [x] Define the detailed test-first implementation plan.
- [x] Define screen inventory, navigation, responsive behavior, and Markdown wireframes.
- [x] Add this checkbox-based development tracker.

**Phase gate:**

- [x] Product scope, UI behavior, implementation sequence, and release gates are documented and pushed.

## Phase 1: Flutter Foundation And Application Shell

**Plan mapping:** Tasks 1-2

- [x] Select and pin the current stable Flutter and Dart versions.
- [x] Create Android and iOS Flutter platform projects.
- [x] Confirm application IDs, minimum OS versions, supported orientations, and release flavors.
- [x] Enable strict analyzer and formatter rules.
- [x] Select maintained dependencies using current documentation and record decisions.
- [x] Add architecture decision records for state, navigation, storage, database, camera, audio, and export.
- [x] Configure GitHub Actions for format, analysis, tests, Android build, and iOS no-codesign build.
- [x] Implement application bootstrap and dependency injection.
- [x] Implement the route contract and route restoration.
- [x] Implement phone bottom navigation and tablet navigation rail.
- [x] Implement light/dark semantic themes from the final-state design tokens.
- [x] Add reusable app scaffolds, loading states, error states, dialogs, sheets, and accessibility helpers.
- [x] Add app-shell widget, route, theme, semantics, and golden tests.

**Phase gate:**

- [ ] A clean checkout formats, analyzes, tests, and builds Android/iOS debug artifacts in CI.
- [x] Every declared route renders a stable screen or explicit error state.

## Phase 2: Project Domain, Storage, And Library

**Plan mapping:** Tasks 3-5

- [ ] Define validated domain models for projects, frames, timeline entries, audio clips, exports, settings, and journals.
- [ ] Implement the transactional database schema, indexes, foreign keys, and migration baseline.
- [ ] Implement project-owned directory structure and relative media paths.
- [ ] Implement atomic file acceptance and read-back verification.
- [ ] Implement operation journals and fault-injection test adapters.
- [ ] Implement project create, rename, duplicate, details, trash, restore, and permanent delete.
- [ ] Implement thumbnail generation and disposable thumbnail caching.
- [ ] Implement first-run onboarding without premature permission prompts.
- [ ] Implement Projects grid/list layouts, search, sort, and filters.
- [ ] Implement empty, loading, no-results, damaged-project, and low-storage library states.
- [ ] Implement the Create Project and Project Details sheets.
- [ ] Add project lifecycle, migration, storage interruption, widget, semantics, and golden tests.

**Phase gate:**

- [ ] Projects and metadata survive restart and process death.
- [ ] No storage fault can create a phantom project or silently remove the only valid media copy.

## Phase 3: Camera, Durable Capture, And Import

**Plan mapping:** Tasks 6-8

- [ ] Define a package-independent camera service and capability model.
- [ ] Validate camera orientation and lifecycle behavior on Android and iOS physical devices.
- [ ] Implement camera permission, denied, restricted, unavailable, and retry states.
- [ ] Implement the nine-step durable frame capture transaction.
- [ ] Suppress duplicate shutter taps while capture is active.
- [ ] Show frame success only after file and database verification.
- [ ] Implement camera switching, flash, zoom, focus/exposure, and capability fallbacks.
- [ ] Implement grid, onion skin, onion opacity, and difference overlays.
- [ ] Implement self-timer and cancelable countdown.
- [ ] Implement interval capture, wake-lock handling, low-storage stop, and explicit start/stop.
- [ ] Implement supported volume-button shutter behavior.
- [ ] Implement single and batch image imports using project-owned copies.
- [ ] Implement frame review, retake, duplicate, delete, and undo.
- [ ] Add capture persistence, interruption, import, interval, permission, lifecycle, semantics, and golden tests.

**Phase gate:**

- [ ] Capture at least 100 consecutive frames per supported platform without loss, duplication, or false success.
- [ ] Captured and imported frames survive force-stop, picker revocation, rotation, and relaunch.

## Phase 4: Timeline And Editor Workspace

**Plan mapping:** Tasks 9-10

- [ ] Implement immutable timeline snapshots and validated duration calculations.
- [ ] Implement deterministic playhead-to-frame mapping and playback clock.
- [ ] Implement reversible timeline commands and session undo/redo.
- [ ] Implement frame insert, reorder, duplicate, delete, reverse, copy, paste, and hold duration.
- [ ] Implement single, range, multi-select, and select-all behavior.
- [ ] Implement project fps changes without data loss.
- [ ] Implement adaptive portrait, landscape, and tablet editor layouts.
- [ ] Implement preview canvas, transport, timecode, and loop controls.
- [ ] Implement virtualized frame timeline, zoom, ruler, thumbnails, insertion marker, and visible playhead.
- [ ] Implement keyboard and menu alternatives for drag-based commands.
- [ ] Implement autosave status based on committed revisions.
- [ ] Add timeline property tests, command tests, playback drift tests, widget tests, integration tests, and goldens.

**Phase gate:**

- [ ] A 1,000-frame timeline remains responsive and within memory limits.
- [ ] Every edit survives restart and every session command can be undone/redone correctly.

## Phase 5: Image Editing And Full-Screen Preview

**Plan mapping:** Tasks 11-12

- [ ] Define serializable non-destructive frame adjustments.
- [ ] Implement crop, straighten, rotate, flip, fit, and fill.
- [ ] Implement exposure, contrast, highlights, shadows, temperature, tint, saturation, and sharpening.
- [ ] Implement reset-per-control, reset-all, and before/after comparison.
- [ ] Implement apply-to-frame, selection, and subsequent-frame scopes.
- [ ] Implement bounded preview rendering and cache invalidation.
- [ ] Prove source frame bytes never change during editing.
- [ ] Implement full-screen preview with play, pause, scrub, loop, quality, and control auto-hide.
- [ ] Preserve route, playhead, orientation, and workspace state when leaving preview.
- [ ] Add deterministic render fixtures, pixel-tolerance tests, memory tests, semantics tests, and goldens.

**Phase gate:**

- [ ] Preview and rendered fixtures match the current timeline and edit instructions.
- [ ] Full-resolution editing stays within the baseline-device memory budget.

## Phase 6: Audio Recording, Editing, And Playback

**Plan mapping:** Tasks 13-14

- [ ] Define audio service, audio timeline, clip, track-limit, and mixer contracts.
- [ ] Implement microphone permission and denied states without blocking imported audio.
- [ ] Implement narration count-in, level meter, record, pause, resume, and stop.
- [ ] Implement project-owned audio import and unreadable-file recovery.
- [ ] Implement waveform generation with bounded cache and cancellation.
- [ ] Implement clip position, trim, split, duplicate, delete, rename, mute, and volume.
- [ ] Implement fade-in, fade-out, project master volume, and track limits.
- [ ] Implement accessible numeric alternatives to timeline trim and positioning gestures.
- [ ] Implement mixed preview playback with audio as authoritative clock.
- [ ] Handle seek, pause, loop, app lifecycle, audio focus, headphones, and route changes.
- [ ] Add audio domain, permission, recovery, mixing, lifecycle, and synchronization tests.

**Phase gate:**

- [ ] Mixed audio remains within 40 milliseconds of timeline timing over two minutes.
- [ ] Audio edits and media survive restart and release resources when the workspace closes.

## Phase 7: Export, Save, And Share

**Plan mapping:** Tasks 15-17

- [ ] Evaluate export engines for compatibility, maintenance, licensing, package size, progress, and cancellation.
- [ ] Prove H.264/AAC MP4 output on physical Android and iOS devices before selecting the final engine.
- [ ] Implement export preflight for missing sources, dimensions, codecs, and storage.
- [ ] Implement journaled export jobs, progress, cancellation, cleanup, and interruption recovery.
- [ ] Implement 720p and 1080p MP4 rendering from current sources and edits.
- [ ] Implement AAC mixing and audio synchronization in MP4 output.
- [ ] Implement bounded-memory GIF export with timing and loop settings.
- [ ] Implement PNG/JPEG image-sequence ZIP export with manifest.
- [ ] Implement export presets, estimates, validation, and previous-setting reuse.
- [ ] Implement system save, open, and share flows.
- [ ] Implement export history and current-revision exported status.
- [ ] Independently validate codecs, duration, fps, dimensions, timing, audio, GIF decoding, and archive contents.

**Phase gate:**

- [ ] MP4, GIF, and image-sequence exports match editor preview and pass independent validation.
- [ ] Cancelled or interrupted exports leave no corrupt output and never modify the project.

## Phase 8: Recovery, Settings, Privacy, And Diagnostics

**Plan mapping:** Tasks 18-19

- [ ] Implement launch-time consistency and operation-journal scanning.
- [ ] Implement Recovery screen actions: repair, remove missing items, keep for later, and export diagnostics.
- [ ] Implement recovery for interrupted capture, import, duplicate, delete, migration, and export.
- [ ] Implement storage categories, low-space monitoring, cache clearing, trash expiry, restore, and empty trash.
- [ ] Implement capture defaults and export defaults.
- [ ] Implement appearance, reduced motion, high-contrast timeline, haptics, and keep-awake settings.
- [ ] Implement privacy, help, troubleshooting, support, licenses, app version, and diagnostics pages.
- [ ] Implement bounded structured logs with redaction and operation IDs.
- [ ] Implement diagnostic export that excludes project content and private paths.
- [ ] Add fault-injection, process-death, disk-full, settings, storage, privacy, and redaction tests.

**Phase gate:**

- [ ] Every known interrupted-operation state has an explicit, idempotent, non-destructive recovery result.
- [ ] Diagnostics are useful while containing no frame, audio, project-title, secret, or private-path data.

## Phase 9: Accessibility, Adaptation, Performance, And Compliance

**Plan mapping:** Tasks 20-22

- [ ] Audit semantics, labels, values, hints, focus order, selected states, and announcements.
- [ ] Verify minimum touch targets and WCAG 2.2 AA contrast where applicable.
- [ ] Verify all workflows at 200% text scale without clipping or hidden commands.
- [ ] Verify screen-reader completion with TalkBack and VoiceOver.
- [ ] Verify reduced motion, high-contrast timeline, hardware keyboard, phone, tablet, portrait, and landscape behavior.
- [ ] Establish and document the lower-memory/current Android and oldest/current iPhone device matrix.
- [ ] Measure and meet launch, project-open, capture, timeline, autosave, playback, export, and memory budgets.
- [ ] Run long-capture, lifecycle, process-death, low-storage, and repeated export/cancel soak tests.
- [ ] Remove unused permissions and review every runtime request.
- [ ] Review dependencies, licenses, transitive native binaries, privacy behavior, and store-policy compatibility.
- [ ] Scan tracked files and release artifacts for secrets, signing material, debug endpoints, and private paths.
- [ ] Verify all primary journeys offline.
- [ ] Complete privacy policy and store data-safety documentation from observed behavior.

**Phase gate:**

- [ ] All accessibility journeys and performance budgets pass on the recorded physical-device matrix.
- [ ] Privacy, security, dependency, license, and platform-policy reviews have no unresolved release blockers.

## Phase 10: Release Candidate And Public Release

**Plan mapping:** Task 23

- [ ] Freeze 1.0 scope and expand requirement IDs into atomic traceability rows.
- [ ] Map every requirement to automated evidence, manual evidence, or an approved exception.
- [ ] Complete clean-install and upgrade-migration testing.
- [ ] Complete acceptance journeys A-D on every baseline device.
- [ ] Build and install signed Android APK, Android App Bundle, and iOS archive.
- [ ] Validate all release media outputs using independent players and probes.
- [ ] Complete store screenshots, listing text, content rating, privacy URL, support route, licenses, and release notes.
- [ ] Resolve all blocker, critical, data-loss, and release-gate defects.
- [ ] Set application version to `1.0.0` and complete the release report.
- [ ] Merge the release branch into `main`.
- [ ] Tag the exact public source as `v1.0.0` and push the tag.
- [ ] Build store artifacts from the tagged commit and record checksums and CI links.
- [ ] Submit signed artifacts to the intended distribution channels.

**Phase gate:**

- [ ] All release quality gates in `docs/FINAL_STATE.md` are evidenced.
- [ ] No known data-loss defect is open.
- [ ] Version 1.0 is publicly distributable and support documentation is live.

## Post-Release Verification

- [ ] Confirm store processing and installation from each public channel.
- [ ] Confirm privacy, support, and license links resolve from production listings.
- [ ] Monitor crash-free sessions, export failures, and recovery events without collecting user media.
- [ ] Triage public-release defects by data-loss risk and workflow impact.
- [ ] Create the 1.0.x maintenance milestone without expanding 1.0 scope retroactively.
