import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ImageCacheService {
  static final ImageCacheService _instance = ImageCacheService._internal();
  factory ImageCacheService() => _instance;
  ImageCacheService._internal();

  final Map<String, Uint8List> _cache = {};

  Future<Uint8List?> getImage(String path) async {
    if (_cache.containsKey(path)) {
      return _cache[path];
    }

    try {
      final bytes = await Supabase.instance.client.storage
          .from('flex-printing')
          .download(path);
      debugPrint(
          'Image loaded, bytes length: ${bytes.length}');
      _cache[path] = bytes;
      return bytes;
    } catch (_) {
      return null;
    }
  }
}

