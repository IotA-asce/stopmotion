# Stop Motion 1.0 Final State

**Document status:** Product contract for the first public release

**Target release:** 1.0

**Last updated:** 2026-07-14

**Primary implementation:** Flutter mobile application

## 1. Purpose

Stop Motion 1.0 is a complete, offline-first mobile application for creating stop-motion films from captured or imported images. A user can start a project, capture frames reliably, arrange and edit those frames, add sound, preview the result, export a finished movie, and return later without losing work.

This document describes the shippable product state. It is the acceptance contract for design, engineering, testing, and release. A feature is not complete because a screen exists; it is complete only when its data survives restart, its loading and error states work, and its behavior is covered by the quality requirements in this document.

## 2. Release Positioning

### 2.1 Intended users

- First-time creators making short stop-motion clips with a phone.
- Students and teachers using stop motion for assignments and demonstrations.
- Hobbyists who need onion skin, timing control, and dependable export without a desktop editor.
- Families creating small films without an account or cloud setup.

### 2.2 Product promise

1. Every accepted frame is durably saved before the interface reports success.
2. Editing is non-destructive and automatically persisted.
3. The core workflow works without an account or internet connection.
4. Export produces a playable, shareable file with predictable timing and audio.
5. Controls remain understandable for a beginner while exposing useful capture and timing tools.

### 2.3 First-release boundaries

The 1.0 release includes a polished local workflow. It does not include:

- Accounts, cloud sync, collaborative editing, or web editing.
- A public template marketplace or social feed.
- Desktop project editing.
- Multi-camera synchronization or remote camera control.
- Advanced compositing such as chroma key, masks, keyframes, or motion tracking.
- Generative image, audio, or video features.
- Paid subscriptions or in-app purchases.

These exclusions are intentional and must not leave dead controls or placeholder screens in the release build.

## 3. Platform And Device Support

### 3.1 Supported platforms

- Android 10 and later.
- iOS 15 and later.
- Phones are the primary form factor.
- Tablets receive an adaptive two-pane editor where space permits; phone functionality must remain complete.

### 3.2 Orientation

- Home, settings, onboarding, and project management support portrait and landscape.
- Capture supports portrait and landscape while keeping the camera preview correctly oriented.
- Editor supports portrait and landscape. Landscape prioritizes preview width and keeps timeline controls reachable.
- Export respects the project canvas orientation, not the device orientation at export time.

### 3.3 Distribution artifacts

- Signed Android App Bundle for Google Play.
- Signed universal or supported-ABI APK for direct testing.
- Signed iOS archive for App Store Connect.
- Release notes, privacy policy URL, store screenshots, and support contact are present before submission.

## 4. Product Language And Visual System

### 4.1 Voice

- Labels use direct verbs: `Capture`, `Import`, `Export`, `Duplicate`, and `Delete`.
- Error messages explain what happened and provide a next action.
- Destructive confirmations name the affected project or frame count.
- Technical storage and codec terms are hidden unless they help the user resolve a problem.

### 4.2 Visual character

The app is a quiet creative workbench, not a marketing surface. Project content receives the strongest visual emphasis. Toolbars are compact, controls are predictable, and decoration never competes with the camera or frames.

### 4.3 Color tokens

Both themes use semantic tokens rather than hard-coded screen colors.

| Token | Light | Dark | Use |
| --- | --- | --- | --- |
| `surface` | `#F7F7F5` | `#151719` | Main background |
| `surfaceRaised` | `#FFFFFF` | `#202326` | Menus, sheets, repeated project tiles |
| `surfaceMuted` | `#ECEDEA` | `#2A2E31` | Toolbars and inactive tracks |
| `textPrimary` | `#17191A` | `#F4F5F2` | Main text |
| `textSecondary` | `#5F6567` | `#B8BDBE` | Supporting text |
| `accent` | `#087E6B` | `#45C9AC` | Selection and primary commands |
| `capture` | `#D33C32` | `#F26055` | Shutter and recording states only |
| `warning` | `#A65B00` | `#FFB65C` | Recoverable warnings |
| `danger` | `#B3261E` | `#FFB4AB` | Destructive actions and errors |
| `focus` | `#315EFB` | `#8EA8FF` | Keyboard and accessibility focus |

