import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../methods/admin/media_utils.dart';
import '../../models/System/system.dart';
import '../../models/product/product_image.dart';
import '../../shared_widgets/admin_manager_widgets.dart';
import '../../shared_widgets/product_image_upload_box.dart';
import '../../shared_widgets/ui_helper.dart';

// ── Data models ───────────────────────────────────────────────────────────────

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

/// Represents one row in the `event_locations` table.
class _LocationItem {
  int? id; // null for newly added rows
  String text;
  bool markedForDelete;

  _LocationItem.existing({required this.id, required this.text})
      : markedForDelete = false;

  _LocationItem.pending({required this.text})
      : id = null,
        markedForDelete = false;

  bool get isExisting => id != null;
  bool get isPending => id == null;
}

// ── Page ──────────────────────────────────────────────────────────────────────

class EventsManagerPage extends StatefulWidget {
  const EventsManagerPage({super.key});

  @override
  State<EventsManagerPage> createState() => _EventsManagerPageState();
}

class _EventsManagerPageState extends State<EventsManagerPage> {
  static const _tableName = 'events';
  static const _locationsTable = 'event_locations';
  static const _storageFolder = 'events';
  static const _bucket = 'flex-printing';

  // ── Media state ──────────────────────────────────────────────────────────
  List<_MediaItem> _items = [];
  bool _loadingMedia = true;
  String? _mediaLoadError;

  // ── Locations state ──────────────────────────────────────────────────────
  List<_LocationItem> _locations = [];
  bool _loadingLocations = true;
  String? _locationsLoadError;

  // ── Shared saving state ──────────────────────────────────────────────────
  bool _saving = false;

