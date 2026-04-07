/// DB model for the `categories` table.
class Category {
  final int id;
  final String name;
  final DateTime? createdAt;

  const Category({
    required this.id,
    required this.name,
    this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      };
}
