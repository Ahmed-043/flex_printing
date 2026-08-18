import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/product/product_image_record.dart';
import '../../models/product/product_record.dart';

/// Fetches products from Supabase.
///
/// [category]: category name filter ("All"/empty/null means no category filter).
/// [limit]: max number of products to return.
/// - null, 0, or negative: no limit is applied.
/// - positive value: applies SQL LIMIT.
/// [ascending]: sort by `updated_at` ascending when true, descending when false.
Future<List<ProductRecord>> fetchProducts({
  String? category,
  int? limit,
  bool ascending = false,
}) async {
  final client = Supabase.instance.client;

  final normalizedCategory = category?.trim();
  int? categoryId;

  if (normalizedCategory != null &&
      normalizedCategory.isNotEmpty &&
      normalizedCategory.toLowerCase() != 'all') {
    final categoryRow = await client
        .from('categories')
        .select('id')
        .ilike('name', normalizedCategory)
        .maybeSingle();

    // Category name does not exist in DB, so there can be no matching products.
    if (categoryRow == null) {
      return const <ProductRecord>[];
    }

    categoryId = categoryRow['id'] as int;
  }

  PostgrestFilterBuilder<dynamic> query = client
      .from('products')
      .select('id, name, description, updated_at, category, sort_order');

  if (categoryId != null) {
    query = query.eq('category', categoryId);
  }

  // We fetch ALL products for the category so we can sort them in Dart
  // based on our custom logic (1,2,3... then 0/null).
  // If we applied a limit in SQL, we might miss highly-ranked older products.
  final response = await query.order('id', ascending: false);

  final productRows = (response as List)
      .map((row) => row as Map<String, dynamic>)
      .toList(growable: false);

  if (productRows.isEmpty) {
    return const <ProductRecord>[];
  }

  final productIds = productRows.map((row) => row['id'] as int).toList(growable: false);

  final imageResponse = await client
      .from('product_images')
      .select('id, product_id, path, alt, sort_order, created_at')
      .inFilter('product_id', productIds)
      .order('product_id', ascending: true)
      .order('sort_order', ascending: true)
      .order('id', ascending: true);

  final firstImageByProductId = <int, ProductImageRecord>{};
  for (final row in (imageResponse as List)) {
    final image = ProductImageRecord.fromJson(row as Map<String, dynamic>);
    firstImageByProductId.putIfAbsent(image.productId, () => image);
  }
  try {
    final products = productRows.map((row) {
      final productId = row['id'] as int;
      final firstImage = firstImageByProductId[productId];

      return ProductRecord.fromJson({
        ...row,
        if (firstImage != null) 'first_image': firstImage.toJson(),
      });
    }).toList();

    // Custom sorting: 1, 2, 3... then 0/null
    products.sort((a, b) {
      final sA = a.sortOrder;
      final sB = b.sortOrder;

      if (sA > 0 && sB > 0) {
        return sA.compareTo(sB);
      }
      if (sA > 0 && sB <= 0) {
        return -1; // A comes first
      }
      if (sA <= 0 && sB > 0) {
        return 1; // B comes first
      }
      // Both are 0 or less, sort by ID descending (newest first)
      return b.id.compareTo(a.id);
    });

    // Apply limit in memory AFTER sorting
    if (limit != null && limit > 0) {
      return products.take(limit).toList();
    }

    return products;
  } catch (e) {
    debugPrint('fetchProducts mapping failed: $e');
    rethrow;
  }
}
