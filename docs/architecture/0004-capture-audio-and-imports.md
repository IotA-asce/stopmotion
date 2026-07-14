# ADR 0004: Capture, Audio, And Imports

**Status:** Accepted for staged implementation

## Decision

Use Flutter's first-party `camera` plugin behind a package-independent `CameraService`. The adapter owns lifecycle disposal and reinitialization and exposes capabilities rather than assuming every device supports flash, focus, exposure, or zoom controls.

Use first-party `image_picker` for single and multiple image selection. Retrieve lost picker data on Android startup and copy every accepted `XFile` into project-owned storage before recording it in the timeline.

Audio recording and playback packages remain deferred until Phase 6, when current recording formats, audio-session behavior, mixing support, licensing, and synchronization can be proven together.

## Consequences

- Camera and picker package types do not enter domain models.
- Durable capture and import share one media-acceptance transaction.
- Physical-device tests remain mandatory for orientation, lifecycle, capability, and permission behavior.

## Sources

- Context7 `/websites/pub_dev_packages_camera`, queried 2026-07-14.
- Context7 `/flutter/packages` image_picker documentation, queried 2026-07-14.