The interface must not rely on color alone. Selected states also use shape, border, icon, or text changes.

### 4.4 Typography and spacing

- Use the platform-resolved Material 3 type scale with dynamic text support.
- Screen titles use title-large; compact tool surfaces use title-small or label-large.
- Body text never renders below 14 logical pixels at the default text scale.
- Icon-only buttons are at least 48 by 48 logical pixels and have tooltips or accessibility labels.
- Base spacing unit is 4 logical pixels; common gaps are 8, 12, 16, and 24.
- Cards and modal surfaces use at most an 8-pixel corner radius.
- Letter spacing is zero unless the platform type style requires otherwise.

### 4.5 Motion and feedback

- Standard transitions complete in 150-250 milliseconds.
- Timeline reordering follows the finger and settles without moving unrelated controls.
- A captured frame briefly appears in the filmstrip only after durable storage succeeds.
- Haptics accompany shutter acceptance, reorder drop, and destructive confirmation where supported.
- Reduced-motion settings remove non-essential scaling and parallax.
- All long operations expose progress and remain cancellable when cancellation cannot corrupt output.

## 5. Information Architecture

### 5.1 Top-level destinations

The application has two top-level destinations:

1. **Projects** - default destination and project library.
2. **Settings** - app behavior, storage, accessibility, privacy, help, and version information.

On phones these appear in a bottom navigation bar. On wide tablets they appear in a navigation rail. Project workspaces replace the top-level navigation while open to maximize working area.

### 5.2 Navigation map

```text
Launch
|- First run -> Welcome -> Permissions primer -> Projects
|- Returning user -> Projects
|- Interrupted write/export -> Recovery -> Projects or affected Project

Projects
|- Create project sheet -> Capture workspace
|- Open project -> Editor workspace
|- Project menu -> Rename / Duplicate / Details / Delete
|- Settings

Capture workspace
|- Frame review
|- Import picker
|- Project settings sheet
|- Editor workspace

Editor workspace
|- Capture workspace
|- Frame inspector
|- Image adjustments
|- Audio workspace
|- Project settings sheet
|- Full-screen preview
|- Export workspace -> Share / Save / Return to editor

Settings
|- Capture defaults
|- Export defaults
|- Storage management
|- Accessibility
|- Privacy
|- Help and about
```

### 5.3 Route contract

| Route | Presentation | Back behavior |
| --- | --- | --- |
| `/onboarding` | Full screen | Exits only after setup or explicit skip |
| `/projects` | Top level | System back exits app on Android |
| `/settings` | Top level | Returns to previous top-level destination |
| `/projects/new` | Modal sheet | Dismisses without creating until confirmed |
| `/project/:projectId/capture` | Workspace | Returns to editor or projects after pending writes settle |
| `/project/:projectId/edit` | Workspace | Returns to projects after autosave settles |
| `/project/:projectId/audio` | Workspace | Returns to editor and preserves edits |
| `/project/:projectId/preview` | Full screen | Returns to the originating workspace and playhead |
| `/project/:projectId/export` | Workspace | Warns before leaving only while an uncancellable export finalizes |
| `/recovery` | Blocking full screen | Resolves or safely postpones each recovery item |

Invalid or deleted project IDs show a recoverable `Project not found` state and a route back to Projects. The app must never leave a blank screen after restoration or deep-link failure.

## 6. First Launch And Onboarding

### 6.1 Welcome

- One screen states the core workflow with a representative stop-motion frame strip.
- Primary command: `Start creating`.
- Secondary command: `How your projects are stored` opens a concise local-storage explanation.
- No sign-in, newsletter prompt, or forced tutorial carousel.

### 6.2 Permission primer

- Camera and microphone permissions are explained before the system prompts.
- Camera permission is requested when entering capture for the first time.
- Microphone permission is requested only when recording narration.
- Photo-library access is requested only when importing or saving to the library.
- A denied permission produces an inline explanation and `Open settings` command when the platform requires settings-based recovery.
- The user can finish onboarding without granting optional permissions.

