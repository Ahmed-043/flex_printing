import 'dart:typed_data';

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
  late final Future<Uint8List?> _imageBytesFuture;

  @override
  void initState() {
    super.initState();
    _imageBytesFuture = _loadImageBytes();
  }

  Future<Uint8List?> _loadImageBytes() async {
    final path = widget.product.firstImage?.path;
    if (path == null || path.isEmpty) {
      return null;
    }

    try {
      return await Supabase.instance.client.storage
          .from('flex-printing')
          .download(path);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
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
          flex: 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(System.isMobile ? 16 : 25),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer.withAlpha(150),
              ),
              child: FutureBuilder<Uint8List?>(
                future: _imageBytesFuture,
                builder: (context, snapshot) {
                  final imageBytes = snapshot.data;
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (imageBytes == null || imageBytes.isEmpty) {
                    return Center(
                      child: Icon(
                        Icons.image_not_supported_rounded,
                        size: System.isMobile ? 35 : 80,
                        color: Theme.of(context).colorScheme.onPrimary.withAlpha(100),
                      ),
                    );
                  }

                  return Image.memory(
                    imageBytes,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.low,
                    gaplessPlayback: true,
                  );
                },
              ),
            ),
          ),
        ),
        Expanded(
          child: Text(
            widget.product.name,
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
