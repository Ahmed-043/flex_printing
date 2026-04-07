import 'package:flutter/material.dart';

class CategoryDropdownTextField extends StatefulWidget {
  const CategoryDropdownTextField({
    super.key,
    required this.controller,
    required this.categories,
    this.hintText = 'Select or type category',
    this.onCategoriesChanged,
    this.onAdd,
  });

  final TextEditingController controller;
  final List<String> categories;
  final String hintText;
  final VoidCallback? onCategoriesChanged;
  final ValueChanged<String>? onAdd;

  @override
  State<CategoryDropdownTextField> createState() =>
      _CategoryDropdownTextFieldState();
}

class _CategoryDropdownTextFieldState extends State<CategoryDropdownTextField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _commitTypedValue();
      }
    });
  }

  List<String> _sortedCategories() {
    final list = [...widget.categories];
    list.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return list;
  }

  String? _findExistingCategory(String rawValue) {
    final value = rawValue.trim();
    if (value.isEmpty) {
      return null;
    }
    for (final c in widget.categories) {
      if (c.toLowerCase() == value.toLowerCase()) {
        return c;
      }
    }
    return null;
  }

  Future<void> _commitTypedValue([String? raw]) async {
    final typed = (raw ?? widget.controller.text).trim();
    if (typed.isEmpty) {
      return;
    }

    final existing = _findExistingCategory(typed);
    if (existing != null) {
      if (widget.controller.text != existing) {
        setState(() => widget.controller.text = existing);
      }
      return;
    }

    widget.categories.add(typed);
    widget.categories.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    widget.controller.text = typed;

    widget.onCategoriesChanged?.call();
    widget.onAdd?.call(typed);

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sorted = _sortedCategories();

    return RawAutocomplete<String>(
      textEditingController: widget.controller,
      focusNode: _focusNode,
      optionsBuilder: (TextEditingValue value) {
        final query = value.text.trim().toLowerCase();
        if (query.isEmpty) {
          return sorted;
        }
        return sorted.where((c) => c.toLowerCase().contains(query));
      },
      onSelected: (selected) {
        widget.controller.text = selected;
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              focusNode: focusNode,
              textInputAction: TextInputAction.done,
              cursorColor: Theme.of(context).colorScheme.onPrimary,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFD1D5DC)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF909398)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFD1D5DC)),
                ),
                suffixIcon: IconButton(
                  tooltip: 'Add typed category',
                  onPressed: _commitTypedValue,
                  icon: const Icon(Icons.add),
                ),
              ),
              onSubmitted: (value) => _commitTypedValue(value),
            ),
          ],
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        final matches = options.toList();
        if (matches.isEmpty) {
          return const SizedBox.shrink();
        }
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220, maxWidth: 420),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 6),
                shrinkWrap: true,
                itemCount: matches.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final option = matches[index];
                  return ListTile(
                    dense: true,
                    title: Text(option, style: TextStyle(color: Theme.of(context).colorScheme.onPrimary), overflow: TextOverflow.ellipsis),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          )
        );
      },
    );

  }
}