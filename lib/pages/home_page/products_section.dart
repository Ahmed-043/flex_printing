import 'package:flex_printing/models/System/system.dart';
import 'package:flex_printing/shared_widgets/ui_helper.dart';
import 'package:flutter/material.dart';

class ProductsSection extends StatelessWidget {
  const ProductsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: .start,
        crossAxisAlignment: .center,
        children: [
          ...ourProducts(context),
          SizedBox(height: System.isMobile ? 150 : 370),
          ...materials(context),
        ],
      ),
    );
  }

  List<Widget> ourProducts(BuildContext context) {
    return [
      UiHelper.title(context: context, title: "Our Products"),
      SizedBox(height: System.isMobile ? 40 : 130),
      Container(
        height: System.isMobile ? 600 : 750,
        margin: EdgeInsets.symmetric(horizontal: System.isMobile ? 35 : 90),
        color: Colors.grey.withAlpha(100),
      ),
      SizedBox(height: System.isMobile ? 35 : 100),
      UiHelper.button(
        callback: () {},
        color: Theme.of(context).colorScheme.secondaryContainer,
        filled: true,
        borderRadius: 75,
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        child: Text(
          "Load More",
          style: TextStyle(
            fontSize: System.isMobile ? 12 : 28,
            color: Theme.of(context).colorScheme.onSecondary,
            fontWeight: FontWeight.w200,
          ),
        ),
      ),
    ];
  }

  List<Widget> materials(BuildContext context) {
    return [
      UiHelper.title(context: context, title: "Material & Parts"),
      SizedBox(height: System.isMobile ? 20 : 50),
      Text(
        "All material and parts${System.isMobile ? "\n" : " "}are available",
        textAlign: .center,
        style: TextStyle(
          fontSize: System.isMobile ? 26 : 36,
          color: Theme.of(context).colorScheme.secondaryContainer,

        ),
      ),
      SizedBox(height: System.isMobile ? 30 : 75),
      SizedBox(

        width: double.infinity,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              10,
              (index) => Container(
                height: System.isMobile ? 185 : 485,
                width: System.isMobile ? 155 : 410,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(500),
                ),
                child: Center(
                  child: Icon(
                    Icons.image,
                    color: Colors.grey,
                    size: System.isMobile ? 30 : 80,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ];
  }
}
