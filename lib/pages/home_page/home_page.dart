import 'dart:math';

import 'package:flex_printing/models/System/system.dart';
import 'package:flex_printing/pages/home_page/about_events.dart';
import 'package:flex_printing/pages/home_page/clients.dart';
import 'package:flex_printing/pages/home_page/home_banner_carousel.dart';
import 'package:flex_printing/pages/home_page/products_section.dart';
import 'package:flex_printing/pages/home_page/upcoming_events.dart';
import 'package:flex_printing/shared_widgets/ui_helper.dart';
import 'package:flutter/material.dart';

import 'other_info.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key, this.initialSection});

  final String? initialSection;

  static const String sectionAbout = 'about';
  static const String sectionEvents = 'events';

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  late double screenHeight, screenWidth;
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _sectionKeys = {
    'products': GlobalKey(),
    'materials': GlobalKey(),
    'clients': GlobalKey(),
    'about': GlobalKey(),
    'events': GlobalKey(),
    'upcoming': GlobalKey(),
    'other': GlobalKey(),
    'equipment': GlobalKey(),
    'footer': GlobalKey(),
  };
  final Map<String, bool> _visibleSections = {
    'products': false,
    'materials': false,
    'clients': false,
    'about': false,
    'events': false,
    'upcoming': false,
    'other': false,
    'equipment': false,
    'footer': false,
  };
  ScrollPosition? _parentScrollPosition;
  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _eventsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _scheduleInitialScroll(widget.initialSection);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateVisibleSections());
  }

  @override
  void didUpdateWidget(covariant HomeContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSection != oldWidget.initialSection) {
      _scheduleInitialScroll(widget.initialSection);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final parentPosition = Scrollable.maybeOf(context)?.position;
    if (_parentScrollPosition == parentPosition) {
      return;
    }
    _parentScrollPosition?.removeListener(_onScroll);
    _parentScrollPosition = parentPosition;
    _parentScrollPosition?.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateVisibleSections());
  }

  @override
  void dispose() {
    _parentScrollPosition?.removeListener(_onScroll);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    _updateVisibleSections();
  }

  void _updateVisibleSections() {
    if (!mounted) {
      return;
    }

    final viewSize = MediaQuery.sizeOf(context);
    final viewportRect = Rect.fromLTWH(
      0,
      0,
      viewSize.width,
      viewSize.height - (System.isMobile ? 100 : 200),
    );
    var changed = false;

    for (final entry in _sectionKeys.entries) {
      final key = entry.key;
      final contextForKey = entry.value.currentContext;
      if (contextForKey == null) {
        continue;
      }

      final renderObject = contextForKey.findRenderObject();
      if (renderObject is! RenderBox || !renderObject.hasSize) {
        continue;
      }

      final rect = renderObject.localToGlobal(Offset.zero) & renderObject.size;

      final intersection = rect.intersect(viewportRect);
      final requiredHeight = (renderObject.size.height * 0.12).clamp(40.0, 180.0);
      final isVisible = intersection.height >= requiredHeight;

      if (_visibleSections[key] != isVisible) {
        _visibleSections[key] = isVisible;
        changed = true;
      }
    }

    if (changed) {
      setState(() {});
    }
  }

  void _scheduleInitialScroll(String? section) {
    if (section == null || section.isEmpty) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _scrollToSection(section);
    });
  }

  void _scrollToSection(String section) {
    final targetContext = switch (section) {
      HomeContent.sectionAbout => _aboutKey.currentContext,
      HomeContent.sectionEvents => _eventsKey.currentContext,
      _ => null,
    };
    if (targetContext == null) {
      return;
    }
    Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOut,
      alignment: 0.05,
    );
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      controller: _scrollController,
      child: Container(
        width: 1500,
        color: Theme.of(context).colorScheme.primary,
        child: Column(
          children: [
            _banner(),
            Container(height: System.isMobile ? 80 : 200),
            _lazySection(
              sectionId: 'products',
              child: ProductsSection(),
            ),
            Container(height: System.isMobile ? 125 : 240),
            _lazySection(
              sectionId: 'materials',
              child: MaterialsSection(),
            ),
            Container(height: System.isMobile ? 125 : 450),
            _lazySection(
              sectionId: 'clients',
              child: ClientsEvents(),
            ),
            Container(height: System.isMobile ? 125 : 450),
            _lazySection(
              sectionId: 'about',
              anchorKey: _aboutKey,
              child: AboutEvents(),
            ),
            Container(height: System.isMobile ? 85 : 450),
            _lazySection(
              sectionId: 'events',
              anchorKey: _eventsKey,
              child: ClientsEvents(isEvents: true),
            ),
            Container(height: System.isMobile ? 164 : 290),
            _lazySection(
              sectionId: 'upcoming',
              child: UpcomingEvents(),
            ),
            Container(height: System.isMobile ? 164 : 290),
            _lazySection(
              sectionId: 'other',
              child: OtherInfo(),
            ),
            Container(height: System.isMobile ? 150 : 270),
            _lazySection(
              sectionId: 'equipment',
              child: OurEquipmentsSection(),
            ),
            Container(height: System.isMobile ? 150 : 250),
            FooterSection(),
          ],
        ),
      ),
    );
  }

  Widget _lazySection({
    required String sectionId,
    required Widget child,
    Key? anchorKey,
  }) {
    final isVisible = _visibleSections[sectionId] ?? false;

    return Container(
      key: anchorKey,
      child: Container(
        key: _sectionKeys[sectionId],
        alignment: Alignment.topCenter,
        child: IgnorePointer(
          ignoring: !isVisible,
          child: AnimatedOpacity(
            opacity: isVisible ? 1 : 0,
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOut,
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _banner() {
    double containerHeight = max(500, screenHeight - (System.isMobile ? 70 : 80));
    if(!System.isMobile){
      containerHeight = min(containerHeight,1200);
    }else{
      containerHeight = min(containerHeight,1200);
    }
    return Container(
      height: containerHeight,
      color: Theme.of(context).colorScheme.secondary,
      child: System.isMobile
          ? Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
            children: _mobileBanner()),
      )
          : Padding(
        padding: const EdgeInsets.only(left: 50.0, right: 50),
        child: Row(
            children: _desktopBanner()),
      ),
    );
  }

  List<Widget> _desktopBanner() {
    return [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1) DIGITAL (won’t overflow)
                ClipRect(
                  child: Text(
                    'DIGITAL',
                    maxLines: 1,
                    overflow: TextOverflow.clip, // or TextOverflow.clip to hide without "..."
                    softWrap: false,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontFamily: 'PaytoneOne',
                      letterSpacing: 5,
                      height: 1.2,
                      fontSize: screenWidth < 1210 ? 100 : 135,
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                ),

                // 2) subtitle (can wrap normally)
                Text(
                  'PRINTING MACHINERY SUPPLER.',
                  maxLines: 3,
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                    height: 1,
                    letterSpacing: 5,
                    fontWeight: FontWeight.w600,
                    fontSize: screenWidth < 1210 ? 35 : 43,
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
              ],
            ),
            UiHelper.button(
              callback: () {},
              color: Colors.black,
              filled: true,
              borderRadius: 50,
              child: Text(
                "Learn More",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                  fontSize: screenWidth<1210 ? 27 : 34,
                ),
              ),
            ),
            Text(
              "ONE DOOR SOLUTION",
              style: TextStyle(
                fontWeight: FontWeight.w200,
                fontFamily: 'RedHatDisplay',
                fontSize: screenWidth<1210 ? 35 : 43,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            )
          ],
        ),
      ),
      HomeBannerCarousel()
    ];
  }

  List<Widget> _mobileBanner() {
    return [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Center(
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'DIGITAL\n',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontFamily: 'PaytoneOne',
                        letterSpacing: 5,
                        fontSize: 80,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                    TextSpan(
                      text: 'PRINTING MACHINERY SUPPLER.',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        height: 0.5,
                        letterSpacing: 2,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            UiHelper.button(
              callback: () {},
              color: Colors.black,
              filled: true,
              borderRadius: 50,
              child: Text(
                "Learn More",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
      HomeBannerCarousel(),
    ];
  }
}