  // ── New location input ───────────────────────────────────────────────────
  final _newLocationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    _newLocationController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    await Future.wait([_loadMedia(), _loadLocations()]);
  }

  // ── Media loading ─────────────────────────────────────────────────────────

  Future<void> _loadMedia() async {
    setState(() {
      _loadingMedia = true;
      _mediaLoadError = null;
    });
    try {
      final rows = await Supabase.instance.client
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
        _loadingMedia = false;
      });
    } catch (e) {
      setState(() {
        _mediaLoadError = 'Failed to load images: $e';
        _loadingMedia = false;
      });
    }
  }

  // ── Locations loading ─────────────────────────────────────────────────────

  Future<void> _loadLocations() async {
    setState(() {
      _loadingLocations = true;
      _locationsLoadError = null;
    });
    try {
      final rows = await Supabase.instance.client
          .from(_locationsTable)
          .select('id, location, sort_order, created_at')
          .order('sort_order', ascending: true)
          .order('created_at', ascending: true);
      setState(() {
        _locations = (rows as List)
            .map((r) => _LocationItem.existing(
                  id: r['id'] as int,
                  text: (r['location'] as String?) ?? '',
                ))
            .toList();
        _loadingLocations = false;
      });
    } catch (e) {
      setState(() {
        _locationsLoadError = 'Failed to load locations: $e';
        _loadingLocations = false;
      });
    }
  }

  // ── Media actions ─────────────────────────────────────────────────────────

  void _addImage(ProductImage img) {
    setState(() {
      _items.add(_MediaItem.pending(
        localFileName: img.fileName,
        localBytes: img.displayBytes,
      ));
    });
  }

  void _toggleDeleteMedia(int index) {
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

  // ── Location actions ──────────────────────────────────────────────────────

  void _addLocation() {
    final text = _newLocationController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _locations.add(_LocationItem.pending(text: text));
      _newLocationController.clear();
    });
  }

  void _toggleDeleteLocation(int index) {
    setState(() {
      final loc = _locations[index];
      if (loc.isPending) {
        _locations.removeAt(index);
      } else {
        loc.markedForDelete = !loc.markedForDelete;
      }
    });
  }

  void _editLocation(int index, String newText) {
    setState(() {
      _locations[index].text = newText;
    });
  }

  void _onReorderLocations(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _locations.removeAt(oldIndex);
      _locations.insert(newIndex, item);
    });
  }

  // ── Save (media + locations together) ────────────────────────────────────

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

      // ── 1. Upload new images ────────────────────────────────────────────
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

      // ── 2. Delete flagged images ────────────────────────────────────────
      final toDeleteMedia = _items.where((i) => i.markedForDelete).toList();
      if (toDeleteMedia.isNotEmpty) {
        final storagePaths = toDeleteMedia.map((i) => i.path!).toList();
        await client.storage.from(_bucket).remove(storagePaths);
        final ids = toDeleteMedia.map((i) => i.id!).toList();
        await client.from(_tableName).delete().inFilter('id', ids);
      }

      // ── 3. Insert new image rows + update sort_order ────────────────────
      final survivingMedia =
          _items.where((i) => !i.markedForDelete).toList();
      for (int i = 0; i < survivingMedia.length; i++) {
        final item = survivingMedia[i];
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

      // ── 4. Delete flagged locations ─────────────────────────────────────
      final toDeleteLocs =
          _locations.where((l) => l.markedForDelete).toList();
      if (toDeleteLocs.isNotEmpty) {
        final ids = toDeleteLocs.map((l) => l.id!).toList();
        await client.from(_locationsTable).delete().inFilter('id', ids);
      }

      // ── 5. Insert new locations + update existing ───────────────────────
      final survivingLocs =
          _locations.where((l) => !l.markedForDelete).toList();
      for (int i = 0; i < survivingLocs.length; i++) {
        final loc = survivingLocs[i];
        if (loc.isPending) {
          await client.from(_locationsTable).insert({
            'location': loc.text,
            'sort_order': i,
          });
        } else if (loc.isExisting) {
          await client.from(_locationsTable).update({
            'location': loc.text,
            'sort_order': i,
          }).eq('id', loc.id!);
        }
      }

      // ── 6. Reload fresh data ────────────────────────────────────────────
      await _loadAll();

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
                      color: Theme.of(context).colorScheme.onPrimary),
                  label: Text('Back to Admin',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary)),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: UiHelper.title(
                  context: context,
                  title: 'Events',
                ),
              ),
              SizedBox(height: isCompact ? 32 : 48),

              // ── Media section ────────────────────────────────────────────
                const AdminSectionHeader(title: 'Event Images'),
              const SizedBox(height: 8),
              Text(
                'Add files one at a time. Drag & drop or click to upload.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),

              if (_loadingMedia)
                const Center(child: CircularProgressIndicator())
              else if (_mediaLoadError != null)
                AdminErrorBanner(message: _mediaLoadError!, onRetry: _loadMedia)
              else ...[
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
              const Divider(),
              const SizedBox(height: 24),

              // ── Locations section ────────────────────────────────────────
              const AdminSectionHeader(title: 'Event Locations'),
              const SizedBox(height: 8),
              const Text(
                'Drag to reorder. Tap ✕ to remove. Tap text to edit.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 16),

              if (_loadingLocations)
                const Center(child: CircularProgressIndicator())
              else if (_locationsLoadError != null)
                AdminErrorBanner(
                    message: _locationsLoadError!, onRetry: _loadLocations)
              else ...[
                _buildLocationsSection(),
                const SizedBox(height: 12),
                _buildAddLocationRow(),
              ],

              SizedBox(height: isCompact ? 32 : 48),

              // ── Save button ──────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 56,
                child: UiHelper.button(
                  callback: _saving ? null : _save,
                  filled: true,
                  color: Theme.of(context).colorScheme.secondaryContainer,
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
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        )
                      : Text(
                          'Save All Changes',
                          style: TextStyle(
                            fontSize: 18,
                            color:
                                Theme.of(context).colorScheme.onSecondary,
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
      BuildContext context, int index, _MediaItem item, double size) {
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
        errorBuilder: (_, __, ___) =>
            const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
      );
    }

    return AdminImageThumbnail(
      size: size,
      isPending: item.isPending,
      isDeleted: isDeleted,
      image: imageWidget,
      onToggleDelete: () => _toggleDeleteMedia(index),
    );
  }

  Widget _buildLocationsSection() {
    if (_locations.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            'No locations yet. Add one below.',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      itemCount: _locations.length,
      onReorder: _onReorderLocations,
      itemBuilder: (context, index) {
        final loc = _locations[index];
        return _LocationTile(
          key: ValueKey('loc_${loc.id ?? 'new_$index'}'),
          location: loc,
          index: index,
          onDelete: () => _toggleDeleteLocation(index),
          onEdit: (text) => _editLocation(index, text),
        );
      },
    );
  }

  Widget _buildAddLocationRow() {
    return Row(
      crossAxisAlignment: .end,
      children: [
        Expanded(
          child:
          UiHelper.inputField(
              controller: _newLocationController,
              context: context, label: 'Enter location name…',
              onSubmitted: (_) => _addLocation()
          ),

        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: _addLocation,
          icon: const Icon(Icons.add),
          label: const Text('Add'),
          style: ElevatedButton.styleFrom(
            iconSize: 20,
            backgroundColor: Theme.of(context).colorScheme.secondary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Location tile ─────────────────────────────────────────────────────────────

class _LocationTile extends StatefulWidget {
  final _LocationItem location;
  final int index;
  final VoidCallback onDelete;
  final ValueChanged<String> onEdit;

  const _LocationTile({
    super.key,
    required this.location,
    required this.index,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<_LocationTile> createState() => _LocationTileState();
}

class _LocationTileState extends State<_LocationTile> {
  late final TextEditingController _controller;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.location.text);
  }

  @override
  void didUpdateWidget(_LocationTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_editing &&
        oldWidget.location.text != widget.location.text) {
      _controller.text = widget.location.text;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startEdit() => setState(() => _editing = true);

  void _commitEdit() {
    widget.onEdit(_controller.text.trim());
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    final loc = widget.location;
    final isDeleted = loc.markedForDelete;

    return Opacity(
      opacity: isDeleted ? 0.5 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isDeleted
              ? Colors.red.shade50
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDeleted
                ? Colors.red.shade200
                : Colors.grey.withAlpha(60),
          ),
        ),
        child: Row(
          children: [
            // Drag handle
            ReorderableDragStartListener(
              index: widget.index,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                child: Icon(Icons.drag_handle, color: Colors.grey, size: 20),
              ),
            ),
            // Location text or edit field
            Expanded(
              child: _editing
                  ? TextField(
                      controller: _controller,
                      autofocus: true,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      onSubmitted: (_) => _commitEdit(),
                      onEditingComplete: _commitEdit,
                    )
                  : GestureDetector(
                      onTap: isDeleted ? null : _startEdit,
                      child: Text(
                        loc.text.isEmpty ? '(empty)' : loc.text,
                        style: TextStyle(
                          fontSize: 15,
                          color: loc.text.isEmpty
                              ? Colors.grey
                              : Theme.of(context).colorScheme.onPrimary,
                          decoration:
                              isDeleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
            ),
            // Edit confirm / delete
            if (_editing)
              IconButton(
                icon: const Icon(Icons.check, color: Colors.green),
                onPressed: _commitEdit,
                tooltip: 'Confirm',
              )
            else
              IconButton(
                icon: Icon(
                  isDeleted ? Icons.restore : Icons.close,
                  color: isDeleted ? Colors.green : Colors.red,
                  size: 20,
                ),
                onPressed: widget.onDelete,
                tooltip: isDeleted ? 'Restore' : 'Delete',
              ),
            // "New" badge
            if (loc.isPending)
              Container(
                margin: const EdgeInsets.only(right: 8),
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
          ],
        ),
      ),
    );
  }
}

// ── Error banner ──────────────────────────────────────────────────────────────

