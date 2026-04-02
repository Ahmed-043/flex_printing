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
  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _eventsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scheduleInitialScroll(widget.initialSection);
  }

  @override
  void didUpdateWidget(covariant HomeContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSection != oldWidget.initialSection) {
      _scheduleInitialScroll(widget.initialSection);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
            ProductsSection(),
            Container(height: System.isMobile ? 125 : 450),
            ClientsEvents(),
            Container(height: System.isMobile ? 125 : 450),
            Container(
              key: _aboutKey,
              child: AboutEvents(),
            ),
            Container(height: System.isMobile ? 85 : 450),
            Container(
              key: _eventsKey,
              child: ClientsEvents(isEvents: true),
            ),
            Container(height: System.isMobile ? 164 : 290),
            UpcomingEvents(),
            Container(height: System.isMobile ? 164 : 290),
            OtherInfo(),
          ],
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