### 6.3 Contextual education

- Onion skin and frame timing may show one-time anchored tips when first encountered.
- Tips never block shutter access or cover the frame being edited.
- Every tip can be dismissed permanently and is available again from Help.

## 7. Projects Library

### 7.1 Projects screen

The screen contains:

- App bar with `Projects`, search, view-mode control, and overflow menu.
- Grid/list segmented control in the toolbar or overflow on narrow screens.
- Sort menu: last edited, date created, title, duration.
- Filter menu: all, draft, exported.
- Primary floating action button with plus icon and `New project` label where width permits.
- Project collection that fills available width without nesting cards inside page cards.

Each project item shows:

- Latest valid thumbnail in the project aspect ratio.
- Project title.
- Frame count and calculated duration.
- Last-edited relative date.
- Exported indicator when the current edit revision has a successful export.
- Overflow menu for rename, duplicate, details, and delete.

### 7.2 Library states

- **Empty:** Shows `Create your first film`, a compact visual frame strip, and a `New project` command.
- **Searching with no match:** Shows the query and a `Clear search` command.
- **Loading:** Uses stable thumbnail placeholders without shifting layout.
- **Damaged project:** Shows a warning badge and opens recovery details instead of crashing.
- **Low storage:** Shows a persistent but dismissible warning with `Manage storage`.

### 7.3 Create project sheet

Required fields and defaults:

- Title, prefilled with `Untitled film` plus a collision-free number.
- Aspect ratio: 16:9, 9:16, 1:1, or 4:3.
- Frame rate: 6, 8, 10, 12, 15, 24, or custom 1-30 fps.
- Resolution intent: 720p or 1080p. Actual capture preserves source quality; this setting controls canvas and default export.
- Background color for letterboxing or transparent image-sequence export.

`Create` validates the title, creates the project atomically, and opens Capture. Dismissing the sheet creates nothing.

### 7.4 Project management

- Rename validates non-empty names and updates immediately.
- Duplicate copies metadata, source references, edit instructions, and audio into an independent project using storage-efficient file copies where safe.
- Delete moves the project to an internal recoverable trash for seven days.
- An undo action is offered immediately after delete.
- Storage management can permanently empty trash.
- Project details report dimensions, fps, frame count, duration, size, creation date, edit date, and last export.

## 8. Capture Workspace

### 8.1 Layout

The camera preview is the dominant full-bleed surface. Controls are layered in stable safe areas:

- Top bar: back, project title, frame count, flash, camera switch, and more menu.
- Preview overlays: onion skin, grid, safe-frame guides, focus indicator, and optional previous-frame difference view.
- Side or lower tool strip: onion-skin toggle and opacity, grid, exposure, focus lock, white-balance lock when supported, timer, interval capture, and import.
- Bottom filmstrip: recent frames, selected-frame marker, add/import affordance, and jump-to-editor command.
- Shutter: a fixed 72-pixel circular capture control using the capture color, separated from other commands.

Controls reflow around the preview in landscape. No control may cover the shutter or selected filmstrip frame.

### 8.2 Frame capture guarantee

The shutter follows this transaction:

1. Reject duplicate taps while a capture is active.
2. Ask the camera service for a source image.
3. Validate that the source file exists and is decodable.
4. Copy or move it into a project-owned temporary path.
5. Normalize orientation metadata without reducing source resolution.
6. Atomically rename it to its final immutable frame path.
7. Write the frame metadata and timeline position in one database transaction.
8. Read back the frame record and verify the final file exists.
9. Only then provide success haptic, increment the count, and reveal the thumbnail.

If any step fails, no timeline entry is created, temporary artifacts are cleaned up, and an actionable error appears. App suspension or process death at any step is resolved by the recovery flow on next launch.

### 8.3 Capture controls

