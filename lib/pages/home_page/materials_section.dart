import 'dart:async';

import 'package:flex_printing/models/System/system.dart';
import 'package:flex_printing/shared_widgets/ui_helper.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/media_item.dart';

class MaterialsSection extends StatefulWidget {
  const MaterialsSection({super.key});

  @override
  State<MaterialsSection> createState() => _MaterialsSectionState();
}

class _MaterialsSectionState extends State<MaterialsSection> {
  static const _tableName = 'materials';

  List<MediaItem> _items = [];

  late final PageController _pageController;
  int _currentPage = 1000; // fake infinite start
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(
      viewportFraction: System.isMobile ? 0.5 : 0.4,
      initialPage: _currentPage,
    );

    _loadItems();
    _startAutoScroll();
  }

  Future<void> _loadItems() async {
    try {
      final client = Supabase.instance.client;

      final rows = await client
          .from(_tableName)
          .select('id, path, sort_order, created_at')
          .order('sort_order', ascending: true)
          .order('created_at', ascending: true);

      if (!mounted) return;

      setState(() {
        _items = (rows as List)
            .map((r) => MediaItem.existing(
          id: r['id'] as int,
          path: r['path'] as String,
        ))
            .toList();
      });
    } catch (e) {
      debugPrint("Error loading materials: $e");
    }
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();

    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || _items.isEmpty) return;

      _currentPage++;

      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          UiHelper.title(context: context, title: "Material & Parts"),
          SizedBox(height: System.isMobile ? 20 : 50),

          Text(
            "All material and parts${System.isMobile ? "\n" : " "}are available",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: System.isMobile ? 20 : 58,
              color: Theme.of(context).colorScheme.secondaryContainer,
            ),
          ),

          SizedBox(height: System.isMobile ? 30 : 75),

          SizedBox(
            width: double.infinity,
            height: System.isMobile ? 185 : 485,

            child: GestureDetector(
              onPanDown: (_) => _stopAutoScroll(),
              onPanCancel: _startAutoScroll,
              onPanEnd: (_) => _startAutoScroll(),

              child: PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.horizontal,

                itemBuilder: (context, index) {
                  if (_items.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final item = _items[index % _items.length];
                  final imageUrl = item.publicUrl();

                  return Center(
                    child: Container(
                      height: System.isMobile ? 185 : 485,
                      width: System.isMobile ? 155 : 410,
                      margin: const EdgeInsets.symmetric(horizontal: 8),

                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(500),
                      ),

                      clipBehavior: Clip.antiAlias,

                      child: item.localBytes != null
                          ? Image.memory(
                        item.localBytes!,
                        fit: BoxFit.cover,
                      )
                          : imageUrl != null
                          ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                      )
                          : Center(
                        child: Icon(
                          Icons.image,
                          color: Colors.grey,
                          size: System.isMobile ? 30 : 80,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}