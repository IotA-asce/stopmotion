# ADR 0003: Media Encoding

**Status:** Deferred with required proof

## Context

Version 1.0 requires H.264/AAC MP4, GIF, and image-sequence export with progress, cancellation, interruption cleanup, and broad playback compatibility.

## Decision

Define package-independent render and export interfaces during editor work. Do not select or bundle an encoder in Phase 1. Task 15 must compare maintained packages and native Android/iOS APIs for codecs, cancellation, background execution, binary size, licenses, store policy, and platform support, then prove MP4 output on physical devices.

## Consequences

- No UI may assume a specific encoder's presets or progress model.
- Export implementation is blocked until the proof and legal review pass.
- The project avoids committing an abandoned or license-incompatible native binary prematurely.
