# Data Safety And Release Scan

## Automated checks

- `tool/release_safety_check.sh` rejects tracked signing material, environment files, private keys, common inline credential patterns, and development endpoints or absolute user paths in release runtime sources.
- Recovery tests verify that abandoned temporary data and partial exports are cleaned without deleting a valid source copy.
- Database tests retain a pre-open snapshot; diagnostics tests verify title/path/media redaction.

## Manual release checks

1. Run `bash tool/release_safety_check.sh` from a clean checkout.
2. Inspect generated APK/AAB/IPA files for signing material, debug endpoints, local developer paths, and private test assets.
3. Run clean-install and upgrade recovery drills on the device matrix.
4. Verify project data survives force-stop, picker interruption, low storage, and cancelled export.

No crash reporting, account system, or automatic network transfer is implemented in this release scope.
