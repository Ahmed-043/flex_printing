import 'package:flex_printing/models/System/system.dart';
import 'package:flex_printing/models/product/product_record.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
class ProductCard extends StatelessWidget {
  final ProductRecord product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final path = product.firstImage?.path;
    final imageUrl = (path == null || path.isEmpty)
        ? null
        : Supabase.instance.client.storage.from('flex-printing').getPublicUrl(path);

    return InkWell(
      onTap: () => context.go(
        '/products/${product.id}',
        extra: product,
      ),
      borderRadius: BorderRadius.circular(System.isMobile ? 16 : 25),
      child: Semantics(
        label: 'View ${product.name} details',
        button: true,
        child: Column(
      children: [
        Expanded(
          flex: 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(System.isMobile ? 16 : 25),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
              ),
              child: imageUrl == null
                  ? Center(
                      child: Icon(
                        Icons.image_not_supported_rounded,
                        size: System.isMobile ? 35 : 80,
                        color: Theme.of(context).colorScheme.onPrimary.withAlpha(100),
                      ),
                    )
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.low,
                    ),
            ),
          ),
        ),
        Expanded(
          child: Text(
            product.name,
            overflow: TextOverflow.fade,
            textAlign: .center,
            style: TextStyle(
              fontSize: System.isMobile ? 16 : 35,
              fontWeight: .w400,
              color: Theme.of(context).colorScheme.onPrimary,),
          ),
        ),
      ],
      ),
      ),
    );
  }
}
