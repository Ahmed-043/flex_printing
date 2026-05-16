import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../methods/admin/media_utils.dart';
import '../../models/System/system.dart';
import '../../models/media_item.dart';
import '../../models/product/product_image.dart';
import '../../shared_widgets/admin_manager_widgets.dart';
import '../../shared_widgets/product_image_upload_box.dart';
import '../../shared_widgets/ui_helper.dart';


// ── Page ──────────────────────────────────────────────────────────────────────

class ClientsManagerPage extends StatefulWidget {
  const ClientsManagerPage({super.key});

  @override
  State<ClientsManagerPage> createState() => _ClientsManagerPageState();
}

class _ClientsManagerPageState extends State<ClientsManagerPage> {
  static const _tableName = 'clients';
  static const _storageFolder = 'clients';
  static const _bucket = 'flex-printing';

  List<MediaItem> _items = [];
  bool _loading = true;
  bool _saving = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

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
            .map((r) => MediaItem.existing(
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

  void _addImage(ProductImage img) {
    setState(() {
      _items.add(MediaItem.pending(
        localFileName: img.fileName,
        localBytes: img.displayBytes,
      ));
    });
  }

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

  void _reorderImages(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _items.removeAt(oldIndex);
      _items.insert(newIndex, item);
    });
  }

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

      final toDelete = _items.where((i) => i.markedForDelete).toList();
      if (toDelete.isNotEmpty) {
        final storagePaths = toDelete.map((i) => i.path!).toList();
        await client.storage.from(_bucket).remove(storagePaths);
        final ids = toDelete.map((i) => i.id!).toList();
        await client.from(_tableName).delete().inFilter('id', ids);
      }

      final surviving =
          _items.where((i) => !i.markedForDelete).toList();

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

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return notSignedInView(context);
    return _buildPage(context);
  }


  Widget _buildPage(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = System.isMobile || screenWidth < 900;
    final theme = Theme.of(context).colorScheme;

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
                  icon: Icon(Icons.arrow_back, color: theme.onPrimary),
                  label: Text(
                    'Back to Admin',
                    style: TextStyle(color: theme.onPrimary),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: UiHelper.title(
                  context: context,
                  title: 'Our Clients',
                ),
              ),
              SizedBox(height: isCompact ? 32 : 48),

              if (_loading)
                const Center(child: CircularProgressIndicator())
              else if (_loadError != null)
                AdminErrorBanner(message: _loadError!, onRetry: _loadItems)
              else ...[
                // ── Images section ───────────────────────────────────────
                const AdminSectionHeader(title: 'Images'),
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
                  callback: _saving ? (){} : _save,
                  filled: true,
                  color: theme.secondaryContainer,
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
                            color: theme.primary,
                          ),
                        )
                      : Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 18,
                            color: theme.onSecondary,
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

  Widget _imageThumbnail(
      BuildContext context, int index, MediaItem item, double size) {
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
        loadingBuilder: (_, child, progress) => progress == null
            ? child
            : const Center(
                child: CircularProgressIndicator(strokeWidth: 2)),
        errorBuilder: (_, _, _) =>
            const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
      );
    }

    return AdminImageThumbnail(
      size: size,
      isPending: item.isPending,
      isDeleted: isDeleted,
      image: imageWidget,
      onToggleDelete: () => _toggleDelete(index),
    );
  }
}
