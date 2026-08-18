import 'package:flex_printing/pages/products_page/product_card.dart';
import 'package:flex_printing/services/product_service.dart';
import 'package:flex_printing/shared_widgets/scaled_container.dart';
import 'package:flex_printing/shared_widgets/ui_helper.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../methods/products/fetch_products.dart';
import '../../models/System/system.dart';
import '../../models/product/product_record.dart';
import '../home_page/footer.dart';
import '../home_page/products_section.dart';
import 'delete_dialog.dart';
List<String> categories = ["All"];

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  int _selectedCategoryIndex = 0;
  int _loadRequestId = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadProducts();
  }

  // Future<void> _loadCategories(int requestId) async {
  //   final names = await fetchCategoryNames();
  //   if (!mounted || requestId != _loadRequestId) return;
  //
  //   final nextCategories = ["All", ...names];
  //   var selectedIndex = _selectedCategoryIndex;
  //   if (selectedIndex >= nextCategories.length) {
  //     selectedIndex = 0;
  //   }
  //
  //   setState(() {
  //     categories = nextCategories;
  //     _selectedCategoryIndex = selectedIndex;
  //   });
  // }

  Future<void> _loadProductsForCategory(String category, int requestId) async {
    // Get product IDs already loaded in products
    if(_selectedCategoryIndex != 0){
      products = [];
    }
    final cachedProductIds =
        products.map((p) => p.id).toSet();

    // Fetch all products for the category
    final fetchedProducts = await fetchProducts(
      category: category,
    );
    if (!mounted || requestId != _loadRequestId) return;

    // Filter to only include products not already cached
    final newProducts = fetchedProducts
        .where((p) => !cachedProductIds.contains(p.id))
        .toList();

    // Merge: cached products first, then new products
    final mergedProducts = [
      if(_selectedCategoryIndex == 0)
        ...products,
      ...newProducts,
    ];
    // Custom sorting: 1, 2, 3... then 0/null
    mergedProducts.sort((a, b) {
      final sA = a.sortOrder;
      final sB = b.sortOrder;

      if (sA > 0 && sB > 0) {
        return sA.compareTo(sB);
      }
      if (sA > 0 && sB <= 0) {
        return -1;
      }
      if (sA <= 0 && sB > 0) {
        return 1;
      }
      return b.id.compareTo(a.id);
    });
    setState(() {
      products = mergedProducts;
    });
  }

  Future<void> _loadProducts({int? nextCategoryIndex}) async {
    final requestId = ++_loadRequestId;

    if (nextCategoryIndex != null) {
      if (!mounted) return;
      setState(() {
        _selectedCategoryIndex = nextCategoryIndex;
      });
    }

    //await _loadCategories(requestId);
    if (!mounted || requestId != _loadRequestId) return;

    await _loadProductsForCategory(categories[_selectedCategoryIndex], requestId);

  }

  Future<void> _handleCategoryLongPress(int index) async {
    if (index <= 0 || index >= categories.length) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final connected = await ProductService.isConnected();
    if (!connected || !mounted) return;

    final categoryName = categories[index];

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => DeleteCategoryDialog(categoryName: categoryName),
    );

    if (confirmed != true || !mounted) return;

    try {
      final result =
          await ProductService.deleteCategoryIfUnusedByName(categoryName);
      if (!mounted) return;

      if (result == CategoryDeleteStatus.inUse) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Cannot delete "$categoryName" because it is used by one or more products.',
            ),
            backgroundColor: Colors.orange.shade800,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      if (result == CategoryDeleteStatus.notFound) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Category "$categoryName" was not found.'),
            backgroundColor: Colors.orange.shade800,
            behavior: SnackBarBehavior.floating,
          ),
        );
        await _loadProducts(nextCategoryIndex: 0);
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Category "$categoryName" deleted successfully.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      var nextIndex = _selectedCategoryIndex;
      if (_selectedCategoryIndex == index) {
        nextIndex = 0;
      } else if (index < _selectedCategoryIndex) {
        nextIndex = _selectedCategoryIndex - 1;
      }

      await _loadProducts(nextCategoryIndex: nextIndex);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ProductService.toUserMessage(e, action: 'delete category'),
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _loadRequestId++;
    super.dispose();
  }

  Future<void> _handleReorder(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final items = List<ProductRecord>.from(products);
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);

    setState(() {
      products = items;
    });

    // Update sort_order for all products in current list
    final Map<int, int> updates = {};
    for (int i = 0; i < items.length; i++) {
      updates[items[i].id] = i + 1; // Start from 1
    }

    try {
      await ProductService.updateProductSortOrders(updates);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update sort order')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final canReorder = user != null;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: System.isMobile ? 40 : 100),
          Hero(
            tag: "product_title",
            child: Material(
                color: Colors.transparent,
                child: UiHelper.title(context: context, title: "Our Products")),
          ),
          SizedBox(height: System.isMobile ? 40 : 90),
          SizedBox(
            height: 70,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  categories.length,
                  (index) => _category(
                    context,
                    categories[index],
                    selected: index == _selectedCategoryIndex,
                    onPress: () async {
                      // await _loadCategories(index);
                      _loadProducts(nextCategoryIndex: index);
                    },
                    onLongPress: index == 0
                        ? null
                        : () => _handleCategoryLongPress(index),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: System.isMobile ? 40 : 90),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: System.isMobile ? 20 : 90),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: System.isMobile ? 180 : 350,
                childAspectRatio: 0.9,
                crossAxisSpacing: System.isMobile ? 15 : 35,
                mainAxisSpacing: System.isMobile ? 20 : 45,
              ),
              itemCount: products.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final product = products[index];
                final card = ProductCard(
                  key: ValueKey(product.id),
                  product: product,
                  onDeleted: () => _loadProducts(
                    nextCategoryIndex: _selectedCategoryIndex,
                  ),
                );

                if (!canReorder) return card;

                return LongPressDraggable<int>(
                  data: index,
                  feedback: SizedBox(
                    width: System.isMobile ? 180 : 300,
                    height: (System.isMobile ? 180 : 350) * 0.9,
                    child: Opacity(opacity: 0.8, child: card),
                  ),
                  childWhenDragging: Opacity(opacity: 0.3, child: card),
                  child: DragTarget<int>(
                    onAcceptWithDetails: (details) =>
                        _handleReorder(details.data, index+1),
                    builder: (context, candidateData, rejectedData) => card,
                  ),
                );
              },
            ),
          ),
          SizedBox(height: System.isMobile ? 75 : 150),
          FooterSection(),
        ],
      ),
    );
  }

  Widget _category(
    BuildContext context,
    String title, {
    bool selected = false,
    VoidCallback? onPress,
    VoidCallback? onLongPress,

      }) {
    final theme = Theme.of(context).colorScheme;

    return ScaledContainer(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: System.isMobile ? 6 : 12),
        child: ElevatedButton(
          onPressed: onPress,
          onLongPress: onLongPress,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: selected
                ? theme.secondary
                : Colors.grey.shade200,
            padding:  EdgeInsets.symmetric(horizontal: System.isMobile ? 10 : 30, vertical: System.isMobile ? 10 : 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: System.isMobile ? 16 :26,
              color: selected
                  ? theme.onSecondary
                  : const Color(0xFF364153),
            ),
          ),
        ),
      ),
    );
  }
}
