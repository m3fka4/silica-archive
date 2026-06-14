# Security Policy

Silica processes user files locally, so security issues matter.

## Reporting

Please open a private GitHub security advisory if possible. If that is not available, open an issue with a minimal description and avoid attaching sensitive files.

## Scope

Interesting reports include:

- Archive extraction path traversal
- Unsafe temporary file handling
- Password leakage
- Metadata removal failures in Private Mode
- Unsafe backend invocation
- Sandbox or entitlement issues

## Principles

- No cloud processing by default.
- Passwords must not be stored in plain text.
- Private Mode must avoid history and unnecessary recents.
- Extracted paths must stay inside the selected destination.
