import 'package:flex_printing/methods/products/fetch_categories.dart';
import 'package:flex_printing/pages/products_page/product_card.dart';
import 'package:flex_printing/shared_widgets/ui_helper.dart';
import 'package:flutter/material.dart';

import '../../methods/products/fetch_products.dart';
import '../../models/System/system.dart';
import '../../models/product/product_record.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<String> categories = ["All"];
  int _selectedCategoryIndex = 0;
  List<ProductRecord> products = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    await fetchCategoryNames().then((names) {
      setState(() {
        categories = ["All", ...names];
      });
    });
    final fetchedProducts = await fetchProducts(category: categories[_selectedCategoryIndex]);
    setState(() {
      products = fetchedProducts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: System.isMobile ? 40 : 100),
          UiHelper.title(context: context, title: "Our Products"),
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
                    onPressed: () {
                      setState(() {
                        _selectedCategoryIndex = index;
                      });
                      _loadProducts();
                    },
                  )
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
                    childAspectRatio: 1,
                    crossAxisSpacing: System.isMobile ? 15 : 35,
                    mainAxisSpacing: System.isMobile ? 20 :45
                ),
                itemCount: products.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index){
                  return ProductCard(product: products[index]);
                }
            ),
          ),
          SizedBox(height: System.isMobile ? 75 : 150),
        ],
      ),
    );
  }

  Widget _category(
    BuildContext context,
    String title, {
    bool selected = false,
    VoidCallback? onPressed,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: System.isMobile ? 6 : 12),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: selected
              ? Theme.of(context).colorScheme.secondary
              : Colors.grey.shade200,
          padding:  EdgeInsets.symmetric(horizontal: System.isMobile ? 10 : 30, vertical: System.isMobile ? 10 : 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: System.isMobile ? 16 :26,
            color: selected
                ? Theme.of(context).colorScheme.onSecondary
                : const Color(0xFF364153),
          ),
        ),
      ),
    );
  }
}
