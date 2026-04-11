import 'package:flutter/material.dart';

class AdminSectionHeader extends StatelessWidget {
  final String title;

  const AdminSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
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
}

class AdminErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const AdminErrorBanner({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class AdminImageThumbnail extends StatelessWidget {
  final double size;
  final bool isPending;
  final bool isDeleted;
  final Widget image;
  final VoidCallback onToggleDelete;

  const AdminImageThumbnail({
    super.key,
    required this.size,
    required this.isPending,
    required this.isDeleted,
    required this.image,
    required this.onToggleDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: isDeleted
                ? ColorFiltered(
                    colorFilter:
                        const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                    child: image,
                  )
                : image,
          ),
          if (isPending)
            Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.shade700,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'NEW',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (isDeleted)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  color: Colors.red.withAlpha(60),
                  child: const Center(
                    child: Text(
                      'Will be\ndeleted',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            top: -6,
            right: -6,
            child: GestureDetector(
              onTap: onToggleDelete,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: isDeleted ? Colors.green.shade700 : theme.colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDeleted ? Icons.restore : Icons.close,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const Positioned(
            bottom: 4,
            right: 4,
            child: Icon(Icons.drag_handle, size: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

