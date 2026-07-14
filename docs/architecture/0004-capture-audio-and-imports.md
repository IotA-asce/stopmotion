# ADR 0004: Capture, Audio, And Imports

**Status:** Accepted and implemented for Phases 3 and 6

## Decision

Use Flutter's first-party `camera` plugin behind a package-independent `CameraService`. The adapter owns lifecycle disposal and reinitialization and exposes capabilities rather than assuming every device supports flash, focus, exposure, or zoom controls.

Use first-party `image_picker` for single and multiple image selection. Retrieve lost picker data when the restored Capture workspace initializes, and copy every accepted `XFile` into project-owned storage before recording it in the timeline.

Use `image` to decode, validate, bake EXIF orientation, and preserve source pixel dimensions before immutable JPEG acceptance. Use `wakelock_plus` only while interval capture is active. Use `permission_handler` only to open app settings from a denied-camera state; camera initialization remains the point at which camera permission can be requested.

The camera adapter exposes zoom/exposure bounds and hides controls that the capability model marks unsupported. White-balance lock is hidden because the selected package does not expose a portable control. Runtime hardware-control failures become actionable UI errors rather than silent failures.

Use `record` behind `AudioRecordingService` for mono AAC/M4A narration with permission-on-action, amplitude metering, pause/resume, and explicit disposal. Use Flutter's first-party `file_selector` for native audio selection and immediately copy accepted media into project storage. Use `audio_waveforms` behind a cancellable, sample-bounded cache. Use `just_audio` for duration probing and per-clip local playback, coordinated by a package-independent mixer contract. Use `audio_session` for play/record focus, interruptions, and noisy-route events.

The database stores non-destructive clip position, trim, volume, fades, mute, missing-media state, and project master volume. A missing source never blocks project opening: it is marked, muted, and retained for recovery.

## Consequences

- Camera and picker package types do not enter domain models.
- Durable capture and import share one media-acceptance transaction.
- Audio package types do not enter domain models, repositories, or editor timing.
- One narration plus three imported tracks bound simultaneous native players and UI complexity.
- Physical-device tests remain mandatory for orientation, lifecycle, capability, and permission behavior.
- The implementation gate passes with fakes and file-backed SQLite; physical Android/iOS evidence remains open in `docs/DEVELOPMENT_PHASES.md`.

## Sources

- Context7 `/websites/pub_dev_packages_camera`, queried 2026-07-14.
- Context7 `/flutter/packages` image_picker documentation, queried 2026-07-14.
- Context7 `/brendan-duncan/image`, `/fluttercommunity/wakelock_plus`, and `/baseflow/flutter-permission-handler`, queried 2026-07-14.
- Context7 `/llfbandit/record`, `/flutter/packages` file_selector, `/websites/pub_dev_audio_waveforms`, `/ryanheise/just_audio`, and `/ryanheise/audio_session`, queried 2026-07-15.
