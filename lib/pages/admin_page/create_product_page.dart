import '../../methods/products/fetch_product_images.dart';
import '../../methods/products/fetch_product_specs.dart';
import '../../models/product/product_record.dart';
import '../../services/image_cache.dart';
import '../../shared_widgets/category_drowdown.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../methods/products/fetch_categories.dart';
import '../../models/System/system.dart';
import '../../models/product/product.dart';
import '../../models/product/product_image.dart';
import '../../models/product/product_spec.dart';
import '../../services/product_service.dart';
import '../../shared_widgets/admin_manager_widgets.dart';
import '../../shared_widgets/product_image_upload_box.dart';
import '../../shared_widgets/ui_helper.dart';

/// Admin page for creating a new [Product].
///
/// Persists data to Supabase via [ProductService].
/// Layout is responsive: two-column on desktop/tablet, single-column on
/// mobile (controlled by [System.isMobile] and screen-width breakpoint).
class CreateProductPage extends StatefulWidget {
  final ProductRecord? product;
  const CreateProductPage({super.key, this.product});

  @override
  State<CreateProductPage> createState() => _CreateProductPageState();
}

class _CreateProductPageState extends State<CreateProductPage> {

  // ── form state ────────────────────────────────────────────────────────────

  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _categoryController = TextEditingController();

  /// Spec rows – each entry holds three controllers: key, value, unit.
  final List<_SpecRow> _specRows = [];

  int? _pendingFocusSpecRowIndex;

  /// Accumulated product images (original + compressed bytes).
  final List<ProductImage> _images = [];

  /// Category names loaded from Supabase (for autocomplete).
  List<String> _categoryNames = [];

  bool _isLoadingCategories = false;
  String? _categoriesLoadError;

  /// True while [_onSave] is running (prevents double-submit).
  bool _isSaving = false;