- Rear/front camera switch where available.
- Flash modes supported by the active camera: off, auto, on, torch.
- Pinch zoom plus a labeled zoom control; digital limits come from the device.
- Tap to focus and expose; long press locks focus/exposure when supported.
- Exposure compensation slider with reset.
- Grid modes: off, thirds, square, and center crosshair.
- Onion skin: off/on, opacity 10-90%, previous frame, or previous two frames.
- Difference mode highlights changed pixels and is mutually exclusive with onion skin.
- 2-, 5-, and 10-second self-timer with visible countdown and cancel.
- Interval capture from 1-60 seconds with explicit start/stop, elapsed frame count, wake lock, and low-storage stop condition.
- Volume buttons trigger one capture when the workspace is active and platform policy allows it.
- Optional shutter sound follows platform requirements and device silent-mode rules.

Unsupported hardware controls are hidden or disabled with an explanation; they do not fail silently.

### 8.4 Import frames

- Import one or multiple images from the system picker.
- Imported assets are copied into project-owned storage, never dependent on temporary picker URLs.
- Order defaults to picker order and can be changed before confirmation.
- Images are oriented correctly and fitted to the project canvas non-destructively.
- A batch import reports progress and can stop safely between files.
- Failed files are listed while valid files remain importable.

### 8.5 Capture review and mistakes

- Tapping a filmstrip frame opens a full preview with `Retake`, `Duplicate`, and `Delete`.
- Retake captures a new immutable source and replaces the timeline reference only after the new file is durable.
- Deleting a frame offers undo and does not immediately remove a source file still referenced elsewhere.
- Returning to Projects waits for an active capture transaction to resolve and communicates that wait.

## 9. Editor Workspace

### 9.1 Layout

The editor has four stable regions:

1. App bar: back, editable project title, undo, redo, and more menu.
2. Preview canvas: fitted project canvas with playhead frame and tap-to-toggle controls.
3. Transport: jump to start, previous frame, play/pause, next frame, loop, current time, and total duration.
4. Timeline: frame track, playhead, audio tracks, selection, zoom, and add controls.

On wide screens the preview and inspector use the upper or left pane while the timeline remains full-width or occupies the right pane. Toolbars do not resize as labels or counts change.

### 9.2 Timeline behavior

- Horizontal frame strip with stable thumbnail dimensions.
- Scrubbing moves the playhead without selecting frames.
- Tap selects one frame; shift-equivalent keyboard action or long-press enters multi-select.
- Range select and select all are available in multi-select mode.
- Drag reorders selected frames and shows the exact insertion point.
- Pinch or slider zoom changes timeline scale without changing project fps.
- Frame numbers and time ruler appear at useful zoom levels.
- Audio waveforms align to the same time ruler.
- The playhead remains visible during keyboard and transport navigation.

### 9.3 Frame commands

- Duplicate one or multiple frames.
- Delete with frame count in confirmation and immediate undo.
- Reverse selected range.
- Copy and paste selected frames within the project.
- Set hold duration from 1-99 frame units without duplicating source files.
- Reset hold duration to one frame unit.
- Rotate left/right, flip horizontal/vertical, and reset transform.
- Fit, fill, or manually crop to project canvas.
- Apply adjustment to one frame, selection, or all subsequent frames after confirmation.

### 9.4 Non-destructive image adjustments

Per-frame edit instructions preserve the immutable source image. The inspector supports:

- Crop and straightening.
- Rotation and flip.
- Exposure.
- Contrast.
- Highlights and shadows.
- Temperature and tint.
- Saturation.
- Sharpening with a safe range.
- Reset individual control or all adjustments.
- Before/after press-and-hold comparison.

Rendered previews may be cached, but export always derives from the source plus current edit instructions. Undo and redo cover all edits made during the current session and persist enough history to recover from app suspension; a reopened project starts a new undo session.

### 9.5 Project timing

- Project fps remains editable from 1-30.
- Changing fps updates playback and duration immediately without deleting frames.
- Frame holds multiply a frame's duration at the project fps.
- Time displays use `mm:ss:ff` in the editor and human-readable duration in the library.
- The preview scheduler must not drift over a two-minute project.

## 10. Audio Workspace

### 10.1 Supported audio

- One recorded narration track.
- Up to three imported music or effects tracks.
- Common picker-supported audio formats are decoded through platform capabilities.
- Export mixes audio into the movie's final duration.

