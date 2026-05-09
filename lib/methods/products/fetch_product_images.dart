import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/product/product_image_record.dart';

/// Fetches all image rows for a single product from `product_images`.
///
/// Images are ordered by `sort_order` and then `id` so gallery order is stable.
Future<List<ProductImageRecord>> fetchProductImages(int productId) async {
  final client = Supabase.instance.client;

  try {
    final response = await client
        .from('product_images')
        .select('id, product_id, path, alt, sort_order, created_at')
        .eq('product_id', productId)
        .order('sort_order', ascending: true)
        .order('id', ascending: true);

    return response
        .map((row) => ProductImageRecord.fromJson(row))
        .toList(growable: false);
  } catch (e) {
    debugPrint('fetchProductImages error (productId=$productId): $e');
    return const <ProductImageRecord>[];
  }
}
