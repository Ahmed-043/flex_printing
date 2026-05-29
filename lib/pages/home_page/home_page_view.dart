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
  final String section;
  const HomeContentView({super.key,this.section = ""});


  @override
  State<HomeContentView> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContentView> {
  late double screenHeight, screenWidth;
  ScrollController scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    if (widget.section.isNotEmpty) {
      _scheduleScroll();
    }
  }

  @override
  void didUpdateWidget(covariant HomeContentView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.section != oldWidget.section && widget.section.isNotEmpty) {
      _scheduleScroll();
    }
  }

  void _scheduleScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scrollToSection(widget.section);
    });
  }

  void _scrollToSection(String section) {
    final normalized = section.trim().toLowerCase();
    double offset = 0;

    if (normalized == 'clients') {
      offset = System.isMobile ? 1345.6 : 2720.6 + screenHeight;
    } else if (normalized == 'about') {
      // Offset for About section (Clients + Spacer)
      offset = System.isMobile ? 2400.2 : 3900.6 + screenHeight;
    } else if (normalized == 'events') {
      // Offset for Events section (About + Spacer)
      offset = System.isMobile ? 2770.2 : 4850.6 + screenHeight;
    }

    if (offset > 0) {
      scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }


  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;



    final theme = Theme.of(context).colorScheme;
    final items = <Widget>[
      _banner(),
      SizedBox(height: System.isMobile ? 80 : 200),
      ProductsSection(),
      SizedBox(height: System.isMobile ? 125 : 240),
      MaterialsSection(),
      SizedBox(height: System.isMobile ? 125 : 450),
      ClientsEvents(isActive: true),
      SizedBox(height: System.isMobile ? 125 : 450),
      AboutEvents(),
      SizedBox(height: System.isMobile ? 85 : 450),
      ClientsEvents(isEvents: true, isActive: true),
      SizedBox(height: System.isMobile ? 164 : 290),
      UpcomingEvents(),
      SizedBox(height: System.isMobile ? 164 : 290),
      OtherInfo(),
      SizedBox(height: System.isMobile ? 150 : 270),
      OurEquipmentsSection(),
      SizedBox(height: System.isMobile ? 150 : 250),
      FooterSection(),
    ];

    return ListView.builder(
      //primary: true,
      //cacheExtent: 1000000,
      controller: scrollController,
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