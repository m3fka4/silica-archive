# Contributing to Silica

Thanks for helping improve Silica.

## Development Setup

```bash
swift test
Scripts/package_app.sh
open build/Silica.app
```

Use Xcode by opening `Package.swift` and selecting the `Silica` scheme.

## Pull Request Guidelines

- Keep changes focused.
- Prefer native macOS APIs and SwiftUI/AppKit integration over non-native UI stacks.
- Keep files local-first and privacy-preserving.
- Add or update tests for archive, analyzer or image behavior.
- Avoid adding binary archive backends without a clear license note.
- Update `README.md` or `TODO.md` when behavior changes.

## Good First Issues

- Improve Russian localization coverage.
- Add image optimizer tests.
- Add archive fixtures.
- Improve Silica Lens explanations.
- Polish accessibility labels.

## Code Style

- Swift concurrency for long-running work.
- MVVM-friendly boundaries.
- Small UI components.
- No unrelated refactors in feature PRs.
