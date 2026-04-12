import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

class MediaItem {
  // Existing DB row fields (null for pending uploads)
  int? id;
  String? path;

  // Pending upload fields (null for existing rows)
  Uint8List? localBytes;
  String? localFileName;

  /// After upload, the storage path is stored here so the DB insert can use it.
  String? uploadedPath;

  bool markedForDelete;

  MediaItem.existing({required this.id, required this.path})
      : localBytes = null,
        localFileName = null,
        markedForDelete = false;

  MediaItem.pending({required this.localFileName, required this.localBytes})
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
