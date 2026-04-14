import 'dart:async';
import 'dart:typed_data';

import 'package:flex_printing/models/System/system.dart';
import 'package:flex_printing/models/product/product_record.dart';
import 'package:flex_printing/services/product_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'delete_dialog.dart';

class ProductCard extends StatefulWidget {
  final ProductRecord product;
  final VoidCallback? onDeleted;

  const ProductCard({super.key, required this.product, this.onDeleted});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  Uint8List? _imageBytes;
  bool _isLoading = false;
  int _requestId = 0;

  Future<void> _handleLongPress() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final connected = await ProductService.isConnected();
    if (!connected || !mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => DeleteProductDialog(productName: widget.product.name),
    );

    if (confirmed != true || !mounted) return;

    try {
      await ProductService.deleteProduct(widget.product.id);
      if (!mounted) return;

      widget.onDeleted?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.product.name} deleted successfully.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ProductService.toUserMessage(e, action: 'delete product'),
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(covariant ProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.product.firstImage?.path != widget.product.firstImage?.path) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    final path = widget.product.firstImage?.path;
    final requestId = ++_requestId;

    if (path == null || path.isEmpty) {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _imageBytes = null;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    Uint8List? bytes;
    try {
      bytes = await Supabase.instance.client.storage
          .from('flex-printing')
          .download(path);
    } catch (_) {
      bytes = null;
    }

    if (!mounted || requestId != _requestId) return;
    setState(() {
      _imageBytes = bytes;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go(
        '/products/${widget.product.id}',
        extra: widget.product,
      ),
      onLongPress: _handleLongPress,
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
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainer
                        .withAlpha(150),
                  ),
                  child: (_imageBytes == null || _imageBytes!.isEmpty)
                      ? Center(
                          child: _isLoading
                              ? SizedBox(
                                  width: System.isMobile ? 24 : 36,
                                  height: System.isMobile ? 24 : 36,
                                  child: const CircularProgressIndicator(
                                      strokeWidth: 2),
                                )
                              : Icon(
                                  Icons.image_not_supported_rounded,
                                  size: System.isMobile ? 35 : 80,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimary
                                      .withAlpha(100),
                                ),
                        )
                      : Image.memory(
                          _imageBytes!,
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.low,
                        ),
                ),
              ),
            ),
            Expanded(
              child: Text(
                widget.product.name,
                overflow: TextOverflow.fade,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: System.isMobile ? 16 : 35,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

