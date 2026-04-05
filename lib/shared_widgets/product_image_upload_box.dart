import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

import '../methods/images/image_picker_utils.dart';
import '../models/product/product_image.dart';

/// A rectangular upload target that lets the user add one image at a time.
///
/// Adapted from inventry_management's UploadBox – without image cropping.
/// Supports both click-to-pick (via [pickImageFile]) and drag & drop
/// (via [desktop_drop]).  Immediately compresses the picked image and calls
/// [onImageAdded] with a fully-populated [ProductImage].
class ProductImageUploadBox extends StatefulWidget {
  final void Function(ProductImage image) onImageAdded;

  const ProductImageUploadBox({super.key, required this.onImageAdded});

  @override
  State<ProductImageUploadBox> createState() => _ProductImageUploadBoxState();
}

class _ProductImageUploadBoxState extends State<ProductImageUploadBox> {
  bool _isDragging = false;
  bool _isLoading = false;
  bool _isCompressing = false;
  bool _isCompressionToastVisible = false;

  bool _isImageFileName(String fileName) {
    final lower = fileName.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.bmp') ||
        lower.endsWith('.heic');
  }

  void _showCompressionToast() {
    if (_isCompressionToastVisible) return;
    _isCompressionToastVisible = true;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Compressing image...'),
        duration: Duration(days: 1),
      ),
    );
  }

  void _hideCompressionToast() {
    if (!_isCompressionToastVisible) return;
    _isCompressionToastVisible = false;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  // ── shared processing ──────────────────────────────────────────────────────

  Future<void> _process(String fileName, Uint8List bytes) async {
    if (!mounted) return;
    final shouldCompress = _isImageFileName(fileName);
    setState(() {
      _isLoading = true;
      _isCompressing = shouldCompress;
    });
    if (shouldCompress) {
      _showCompressionToast();
    }
    try {
      final compressed = shouldCompress ? await compressImageBytes(bytes) : null;
      if (!mounted) return;
      widget.onImageAdded(
        ProductImage(
          fileName: fileName,
          originalBytes: bytes,
          compressedBytes: compressed,
        ),
      );
    } catch (e) {
      debugPrint('ProductImageUploadBox._process error: $e');
    } finally {
      _hideCompressionToast();
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isCompressing = false;
        });
      }
    }
  }

  // ── click-to-pick ──────────────────────────────────────────────────────────

  void _onTap() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _isCompressing = false;
    });
    try {
      final picked = await pickImageFile();
      if (picked == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      await _process(picked.fileName, picked.bytes);
    } catch (e) {
      debugPrint('ProductImageUploadBox._onTap error: $e');
      if (mounted) setState(() { _isLoading = false; _isCompressing = false; });
    }
  }

  // ── drag and drop ──────────────────────────────────────────────────────────

  void _onDrop(List<XFile> files) async {
    if (files.isEmpty) return;
    try {
      final file = files.first;
      final bytes = await file.readAsBytes();
      await _process(file.name, bytes);
    } catch (e) {
      debugPrint('ProductImageUploadBox._onDrop error: $e');
      if (mounted) setState(() { _isLoading = false; _isCompressing = false; });
    }
  }

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = _isDragging
        ? theme.colorScheme.secondary
        : Colors.grey.shade400;

    return DropTarget(
      onDragDone: (details) => _onDrop(details.files),
      onDragEntered: (_) => setState(() => _isDragging = true),
      onDragExited: (_) => setState(() => _isDragging = false),
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          dashPattern: const [6.0, 3.0],
          strokeWidth: 2,
          radius: const Radius.circular(12),
          color: accentColor,
          padding: EdgeInsets.zero,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: _isLoading ? null : _onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: _isDragging
                    ? theme.colorScheme.secondary.withAlpha(20)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isLoading)
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: theme.colorScheme.secondary,
                        ),
                      )
                    else
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 40,
                        color: _isDragging
                            ? theme.colorScheme.secondary
                            : Colors.grey.shade500,
                      ),
                    const SizedBox(height: 8),
                    if (_isCompressing)
                      Text(
                        'Compressing...',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    else ...[
                      Text(
                        'Drag & Drop File Here',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        'or Click to Upload',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
