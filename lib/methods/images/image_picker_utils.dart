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
/// Images larger than 1080p bounds are downscaled to fit within 1920x1080
/// while preserving aspect ratio before compression.
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

  const maxWidth = 1920;
  const maxHeight = 1080;
  var outputImage = decoded;

  final widthScale = maxWidth / decoded.width;
  final heightScale = maxHeight / decoded.height;
  final scale = widthScale < heightScale ? widthScale : heightScale;

  if (scale < 1) {
    final targetWidth = (decoded.width * scale).round().clamp(1, maxWidth);
    final targetHeight = (decoded.height * scale).round().clamp(1, maxHeight);
    outputImage = img.copyResize(
      decoded,
      width: targetWidth,
      height: targetHeight,
      interpolation: img.Interpolation.average,
    );
  }

  final quality = length > 1200 * 1024 ? 40 : 70;
  return Uint8List.fromList(img.encodeJpg(outputImage, quality: quality));
}