### 10.2 Audio commands

- Record narration with count-in, input-level meter, pause/resume, and stop.
- Import audio through the system picker and copy it into project storage.
- Display waveform after background analysis.
- Drag a clip on the timeline.
- Trim start and end with handles and time readout.
- Split at playhead.
- Delete, duplicate, mute, and rename clip.
- Set clip volume from 0-200%.
- Add configurable fade-in and fade-out.
- Set project master volume and mute while editing.
- Preview mixed audio in sync with frames.

If microphone permission is denied, imported audio remains available. If an audio file becomes unreadable, the project opens with that clip muted and marked for repair.

## 11. Playback And Preview

- Full-screen preview uses the project aspect ratio and background color.
- Play, pause, scrub, jump to start/end, and loop are available.
- Preview honors fps, frame holds, image edits, orientation, and mixed audio.
- Dropped preview frames may reduce preview rendering quality but never alter timing or export output.
- A quality menu offers automatic, full, and performance preview modes.
- External display and screen casting use the system-provided route where available; no custom casting protocol is required.
- Exiting preview returns to the same playhead and workspace.

## 12. Export And Sharing

### 12.1 Export workspace

The export screen shows:

- Project preview thumbnail and duration.
- Format segmented control: Movie, GIF, or Image sequence.
- Presets appropriate to the selected format.
- Estimated output dimensions, frame rate, and file size range.
- Destination controls when supported by the platform.
- Primary `Export` command.

### 12.2 Movie export

- MP4 container.
- H.264 video with broadly compatible pixel format.
- AAC audio when the project contains audible tracks.
- 720p and 1080p presets; source and device limits may constrain output with a clear message.
- Project fps by default, with optional compatible export fps that preserves duration.
- Fit/fill behavior matches editor preview exactly.
- Metadata contains app name and project title but no private source paths.

### 12.3 GIF export

- Project-canvas dimensions with practical presets capped for memory safety.
- Loop forever, loop count, or play once.
- Dithering and color reduction chosen for a useful quality/size balance.
- Audio is excluded and the UI states that clearly.

### 12.4 Image-sequence export

- ZIP archive containing ordered PNG or JPEG files.
- Zero-padded filenames that preserve timeline order.
- Optional transparent background only when all rendering operations support it.
- A manifest records fps, frame holds, dimensions, and project title.

### 12.5 Export reliability

- Preflight checks storage space, source readability, and supported dimensions.
- Export runs as a foreground-capable operation according to platform rules.
- Progress reports stage, percentage where measurable, elapsed time, and cancel.
- Cancellation deletes incomplete output and leaves the project unchanged.
- Process interruption leaves a recovery record and removes or resumes temporary output safely on next launch.
- Completed output is opened, shared, saved to the media library, or located in Files using system interfaces.
- Export history stores settings, timestamp, revision, location when available, and success/failure.
- Re-export offers the previous successful settings.

## 13. Persistence, Data Integrity, And Recovery

### 13.1 Ownership model

- Each project has an immutable identifier and a dedicated application-owned directory.
- Source frames and imported audio are copied into project storage.
- Database records store relative paths, never temporary absolute picker paths.
- Derived thumbnails, waveforms, and render caches are disposable and reproducible.
- Project metadata and timeline ordering live in a transactional local database.

### 13.2 Autosave

- Every user command updates in-memory state and is queued for persistence immediately.
- Critical media acceptance is synchronous with durable storage as defined by the capture transaction.
- Metadata edits become durable within 500 milliseconds during normal operation.
- Navigation away waits for pending critical writes; non-critical cache work may continue.
- A subtle saving indicator appears only when persistence exceeds 300 milliseconds.
- A saved checkmark is never shown unless the last project revision is committed.

### 13.3 Recovery

On launch, the recovery service scans operation journals and project consistency:

- Complete an atomic rename when the verified final media exists.
- Remove abandoned temporary files that have no valid database reference.
- Restore the last valid database snapshot if migration or write verification failed.
- Flag missing source media and identify affected frames or audio clips.
- Offer `Repair`, `Remove missing items`, `Export diagnostics`, and `Keep for later` as applicable.
- Never delete the only known valid copy during automatic recovery.

