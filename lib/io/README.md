# io/

Cross-platform IO bridges using conditional imports.

## Done

- **`universal_file_saver.dart`** — `saveJsonFile`, `shareJsonFile`,
  `saveImageFile`, `shareImageFile`, `pickJsonFile`. Bridges Web (blob
  download / `navigator.share`), Desktop (native file-picker save dialog),
  and Mobile (system share sheet) behind one API. Ported from The Lounge's
  `lib/utils/export_helper*.dart` (the `_native`/`_stub`/`_web`
  conditional-import split, now under `src/`). The only app-specific
  coupling was two hardcoded share-sheet subject strings ("The Lounge
  Backup"/"The Lounge Analytics") — now `subject`/`dialogTitle` parameters
  with generic defaults.
