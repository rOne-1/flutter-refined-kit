import 'dart:convert';
import 'dart:typed_data';
import 'package:web/web.dart' as web;
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:file_picker/file_picker.dart';

/// Triggers a browser download of [jsonString] as a `.json` file via a
/// blob-URL anchor click. Always returns `true` (the browser handles the
/// save location, there's no cancel signal to report).
Future<bool> saveJsonFile(
  String jsonString,
  String fileName, {
  String dialogTitle = 'Save File',
}) async {
  final bytes = utf8.encode(jsonString);
  final blob = web.Blob(
      [bytes.toJS].toJS, web.BlobPropertyBag(type: 'application/json'));
  final url = web.URL.createObjectURL(blob);
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement
    ..href = url
    ..download = fileName;
  anchor.click();
  web.URL.revokeObjectURL(url);
  return true;
}

/// Uses `navigator.share` if the browser supports it; falls back to
/// [saveJsonFile] (a direct download) otherwise.
Future<void> shareJsonFile(
  String jsonString,
  String fileName, {
  String subject = 'Shared File',
}) async {
  try {
    final jsNavigator = web.window.navigator;
    if (jsNavigator.hasProperty('share'.toJS).toDart) {
      final bytes = utf8.encode(jsonString);
      final file = web.File([bytes.toJS].toJS, fileName,
          web.FilePropertyBag(type: 'application/json'));
      final shareData = {
        'title': subject,
        'text': subject,
        'files': [file],
      }.jsify();
      await (jsNavigator.callMethod<JSPromise>('share'.toJS, shareData)).toDart;
      return;
    }
  } catch (_) {
    // Fall through to the download fallback below.
  }
  await saveJsonFile(jsonString, fileName);
}

/// Triggers a browser download of [pngBytes] as a `.png` file via a
/// blob-URL anchor click.
Future<bool> saveImageFile(
  Uint8List pngBytes,
  String fileName, {
  String dialogTitle = 'Save Image',
}) async {
  final blob =
      web.Blob([pngBytes.toJS].toJS, web.BlobPropertyBag(type: 'image/png'));
  final url = web.URL.createObjectURL(blob);
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement
    ..href = url
    ..download = fileName;
  anchor.click();
  web.URL.revokeObjectURL(url);
  return true;
}

/// Uses `navigator.share` if the browser supports it; falls back to
/// [saveImageFile] (a direct download) otherwise.
Future<void> shareImageFile(
  Uint8List pngBytes,
  String fileName, {
  String subject = 'Shared Image',
}) async {
  try {
    final jsNavigator = web.window.navigator;
    if (jsNavigator.hasProperty('share'.toJS).toDart) {
      final file = web.File([pngBytes.toJS].toJS, fileName,
          web.FilePropertyBag(type: 'image/png'));
      final shareData = {
        'title': subject,
        'text': subject,
        'files': [file],
      }.jsify();
      await (jsNavigator.callMethod<JSPromise>('share'.toJS, shareData)).toDart;
      return;
    }
  } catch (_) {
    // Fall through to the download fallback below.
  }
  await saveImageFile(pngBytes, fileName);
}

/// Opens a browser file-picker dialog restricted to `.json`, returning the
/// picked file's contents as a string, or `null` if the user cancelled.
Future<String?> pickJsonFile() async {
  final result = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['json'],
  );
  if (result != null && result.files.isNotEmpty) {
    final file = result.files.first;
    if (file.bytes != null) {
      return utf8.decode(file.bytes!);
    }
  }
  return null;
}
