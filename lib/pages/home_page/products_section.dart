import 'package:flex_printing/models/system.dart';
import 'package:flex_printing/shared_widgets/ui_helper.dart';
import 'package:flutter/material.dart';

class ProductsSection extends StatelessWidget {
  const ProductsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2200,
      width: double.infinity,
      color: Theme.of(context).colorScheme.primary,
      child: Column(
        children: [
          ...ourProducts(context),
          SizedBox(height: 370,),
          ...materials(context)
        ],
      ),
    );
  }
  List<Widget> ourProducts(BuildContext context){
    return [
      Container(
        color: Theme.of(context).colorScheme.secondaryContainer,
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        child: Text(
          "Our Products",
          style: TextStyle(
            fontSize: System.isMobile ? 26 : 36,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ),
      SizedBox(height: System.isMobile ? 40 : 130,),
      Container(
        height: System.isMobile ? 600 : 750,
        margin: EdgeInsets.symmetric(horizontal: System.isMobile ? 35: 90),
        color: Colors.grey.withAlpha(100),
      ),
      SizedBox(height: System.isMobile ? 35 : 100,),
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
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.w200,
          ),
        ),
      ),
    ] ;
  }
  List<Widget> materials(BuildContext context){
    return [
      Container(
        color: Theme.of(context).colorScheme.secondaryContainer,
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        child: Text(
          "Material & Parts",
          style: TextStyle(
            fontSize: System.isMobile ? 26 : 36,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ),
      SizedBox(height: System.isMobile ? 28 : 55,),
      Text("All material and parts are available"),
      SizedBox(height: System.isMobile ? 30 : 75,),
      SizedBox(
        height: 485,
        width: double.infinity,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(10, (index) => Container(
              height: 485,
              width: 410,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(500),

              ),
              child: Center(
                child: Icon(Icons.image,color: Colors.grey,size: 100,),
              ),
            ))),
        ),
      )

    ];
  }
}