  bool _isInitialLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    if (widget.product != null) {
      _loadProductData();
    }
  }

  Future<void> _loadProductData() async {
    setState(() => _isInitialLoading = true);
    try {
      final p = widget.product!;
      _nameController.text = p.name;
      _descController.text = p.description;

      if (p.category != null) {
        final catName = await ProductService.fetchCategoryNameById(p.category!);
        if (catName != null) {
          _categoryController.text = catName;
        }
      }

      // Fetch specs
      final specs = await fetchProductSpecs(p.id);
      for (final s in specs) {
        final row = _SpecRow();
        row.keyCtrl.text = s.key ?? '';
        row.valueCtrl.text = s.value;
        row.unitCtrl.text = s.unit;
        _specRows.add(row);
      }

      // Fetch images
      final images = await fetchProductImages(p.id);
      for (final img in images) {
        final path = img.path;
        if (path == null) continue;
        final bytes = await ImageCacheService().getImage(path);
        if (bytes != null) {
          _images.add(ProductImage(
            fileName: img.alt,
            originalBytes: bytes,
            path: path,
          ));
        }
      }
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Error loading product data: $e');
    } finally {
      if (mounted) setState(() => _isInitialLoading = false);
    }
  }

  void _showAdminLandingPage() {
    context.go('/admin');
  }

  Future<void> _loadCategories() async {
    debugPrint('Loading categories from Supabase...');
    if (mounted) {
      setState(() {
        _isLoadingCategories = true;
        _categoriesLoadError = null;
      });
    }
    try {
      final categoryNames = await fetchCategoryNames();
      if (mounted) {
        _categoryNames = categoryNames;

        setState(() {
          debugPrint('Loaded categories: ${_categoryNames.join(', ')}');
          _categoriesLoadError = null;
        });
      }
    } catch (e) {
      debugPrint('AdminPage: failed to load categories: $e');
      if (mounted) {
        setState(() {
          _categoriesLoadError =
          'Could not load categories from Supabase. You can still type a new category and save.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCategories = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _categoryController.dispose();
    for (final row in _specRows) {
      row.dispose();
    }
    super.dispose();
  }

  void _requestFocusSpecKey(int index) {
    if (!mounted) return;
    if (index < 0 || index >= _specRows.length) return;
    FocusScope.of(context).requestFocus(_specRows[index].keyFocus);
  }

  void _requestFocusSpecValue(int index) {
    if (!mounted) return;
    if (index < 0 || index >= _specRows.length) return;
    FocusScope.of(context).requestFocus(_specRows[index].valueFocus);
  }

  void _requestFocusSpecUnit(int index) {
    if (!mounted) return;
    if (index < 0 || index >= _specRows.length) return;
    FocusScope.of(context).requestFocus(_specRows[index].unitFocus);
  }

  // ── spec helpers ──────────────────────────────────────────────────────────

  void _addSpec() {
    setState(() => _specRows.add(_SpecRow()));
  }

  void _ensureSpecRow(int index) {
    if (index < 0) return;
    if (index < _specRows.length) return;

    setState(() {
      while (_specRows.length <= index) {
        _specRows.add(_SpecRow());
      }
    });
  }

  void _focusSpecKeyAfterBuild(int index) {
    _pendingFocusSpecRowIndex = index;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final i = _pendingFocusSpecRowIndex;
      _pendingFocusSpecRowIndex = null;
      if (i == null) return;
      _requestFocusSpecKey(i);
    });
  }

  void _onSpecKeySubmitted(int index) {
    _requestFocusSpecValue(index);
  }

  void _onSpecValueSubmitted(int index) {
    _requestFocusSpecUnit(index);
  }

  void _onSpecUnitSubmitted(int index) {
    final nextIndex = index + 1;
    final needsNewRow = nextIndex >= _specRows.length;
    if (needsNewRow) {
      _ensureSpecRow(nextIndex);
      _focusSpecKeyAfterBuild(nextIndex);
    } else {
      _requestFocusSpecKey(nextIndex);
    }
  }

  void _removeSpec(int index) {
    setState(() {
      _specRows[index].dispose();
      _specRows.removeAt(index);
    });
  }

  // ── image helpers ─────────────────────────────────────────────────────────

  void _addImage(ProductImage img) {
    setState(() => _images.add(img));
  }

  void _removeImage(int index) {
    setState(() => _images.removeAt(index));
  }

  void _reorderImages(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _images.removeAt(oldIndex);
      _images.insert(newIndex, item);
    });
  }

  // ── save / collect ────────────────────────────────────────────────────────

  Product _collectProduct() {
    return Product(
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      category: _categoryController.text.trim(),
      sortOrder: widget.product?.sortOrder ?? 0,
      specs: _specRows
          .map(
            (r) => ProductSpec(
          key: r.keyCtrl.text.trim(),
          value: r.valueCtrl.text.trim(),
          unit: r.unitCtrl.text.trim(),
        ),
      )
          .toList(),
      images: List.unmodifiable(_images),
    );
  }

  Future<void> _onSave() async {
    if (_isSaving) return;

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showError('Product name is required.');
      return;
    }

    setState(() => _isSaving = true);

    final product = _collectProduct();

    try {
      if (widget.product != null) {
        await ProductService.updateProduct(widget.product!.id, product);
        if (!mounted) return;
        _showSuccess('Product Updated Successfully');
      } else {
        final productId = await ProductService.createProduct(product);
        if (!mounted) return;
        _clearForm();
        _showSuccess(
          'Product Saved, ID $productId',
        );
      }
      // Refresh category list so a newly added category shows up next time
      await _loadCategories();
    } catch (e) {
      if (!mounted) return;
      _showError(
        '${ProductService.toUserMessage(e, action: widget.product != null ? 'update product' : 'save product')}\n\nDetails: ${e.toString()}',
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _clearForm() {
    _nameController.clear();
    _descController.clear();
    _categoryController.clear();
    setState(() {
      for (final row in _specRows) {
        row.dispose();
      }
      _specRows.clear();
      _images.clear();
    });
  }

  void _showSuccess(String message) {
    final theme = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,style: TextStyle(color: theme.onSecondary),),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _showError(String message) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error_outline,
                color: Theme.of(ctx).colorScheme.error),
            const SizedBox(width: 8),
            const Text('Error'),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(message),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return notSignedInView(context);
    return _createProductView(context);
  }


  Widget _createProductView(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = System.isMobile || screenWidth < 900;
    final theme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 20 : 60,
        vertical: 40,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _showAdminLandingPage,
                  icon:  Icon(Icons.arrow_back,color: theme.onPrimary),
                  label: Text('Back to Admin',style: TextStyle(color: theme.onPrimary),),
                ),
              ),
              const SizedBox(height: 8),

              // ── page title ──────────────────────────────────────────────
              Center(
                child: UiHelper.title(
                  context: context,
                  title: widget.product != null ? 'Edit Product' : 'Create Product',
                ),
              ),
              SizedBox(height: isCompact ? 32 : 48),

              if (_isInitialLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: CircularProgressIndicator(),
                  ),
                )
              else ...[
                // ── main body ───────────────────────────────────────────────
                isCompact ? _singleColumn(context) : _twoColumns(context),

                SizedBox(height: isCompact ? 32 : 48),

                // ── save button ─────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: UiHelper.button(
                    callback: _isSaving ? () {} : _onSave,
                    filled: true,
                    color: theme.secondaryContainer,
                    borderRadius: 14,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    elevation: 2,
                    child: _isSaving
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: theme.primary,
                            ),
                          )
                        : Text(
                            widget.product != null ? 'Update Product' : 'Save Product',
                            style: TextStyle(
                              fontSize: 18,
                              color: theme.onSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                ),
              ],

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  // ── two-column layout (desktop/tablet) ────────────────────────────────────

  Widget _twoColumns(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 5, child: _detailsSection(context)),
        const SizedBox(width: 40),
        Expanded(flex: 6, child: _imagesSection(context)),
      ],
    );
  }

  // ── single-column layout (mobile) ─────────────────────────────────────────

  Widget _singleColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _detailsSection(context),
        const SizedBox(height: 40),
        _imagesSection(context),
      ],
    );
  }

  // ── details section (name + description + specs) ──────────────────────────

  Widget _detailsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(context, 'Product Details'),
        const SizedBox(height: 20),

        // Product name
        UiHelper.inputField(
          context: context,
          label: 'Product Name',
          requiredField: true,
          hint: 'e.g. UV Flatbed Printer',
          controller: _nameController,
        ),
        const SizedBox(height: 20),

        // Description
        UiHelper.inputField(
          context: context,
          label: 'Description',
          requiredField: false,
          hint: 'Describe the product…',
          maxLines: 5,
          keyboardType: TextInputType.multiline,
          controller: _descController,
        ),
        const SizedBox(height: 32),

        // Specifications
        _specsSection(context),
      ],
    );
  }

  // ── specifications section ────────────────────────────────────────────────

  Widget _specsSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(context, 'Specifications'),
        const SizedBox(height: 12),

        if (_specRows.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'No specifications added yet.',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 15,
              ),
            ),
          ),

        // Spec rows
        ..._specRows
            .asMap()
            .entries
            .map(
              (entry) => _specRowWidget(context, entry.key, entry.value),
        ),

        const SizedBox(height: 12),

        // "Add Spec" button
        OutlinedButton.icon(
          onPressed: _addSpec,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: theme.colorScheme.secondary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          icon: Icon(Icons.add, color: theme.colorScheme.secondary),
          label: Text(
            'Add Spec',
            style: TextStyle(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _specRowWidget(BuildContext context, int index, _SpecRow row) {
    return Row(
      children: [
        // Key
        Expanded(
          flex: 3,
          child: SizedBox(
            height: 50,
            child: UiHelper.compactTextField(
              controller: row.keyCtrl,
              focusNode: row.keyFocus,
              hint: 'Spec Name',
              context: context,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _onSpecKeySubmitted(index),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Value
        Expanded(
          flex: 3,
          child: SizedBox(
            height: 50,

            child: UiHelper.compactTextField(
              controller: row.valueCtrl,
              focusNode: row.valueFocus,
              hint: 'Value',
              context: context,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _onSpecValueSubmitted(index),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Unit (optional)
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 50,
            child: UiHelper.compactTextField(
              controller: row.unitCtrl,
              focusNode: row.unitFocus,
              hint: 'Unit (opt.)',
              context: context,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _onSpecUnitSubmitted(index),
            ),
          ),
        ),
        const SizedBox(width: 6),
        // Delete
        IconButton(
          onPressed: () => _removeSpec(index),
          icon: const Icon(Icons.delete_outline),
          color: Colors.redAccent,
          tooltip: 'Remove spec',
        ),
      ],
    );
  }

  // ── images section ────────────────────────────────────────────────────────

  Widget _imagesSection(BuildContext context) {
    final isCompact = System.isMobile ||
        MediaQuery
            .of(context)
            .size
            .width < 900;
    final theme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(context, 'Category'),
        const SizedBox(height: 12),
        if(!_isLoadingCategories)
        CategoryDropdownTextField(
          controller: _categoryController,
          categories: _categoryNames,
        ),
        if (_isLoadingCategories)
           Center(
             child: Padding(
              padding: EdgeInsets.only(top: 8),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2,color: theme.secondary,),
              ),
                       ),
           ),
        if (_categoriesLoadError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _categoriesLoadError!,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                  ),
                ),
                TextButton(
                  onPressed: _isLoadingCategories ? null : _loadCategories,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        const SizedBox(height: 32),
        _sectionHeader(context, 'Product Images'),
        const SizedBox(height: 8),
        Text(
          'Add files one at a time. Drag & drop or click to upload.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 16),

        // Previews
        if (_images.isNotEmpty) ...[
          _imagePreviewsGrid(context, isCompact),
          const SizedBox(height: 16),
        ],

        // Upload box
        SizedBox(
          height: 150,
          child: ProductImageUploadBox(onImageAdded: _addImage),
        ),
      ],
    );
  }

  Widget _imagePreviewsGrid(BuildContext context, bool isCompact) {
    final thumbSize = isCompact ? 90.0 : 110.0;

    return SizedBox(
      height: thumbSize + 32, // thumb + reorder handle space
      child: ReorderableListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _images.length,
        onReorder: _reorderImages,
        buildDefaultDragHandles: false,
        itemBuilder: (context, index) {
          final img = _images[index];
          return ReorderableDragStartListener(
            key: ValueKey(index),
            index: index,
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: _imageThumbnail(context, index, img, thumbSize),
            ),
          );
        },
      ),
    );
  }

  Widget _imageThumbnail(BuildContext context,
      int index,
      ProductImage img,
      double size,) {
    final theme = Theme.of(context);
    final preview = img.isImage && img.displayBytes != null
        ? Image.memory(
      img.displayBytes!,
      width: size,
      height: size,
      fit: BoxFit.cover,
    )
        : Container(
      width: size,
      height: size,
      color: Colors.grey.shade200,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.insert_drive_file,
              size: 28,
              color: Colors.grey.shade600,
            ),
            const SizedBox(height: 6),
            Text(
              img.extension.isEmpty
                  ? 'FILE'
                  : img.extension.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Preview image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: preview,
          ),

          // Compressed-size badge
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${img.displaySizeKB} KB',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Remove button
          Positioned(
            top: -6,
            right: -6,
            child: GestureDetector(
              onTap: () => _removeImage(index),
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Drag handle (bottom-right)
          Positioned(
            bottom: 4,
            right: 4,
            child: const Icon(
              Icons.drag_handle,
              size: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  // ── shared helpers ────────────────────────────────────────────────────────

  Widget _sectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 4,
          height: 22,
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onPrimary,
            fontFamily: 'RedHatDisplay',
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

// ── internal helper class for spec row controllers ────────────────────────────
}
class _SpecRow {
  final keyCtrl = TextEditingController();
  final valueCtrl = TextEditingController();
  final unitCtrl = TextEditingController();

  final keyFocus = FocusNode();
  final valueFocus = FocusNode();
  final unitFocus = FocusNode();

  void dispose() {
    keyCtrl.dispose();
    valueCtrl.dispose();
    unitCtrl.dispose();

    keyFocus.dispose();
    valueFocus.dispose();
    unitFocus.dispose();
  }
}