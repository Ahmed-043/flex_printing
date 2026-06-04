import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../methods/products/fetch_product_by_id.dart';
import '../../methods/products/fetch_product_images.dart';
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
  final Uint8List? initialImageBytes;

  const ProductDetailsPage({
    super.key,
    required this.product,
    this.productId,
    this.initialImageBytes,
  });

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  List<ProductSpecRecord> _specs = [];
  bool _loadingSpecs = true;
  List<String> _imageUrls = [];
  ProductRecord? _product;
  Uint8List? _heroImageBytes;
  final PageController _imagePageController = PageController();
  int _currentImageIndex = 0;
  bool _showLeftArrow = false;
  bool _showRightArrow = false;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _heroImageBytes = widget.initialImageBytes;
    _loadingSpecs = true;
    _loadData();
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    ProductRecord? product = widget.product;

    if (product == null && widget.productId != null) {
      product = await fetchProductById(widget.productId!);
    }

    if (!mounted) return;

    if (product == null) {
      setState(() {
        _product = null;
        _specs = const <ProductSpecRecord>[];
        _imageUrls = const <String>[];
        _loadingSpecs = false;
      });
      return;
    }

    // Only update product state if it changed or wasn't set in initState
    if (_product == null || _product!.id != product.id) {
      setState(() {
        _product = product;
        _heroImageBytes = widget.initialImageBytes;
        _currentImageIndex = 0;
      });
    }

    final imageRecords = await fetchProductImages(product.id);
    final imageUrls = imageRecords
        .map((image) => image.path)
        .whereType<String>()
        .where((path) => path.trim().isNotEmpty)
        .map((path) => Supabase.instance.client.storage
            .from('flex-printing')
            .getPublicUrl(path))
        .toList(growable: false);

    final displayImageUrls =
        _heroImageBytes != null && imageUrls.isNotEmpty
            ? imageUrls.sublist(1)
            : imageUrls;

    // Fetch spec rows.
    final specs = await fetchProductSpecs(product.id);

    if (!mounted) return;
    setState(() {
      _imageUrls = displayImageUrls;
      _specs = specs;
      _loadingSpecs = false;
    });
  }

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final product = _product;
    final theme = Theme.of(context).colorScheme;

    Widget heroText({required bool isCompact}) {
      final product = _product!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product name
          Hero(
            tag: 'product-name-${widget.product?.id}',
            child: Material(
              color: Colors.transparent,
              child: Text(
                product.name,
                style: TextStyle(
                  fontSize: isCompact ? 32 : 56,
                  fontWeight: FontWeight.w800,
                  color: theme.onPrimary,
                  fontFamily: 'RedHatDisplay',
                  height: 1.15,
                ),
              ),
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
              color: theme.secondary,
              filled: true,
              borderRadius: 75,
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 28 : 44,
              ),
              child: Text(
                'Contact Us',
                style: TextStyle(
                  fontSize: isCompact ? 18 : 22,
                  color: theme.onSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      );
    }

    Widget navButton({
      required IconData icon,
      required VoidCallback onPressed,
    }) {
      return Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          highlightColor:  Colors.transparent,
          focusColor:  Colors.transparent,
          hoverColor:  Colors.transparent,
          splashColor:  Colors.transparent,
          child: Icon(icon, color: Theme.of(context).colorScheme.onPrimary.withAlpha(80), size: 85),
        ),
      );
    }

    Widget productImage({required bool isCompact}) {
      final hasInlineFirstImage = _heroImageBytes != null;
      final totalImageCount = _imageUrls.length + (hasInlineFirstImage ? 1 : 0);
      final hasPrevious = _currentImageIndex > 0;
      final hasNext = _currentImageIndex < totalImageCount - 1;

      return Hero(
        tag: 'product-image-${widget.product?.id}',
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: Material(
            color: Colors.transparent,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return MouseRegion(
                  onHover: (event) {
                    final x = event.localPosition.dx;
                    final half = constraints.maxWidth / 4;
                    setState(() {
                      _showLeftArrow = x < half;
                      _showRightArrow = x >= half*3;
                    });
                  },
                  onExit: (_) => setState(() {
                    _showLeftArrow = false;
                    _showRightArrow = false;
                  }),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.surfaceContainer,
                      borderRadius: BorderRadius.circular(isCompact ? 20 : 30),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: totalImageCount > 0
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              // Main Image Swiper
                              ScrollConfiguration(
                                behavior: const _MouseDragScrollBehavior(),
                                child: PageView.builder(
                                  controller: _imagePageController,
                                  itemCount: totalImageCount,
                                  onPageChanged: (index) {
                                    if (!mounted) return;
                                    setState(() => _currentImageIndex = index);
                                  },
                                  itemBuilder: (context, index) {
                                    if (hasInlineFirstImage && index == 0) {
                                      final bytes = _heroImageBytes!;
                                      return InkWell(
                                        onTap: () {
                                          showImageBytes(bytes);
                                        },
                                        child: Image.memory(
                                          bytes,
                                          fit: BoxFit.cover,
                                          gaplessPlayback: true,
                                          filterQuality: FilterQuality.low, // Match low quality during flight/initial load
                                          // EXACT MATCH of cacheWidth from ProductCard to ensure zero-decode cache hit
                                          cacheWidth: (System.isMobile ? 600 : 1000) *
                                              (MediaQuery.of(context).devicePixelRatio).round(),
                                          errorBuilder: (_, _, _) => Center(
                                            child: Icon(
                                              Icons.broken_image_rounded,
                                              size: isCompact ? 50 : 80,
                                              color: theme.onPrimary.withAlpha(100),
                                            ),
                                          ),
                                        ),
                                      );
                                    }

                                    final urlIndex =
                                        hasInlineFirstImage ? index - 1 : index;
                                    final imageUrl = _imageUrls[urlIndex];
                                    return InkWell(
                                      onTap: () {
                                        showImageUrl(imageUrl);
                                      },
                                      child: Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) => Center(
                                          child: Icon(
                                            Icons.broken_image_rounded,
                                            size: isCompact ? 50 : 80,
                                            color: theme.onPrimary.withAlpha(100),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),

                              if(!System.isMobile)
                              ...[// Animated Left Arrow
                              AnimatedPositioned(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutCubic,
                                left: (_showLeftArrow && hasPrevious) ? 16 : -60,
                                top: 0,
                                bottom: 0,
                                child: Center(
                                  child: navButton(
                                    icon: Icons.chevron_left_rounded,
                                    onPressed: () =>
                                        _imagePageController.previousPage(
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    ),
                                  ),
                                ),
                              ),

                              // Animated Right Arrow
                              AnimatedPositioned(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutCubic,
                                right: (_showRightArrow && hasNext) ? 16 : -60,
                                top: 0,
                                bottom: 0,
                                child: Center(
                                  child: navButton(
                                    icon: Icons.chevron_right_rounded,
                                    onPressed: () => _imagePageController.nextPage(
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    ),
                                  ),
                                ),
                              ),
                              ],

                              if (totalImageCount > 1)
                                Positioned(
                                  right: 12,
                                  bottom: 12,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withAlpha(110),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      child: Text(
                                        '${_currentImageIndex + 1}/$totalImageCount',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          )
                        : Center(
                            child: Icon(
                              Icons.image_not_supported_rounded,
                              size: isCompact ? 50 : 80,
                              color: theme.onPrimary.withAlpha(100),
                            ),
                          ),
                  ),
                );
              },
            ),
          ),
        ),
      );
    }

    Widget heroDesktop() {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: heroText(isCompact: false)),
          const SizedBox(width: 60),
          Expanded(child: productImage(isCompact: false)),
        ],
      );
    }

    Widget heroMobile() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          productImage(isCompact: true),
          const SizedBox(height: 30),
          heroText(isCompact: true),
        ],
      );
    }

    Widget specRow(
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

    Widget specTable(List<ProductSpecRecord> specs) {
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
            return specRow(
              label,
              value,
              isLast: isLast,
              isEven: i.isEven,
            );
          }),
        ),
      );
    }

    Widget specsDesktop() {
      final half = (_specs.length / 2).ceil();
      final left = _specs.sublist(0, half);
      final right = _specs.sublist(half);
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: specTable(left)),
          const SizedBox(width: 30),
          Expanded(child: specTable(right)),
        ],
      );
    }

    Widget specsMobile() {
      return specTable(_specs);
    }

    Widget notFound() {
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
                color: theme.onPrimary.withAlpha(80),
              ),
              const SizedBox(height: 20),
              Text(
                'Product not found',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: theme.onPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'The product you are looking for does not exist\nor may have been removed.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF364153),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 48,
                child: UiHelper.button(
                  callback: () => context.go('/products'),
                  color: theme.secondary,
                  filled: true,
                  borderRadius: 75,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Back to Products',
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.onSecondary,
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

    if (product == null) {
      if (_loadingSpecs) {
        return const Center(child: CircularProgressIndicator());
      }
      return notFound();
    }

    final isCompact = System.isMobile || MediaQuery.of(context).size.width < 900;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: isCompact ? 30 : 60),

          // ── "PRODUCT DETAILS" label ───────────────────────────────────────
          Hero(
              tag: "product_title",
              child: Material(
                  color: Colors.transparent,
                  child: UiHelper.title(context: context, title: 'PRODUCT DETAILS'))),

          SizedBox(height: isCompact ? 30 : 60),

          // ── Hero section ─────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isCompact ? 20 : 90),
            child: isCompact ? heroMobile() : heroDesktop(),
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
              child: isCompact ? specsMobile() : specsDesktop(),
            ),

          SizedBox(height: isCompact ? 60 : 120),
        ],
      ),
    );
  }
  void _showImageDialog(Widget image) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                color: Colors.transparent,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height - 100,
              ),
              child: InteractiveViewer(
                clipBehavior: Clip.none,
                minScale: 1.0,
                maxScale: 5.0,
                child: image,
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showImageUrl(String imageUrl) {
    _showImageDialog(
      Image.network(
        imageUrl,
        fit: BoxFit.contain,
      ),
    );
  }

  void showImageBytes(Uint8List imageBytes) {
    _showImageDialog(
      Image.memory(
        imageBytes,
        fit: BoxFit.contain,
      ),
    );
  }

}

class _MouseDragScrollBehavior extends MaterialScrollBehavior {
  const _MouseDragScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.invertedStylus,
        PointerDeviceKind.trackpad,
      };
}
