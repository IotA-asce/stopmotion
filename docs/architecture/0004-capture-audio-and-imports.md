# ADR 0004: Capture, Audio, And Imports

**Status:** Accepted and implemented for Phase 3

## Decision

Use Flutter's first-party `camera` plugin behind a package-independent `CameraService`. The adapter owns lifecycle disposal and reinitialization and exposes capabilities rather than assuming every device supports flash, focus, exposure, or zoom controls.

Use first-party `image_picker` for single and multiple image selection. Retrieve lost picker data when the restored Capture workspace initializes, and copy every accepted `XFile` into project-owned storage before recording it in the timeline.

Use `image` to decode, validate, bake EXIF orientation, and preserve source pixel dimensions before immutable JPEG acceptance. Use `wakelock_plus` only while interval capture is active. Use `permission_handler` only to open app settings from a denied-camera state; camera initialization remains the point at which camera permission can be requested.

The camera adapter exposes zoom/exposure bounds and hides controls that the capability model marks unsupported. White-balance lock is hidden because the selected package does not expose a portable control. Runtime hardware-control failures become actionable UI errors rather than silent failures.

Audio recording and playback packages remain deferred until Phase 6, when current recording formats, audio-session behavior, mixing support, licensing, and synchronization can be proven together.

## Consequences

- Camera and picker package types do not enter domain models.
- Durable capture and import share one media-acceptance transaction.
- Physical-device tests remain mandatory for orientation, lifecycle, capability, and permission behavior.
- The implementation gate passes with fakes and file-backed SQLite; physical Android/iOS evidence remains open in `docs/DEVELOPMENT_PHASES.md`.

## Sources

- Context7 `/websites/pub_dev_packages_camera`, queried 2026-07-14.
- Context7 `/flutter/packages` image_picker documentation, queried 2026-07-14.
- Context7 `/brendan-duncan/image`, `/fluttercommunity/wakelock_plus`, and `/baseflow/flutter-permission-handler`, queried 2026-07-14.
