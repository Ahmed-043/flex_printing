import 'dart:async';
import 'dart:math';

import 'package:flex_printing/models/system.dart';
import 'package:flex_printing/shared_widgets/ui_helper.dart';
import 'package:flutter/material.dart';

import 'home_banner_carousel.dart';


class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  late double screenHeight, screenWidth;

  final PageController scrollController = PageController();

  static const int _bannerCount = 10;

  Timer? _autoTimer;
  bool _autoAnimating = false;

  @override
  void initState() {
    super.initState();

    // start after first frame (safe)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoPlay();
    });
  }

  void _startAutoPlay() {
    _autoTimer?.cancel();

    _autoTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (!mounted || !scrollController.hasClients || _autoAnimating) return;

      final page = scrollController.page;
      if (page == null) return;

      // Only run when settled (prevents fighting with user drag)
      final settled = (page - page.round()).abs() < 0.001;
      if (!settled) return;

      final current = page.round();
      final next = (current + 1) % _bannerCount;

      _autoAnimating = true;
      try {
        if (next == 0 && current != 0) {
          // last -> first
          scrollController.jumpToPage(0);
        } else {
          await scrollController.animateToPage(
            next,
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOut,
          );
        }
      } finally {
        _autoAnimating = false;
      }
    });
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      child: Column(
        children: [
          _banner(),
          Container(height: 1500, color: Theme.of(context).colorScheme.primary),
          const Text(
            'Welcome to Flex Printing Home Page',
            style: TextStyle(fontSize: 22),
          ),
        ],
      ),
    );
  }

  Widget _banner() {
    double containerHeight = max(
      500,
      screenHeight - (System.isMobile ? 70 : 100),
    );

    return Container(
      height: containerHeight,
      color: Theme.of(context).colorScheme.secondary,
      child: System.isMobile
          ? Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(children: _mobileBanner()),
      )
          : Padding(
        padding: const EdgeInsets.only(left: 50.0, right: 50, top: 60),
        child: Row(children: _desktopBanner()),
      ),
    );
  }

  List<Widget> _desktopBanner() {
    return [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'DIGITAL\n',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontFamily: 'PaytoneOne',
                      letterSpacing: 5,
                      fontSize: 135,
                      color: Theme.of(context).colorScheme.onSecondary,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextSpan(
                    text: 'PRINTING MACHINERY SUPPLER.',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 43,
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                ],
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
                  fontSize: 34,
                ),
              ),
            ),
            Text(
              "ONE DOOR SOLUTION",
              style: TextStyle(
                fontWeight: FontWeight.w200,
                fontFamily: 'RedHatDisplay',
                fontSize: 43,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            )
          ],
        ),
      ),
      Expanded(
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(1000),
            topRight: Radius.circular(1000),
          ),
          child: Container(
            padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
            decoration: BoxDecoration(
              gradient: const RadialGradient(
                center: Alignment.center,
                radius: 0.8,
                colors: [Colors.white, Color(0xFFBDBDBD)],
                stops: [0.0, 1.0],
              ),
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 5,
                ),
                left: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 5,
                ),
                right: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 5,
                ),
                bottom: BorderSide.none,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(1000),
                topRight: Radius.circular(1000),
              ),
            ),
            child: Column(
              children: [
                HomeBannerCarousel(controller: scrollController, itemCount: _bannerCount),
                SizedBox(
                  height: 55,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            scrollController.previousPage(
                              duration: const Duration(seconds: 1),
                              curve: Curves.easeInOut,
                            );
                          },
                          iconSize: 30,
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: const CircleBorder(),
                          ),
                          icon: const Icon(Icons.arrow_back_ios_rounded),
                        ),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 35),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            scrollController.nextPage(
                              duration: const Duration(seconds: 1),
                              curve: Curves.easeInOut,
                            );
                          },
                          iconSize: 30,
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: const CircleBorder(),
                          ),
                          icon: const Icon(Icons.arrow_forward_ios_rounded),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
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
      Expanded(
        flex: 2,
        child: ClipRRect(
          child: OverflowBox(
            maxWidth: MediaQuery.of(context).size.width + 60,
            child: Container(
              padding: const EdgeInsets.only(top: 10, left: 40, right: 40),
              decoration: BoxDecoration(
                gradient: const RadialGradient(
                  center: Alignment.center,
                  radius: 0.8,
                  colors: [Colors.white, Color(0xFFBDBDBD)],
                  stops: [0.0, 1.0],
                ),
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 5,
                  ),
                  left: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 5,
                  ),
                  right: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 5,
                  ),
                  bottom: BorderSide.none,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(1000),
                  topRight: Radius.circular(1000),
                ),
              ),
              child: Column(
                children: [
                  HomeBannerCarousel(controller: scrollController, itemCount: _bannerCount),
                  SizedBox(
                    height: 55,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              scrollController.previousPage(
                                duration: const Duration(seconds: 1),
                                curve: Curves.easeInOut,
                              );
                            },
                            iconSize: 30,
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              shape: const CircleBorder(),
                            ),
                            icon: const Icon(Icons.arrow_back_ios_rounded),
                          ),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 35),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              scrollController.nextPage(
                                duration: const Duration(seconds: 1),
                                curve: Curves.easeInOut,
                              );
                            },
                            iconSize: 30,
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              shape: const CircleBorder(),
                            ),
                            icon: const Icon(Icons.arrow_forward_ios_rounded),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    ];
  }
}