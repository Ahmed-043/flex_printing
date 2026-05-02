import 'dart:async';
import 'package:flutter/material.dart';

class DeleteProductDialog extends StatefulWidget {
  final String productName;

  const DeleteProductDialog({required this.productName});

  @override
  State<DeleteProductDialog> createState() => _DeleteProductDialogState();
}

class _DeleteProductDialogState extends State<DeleteProductDialog> {
  static const int _initialSeconds = 5;
  int _secondsRemaining = _initialSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining <= 1) {
        timer.cancel();
        setState(() => _secondsRemaining = 0);
        return;
      }
      setState(() => _secondsRemaining -= 1);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canDelete = _secondsRemaining == 0;

    return AlertDialog(
      backgroundColor: theme.colorScheme.onPrimary.withAlpha(150),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.delete_outline, color: theme.colorScheme.error),
          const SizedBox(width: 8),
          Text(
            'Delete Product',
            style: TextStyle(color: theme.colorScheme.onSecondary),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: SingleChildScrollView(
          child: Text(
            'Delete "${widget.productName}" and all of its product images and specs?\n'
                '\nThis will remove the product row, related rows, and uploaded images from the storage.',
            style: TextStyle(color: theme.colorScheme.onSecondary),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: canDelete ? () => Navigator.of(context).pop(true) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: Colors.white,
            disabledBackgroundColor: theme.colorScheme.error.withAlpha(120),
            disabledForegroundColor: Colors.white70,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(canDelete ? 'Delete' : 'Delete ($_secondsRemaining)'),
        ),
      ],
    );
  }
}

class DeleteCategoryDialog extends StatefulWidget {
  final String categoryName;

  const DeleteCategoryDialog({super.key, required this.categoryName});

  @override
  State<DeleteCategoryDialog> createState() => _DeleteCategoryDialogState();
}

class _DeleteCategoryDialogState extends State<DeleteCategoryDialog> {
  static const int _initialSeconds = 5;
  int _secondsRemaining = _initialSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining <= 1) {
        timer.cancel();
        setState(() => _secondsRemaining = 0);
        return;
      }
      setState(() => _secondsRemaining -= 1);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canDelete = _secondsRemaining == 0;

    return AlertDialog(
      backgroundColor: theme.colorScheme.onPrimary.withAlpha(150),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.delete_outline, color: theme.colorScheme.error),
          const SizedBox(width: 8),
          Text(
            'Delete Category',
            style: TextStyle(color: theme.colorScheme.onSecondary),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: SingleChildScrollView(
          child: Text(
            'Delete "${widget.categoryName}" category?\n'
            '\nThis works only when no product is using this category.',
            style: TextStyle(color: theme.colorScheme.onSecondary),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: canDelete ? () => Navigator.of(context).pop(true) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: Colors.white,
            disabledBackgroundColor: theme.colorScheme.error.withAlpha(120),
            disabledForegroundColor: Colors.white70,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(canDelete ? 'Delete' : 'Delete ($_secondsRemaining)'),
        ),
      ],
    );
  }
}
