import 'package:flex_printing/shared_widgets/ui_helper.dart';
import 'package:flutter/material.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .center,
      children: [
        SizedBox(height: 190),
        UiHelper.title(context: context, title: "Our Products"),
        SizedBox(height: 90),
        Row(
          mainAxisAlignment: .center,
          children: [
            _category(context,"All",selected: true),
            SizedBox(width: 20),
            _category(context,"Sublimation"),
            SizedBox(width: 20),
            _category(context,"DTF"),
            SizedBox(width: 20),
          ],
        )

      ],
    );
  }
 Widget _category(BuildContext context,String title,{bool selected = false}){
    return ElevatedButton(
      onPressed: (){},

      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: selected ? Theme.of(context).colorScheme.secondary : Colors.grey.shade200,
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      ), child: Text(title,
      style: TextStyle(
          fontSize: 26,
          color: selected ? Theme.of(context).colorScheme.onSecondary : Color(0xFF364153)),),
    );
  }
}
