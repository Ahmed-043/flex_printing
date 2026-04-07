/// DB model for the `products` table row returned from Supabase.
class ProductRecord {
  final int id;
  final String name;
  final String description;
  final DateTime updatedAt;
  final int? category;

  const ProductRecord({
    required this.id,
    required this.name,
    required this.description,
    required this.updatedAt,
    this.category,
  });

  factory ProductRecord.fromJson(Map<String, dynamic> json) {
    return ProductRecord(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      updatedAt: DateTime.parse(json['updated_at'] as String),
      category: json['category'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'updated_at': updatedAt.toIso8601String(),
        if (category != null) 'category': category,
      };
}
