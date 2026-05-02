import 'package:flex_printing/models/System/system.dart';
import 'package:flex_printing/shared_widgets/ui_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/media_item.dart';

class MaterialsSection extends StatefulWidget {
  const MaterialsSection({super.key});

  @override
  State<MaterialsSection> createState() => _MaterialsSectionState();
}

class _MaterialsSectionState extends State<MaterialsSection> with SingleTickerProviderStateMixin {

  static const _tableName = 'materials';


  List<MediaItem> _items = [];


  final ScrollController _scrollController = ScrollController();
  late final Ticker _ticker;
  Duration? _lastElapsed;

  // Pixels per second for smooth constant marquee movement.
  double get _speed => System.isMobile ? 45 : 100;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _ticker.start();
    });
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
            .map((r) =>
            MediaItem.existing(
              id: r['id'] as int,
              path: r['path'] as String,
            ))
            .toList();
      });
    } catch (e) {
     debugPrint("Error loading materials: $e");
     // Optionally, set _items to an empty list or show an error message in the
    }
  }


  void _onTick(Duration elapsed) {
    if (_items.isEmpty) {
      _lastElapsed = elapsed;
      return;
    }

    if (!_scrollController.hasClients) {
      _lastElapsed = elapsed;
      return;
    }

    final last = _lastElapsed;
    _lastElapsed = elapsed;
    if (last == null) return;

    final dtSeconds = (elapsed - last).inMicroseconds / Duration.microsecondsPerSecond;
    if (dtSeconds <= 0) return;

    final position = _scrollController.position;
    final maxExtent = position.maxScrollExtent;
    if (maxExtent <= 0) return;

    final loopExtent = maxExtent / 2;
    if (loopExtent <= 0) return;

    var nextOffset = position.pixels + (_speed * dtSeconds);
    if (nextOffset >= loopExtent) {
      nextOffset -= loopExtent;
    }

    _scrollController.jumpTo(nextOffset);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalCount = _items.isEmpty ? 0 : _items.length * 2;

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
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: totalCount,
              itemBuilder: (context, index) {
                final item = _items[index % _items.length];
                final imageUrl = item.publicUrl();

                return Container(
                  height: System.isMobile ? 185 : 485,
                  width: System.isMobile ? 155 : 410,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(500),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: item.localBytes != null
                      ? Image.memory(
                    item.localBytes!,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.low,
                  )
                      : imageUrl != null
                      ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.low,
                    cacheWidth: (MediaQuery.of(context).size.width *
                        MediaQuery.of(context).devicePixelRatio)
                        .toInt(),
                  )
                      : Center(
                    child: Icon(
                      Icons.image,
                      color: Colors.grey,
                      size: System.isMobile ? 30 : 80,
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
