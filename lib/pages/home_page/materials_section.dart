import 'package:carousel_slider/carousel_slider.dart';
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

  @override
  void initState() {
    super.initState();
    _loadItems();
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
            child: CarouselSlider.builder(
              itemCount: _items.isEmpty ? 0 : _items.length,
              options: CarouselOptions(
                height: System.isMobile ? 200 : 485,
                viewportFraction: System.isMobile ? 0.45 : 0.3,
                enlargeCenterPage: true,
                enlargeFactor: System.isMobile ? 0.5 : 0.35,
                clipBehavior: Clip.none,
                autoPlay: _items.isNotEmpty,
                autoPlayInterval: const Duration(seconds: 2),
                enableInfiniteScroll: true,
               // padEnds: true,
              ),
              itemBuilder: (context, index, realIndex) {
                final item = _items[index];
                final imageUrl = item.publicUrl();

                return Center(
                  child: Container(
                    height: System.isMobile ? 250 : 485,
                    width: System.isMobile ? 250 : 500,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                     // borderRadius: BorderRadius.circular(500),
                     //  border: Border.all(
                     //    color: Colors.grey.shade300,
                     //    width: 2,
                     //  ),
                    ),
                    //clipBehavior: Clip.antiAlias,
                    child: item.localBytes != null
                        ? Image.memory(
                      item.localBytes!,
                      fit: BoxFit.fitWidth,
                    )
                        : imageUrl != null
                        ? Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
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
        ],
      ),
    );
  }
}