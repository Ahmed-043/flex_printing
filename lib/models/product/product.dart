import 'product_image.dart';
import 'product_spec.dart';

/// Input / DTO model for creating a product.
/// Data lives only in the running app session until [ProductService.createProduct]
/// persists it to Supabase.
class Product {
  String name;
  String description;

  /// Category name (will be upserted to the categories table on save).
  String category;

  List<ProductSpec> specs;
  List<ProductImage> images;

  Product({
    this.name = '',
    this.description = '',
    this.category = '',
    List<ProductSpec>? specs,
    List<ProductImage>? images,
  })  : specs = specs ?? [],
        images = images ?? [];
}
