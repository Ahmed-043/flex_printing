/// DB model for the `product_specs` table row returned from Supabase.
class ProductSpecRecord {
  final int id;
  final int productId;
  final String? key;
  final String value;
  final String unit;
  final int sortOrder;
  final DateTime? createdAt;

  const ProductSpecRecord({
    required this.id,
    required this.productId,
    this.key,
    required this.value,
    required this.unit,
    required this.sortOrder,
    this.createdAt,
  });

  factory ProductSpecRecord.fromJson(Map<String, dynamic> json) {
    return ProductSpecRecord(
      id: json['id'] as int,
      productId: json['product_id'] as int,
      key: json['key'] as String?,
      value: json['value'] as String,
      unit: json['unit'] as String,
      sortOrder: json['sort_order'] as int,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_id': productId,
        if (key != null) 'key': key,
        'value': value,
        'unit': unit,
        'sort_order': sortOrder,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      };
}
