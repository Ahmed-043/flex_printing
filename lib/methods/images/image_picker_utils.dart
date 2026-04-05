import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Result record from [pickImageFile].
typedef PickedFile = ({String fileName, Uint8List bytes});

/// Opens the system file picker (single image at a time, no cropping).
/// Returns a [PickedFile] record with the file name and raw bytes, or null
/// if the user cancelled or an error occurred.
Future<PickedFile?> pickImageFile() async {
  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      withData: true,
    );
    if (result == null) return null;
    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes == null) return null;
    return (fileName: file.name, bytes: bytes);
  } catch (e) {
    debugPrint('pickImageFile error: $e');
    return null;
  }
}

/// Compresses [imageBytes] using JPEG encoding when the file exceeds size
/// thresholds (mirrors the logic from inventry_management/files.dart).
///
/// - > 1 200 KB  → quality 40
/// - > 500 KB    → quality 70
/// - ≤ 500 KB    → returned as-is
///
/// Heavy decode/encode runs in a separate isolate via [compute].
/// Returns null only on an unrecoverable error.
Future<Uint8List?> compressImageBytes(Uint8List imageBytes) async {
  try {
    return await compute(_compressOnIsolate, imageBytes);
  } catch (e) {
    debugPrint('compressImageBytes error: $e');
    return null;
  }
}

// Top-level function required by compute().
Uint8List? _compressOnIsolate(Uint8List bytes) {
  final length = bytes.lengthInBytes;
  if (length <= 500 * 1024) return bytes;
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return null;
  final quality = length > 1200 * 1024 ? 40 : 70;
  return Uint8List.fromList(img.encodeJpg(decoded, quality: quality));
}
