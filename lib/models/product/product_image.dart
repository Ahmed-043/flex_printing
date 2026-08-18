import 'dart:typed_data';

/// Holds original and compressed bytes for a product image.
class ProductImage {
  /// Original file name (e.g. "photo.jpg").
  final String fileName;

  /// Raw bytes read directly from the picked file.
  final Uint8List? originalBytes;

  /// Compressed bytes produced after picking. May be null if compression
  /// failed, in which case [originalBytes] should be used as a fallback.
  final Uint8List? compressedBytes;

  /// Storage path for existing images.
  final String? path;

  const ProductImage({
    required this.fileName,
    this.originalBytes,
    this.compressedBytes,
    this.path,
  });

  /// Returns compressed bytes when available, otherwise original bytes.
  Uint8List? get displayBytes => compressedBytes ?? originalBytes;

  /// Lower-cased file extension without the dot.
  String get extension {
    final dot = fileName.lastIndexOf('.');
    if (dot == -1 || dot == fileName.length - 1) {
      if (path != null) {
        final pathDot = path!.lastIndexOf('.');
        if (pathDot != -1 && pathDot < path!.length - 1) {
          return path!.substring(pathDot + 1).toLowerCase();
        }
      }
      return '';
    }
    return fileName.substring(dot + 1).toLowerCase();
  }

  /// True when the file name suggests an image format.
  bool get isImage {
    const imageExts = {
      'png',
      'jpg',
      'jpeg',
      'webp',
      'gif',
      'bmp',
      'heic',
    };
    return imageExts.contains(extension);
  }

  /// Size of the display bytes in kilobytes (rounded).
  int get displaySizeKB =>
      displayBytes != null ? (displayBytes!.lengthInBytes / 1024).round() : 0;

  /// Size of the original bytes in kilobytes (rounded).
  int get originalSizeKB =>
      originalBytes != null ? (originalBytes!.lengthInBytes / 1024).round() : 0;
}
