import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/product/product_spec_record.dart';

/// Fetches spec rows for a single product from the `product_specs` table,
/// ordered by [sort_order] ascending.
///
/// Returns an empty list on any error so callers can degrade gracefully.
Future<List<ProductSpecRecord>> fetchProductSpecs(int productId) async {
  final client = Supabase.instance.client;
  try {
    final response = await client
        .from('product_specs')
        .select('id, product_id, key, value, unit, sort_order, created_at')
        .eq('product_id', productId)
        .order('sort_order', ascending: true);

    if (response is! List) return const <ProductSpecRecord>[];

    return response
        .map((row) => ProductSpecRecord.fromJson(row as Map<String, dynamic>))
        .toList(growable: false);
  } catch (e) {
    debugPrint('fetchProductSpecs error (productId=$productId): $e');
    return const <ProductSpecRecord>[];
  }
}
