/// DB model for the `product_images` table row returned from Supabase.
class ProductImageRecord {
  final int id;
  final int productId;
  final String? path;
  final String alt;
  final int sortOrder;
  final DateTime? createdAt;

  const ProductImageRecord({
    required this.id,
    required this.productId,
    this.path,
    required this.alt,
    required this.sortOrder,
    this.createdAt,
  });

  factory ProductImageRecord.fromJson(Map<String, dynamic> json) {
    return ProductImageRecord(
      id: json['id'] as int,
      productId: json['product_id'] as int,
      path: json['path'] as String?,
      alt: json['alt'] as String,
      sortOrder: json['sort_order'] as int,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_id': productId,
        if (path != null) 'path': path,
        'alt': alt,
        'sort_order': sortOrder,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      };
}
