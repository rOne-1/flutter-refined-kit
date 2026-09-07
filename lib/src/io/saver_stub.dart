import 'dart:typed_data';

/// Fallback implementation for platforms with neither `dart:io` nor
/// `dart:html` (should not normally be reached on Flutter's supported
/// targets -- present so the conditional export always has somewhere to
/// land).
Future<bool> saveJsonFile(
  String jsonString,
  String fileName, {
  String dialogTitle = 'Save File',
}) async {
  throw UnimplementedError('saveJsonFile is not implemented on this platform');
}

Future<void> shareJsonFile(
  String jsonString,
  String fileName, {
  String subject = 'Shared File',
}) async {
  throw UnimplementedError('shareJsonFile is not implemented on this platform');
}

Future<void> shareImageFile(
  Uint8List pngBytes,
  String fileName, {
  String subject = 'Shared Image',
}) async {
  throw UnimplementedError(
      'shareImageFile is not implemented on this platform');
}

Future<bool> saveImageFile(
  Uint8List pngBytes,
  String fileName, {
  String dialogTitle = 'Save Image',
}) async {
  throw UnimplementedError('saveImageFile is not implemented on this platform');
}

Future<String?> pickJsonFile() async {
  throw UnimplementedError('pickJsonFile is not implemented on this platform');
}
