import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../methods/admin/media_utils.dart';
import '../../models/System/system.dart';
import '../../models/product/product_image.dart';
import '../../shared_widgets/product_image_upload_box.dart';
import '../../shared_widgets/ui_helper.dart';

// ── Data models ───────────────────────────────────────────────────────────────

class _MediaItem {
  // Existing DB row fields (null for pending uploads)
  int? id;
  String? path;

  // Pending upload fields (null for existing rows)
  Uint8List? localBytes;
  String? localFileName;

  /// After upload, the storage path is stored here so the DB insert can use it.
  String? uploadedPath;

  bool markedForDelete;

  _MediaItem.existing({required this.id, required this.path})
      : localBytes = null,
        localFileName = null,
        markedForDelete = false;

  _MediaItem.pending({required this.localFileName, required this.localBytes})
      : id = null,
        path = null,
        markedForDelete = false;

  bool get isExisting => id != null;
  bool get isPending => id == null;

  /// Public URL used to render the thumbnail.
  String? publicUrl() {
    if (path == null) return null;
    return Supabase.instance.client.storage
        .from('flex-printing')
        .getPublicUrl(path!);
  }
}

// ── Page ──────────────────────────────────────────────────────────────────────

class MaterialsManagerPage extends StatefulWidget {
  const MaterialsManagerPage({super.key});

  @override
  State<MaterialsManagerPage> createState() => _MaterialsManagerPageState();
}

class _MaterialsManagerPageState extends State<MaterialsManagerPage> {
  static const _tableName = 'materials';
  static const _storageFolder = 'materials';
  static const _bucket = 'flex-printing';

  List<_MediaItem> _items = [];
  bool _loading = true;
  bool _saving = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  // ── Data loading ─────────────────────────────────────────────────────────

