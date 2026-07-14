# Accessibility Test Plan

## Automated coverage

- `test/accessibility/primary_flows_test.dart` verifies named top-level navigation, Flutter's Android/iOS tap-target, label, and text-contrast guidelines, Recovery continuation, and no layout exceptions.
- `test/goldens/text_scale_golden_test.dart` and the onboarding, project lifecycle, Capture, Editor, Audio, Preview, Export, Recovery, and Settings tests run primary surfaces at 200% text scale.
- Editor timeline tests verify selection state, a playhead value, keyboard shortcuts, and menu/numeric alternatives to drag operations.

## Physical-device script

Run on the device matrix in `docs/release/device-matrix.md` before release:

1. Enable TalkBack or VoiceOver and complete Journeys A-D in `docs/FINAL_STATE.md`.
2. Confirm logical reading and focus order for Projects, Settings, Capture, Editor, Audio, Export, and Recovery.
3. Confirm every icon-only control announces its purpose, selected state, and unavailable state where applicable.
4. With system text at 200%, complete project creation, capture, timeline edit, export, and recovery without clipped text or hidden commands.
5. Enable reduced motion and high-contrast timeline, then repeat selection, playhead, playback, and export completion checks.
6. Connect a hardware keyboard and verify undo, redo, select all, delete, space, and arrow-key editor commands.

## Status

Automated structural coverage is complete. TalkBack/VoiceOver and physical-device text-scale evidence remains an explicit Phase 9 release gate.
