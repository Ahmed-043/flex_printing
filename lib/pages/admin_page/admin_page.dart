
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/System/system.dart';

import '../../shared_widgets/ui_helper.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {

  @override
  void initState() {
    super.initState();
  }

  void _openCreateProductPage() {
    context.go('/admin/create-product');
  }

  @override
  Widget build(BuildContext context) {

      return _landingView(context);
  }

  Widget _landingView(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final isCompact = System.isMobile || screenWidth < 900;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 20 : 60,
        vertical: 40,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isCompact ? 24 : 36),
                decoration: BoxDecoration(
                  color: Theme
                      .of(context)
                      .colorScheme
                      .surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: UiHelper.title(
                        context: context,
                        title: 'Admin',
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Start creating a new product from here.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 64,
                      child: UiHelper.button(
                        callback: _openCreateProductPage,
                        filled: true,
                        color: Colors.black,
                        borderRadius: 16,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        elevation: 2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.add_box_outlined, color: Colors.white),
                            SizedBox(width: 12),
                            Text(
                              'New Product',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}