import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';

/// Opens a native "save file" dialog and writes [jsonString] to the chosen
/// location. Returns `true` if the user picked a location and the write
/// happened, `false` if they cancelled.
Future<bool> saveJsonFile(
  String jsonString,
  String fileName, {
  String dialogTitle = 'Save File',
}) async {
  final bytes = utf8.encode(jsonString);
  final path = await FilePicker.saveFile(
    dialogTitle: dialogTitle,
    fileName: fileName,
    bytes: bytes,
  );
  return path != null && path.isNotEmpty;
}

/// Opens the system share sheet with [jsonString] as a `.json` file.
Future<void> shareJsonFile(
  String jsonString,
  String fileName, {
  String subject = 'Shared File',
}) async {
  final xFile = XFile.fromData(
    utf8.encode(jsonString),
    mimeType: 'application/json',
    name: fileName,
  );
  await SharePlus.instance.share(
    ShareParams(
      files: [xFile],
      fileNameOverrides: [fileName],
      subject: subject,
    ),
  );
}

/// Opens the system share sheet with [pngBytes] as a `.png` image.
Future<void> shareImageFile(
  Uint8List pngBytes,
  String fileName, {
  String subject = 'Shared Image',
}) async {
  final xFile = XFile.fromData(
    pngBytes,
    mimeType: 'image/png',
    name: fileName,
  );
  await SharePlus.instance.share(
    ShareParams(
      files: [xFile],
      fileNameOverrides: [fileName],
      subject: subject,
    ),
  );
}

/// Opens a native "save file" dialog and writes [pngBytes] to the chosen
/// location.
Future<bool> saveImageFile(
  Uint8List pngBytes,
  String fileName, {
  String dialogTitle = 'Save Image',
}) async {
  final path = await FilePicker.saveFile(
    dialogTitle: dialogTitle,
    fileName: fileName,
    bytes: pngBytes,
  );
  return path != null && path.isNotEmpty;
}

/// Opens a native "pick file" dialog restricted to `.json`, returning the
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
    } else if (file.path != null) {
      final ioFile = File(file.path!);
      return await ioFile.readAsString();
    }
  }
  return null;
}
