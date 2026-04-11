import '../../services/product_service.dart';

/// Reusable helper that loads category names from Supabase.
///
/// This keeps widget-specific state handling (`mounted`, `setState`) out of the
/// data-access layer so multiple pages can reuse the same category loader.
Future<List<String>> fetchCategoryNames() async {
  final categories = await ProductService.fetchCategories();
  return categories.map((category) => category.name).toList(growable: false);
}
