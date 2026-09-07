/// Cross-platform (Web/Desktop/Mobile) file save/share/pick bridge.
///
/// Ported from The Lounge (`lib/utils/export_helper*.dart`) -- the only
/// app-specific coupling was two hardcoded share-sheet subject strings
/// ("The Lounge Backup"/"The Lounge Analytics"), now `subject` parameters
/// with generic defaults. Everything else was already domain-agnostic:
/// pure platform-conditional IO behind one API (Web: blob download/
/// `navigator.share`, Desktop: native file-picker save dialog, Mobile:
/// system share sheet).
library;

export 'saver_stub.dart'
    if (dart.library.html) 'saver_web.dart'
    if (dart.library.io) 'saver_native.dart';
