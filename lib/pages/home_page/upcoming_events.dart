import 'package:flex_printing/models/System/system.dart';
import 'package:flex_printing/shared_widgets/ui_helper.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UpcomingEvents extends StatefulWidget {
  const UpcomingEvents({super.key});

  @override
  State<UpcomingEvents> createState() => _UpcomingEventsState();
}

class _UpcomingEventsState extends State<UpcomingEvents> {
  List<String> _imageUrls = [];
  List<String> _locations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final client = Supabase.instance.client;

      final eventRows = await client
          .from('upcomming_events')
          .select('path, sort_order, created_at')
          .order('sort_order', ascending: true)
          .order('created_at', ascending: true);

      final locationRows = await client
          .from('event_locations')
          .select('location, sort_order, created_at')
          .order('sort_order', ascending: true)
          .order('created_at', ascending: true);

      final urls = (eventRows as List)
          .map((row) => row['path'] as String?)
          .whereType<String>()
          .where((path) => path.isNotEmpty)
          .map((path) => client.storage.from('flex-printing').getPublicUrl(path))
          .toList(growable: false);

      final locations = (locationRows as List)
          .map((row) => row['location'] as String?)
          .whereType<String>()
          .where((loc) => loc.trim().isNotEmpty)
          .toList(growable: false);

      if (!mounted) return;
      setState(() {
        _imageUrls = urls;
        _locations = locations;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _imageUrls = [];
        _locations = [];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget locationChip(String location) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: System.isMobile ? 10 : 20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.circle,
              size: 10,
              color: Theme.of(context).colorScheme.secondary,
            ),
            SizedBox(width: System.isMobile ? 6 : 15),
            Text(
              location,
              style: TextStyle(
                fontSize: System.isMobile ? 20 : 45,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      );
    }

    Widget eventPoster({String? imageUrl}) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: System.isMobile ? 15 : 35),
        width: System.isMobile ? 150 : 360,
        height: System.isMobile ? 150 : 360,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: imageUrl == null
            ? Icon(
                Icons.image,
                size: System.isMobile ? 50 : 100,
                color: Colors.grey,
              )
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.low,
              ),
      );
    }

    Widget events() {
      final displayImages = _imageUrls.isEmpty ? <String?>[null] : _imageUrls;
      final displayLocations = _locations.isEmpty ? const <String>['No locations'] : _locations;

      return Padding(
        padding: EdgeInsets.only(
          bottom: System.isMobile ? 35 : 65,
          top: System.isMobile ? 60 : 120,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: displayImages
                    .map((url) => eventPoster(imageUrl: url))
                    .toList(growable: false),
              ),
            ),
            if (_loading)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: CircularProgressIndicator(),
              ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: displayLocations
                    .map((location) => locationChip(location))
                    .toList(growable: false),
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: System.isMobile ? 320 : 790,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned(
            top: System.isMobile ? 20 : 25,
            left: 0,
            right: 0,
            child: Container(
              height: System.isMobile ? 320 : 745,
              width: double.infinity,
              color: Theme
                  .of(context)
                  .colorScheme
                  .surfaceContainer,
              child: events(),
            ),
          ),
          Align(
              alignment: .topCenter,
              child: UiHelper.title(
                  context: context, title: "Upcoming Events")),
        ],
      ),
    );


  }
}
