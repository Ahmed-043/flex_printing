import 'dart:typed_data';

/// Holds original and compressed bytes for a product image.
class ProductImage {
  /// Original file name (e.g. "photo.jpg").
  final String fileName;

  /// Raw bytes read directly from the picked file.
  final Uint8List originalBytes;

  /// Compressed bytes produced after picking. May be null if compression
  /// failed, in which case [originalBytes] should be used as a fallback.
  final Uint8List? compressedBytes;

  const ProductImage({
    required this.fileName,
    required this.originalBytes,
    this.compressedBytes,
  });

  /// Returns compressed bytes when available, otherwise original bytes.
  Uint8List get displayBytes => compressedBytes ?? originalBytes;

  /// Size of the display bytes in kilobytes (rounded).
  int get displaySizeKB => (displayBytes.lengthInBytes / 1024).round();

  /// Size of the original bytes in kilobytes (rounded).
  int get originalSizeKB => (originalBytes.lengthInBytes / 1024).round();
}