### 13.4 Migrations and compatibility

- Every schema and project-format change has a forward migration test.
- Migrations create a backup before destructive transformation.
- Opening a newer unsupported project format is read-only and explains the version mismatch.
- Release builds never silently reset the database after migration failure.

### 13.5 Storage management

- Settings reports project media, exported files known to the app, cache, and trash sizes.
- `Clear cache` cannot remove source media or exports.
- Trash shows expiration and supports restore or permanent delete.
- Low-space thresholds warn before capture and block capture only when a durable frame cannot be guaranteed.
- The app handles OS-level file removal or permission revocation without crashing.

## 14. Settings

### 14.1 Capture defaults

- Preferred aspect ratio, fps, resolution intent, grid, onion-skin opacity, timer, and volume-shutter behavior.
- Defaults affect new projects only unless explicitly applied to an open project.

### 14.2 Export defaults

- Default format, resolution, quality preset, GIF looping, and image-sequence format.
- `Reset export defaults` restores shipped values.

### 14.3 Appearance and accessibility

- System, light, or dark theme.
- Reduced motion override: follow system, on, or off.
- High-contrast timeline option.
- Haptics toggle.
- Keep screen awake during capture toggle.

### 14.4 Privacy and diagnostics

- Clear statement that projects remain on device unless the user exports or shares them.
- Optional, off-by-default diagnostic sharing for 1.0 unless store policy or product decision explicitly changes it before implementation.
- Diagnostic export redacts media, project titles, source paths, and other user content by default.
- Links to privacy policy and open-source licenses.

### 14.5 Help and about

- Short workflow help for capture, onion skin, editing, audio, and export.
- Troubleshooting for permissions, low storage, missing media, and failed export.
- App version and build number.
- Support contact and `Export diagnostics` command.

## 15. Accessibility And Input

- Meets WCAG 2.2 AA contrast for text and essential controls where applicable to native mobile UI.
- Supports screen readers with ordered focus, meaningful labels, values, hints, and selected states.
- Supports text scaling to 200% without clipped controls or hidden commands.
- All primary editor commands are reachable without color or precise drag gestures; menus provide alternatives for reorder, trim, and numeric adjustments.
- Touch targets are at least 48 by 48 logical pixels.
- Capture count, timer, interval state, save failure, and export completion are announced accessibly.
- Hardware keyboard support on tablets includes Space play/pause, arrows frame navigation, Delete, standard undo/redo, and Escape/back.
- Shutter and critical errors provide visual feedback in addition to sound or haptics.

## 16. Offline, Privacy, And Security

- Creating, editing, previewing, and exporting require no internet connection.
- No account is required.
- Media stays in application-owned storage until the user invokes a platform share or save action.
- Temporary files use non-public application directories and are removed after use.
- Exported diagnostics exclude frame images and audio unless the user explicitly opts in through a separate confirmation.
- Release builds contain no API secrets, test credentials, private signing material, or verbose media paths in logs.
- Third-party dependencies receive license and privacy review before release.

## 17. Error And Interruption Behavior

Every async screen supports loading, success, empty, denied, low-storage, and unexpected-error states where relevant.

| Situation | Required behavior |
| --- | --- |
| Camera unavailable | Explain cause, allow import, retry after lifecycle change |
| Camera permission denied | Keep project usable, offer system settings or import |
| Capture write fails | Do not increment frame count; preserve camera session; offer retry |
| App backgrounds during capture | Finish or roll back transaction; recover on next launch |
| Source frame missing | Mark exact timeline item; continue with unaffected frames |
| Storage becomes full | Stop interval capture/export safely; remove incomplete temporary file |
| Audio decode fails | Mute and mark clip; preserve project and other tracks |
| Export fails | Show stage and actionable reason; retain settings for retry |
| Database migration fails | Open recovery; do not reset user data |
| Share target cancels | Return to completed export without reporting failure |
| Device rotates | Preserve camera, selection, playhead, and operation state |
| Process is killed | Reopen last safe route and reconcile journals |

