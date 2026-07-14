# Performance Test Plan

## CI guardrails

- `test/performance/release_budgets_test.dart` exercises deterministic 50-project metadata and 1,000-frame timeline normalization/time mapping with a conservative CI-bound threshold.
- Existing timeline virtualization, renderer cache, capture persistence, audio synchronization, export cleanup, and recovery tests protect the structural performance and reliability contracts.
- `dart run tool/generate_test_project.dart` creates a manifest for repeatable 50-project, 500-frame, and 1,000-frame device fixtures without committing media.

## Physical-device measurement

Record p95 measurements against the device matrix for warm launch, 500-frame editor open, accepted capture, timeline scroll, playback drift, export memory, repeated cancellation, and long capture. Use the budgets in section 18 of `docs/FINAL_STATE.md` as pass/fail thresholds.

## Status

CI only proves deterministic structural bounds. Real-device performance, memory, process-death, low-storage, and soak evidence remains required before release.
