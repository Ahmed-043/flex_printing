import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/product/product_image_record.dart';
import '../../models/product/product_record.dart';

/// Fetches one product by id, including its first image (if any).
Future<ProductRecord?> fetchProductById(int productId) async {
  final client = Supabase.instance.client;

  try {
    final productRow = await client
        .from('products')
        .select('id, name, description, updated_at, category')
        .eq('id', productId)
        .maybeSingle();

    if (productRow == null) {
      return null;
    }

    final imageRows = await client
        .from('product_images')
        .select('id, product_id, path, alt, sort_order, created_at')
        .eq('product_id', productId)
        .order('sort_order', ascending: true)
        .order('id', ascending: true)
        .limit(1);

    ProductImageRecord? firstImage;
    if (imageRows.isNotEmpty) {
      firstImage = ProductImageRecord.fromJson(imageRows.first);
    }

    return ProductRecord.fromJson({
      ...productRow,
      if (firstImage != null) 'first_image': firstImage.toJson(),
    });
  } catch (e) {
    debugPrint('fetchProductById error (productId=$productId): $e');
    return null;
  }
}

