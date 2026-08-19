import 'dart:math';

import 'package:flex_printing/models/System/system.dart';
import 'package:flex_printing/pages/home_page/about_events.dart';
import 'package:flex_printing/pages/home_page/clients.dart';
import 'package:flex_printing/pages/home_page/home_banner_carousel.dart';
import 'package:flex_printing/pages/home_page/products_section.dart';
import 'package:flex_printing/pages/home_page/upcoming_events.dart';
import 'package:flex_printing/shared_widgets/ui_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
    if (widget.section != oldWidget.section) {
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
    double? offset;

    if (normalized == '') {
      offset = 0;
    } else if (normalized == 'about') {
      // Offset for About section (Clients + Spacer)
      offset = System.isMobile ? 2400.2 : 3800 + screenHeight;
    } else if (normalized == 'events') {
      // Offset for Events section (About + Spacer)
      offset = System.isMobile ? 2770.2 : 4850 + screenHeight;
    }

    if (offset != null) {
      final controller = PrimaryScrollController.of(context);
      if (controller.hasClients) {
        controller.animateTo(
          offset,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
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

    return Center(
      child: ListView.builder(
        shrinkWrap: true,
       // physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: items.length,
        itemBuilder: (ctx, i) {
          return Center(
            child: Container(
              width: 2500,
              color: theme.primary,
              child: items[i],
            ),
          );
        },
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
    final useCompactNav = screenWidth < 1050;

    return Container(
      height: containerHeight,
      color: Theme.of(context).colorScheme.primary,
      child: System.isMobile
          ? Padding(
        padding: const EdgeInsets.only( top: 10),
        child: Column(
            children: _mobileBanner()),
      )
          : Padding(
        padding: EdgeInsets.only(left: useCompactNav ? 0 : 0),
        child: _desktopBannerNew(),
      ),
    );
  }

  // List<Widget> _desktopBanner() {
  //   return [
  //     Expanded(
  //       flex: 4,
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //         children: [
  //           // 1) DIGITAL (won’t overflow)
  //           // ClipRect(
  //           //   child: Text(
  //           //     'DIGITAL',
  //           //     maxLines: 1,
  //           //     overflow: TextOverflow.clip, // or TextOverflow.clip to hide without "..."
  //           //     softWrap: false,
  //           //     style: TextStyle(
  //           //       fontWeight: FontWeight.w900,
  //           //       fontFamily: 'PaytoneOne',
  //           //       letterSpacing: 5,
  //           //       height: 1.2,
  //           //       fontSize: screenWidth < 1210 ? 100 : 135,
  //           //       color: Theme.of(context).colorScheme.onPrimary,
  //           //     ),
  //           //   ),
  //           // ),
  //
  //           Container(
  //               width:  System.isMobile ? 200 : 300,
  //               height:  System.isMobile ? 200 : 300,
  //               decoration: const BoxDecoration(
  //                 color: Colors.transparent,
  //                 shape: BoxShape.circle,
  //               ),
  //               child: SvgPicture.asset(
  //                 'assets/images/logo_sharp.svg',
  //                 width: System.isMobile ? 48 : 65,
  //                 height: System.isMobile ? 48 : 65,
  //               )),
  //
  //           // 2) subtitle (can wrap normally)
  //           Text(
  //             'DIGITAL PRINTING\nMACHINERY SUPPLIER.',
  //             maxLines: 3,
  //             overflow: TextOverflow.clip,
  //             style: TextStyle(
  //               height: 1,
  //               letterSpacing: 0,
  //               fontWeight: FontWeight.w600,
  //               fontSize: screenWidth < 1210 ? 40 : 55,
  //               color: Theme.of(context).colorScheme.onPrimary,
  //             ),
  //           ),
  //
  //           UiHelper.button(
  //             callback: () {
  //               context.go('/products');
  //               return;
  //             },
  //             color: Colors.black,
  //             filled: true,
  //             borderRadius: 50,
  //             rotation: 8,
  //             padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 20),
  //             child: Text(
  //               "Learn More",
  //               style: TextStyle(
  //                 fontWeight: FontWeight.w400,
  //                 color: Theme.of(context).colorScheme.onSecondary,
  //                 fontSize: screenWidth<1210 ? 27 : 34,
  //               ),
  //             ),
  //           ),
  //           // Padding(
  //           //   padding: const EdgeInsets.only(bottom: 25.0),
  //           //   child: Text(
  //           //     "ONE DOOR SOLUTION",
  //           //     style: TextStyle(
  //           //       fontWeight: FontWeight.w200,
  //           //       fontFamily: 'RedHatDisplay',
  //           //       fontSize: screenWidth<1210 ? 35 : 43,
  //           //       color: Theme.of(context).colorScheme.onPrimary,
  //           //     ),
  //           //   ),
  //           // ),
  //         ],
  //       ),
  //     ),
  //     HomeBannerCarousel(isActive: true)
  //   ];
  // }

  Widget _desktopBannerNew() {
    return Stack(
      children: [
        Positioned.fill(child: Column(
          children: [
            Expanded(
              flex: 2,
              child: SizedBox(),
            ),
            Expanded(
              flex: 10,
                child: HomeBannerCarousel(isActive: true)),
          ],
        )),
        Positioned.fill(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                  width:  System.isMobile ? 200 : 300,
                  height:  System.isMobile ? 200 : 300,
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    'assets/images/logo_sharp.svg',
                    width: System.isMobile ? 48 : 65,
                    height: System.isMobile ? 48 : 65,
                  )),
          
              // 2) subtitle (can wrap normally)
              Text(
                'DIGITAL PRINTING\nMACHINERY SUPPLIER.',
                maxLines: 3,
                overflow: TextOverflow.clip,
                textAlign: .center,
                style: TextStyle(
                  height: 1,
                  letterSpacing: 0,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'RedHatDisplay',
                  fontSize: screenWidth < 1210 ? 65 : 77,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
          
              SizedBox(
                width: 225,
                height: 60,
                child: UiHelper.button(
                  callback: () {
                    context.go('/products');
                    return;
                  },
                  color: Colors.blue,
                  filled: true,
                  borderRadius: 0,
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
              ),
          
            ],
          ),
        ),
        Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 30,
              height: 150,
              color: Theme.of(context).colorScheme.secondary,
            )
        ),
        Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: 30,
              height: 150,
              color: Theme.of(context).colorScheme.onPrimary,
            )
        )
      ],
    );
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
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    TextSpan(
                      text: 'PRINTING MACHINERY SUPPLIER.',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        height: 1,
                        letterSpacing: 2,
                        color: Theme.of(context).colorScheme.onPrimary,
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
      Expanded(
        flex: 2,
        child: HomeBannerCarousel(isActive: true),
      ),
    ];
  }
}