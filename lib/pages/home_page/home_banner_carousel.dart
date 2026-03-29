import 'dart:async';

import 'package:flex_printing/models/system.dart';
import 'package:flutter/material.dart';
class HomeBannerCarousel extends StatefulWidget {
  const HomeBannerCarousel({
    super.key,
  });

  @override
  State<HomeBannerCarousel> createState() => _HomeBannerCarouselState();
}

class _HomeBannerCarouselState extends State<HomeBannerCarousel> {

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
print(MediaQuery.of(context).size);
    if(System.isMobile){
      return Expanded(
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
                  _pages(),
                  SizedBox(
                    height: 50,
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
                              margin: const EdgeInsets.symmetric(horizontal: 15),
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
      );

    }
    else{
      return  Expanded(
        child: Padding(
          padding: const EdgeInsets.only(right: 10,top: 60),
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
                  _pages(),
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
      );

  }
  }

  Widget _pages(){
    return  Expanded(
      child: Center(
        child: PageView.builder(
          controller: scrollController,
          itemCount: _bannerCount,
          itemBuilder: (context, index) {
            return Center(
              child: Text(
                'Item ${index + 1}',
                style: const TextStyle(color: Colors.black, fontSize: 50),
              ),
            );
          },
        ),
      ),
    );
  }
}