import 'package:flex_printing/methods/products/fetch_categories.dart';
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
import 'delete_dialog.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<String> categories = ["All"];
  int _selectedCategoryIndex = 0;
  List<ProductRecord> products = [];
  int _loadRequestId = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts({int? nextCategoryIndex}) async {
    final requestId = ++_loadRequestId;

    if (nextCategoryIndex != null) {
      if (!mounted) return;
      setState(() {
        _selectedCategoryIndex = nextCategoryIndex;
      });
    }

    final names = await fetchCategoryNames();
    if (!mounted || requestId != _loadRequestId) return;

    final nextCategories = ["All", ...names];
    var selectedIndex = _selectedCategoryIndex;
    if (selectedIndex >= nextCategories.length) {
      selectedIndex = 0;
    }

    setState(() {
      categories = nextCategories;
      _selectedCategoryIndex = selectedIndex;
    });

    final fetchedProducts = await fetchProducts(
      category: nextCategories[selectedIndex],
    );
    if (!mounted || requestId != _loadRequestId) return;

    setState(() {
      products = fetchedProducts;
    });
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

  @override
  Widget build(BuildContext context) {
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
                    onPress: () {
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
            padding: EdgeInsets.symmetric(horizontal: System.isMobile ? 20 :90),
            child: GridView.builder(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: System.isMobile ? 180 : 350,
                    childAspectRatio: 0.9,
                    crossAxisSpacing: System.isMobile ? 15 : 35,
                    mainAxisSpacing: System.isMobile ? 20 :45
                ),
                itemCount: products.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index){

                  //final image = fetchProductImageBytes(products[index].firstImage?.path);

                  return ProductCard(
                    product: products[index],
                    onDeleted: () => _loadProducts(
                      nextCategoryIndex: _selectedCategoryIndex,
                    ),
                  );
                }
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
