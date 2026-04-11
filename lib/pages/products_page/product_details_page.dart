import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../methods/products/fetch_product_by_id.dart';
import '../../methods/products/fetch_product_specs.dart';
import '../../models/System/system.dart';
import '../../models/product/product_record.dart';
import '../../models/product/product_spec_record.dart';
import '../../shared_widgets/ui_helper.dart';

class ProductDetailsPage extends StatefulWidget {
  /// The product to display. May be [null] when the page is reached via direct
  /// URL (i.e. no [extra] was provided by go_router).
  final ProductRecord? product;
  final int? productId;

  const ProductDetailsPage({
    super.key,
    required this.product,
    this.productId,
  });

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  List<ProductSpecRecord> _specs = [];
  bool _loadingSpecs = true;
  String? _imageUrl;
  ProductRecord? _product;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    ProductRecord? product = widget.product;

    if (product == null && widget.productId != null) {
      product = await fetchProductById(widget.productId!);
    }

    if (product == null) {
      if (!mounted) return;
      setState(() {
        _product = null;
        _specs = const <ProductSpecRecord>[];
        _imageUrl = null;
        _loadingSpecs = false;
      });
      return;
    }

    // Resolve image URL from Supabase Storage.
    final path = product.firstImage?.path;
    String? imageUrl;
    if (path != null && path.isNotEmpty) {
      imageUrl = Supabase.instance.client.storage
          .from('flex-printing')
          .getPublicUrl(path);
    }

    // Fetch spec rows.
    final specs = await fetchProductSpecs(product.id);

    if (!mounted) return;
    setState(() {
      _product = product;
      _imageUrl = imageUrl;
      _specs = specs;
      _loadingSpecs = false;
    });
  }

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final product = _product;
    if (product == null) {
      if (_loadingSpecs) {
        return const Center(child: CircularProgressIndicator());
      }
      return _notFound(context);
    }

    final isCompact = System.isMobile || MediaQuery.of(context).size.width < 900;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: isCompact ? 30 : 60),

          // ── "PRODUCT DETAILS" label ───────────────────────────────────────
          UiHelper.title(context: context, title: 'PRODUCT DETAILS'),

          SizedBox(height: isCompact ? 30 : 60),

          // ── Hero section ─────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isCompact ? 20 : 90),
            child: isCompact ? _heroMobile(context) : _heroDesktop(context),
          ),

          SizedBox(height: isCompact ? 36 : 60),

          // ── Spec tables ───────────────────────────────────────────────────
          if (_loadingSpecs)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: CircularProgressIndicator(),
            )
          else if (_specs.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isCompact ? 20 : 90),
              child: isCompact
                  ? _specsMobile(context)
                  : _specsDesktop(context),
            ),

          SizedBox(height: isCompact ? 60 : 120),
        ],
      ),
    );
  }

  // ── Hero ───────────────────────────────────────────────────────────────────

  Widget _heroDesktop(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: _heroText(context, isCompact: false)),
        const SizedBox(width: 60),
        Expanded(child: _productImage(context, isCompact: false)),
      ],
    );
  }

  Widget _heroMobile(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _productImage(context, isCompact: true),
        const SizedBox(height: 30),
        _heroText(context, isCompact: true),
      ],
    );
  }

  Widget _heroText(BuildContext context, {required bool isCompact}) {
    final product = _product!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product name
        Text(
          product.name,
          style: TextStyle(
            fontSize: isCompact ? 32 : 56,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onPrimary,
            fontFamily: 'RedHatDisplay',
            height: 1.15,
          ),
        ),
        SizedBox(height: isCompact ? 12 : 20),
        // Description / subtitle
        Text(
          product.description,
          style: TextStyle(
            fontSize: isCompact ? 16 : 20,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF364153),
            height: 1.6,
          ),
        ),
        SizedBox(height: isCompact ? 28 : 44),
        // "Contact Us" button
        SizedBox(
          height: isCompact ? 48 : 58,
          child: UiHelper.button(
            callback: () => context.go('/contact'),
            color: Theme.of(context).colorScheme.secondary,
            filled: true,
            borderRadius: 75,
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 28 : 44,
            ),
            child: Text(
              'Contact Us',
              style: TextStyle(
                fontSize: isCompact ? 18 : 22,
                color: Theme.of(context).colorScheme.onSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _productImage(BuildContext context, {required bool isCompact}) {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(isCompact ? 20 : 30),
        ),
        clipBehavior: Clip.antiAlias,
        child: _imageUrl != null
            ? Image.network(_imageUrl!, fit: BoxFit.cover)
            : Center(
                child: Icon(
                  Icons.image_not_supported_rounded,
                  size: isCompact ? 50 : 80,
                  color: Theme.of(context)
                      .colorScheme
                      .onPrimary
                      .withAlpha(100),
                ),
              ),
      ),
    );
  }

  // ── Spec tables ────────────────────────────────────────────────────────────

  Widget _specsDesktop(BuildContext context) {
    final half = (_specs.length / 2).ceil();
    final left = _specs.sublist(0, half);
    final right = _specs.sublist(half);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _specTable(context, left)),
        const SizedBox(width: 30),
        Expanded(child: _specTable(context, right)),
      ],
    );
  }

  Widget _specsMobile(BuildContext context) {
    return _specTable(context, _specs);
  }

  Widget _specTable(BuildContext context, List<ProductSpecRecord> specs) {
    if (specs.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: List.generate(specs.length, (i) {
          final spec = specs[i];
          final isLast = i == specs.length - 1;
          final label = spec.key ?? '';
          final trimmedUnit = spec.unit.trim();
          final value = trimmedUnit.isNotEmpty
              ? '${spec.value} $trimmedUnit'
              : spec.value;
          return _specRow(
            context,
            label,
            value,
            isLast: isLast,
            isEven: i.isEven,
          );
        }),
      ),
    );
  }

  Widget _specRow(
    BuildContext context,
    String label,
    String value, {
    bool isLast = false,
    bool isEven = false,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isEven ? Colors.white : const Color(0xFFF9FAFB),
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: Color(0xFFE5E7EB)),
              ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF364153),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Not-found fallback ─────────────────────────────────────────────────────

  Widget _notFound(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 80),
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.onPrimary.withAlpha(80),
            ),
            const SizedBox(height: 20),
            Text(
              'Product not found',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'The product you are looking for does not exist\nor may have been removed.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: const Color(0xFF364153),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 48,
              child: UiHelper.button(
                callback: () => context.go('/products'),
                color: Theme.of(context).colorScheme.secondary,
                filled: true,
                borderRadius: 75,
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Back to Products',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
