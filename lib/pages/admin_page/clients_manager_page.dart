import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../methods/admin/media_utils.dart';
import '../../methods/images/image_picker_utils.dart';
import '../../models/System/system.dart';
import '../../shared_widgets/ui_helper.dart';

// ── Data model ────────────────────────────────────────────────────────────────

class _MediaItem {
  int? id;
  String? path;
  Uint8List? localBytes;
  String? localFileName;
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

  String? publicUrl() {
    if (path == null) return null;
    return Supabase.instance.client.storage
        .from('flex-printing')
        .getPublicUrl(path!);
  }
}

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

  List<_MediaItem> _items = [];
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
            .map((r) => _MediaItem.existing(
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

  Future<void> _addImage() async {
    final picked = await pickImageFile();
    if (picked == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Processing image…'),
        duration: Duration(seconds: 30),
      ),
    );

    final compressed = await compressImageBytes(picked.bytes);

    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    setState(() {
      _items.add(_MediaItem.pending(
        localFileName: picked.fileName,
        localBytes: compressed ?? picked.bytes,
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

  void _onReorder(int oldRow, int newRow, int crossAxisCount) {
    setState(() {
      if (newRow > oldRow) newRow--;
      final srcStart = oldRow * crossAxisCount;
      final dstStart = newRow * crossAxisCount;
      final srcEnd = (srcStart + crossAxisCount).clamp(0, _items.length);
      final chunk = _items.sublist(srcStart, srcEnd);
      _items.removeRange(srcStart, srcEnd);
      final insertAt =
          dstStart > srcStart ? dstStart - chunk.length : dstStart;
      _items.insertAll(insertAt.clamp(0, _items.length), chunk);
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
    if (user == null) return _notSignedInView(context);
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = System.isMobile || screenWidth < 900;
    final crossAxisCount = isCompact ? 2 : 4;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 16 : 48,
        vertical: 32,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    tooltip: 'Back to Admin',
                    onPressed: () => context.go('/admin'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: UiHelper.title(
                      context: context,
                      title: 'Our Clients',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Drag to reorder. Tap ✕ to remove. Press Save to sync changes.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              if (_loading)
                const Center(child: CircularProgressIndicator())
              else if (_loadError != null)
                _ErrorBanner(message: _loadError!, onRetry: _loadItems)
              else ...[
                if (_items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(
                        'No images yet. Add some below.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  _buildReorderableGrid(crossAxisCount),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _saving ? null : _addImage,
                        icon: const Icon(Icons.add_photo_alternate_outlined),
                        label: const Text('Add Image'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: UiHelper.button(
                        callback: _saving ? null : _save,
                        filled: true,
                        color: Colors.black,
                        borderRadius: 12,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        elevation: 2,
                        child: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Save',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReorderableGrid(int crossAxisCount) {
    final rowCount = (_items.length / crossAxisCount).ceil();

    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      itemCount: rowCount,
      onReorder: (o, n) => _onReorder(o, n, crossAxisCount),
      itemBuilder: (context, rowIndex) {
        final start = rowIndex * crossAxisCount;
        final end = (start + crossAxisCount).clamp(0, _items.length);
        final rowItems = _items.sublist(start, end);

        return Material(
          key: ValueKey('row_$rowIndex'),
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ReorderableDragStartListener(
                  index: rowIndex,
                  child: const Padding(
                    padding: EdgeInsets.only(right: 8, top: 40),
                    child: Icon(Icons.drag_handle, color: Colors.grey),
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      for (int col = 0; col < crossAxisCount; col++)
                        Expanded(
                          child: col < rowItems.length
                              ? Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: _ImageTile(
                                    item: rowItems[col],
                                    onDelete: () =>
                                        _toggleDelete(start + col),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Shared image tile ─────────────────────────────────────────────────────────

class _ImageTile extends StatelessWidget {
  final _MediaItem item;
  final VoidCallback onDelete;

  const _ImageTile({required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isDeleted = item.markedForDelete;

    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ColorFiltered(
              colorFilter: isDeleted
                  ? const ColorFilter.mode(Colors.red, BlendMode.saturation)
                  : const ColorFilter.mode(
                      Colors.transparent, BlendMode.dst),
              child: item.isPending
                  ? Image.memory(item.localBytes!, fit: BoxFit.cover)
                  : Image.network(
                      item.publicUrl()!,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) =>
                          progress == null
                              ? child
                              : const Center(
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2)),
                      errorBuilder: (_, __, ___) => const Center(
                        child:
                            Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
            ),
          ),
        ),
        if (item.isPending)
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.shade700,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'NEW',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onDelete,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isDeleted
                    ? Colors.green.shade700
                    : Colors.red.shade600,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isDeleted ? Icons.restore : Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
        if (isDeleted)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                color: Colors.red.withAlpha(60),
                child: const Center(
                  child: Text(
                    'Will be\ndeleted',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ),
              ),
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
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
