import 'dart:math';

import 'package:flex_printing/models/System/system.dart';
import 'package:flex_printing/pages/home_page/about_events.dart';
import 'package:flex_printing/pages/home_page/clients.dart';
import 'package:flex_printing/pages/home_page/home_banner_carousel.dart';
import 'package:flex_printing/pages/home_page/products_section.dart';
import 'package:flex_printing/pages/home_page/upcoming_events.dart';
import 'package:flex_printing/shared_widgets/ui_helper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'footer.dart';
import 'materials_section.dart';
import 'other_info.dart';

class HomeContentView extends StatefulWidget {
  const HomeContentView({super.key, this.initialSection});

  final String? initialSection;

  static const String sectionAbout = 'about';
  static const String sectionEvents = 'events';

  @override
  State<HomeContentView> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContentView> {
  late double screenHeight, screenWidth;
  final Map<String, GlobalKey> _sectionKeys = {
    'banner': GlobalKey(),
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
  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _eventsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scheduleInitialScroll(widget.initialSection);
  }

  @override
  void didUpdateWidget(covariant HomeContentView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSection != oldWidget.initialSection) {
      _scheduleInitialScroll(widget.initialSection);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
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
      HomeContentView.sectionAbout => _aboutKey.currentContext,
      HomeContentView.sectionEvents => _eventsKey.currentContext,
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

    final theme = Theme.of(context).colorScheme;
    final items = <Widget>[
      Container(
        key: _sectionKeys['banner'],
        child: RepaintBoundary(child: _banner()),
      ),
      SizedBox(height: System.isMobile ? 80 : 200),
      Container(
        key: _sectionKeys['products'],
        alignment: Alignment.topCenter,
        child: ProductsSection(),
      ),
      SizedBox(height: System.isMobile ? 125 : 240),
      Container(
        key: _sectionKeys['materials'],
        alignment: Alignment.topCenter,
        child: MaterialsSection(),
      ),
      SizedBox(height: System.isMobile ? 125 : 450),
      Container(
        key: _sectionKeys['clients'],
        alignment: Alignment.topCenter,
        child: ClientsEvents(isActive: true),
      ),
      SizedBox(height: System.isMobile ? 125 : 450),
      Container(
        key: _sectionKeys['about'],
        child: Container(key: _aboutKey, child: AboutEvents()),
      ),
      SizedBox(height: System.isMobile ? 85 : 450),
      Container(
        key: _sectionKeys['events'],
        child: Container(
          key: _eventsKey,
          child: ClientsEvents(isEvents: true, isActive: true),
        ),
      ),
      SizedBox(height: System.isMobile ? 164 : 290),
      Container(key: _sectionKeys['upcoming'], child: UpcomingEvents()),
      SizedBox(height: System.isMobile ? 164 : 290),
      Container(key: _sectionKeys['other'], child: OtherInfo()),
      SizedBox(height: System.isMobile ? 150 : 270),
      Container(key: _sectionKeys['equipment'], child: OurEquipmentsSection()),
      SizedBox(height: System.isMobile ? 150 : 250),
      Container(key: _sectionKeys['footer'], child: FooterSection()),
    ];

    return ListView.builder(
      primary: true,
      padding: EdgeInsets.zero,
      itemCount: items.length,
      itemBuilder: (ctx, i) {
        return Center(
          child: Container(
            width: 1500,
            color: theme.primary,
            child: items[i],
          ),
        );
      },
    );
  }

  Widget _banner() {
    double containerHeight = max(500, screenHeight - (System.isMobile ? 70 : 80));
    if(!System.isMobile){
      containerHeight = min(containerHeight,1200);
    }else{
      containerHeight = min(containerHeight,1200);
    }
    final useCompactNav = screenWidth < 1050;

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
        padding: EdgeInsets.symmetric(horizontal: useCompactNav ? 50 : 100.0),
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
                  'PRINTING MACHINERY\nSUPPLER.',
                  maxLines: 3,
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                    height: 1,
                    letterSpacing: 0,
                    fontWeight: FontWeight.w600,
                    fontSize: screenWidth < 1210 ? 35 : 43,
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
              ],
            ),
            UiHelper.button(
              callback: () {
                context.go('/products');
                return;
              },
              color: Colors.black,
              filled: true,
              borderRadius: 50,
              rotation: 8,
              padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 20),
              child: Text(
                "Learn More",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.onSecondary,
                  fontSize: screenWidth<1210 ? 27 : 34,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 25.0),
              child: Text(
                "ONE DOOR SOLUTION",
                style: TextStyle(
                  fontWeight: FontWeight.w200,
                  fontFamily: 'RedHatDisplay',
                  fontSize: screenWidth<1210 ? 35 : 43,
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
            ),

          ],
        ),
      ),
      HomeBannerCarousel(isActive: true)
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
              callback: () {
                context.go('/products');
                return;
              },
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
      HomeBannerCarousel(isActive: true),
    ];
  }
}