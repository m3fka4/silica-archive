# Silica TODO

This backlog is intentionally public. If you want to contribute, pick a scoped item, open an issue, and describe the approach before a large pull request.

## Product Polish

- Finish full Russian localization across every visible string.
- Add richer empty states for Archive, Images, Lens and History.
- Add keyboard accessibility checks.
- Add visual QA screenshots for light/dark mode.
- Add better first-launch education for Silica Lens and Private Mode.

## Archive Backends

- Add bundled or user-configured RAR extraction backend.
- Add bundled or user-configured 7Z create/extract/test/list backend.
- Add ZSTD creation and extraction.
- Add split archive support.
- Add progress parsing for long-running backends.
- Add password prompt UI and wrong-password recovery.
- Add archive repack workflow.

## Finder And System Integration

- Promote Swift Package MVP to a full Xcode workspace.
- Add signed app target, Finder Sync Extension target and Quick Actions target.
- Implement context menu actions:
  - Compress with Silica
  - Compress to ZIP
  - Compress to 7Z
  - Create Password Archive
  - Extract Here
  - Preview Archive
  - Optimize Images
  - Smart Compress
- Add user-configurable watched folders for "latest file".

## Quick Panel

- Add custom keyboard shortcut recorder UI.
- Add conflict detection when a shortcut is already used.
- Add command history.
- Add more command parser patterns.
- Polish experimental top-center/notch positioning.

## Image Optimization

- Add before/after comparison.
- Add exact EXIF/GPS byte reporting where possible.
- Add destination folder picker.
- Add image optimizer fixture tests.
- Add GIF handling policy.
- Add WebP fallback messaging per macOS capability.

## Silica Lens

- Add deeper PDF/document analysis.
- Add archive recompression sampling.
- Add confidence scores.
- Add per-file recommendations.
- Add post-operation Lens report comparing estimated and real savings.

## Release

- Wire entitlements into a full Xcode app target.
- Add hardened runtime.
- Add Developer ID signing docs.
- Add notarization workflow.
- Add privacy policy review.
- Add App Store packaging research.

## Testing

- Add UI tests for drag/drop replacement flows.
- Add archive backend integration fixtures.
- Add image optimizer tests.
- Add preferences persistence tests.
- Add GitHub Actions CI for Swift build and tests.