  Future<void> _loadItems() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final client = Supabase.instance.client;
      final rows = await client
          .from(_tableName)
          .select('id, path, sort_order, created_at')
          .order('sort_order', ascending: true)
          .order('created_at', ascending: true);
      setState(() {
        _items = (rows as List)
            .map((r) =>
            _MediaItem.existing(
              id: r['id'] as int,
              path: r['path'] as String,
            ))
            .toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loadError = 'Failed to load images: $e';
        _loading = false;
      });
    }
  }

  // ── Add image ─────────────────────────────────────────────────────────────

  void _addImage(ProductImage img) {
    setState(() {
      _items.add(_MediaItem.pending(
        localFileName: img.fileName,
        localBytes: img.displayBytes,
      ));
    });
  }

  // ── Delete / un-delete ───────────────────────────────────────────────────

  void _toggleDelete(int index) {
    setState(() {
      final item = _items[index];
      if (item.isPending) {
        _items.removeAt(index);
      } else {
        item.markedForDelete = !item.markedForDelete;
      }
    });
  }

  // ── Reorder ───────────────────────────────────────────────────────────────

  void _reorderImages(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _items.removeAt(oldIndex);
      _items.insert(newIndex, item);
    });
  }

  // ── Save ─────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (_saving) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      _showError('Not signed in. Please sign in to save changes.');
      return;
    }

    setState(() => _saving = true);

    try {
      final client = Supabase.instance.client;

      // 1. Upload pending images
      for (final item in _items) {
        if (!item.isPending) continue;
        final ext = extensionFromFileName(item.localFileName ?? 'image');
        final storagePath = '$_storageFolder/${generateUuid()}.$ext';
        await client.storage.from(_bucket).uploadBinary(
          storagePath,
          item.localBytes!,
        );
        item.uploadedPath = storagePath;
      }

      // 2. Delete flagged items (storage + DB)
      final toDelete = _items.where((i) => i.markedForDelete).toList();
      if (toDelete.isNotEmpty) {
        final storagePaths = toDelete.map((i) => i.path!).toList();
        await client.storage.from(_bucket).remove(storagePaths);
        final ids = toDelete.map((i) => i.id!).toList();
        await client.from(_tableName).delete().inFilter('id', ids);
      }

      // 3. Build the surviving ordered list
      final surviving = _items
          .where((i) => !i.markedForDelete)
          .toList();

      // 4. Insert new rows; update sort_order for existing
      for (int i = 0; i < surviving.length; i++) {
        final item = surviving[i];
        if (item.isPending && item.uploadedPath != null) {
          await client.from(_tableName).insert({
            'path': item.uploadedPath,
            'sort_order': i,
          });
        } else if (item.isExisting) {
          await client
              .from(_tableName)
              .update({'sort_order': i}).eq('id', item.id!);
        }
      }

      // 5. Reload fresh data
      await _loadItems();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved successfully!')),
        );
      }
    } catch (e) {
      if (mounted) _showError('Save failed: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  // ── UI ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      return _notSignedInView(context);
    }

    return _buildPage(context);
  }

  Widget _notSignedInView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 56, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'You must be signed in to manage media.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/admin'),
              child: const Text('Go to Admin'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final isCompact = System.isMobile || screenWidth < 900;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 20 : 60,
        vertical: 40,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ───────────────────────────────────────────────────
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => context.go('/admin'),
                  icon: Icon(Icons.arrow_back,
                      color: Theme
                          .of(context)
                          .colorScheme
                          .onPrimary),
                  label: Text('Back to Admin',
                      style: TextStyle(
                          color: Theme
                              .of(context)
                              .colorScheme
                              .onPrimary)),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: UiHelper.title(
                  context: context,
                  title: 'Materials & Parts',
                ),
              ),
              SizedBox(height: isCompact ? 32 : 48),

              // ── Loading / error ──────────────────────────────────────────
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else
                if (_loadError != null)
                  _ErrorBanner(
                    message: _loadError!,
                    onRetry: _loadItems,
                  )
                else
                  ...[
                    // ── Images section ───────────────────────────────────────
                    _sectionHeader(context, 'Images'),
                    const SizedBox(height: 8),
                    Text(
                      'Add files one at a time. Drag & drop or click to upload.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (_items.isNotEmpty) ...[
                      _imagePreviewsSection(context, isCompact),
                      const SizedBox(height: 16),
                    ],

                    SizedBox(
                      height: 150,
                      child: ProductImageUploadBox(onImageAdded: _addImage),
                    ),
                  ],

              SizedBox(height: isCompact ? 32 : 48),

              // ── Save button ──────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 56,
                child: UiHelper.button(
                  callback: _saving ? null : _save,
                  filled: true,
                  color: Theme
                      .of(context)
                      .colorScheme
                      .secondaryContainer,
                  borderRadius: 14,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  elevation: 2,
                  child: _saving
                      ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Theme
                          .of(context)
                          .colorScheme
                          .primary,
                    ),
                  )
                      : Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 18,
                      color:
                      Theme
                          .of(context)
                          .colorScheme
                          .onSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imagePreviewsSection(BuildContext context, bool isCompact) {
    final thumbSize = isCompact ? 90.0 : 110.0;

    return SizedBox(
      height: thumbSize + 32,
      child: ReorderableListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _items.length,
        onReorder: _reorderImages,
        buildDefaultDragHandles: false,
        itemBuilder: (context, index) {
          return ReorderableDragStartListener(
            key: ValueKey(index),
            index: index,
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: _imageThumbnail(context, index, _items[index], thumbSize),
            ),
          );
        },
      ),
    );
  }

  Widget _imageThumbnail(BuildContext context, int index, _MediaItem item,
      double size) {
    final theme = Theme.of(context);
    final isDeleted = item.markedForDelete;

    Widget imageWidget;
    if (item.isPending) {
      imageWidget = Image.memory(
        item.localBytes!,
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    } else {
      imageWidget = Image.network(
        item.publicUrl()!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        loadingBuilder: (_, child, progress) =>
        progress == null
            ? child
            : const Center(
            child: CircularProgressIndicator(strokeWidth: 2)),
        errorBuilder: (_, __, ___) =>
        const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: isDeleted
                ? ColorFiltered(
              colorFilter: const ColorFilter.mode(
                  Colors.grey, BlendMode.saturation),
              child: imageWidget,
            )
                : imageWidget,
          ),

          // "NEW" badge for pending items
          if (item.isPending)
            Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.shade700,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'NEW',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

          // Delete overlay
          if (isDeleted)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  color: Colors.red.withAlpha(60),
                  child: const Center(
                    child: Text(
                      'Will be\ndeleted',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Remove / restore button (top-right)
          Positioned(
            top: -6,
            right: -6,
            child: GestureDetector(
              onTap: () => _toggleDelete(index),
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: isDeleted
                      ? Colors.green.shade700
                      : theme.colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDeleted ? Icons.restore : Icons.close,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Drag handle (bottom-right)
          const Positioned(
            bottom: 4,
            right: 4,
            child: Icon(
              Icons.drag_handle,
              size: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 4,
          height: 22,
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onPrimary,
            fontFamily: 'RedHatDisplay',
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
// ── Error banner ──────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
