import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product/category.dart' as product_model;
import '../models/product/product.dart';

enum CategoryDeleteStatus { deleted, inUse, notFound }

/// Service that wraps all Supabase operations related to products.
///
/// Bucket name: "flex-printing"
/// Tables used: categories, products, product_images, product_specs
class ProductService {
  ProductService._();

  static SupabaseClient get _client => Supabase.instance.client;

  static const String _bucket = 'flex-printing';
  static const int _maxCreateAttempts = 2;

  // ── Categories ─────────────────────────────────────────────────────────────

  /// Deletes a category by [name] only if no product currently references it.
  static Future<CategoryDeleteStatus> deleteCategoryIfUnusedByName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return CategoryDeleteStatus.notFound;
    }

    final existing = await _client
        .from('categories')
        .select('id')
        .ilike('name', trimmed)
        .maybeSingle();

    if (existing == null) {
      return CategoryDeleteStatus.notFound;
    }

    final categoryId = existing['id'] as int;

    final usageRows = await _client
        .from('products')
        .select('id')
        .eq('category', categoryId)
        .limit(1);

    if ((usageRows as List).isNotEmpty) {
      return CategoryDeleteStatus.inUse;
    }

    await _client.from('categories').delete().eq('id', categoryId);
    return CategoryDeleteStatus.deleted;
  }

  /// Loads all categories ordered by name.
  static Future<List<product_model.Category>> fetchCategories() async {
    try {
      final response = await _client
          .from('categories')
          .select('id, name, created_at')
          .order('name', ascending: true)
          .timeout(const Duration(seconds: 12));
      return (response as List)
          .map((e) => product_model.Category.fromJson(e as Map<String, dynamic>))
          .toList();
    } on TimeoutException {
      throw Exception('Categories request timed out.');
    } catch (e) {
      debugPrint('ProductService.fetchCategories failed: $e');
      rethrow;
    }
  }

  /// Fetches a category name by its [id].
  static Future<String?> fetchCategoryNameById(int id) async {
    try {
      final res = await _client
          .from('categories')
          .select('name')
          .eq('id', id)
          .maybeSingle();
      return res?['name'] as String?;
    } catch (e) {
      debugPrint('ProductService.fetchCategoryNameById failed: $e');
      return null;
    }
  }

  /// Returns the id of an existing category with [name] (case-insensitive),
  /// or inserts a new row and returns the new id.
  static Future<int> upsertCategory(String name) async {
    final trimmed = name.trim();

    // Look for an existing match (case-insensitive)
    final existing = await _client
        .from('categories')
        .select('id')
        .ilike('name', trimmed)
        .maybeSingle();

    if (existing != null) {
      return existing['id'] as int;
    }

    // Insert and return the new id
    final result = await _client
        .from('categories')
        .insert({'name': trimmed})
        .select('id')
        .single();

    return result['id'] as int;
  }

  // ── Product creation ────────────────────────────────────────────────────────

  /// Creates a full product (row + images + specs) in Supabase.
  ///
  /// Steps:
  /// 1. Upsert category → obtain category id.
  /// 2. Insert `products` row → obtain product_id.
  /// 3. For each image: upload file to Storage then insert `product_images` row.
  /// 4. For each spec: insert `product_specs` row.
  ///
  /// If step 3 or 4 fails the product row (and any already-uploaded storage
  /// objects) are deleted before re-throwing the error.
  ///
  /// Returns the new product id on success.
  static Future<int> createProduct(Product product) async {
    Object? lastError;
    for (var attempt = 1; attempt <= _maxCreateAttempts; attempt++) {
      try {
        return await _createProductOnce(product);
      } catch (e) {
        lastError = e;
        final canRetry = attempt < _maxCreateAttempts && _isTransientNetworkError(e);
        if (!canRetry) {
          rethrow;
        }
        debugPrint('ProductService.createProduct retrying after transient error: $e');
        await Future<void>.delayed(const Duration(milliseconds: 600));
      }
    }
    throw lastError ?? Exception('Unknown product save error');
  }

  /// Updates an existing product and its related images/specs.
  static Future<void> updateProduct(int productId, Product product) async {
    try {
      // 1. Category
      int? categoryId;
      if (product.category.trim().isNotEmpty) {
        categoryId = await upsertCategory(product.category.trim());
      }

      // 2. Update product row
      await _client.from('products').update({
        'name': product.name,
        'description': product.description,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
        'category': categoryId,
      }).eq('id', productId);

      // 3. Handle Images
      final existingImages = await _client
          .from('product_images')
          .select('path')
          .eq('product_id', productId);
      final existingPaths =
          (existingImages as List).map((e) => e['path'] as String).toSet();

      final currentPaths =
          product.images.map((e) => e.path).whereType<String>().toSet();
      final pathsToRemove =
          existingPaths.difference(currentPaths).toList();

      if (pathsToRemove.isNotEmpty) {
        await _client.storage.from(_bucket).remove(pathsToRemove);
      }

      // Delete old rows to re-insert with correct sort_order
      await _client.from('product_images').delete().eq('product_id', productId);
      await _client.from('product_specs').delete().eq('product_id', productId);

      // Re-insert images
      for (int i = 0; i < product.images.length; i++) {
        final img = product.images[i];
        String? path = img.path;

        if (path == null) {
          final bytes = img.displayBytes;
          if (bytes != null) {
            final timestamp = DateTime.now().millisecondsSinceEpoch;
            final safeName =
                img.fileName.replaceAll(RegExp(r'[^\w.\-]'), '_');
            path = 'products/$productId/${timestamp}_$safeName';
            await _client.storage.from(_bucket).uploadBinary(path, bytes);
          }
        }

        if (path != null) {
          await _client.from('product_images').insert({
            'product_id': productId,
            'path': path,
            'alt': img.fileName,
            'sort_order': i,
          });
        }
      }

      // 4. Re-insert specs
      for (int i = 0; i < product.specs.length; i++) {
        final spec = product.specs[i];
        await _client.from('product_specs').insert({
          'product_id': productId,
          'key': spec.key,
          'value': spec.value,
          'unit': spec.unit,
          'sort_order': i,
        });
      }
    } catch (e) {
      debugPrint('ProductService.updateProduct failed: $e');
      rethrow;
    }
  }

  /// Returns true when Supabase responds within a short timeout.
  ///
  /// UI gestures can call this and stay silent if the app is offline or the
  /// Supabase host is unreachable.
  static Future<bool> isConnected() async {
    try {
      await _client.from('products').select('id').limit(1).timeout(
            const Duration(seconds: 4),
          );
      return true;
    } catch (e) {
      debugPrint('ProductService.isConnected failed: $e');
      return false;
    }
  }

  /// Deletes a product and all of its product-owned data.
  ///
  /// Categories are intentionally preserved.
  static Future<void> deleteProduct(int productId) async {
    try {
      final imageRows = await _client
          .from('product_images')
          .select('id, path')
          .eq('product_id', productId);

      final imagePaths = <String>[];
      for (final row in imageRows as List) {
        final map = row as Map<String, dynamic>;
        final path = map['path'] as String?;
        if (path != null && path.isNotEmpty) {
          imagePaths.add(path);
        }
      }

      if (imagePaths.isNotEmpty) {
        await _client.storage.from(_bucket).remove(imagePaths);
      }

      await _client.from('product_specs').delete().eq('product_id', productId);
      await _client.from('product_images').delete().eq('product_id', productId);
      await _client.from('products').delete().eq('id', productId);
    } catch (e) {
      debugPrint('ProductService.deleteProduct failed (productId=$productId): $e');
      rethrow;
    }
  }

  static Future<int> _createProductOnce(Product product) async {
    // 1. Category
    int? categoryId;
    if (product.category.trim().isNotEmpty) {
      categoryId = await upsertCategory(product.category.trim());
    }

    // 2. Insert product row
    final productResult = await _client
        .from('products')
        .insert({
          'name': product.name,
          'description': product.description,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
          if (categoryId != null) 'category': categoryId,
        })
        .select('id')
        .single();

    final productId = productResult['id'] as int;

    // 3. Upload images + insert rows  (with compensating cleanup on failure)
    final uploadedPaths = <String>[];
    try {
      for (int i = 0; i < product.images.length; i++) {
        final img = product.images[i];
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        // Sanitise file name for storage path
        final safeName =
            img.fileName.replaceAll(RegExp(r'[^\w.\-]'), '_');
        final path = 'products/$productId/${timestamp}_$safeName';

        await _client.storage.from(_bucket).uploadBinary(
              path,
              img.displayBytes!,
            );

        uploadedPaths.add(path);

        await _client.from('product_images').insert({
          'product_id': productId,
          'path': path,
          'alt': img.fileName,
          'sort_order': i,
        });
      }

      // 4. Insert specs
      for (int i = 0; i < product.specs.length; i++) {
        final spec = product.specs[i];
        await _client.from('product_specs').insert({
          'product_id': productId,
          'key': spec.key,
          'value': spec.value,
          'unit': spec.unit,
          'sort_order': i,
        });
      }
    } catch (e) {
      debugPrint('ProductService.createProduct: error – attempting cleanup. $e');
      await _cleanup(productId, uploadedPaths);
      rethrow;
    }

    return productId;
  }

  static bool _isTransientNetworkError(Object error) {
    final msg = error.toString().toLowerCase();
    return msg.contains('failed host lookup') ||
        msg.contains('no such host is known') ||
        msg.contains('socketexception') ||
        msg.contains('failed to fetch') ||
        msg.contains('timed out') ||
        msg.contains('timeoutexception');
  }

  static String toUserMessage(Object error, {String action = 'complete request'}) {
    final msg = error.toString().toLowerCase();
    if (msg.contains('failed host lookup') || msg.contains('no such host is known')) {
      return 'Could not reach Supabase host while trying to $action. Check internet/DNS and confirm the project URL.';
    }
    if (msg.contains('failed to fetch') || msg.contains('socketexception')) {
      return 'Network error while trying to $action. Please check connection and retry.';
    }
    if (msg.contains('timed out') || msg.contains('timeoutexception')) {
      return 'Request timed out while trying to $action. Please retry.';
    }
    return 'Unable to $action right now. Please retry.';
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  /// Best-effort compensating cleanup: removes storage files and product row.
  static Future<void> _cleanup(
      int productId, List<String> uploadedPaths) async {
    try {
      if (uploadedPaths.isNotEmpty) {
        await _client.storage.from(_bucket).remove(uploadedPaths);
      }
    } catch (e) {
      debugPrint('ProductService._cleanup storage error: $e');
    }
    try {
      // Also remove any product_images and product_specs rows that were
      // inserted before the failure. These explicit deletes are intentional:
      // the schema does not configure ON DELETE CASCADE between products and
      // its child tables, so we handle cleanup manually.
      await _client
          .from('product_images')
          .delete()
          .eq('product_id', productId);
      await _client
          .from('product_specs')
          .delete()
          .eq('product_id', productId);
      await _client.from('products').delete().eq('id', productId);
    } catch (e) {
      debugPrint('ProductService._cleanup DB error: $e');
    }
  }
}