## 18. Performance Budgets

Measured on the agreed baseline devices before release:

- Warm launch to interactive Projects screen: under 1.5 seconds at p95 for 50 projects.
- Open a 500-frame project to usable editor: under 2.0 seconds at p95, with thumbnails loaded progressively.
- Accepted capture to visible durable thumbnail: under 1.0 second at p95 after camera delivery, excluding unusually slow storage with an active progress state.
- Timeline scroll: sustained 55+ frames per second on baseline 60 Hz devices for a 1,000-frame project.
- Playback audio drift: less than 40 milliseconds over two minutes.
- Metadata autosave: under 500 milliseconds at p95.
- Memory remains within platform limits while opening and exporting a 1,000-frame 1080p project; full-resolution frames are never all decoded simultaneously.
- Cancelled export releases codecs, file handles, wake locks, and temporary storage.

The baseline device matrix is recorded in release documentation and includes one lower-memory Android device, one current Android device, one oldest-supported iPhone, and one current iPhone.

## 19. Observability And Diagnostics

- Structured logs use operation IDs and non-sensitive project IDs.
- Logs record lifecycle, capture transaction stages, database migrations, recovery actions, and export stages.
- Release logs omit project titles, frame content, audio content, and absolute user paths.
- A rolling local log has a bounded size and retention period.
- Diagnostic export includes app/build version, platform version, device capability summary, redacted logs, database schema version, and dependency licenses.
- Crashes and unhandled errors can be integrated with a privacy-reviewed service only after the product decision and consent behavior are documented.

## 20. Release Quality Gates

Version 1.0 is shippable only when all of the following are true:

- No open blocker or critical defect.
- No known data-loss defect at any severity.
- Capture durability tests pass across lifecycle interruption and low-storage scenarios.
- Automated unit, widget, integration, migration, and golden tests pass.
- Android and iOS release builds compile and install on physical devices.
- A 1,000-frame stress project can be captured/imported, edited, reopened, previewed, and exported.
- Exported MP4, GIF, and image sequence pass playback or validation checks on target platforms.
- Screen-reader and 200% text-scale passes are complete for every primary workflow.
- Permission-denied and offline test passes are complete.
- Privacy, dependency license, and store-policy reviews are complete.
- Store metadata, support route, privacy policy, signing, and release notes are ready.
- Backup and recovery drills prove that interrupted capture, interrupted import, interrupted export, and failed migration do not silently lose valid source media.

## 21. End-To-End Acceptance Journeys

### Journey A: First film

1. Install and complete onboarding without creating an account.
2. Create a 16:9, 12 fps project.
3. Grant camera access and capture 24 frames with onion skin.
4. Leave the app, force-stop it, and reopen.
5. Confirm all 24 frames and their order remain.
6. Preview the two-second loop.
7. Export a 1080p MP4 and share it through the system sheet.

### Journey B: Edited film with sound

1. Import 60 images in a known order.
2. Reorder, delete, duplicate, and hold selected frames.
3. Crop and adjust a frame range non-destructively.
4. Record narration and import music.
5. Trim, position, fade, and mix audio.
6. Reopen the project and confirm visual and audio edits.
7. Export MP4 and verify duration, synchronization, dimensions, and audio.

### Journey C: Recovery

1. Interrupt the app during frame persistence using the test fault injector.
2. Relaunch into recovery.
3. Confirm the transaction is completed or rolled back without a phantom frame.
4. Fill storage during interval capture and confirm capture stops cleanly.
5. Interrupt export and confirm incomplete output is removed or explicitly recoverable.
6. Confirm the project remains editable and exports after storage is restored.

### Journey D: Accessible creation

1. Enable a screen reader, reduced motion, and 200% text scaling.
2. Create and rename a project.
3. Capture or import frames and navigate the timeline.
4. Set a frame hold using a non-drag control.
5. Preview and export.
6. Confirm no critical command is clipped, unlabeled, or gesture-only.

## 22. Requirement Traceability

