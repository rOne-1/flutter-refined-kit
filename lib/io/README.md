# io/

Cross-platform IO bridges using conditional imports.

Planned modules (seed source: The Lounge):
- **Universal File Saver** — `saveJsonFile(String content, String fileName)`
  bridging Web (blob download), Desktop (file picker), and Mobile (share
  sheet) behind one call, from `lib/utils/export_helper*.dart` (the
  `_native`/`_stub`/`_web` conditional-import split). Portable as-is; pure
  platform-conditional file export, no app-specific format assumptions.
