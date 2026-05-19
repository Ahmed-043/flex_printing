import 'package:flex_printing/models/System/system.dart';
import 'package:flex_printing/shared_widgets/ui_helper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../methods/products/fetch_categories.dart';
import '../../methods/products/fetch_products.dart';
import '../../models/product/product_record.dart';
import '../products_page/product_card.dart';

class ProductsSection extends StatefulWidget {
  const ProductsSection({super.key});

  @override
  State<ProductsSection> createState() => _ProductsSectionState();
}

class _ProductsSectionState extends State<ProductsSection> {
  List<String> categories = ["All"];
  final int _selectedCategoryIndex = 0;
  List<ProductRecord> products = [];
  static const int _baseHomeCount = 6;
  int? _appliedLimit;
  bool _loadingProducts = false;
  int _loadRequestId = 0;

  @override
  void initState() {
    super.initState();
    _loadProducts(limit: _baseHomeCount);
  }

  int _computeColumnCount(double width) {
    final maxCrossAxisExtent = System.isMobile ? 180.0 : 350.0;
    final crossAxisSpacing = System.isMobile ? 15.0 : 35.0;
    final count = (width / (maxCrossAxisExtent + crossAxisSpacing)).ceil();
    return count < 1 ? 1 : count;
  }

  int _computeLimitForColumns(int columns) {
    final rows = (_baseHomeCount / columns).ceil();
    return rows * columns;
  }

  void _syncLimitForWidth(double width) {
    final columns = _computeColumnCount(width);
    final nextLimit = _computeLimitForColumns(columns);

    if (_appliedLimit == nextLimit || _loadingProducts) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _appliedLimit == nextLimit || _loadingProducts) return;
      _loadProducts(limit: nextLimit);
    });
  }

  Future<void> _loadProducts({required int limit}) async {
    final requestId = ++_loadRequestId;
    _loadingProducts = true;
    try {
      final names = await fetchCategoryNames();
      if (!mounted || requestId != _loadRequestId) return;

      final nextCategories = ["All", ...names];
      setState(() {
        categories = nextCategories;
      });

      final fetchedProducts = await fetchProducts(
        limit: limit,
        category: nextCategories[_selectedCategoryIndex],
      );

      if (!mounted || requestId != _loadRequestId) return;
      setState(() {
        _appliedLimit = limit;
        products = fetchedProducts;
      });
    } finally {
      if (mounted && requestId == _loadRequestId) {
        _loadingProducts = false;
      }
    }
  }

  @override
  void dispose() {
    _loadRequestId++;
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: .start,
        crossAxisAlignment: .center,
        children: [
          ...ourProducts(context),
        ],
      ),
    );
  }

  List<Widget> ourProducts(BuildContext context) {
    return [
      UiHelper.title(context: context, title: "OUR PRODUCTS"),
      SizedBox(height: System.isMobile ? 40 : 130),
      Container(
       // height: System.isMobile ? 600 : 750,
        margin: EdgeInsets.symmetric(horizontal: System.isMobile ? 35 : 90),
        child: LayoutBuilder(
          builder: (context, constraints) {
            _syncLimitForWidth(constraints.maxWidth);

            return GridView.builder(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: System.isMobile ? 180 : 350,
                    childAspectRatio: 0.95,
                    crossAxisSpacing: System.isMobile ? 15 : 35,
                    mainAxisSpacing: System.isMobile ? 20 :45
                ),
                itemCount: products.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index){
                  return ProductCard(
                    product: products[index],
                    onDeleted: () => _loadProducts(
                      limit: _appliedLimit ?? _baseHomeCount,
                    ),
                  );
                }
            );
          },
        ),
      ),
      SizedBox(height: System.isMobile ? 35 : 100),
      SizedBox(
        height: System.isMobile ? 35 : 70,
        width: System.isMobile ? 150 : 235,
        child: UiHelper.button(
          callback: () {
            context.go('/products');
          },
          color: Theme.of(context).colorScheme.secondaryContainer,
          filled: true,
          borderRadius: 75,
          rotation: 8,
          child: Text(
            "Load More",
            style: TextStyle(
              fontSize: System.isMobile ? 16 : 28,
              color: Theme.of(context).colorScheme.onSecondary,
              fontWeight: FontWeight.w200,
            ),
          ),
        ),
      ),
    ];
  }

}