Implementation tasks and tests must reference stable requirement IDs derived from this document:

- `REL-NAV-*` navigation and restoration.
- `REL-CAP-*` capture and import.
- `REL-EDIT-*` timeline and image editing.
- `REL-AUD-*` audio.
- `REL-EXP-*` export and sharing.
- `REL-DATA-*` persistence, migration, and recovery.
- `REL-ACC-*` accessibility.
- `REL-PERF-*` performance.
- `REL-OPS-*` diagnostics, privacy, and release operations.

The implementation plan maps work to these groups. Any scope change must update this file, the implementation plan, and affected acceptance tests in the same pull request.

## 23. Requirement ID Catalog

The following ranges are reserved for implementation and test traceability. Each automated or manual test must cite the narrowest applicable ID. The detailed behavior remains defined by the referenced section; the ID does not replace that text.

| Range | Contract area |
| --- | --- |
| `REL-NAV-001` to `REL-NAV-010` | Launch, onboarding, top-level navigation, route restoration, invalid routes, and back behavior in sections 5-7 |
| `REL-CAP-001` to `REL-CAP-015` | Camera lifecycle, orientation, permissions, capability discovery, and workspace layout in sections 6 and 8.1 |
| `REL-CAP-016` to `REL-CAP-030` | Durable single-frame capture transaction and capture review in sections 8.2 and 8.5 |
| `REL-CAP-031` to `REL-CAP-055` | Camera tools, timer, interval capture, onion skin, difference mode, and imports in sections 8.3 and 8.4 |
| `REL-EDIT-001` to `REL-EDIT-025` | Timeline model, project timing, commands, selection, playback clock, and editor persistence in sections 9.1-9.3 and 9.5 |
| `REL-EDIT-026` to `REL-EDIT-045` | Non-destructive transforms, image adjustments, rendering, reset, and comparison in section 9.4 |
| `REL-EDIT-046` to `REL-EDIT-060` | Full-screen preview, adaptive editor layout, keyboard behavior, and preview quality in sections 9 and 11 |
| `REL-AUD-001` to `REL-AUD-035` | Recording, importing, waveform generation, clip limits, editing, and audio recovery in section 10 |
| `REL-AUD-036` to `REL-AUD-045` | Mixed playback, audio focus, lifecycle, seeking, looping, and synchronization in sections 10 and 11 |
| `REL-EXP-001` to `REL-EXP-012` | Export architecture, compatibility, preflight, licensing, and job lifecycle in section 12 |
| `REL-EXP-013` to `REL-EXP-040` | MP4 rendering, AAC mix, progress, cancellation, history, sharing, and interruption handling in sections 12.2 and 12.5 |
| `REL-EXP-041` to `REL-EXP-055` | GIF and image-sequence settings, rendering, manifests, validation, and cleanup in sections 12.3 and 12.4 |
| `REL-DATA-001` to `REL-DATA-010` | Project identity, models, schema, timeline integrity, and migration baseline in sections 7, 9, and 13 |
| `REL-DATA-011` to `REL-DATA-025` | Project-owned files, atomic writes, journals, autosave, duplication, trash, and source ownership in sections 7 and 13.1-13.2 |
| `REL-DATA-026` to `REL-DATA-050` | Launch recovery, missing media, migrations, storage management, cache, trash expiration, and low-space behavior in sections 13.3-13.5 and 17 |
| `REL-ACC-001` to `REL-ACC-020` | Semantics, contrast, target sizes, text scaling, reduced motion, keyboard input, announcements, and non-gesture alternatives in sections 4 and 15 |
| `REL-PERF-001` to `REL-PERF-010` | Launch, project-open, capture, timeline, playback, autosave, memory, export, and resource-release budgets in section 18 |
| `REL-OPS-001` to `REL-OPS-025` | Platform artifacts, offline/privacy/security, diagnostics, dependency review, quality gates, store readiness, and release evidence in sections 3, 16, and 19-21 |

When implementation starts, `docs/release/requirement-traceability.md` must expand these ranges into atomic rows as tests are designed. An ID may be marked complete only when its implementation and evidence links both exist.
