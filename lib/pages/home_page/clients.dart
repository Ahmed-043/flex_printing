import 'package:carousel_slider/carousel_slider.dart';
import 'package:flex_printing/models/System/system.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/media_item.dart';
import '../../shared_widgets/ui_helper.dart';

class ClientsEvents extends StatefulWidget {
  final bool isEvents;
  const ClientsEvents({super.key, this.isEvents = false});

  @override
  State<ClientsEvents> createState() => _ClientsEventsState();
}

class _ClientsEventsState extends State<ClientsEvents> {
  List<MediaItem> _items = [];
  bool _loading = true;

  String get _tableName => widget.isEvents ? 'events' : 'clients';

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void didUpdateWidget(covariant ClientsEvents oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isEvents != widget.isEvents) {
      _loadItems();
    }
  }

  Future<void> _loadItems() async {
    setState(() {
      _loading = true;
    });
    try {
      final rows = await Supabase.instance.client
          .from(_tableName)
          .select('id, path, sort_order, created_at')
          .order('sort_order', ascending: true)
          .order('created_at', ascending: true);

      if (!mounted) return;
      setState(() {
        _items = (rows as List)
            .map(
              (r) => MediaItem.existing(
                id: r['id'] as int,
                path: r['path'] as String,
              ),
            )
            .toList();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _items = [];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double cardWidth = System.isMobile ? 270 : 550;
    final double cardHeight = System.isMobile ? 270 : 650;

    final screenWidth = MediaQuery.of(context).size.width;
    const double desiredGap = 24; // keep card-to-card spacing almost constant

    final double viewportFraction = ((cardWidth + desiredGap) / screenWidth).clamp(
      System.isMobile ? 0.55 : 0.20, // min
      System.isMobile ? 0.60 : 0.75, // max
    );

    final itemCount = _items.isEmpty ? 10 : _items.length;

    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          UiHelper.title(context: context, title: !widget.isEvents ? "Satisfied Clients" : "Events"),
          SizedBox(height: System.isMobile ? 58 : 115),
          Center(
            child: CarouselSlider.builder(
              itemCount: itemCount,
              options: CarouselOptions(
                height: cardHeight,
                viewportFraction: viewportFraction,
                enlargeCenterPage: true,     // ⭐ center zoom
                enlargeFactor: 0.18,         // ≈ your minScale 0.85
                clipBehavior: Clip.none,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 2),
                enableInfiniteScroll: true,
                padEnds: true,
              ),
              itemBuilder: (context, index, realIndex) {
                final item = _items.isEmpty ? null : _items[index];
                final imageUrl = item?.publicUrl();

                return Center(
                  child: SizedBox(
                    width: cardWidth,   // STRICT width preserved
                    height: cardHeight,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: imageUrl != null
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                filterQuality: FilterQuality.low,
                              )
                            : Center(
                                child: _loading
                                    ? const CircularProgressIndicator()
                                    : Icon(
                                        Icons.image,
                                        color: Colors.grey,
                                        size: System.isMobile ? 30 : 80,
                                      ),
                              ),
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