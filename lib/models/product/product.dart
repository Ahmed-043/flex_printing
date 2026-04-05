import 'product_image.dart';
import 'product_spec.dart';

/// In-memory representation of a product being created by an admin.
/// No persistence – data lives only in the running app session.
class Product {
  String name;
  String description;
  List<ProductSpec> specs;
  List<ProductImage> images;

  Product({
    this.name = '',
    this.description = '',
    List<ProductSpec>? specs,
    List<ProductImage>? images,
  })  : specs = specs ?? [],
        images = images ?? [];
}
