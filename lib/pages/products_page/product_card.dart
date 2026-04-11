import 'package:flex_printing/models/System/system.dart';
import 'package:flex_printing/models/product/product_record.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductCard extends StatefulWidget {
  final ProductRecord product;
  const ProductCard({super.key, required this.product});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final path = widget.product.firstImage?.path;

    if (!mounted) return;

    setState(() {
      _imageUrl = (path == null || path.isEmpty)
          ? null
          : Supabase.instance.client.storage
                .from('flex-printing')
                .getPublicUrl(path);
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("ProductCard build: ${widget.product.id}, imageUrl: $_imageUrl");
    return InkWell(
      onTap: () => context.go(
        '/products/${widget.product.id}',
        extra: widget.product,
      ),
      borderRadius: BorderRadius.circular(System.isMobile ? 16 : 25),
      child: Semantics(
        label: 'View ${widget.product.name} details',
        button: true,
        child: Column(
      children: [
        Expanded(
          flex: 2,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(System.isMobile ? 16 : 25),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
              ),
              child: _imageUrl == null
                  ? Center(
                      child: Icon(
                        Icons.image_not_supported_rounded,
                        size: System.isMobile ? 35 : 80,
                        color: Theme.of(context).colorScheme.onPrimary.withAlpha(100),
                      ),
                    )
                  : Image.network(_imageUrl!, fit: BoxFit.cover),
            ),
          ),
        ),
        Expanded(
          child: Text(
            widget.product.name,
            overflow: TextOverflow.fade,
            textAlign: .center,
            style: TextStyle(
              fontSize: System.isMobile ? 25 : 35,
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
