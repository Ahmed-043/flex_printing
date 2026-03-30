import 'dart:async';
import 'dart:convert';

import 'package:flex_printing/models/system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<List<String>> getBannerImagesPaths() async {
  try {
    // Try to load from manifest (works on native platforms)
    final manifestJson = await rootBundle.loadString('AssetManifest.json');
    final manifest = json.decode(manifestJson) as Map<String, dynamic>;

    final bannerImages = manifest.keys
        .where((key) => key.startsWith('assets/images/banner_images/'))
        .toList()
      ..sort();

    if (bannerImages.isNotEmpty) {
      return bannerImages;
    }
  } catch (e) {
    print('AssetManifest not available, using fallback: $e');
  }

  // Fallback: hardcode paths for web and cases where manifest fails
  // This still allows easy future additions—just add more lines here
  return [
    'assets/images/banner_images/banner1.png',
    'assets/images/banner_images/banner2.png',
    'assets/images/banner_images/banner3.png',
    'assets/images/banner_images/banner4.png',
    'assets/images/banner_images/banner5.png',
    'assets/images/banner_images/banner6.png',
  ];
}

class HomeBannerCarousel extends StatefulWidget {
  const HomeBannerCarousel({
    super.key,
  });

  @override
  State<HomeBannerCarousel> createState() => _HomeBannerCarouselState();
}

class _HomeBannerCarouselState extends State<HomeBannerCarousel> {

  final PageController scrollController = PageController();

  late List<String> bannerImages = [];
  late int _bannerCount = 0;

  Timer? _autoTimer;
  bool _autoAnimating = false;

  @override
  void initState() {
    super.initState();
    _loadBannerImages();
    // start after first frame (safe)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoPlay();
    });
  }

  Future<void> _loadBannerImages() async {
    bannerImages = await getBannerImagesPaths();
    setState(() {
      _bannerCount = bannerImages.length;
    });

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
    if (_bannerCount == 0) {
      return const Expanded(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
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

  Widget _pages() {
    return Expanded(
      child: Center(
        child: PageView.builder(
          controller: scrollController,
          itemCount: _bannerCount,
          itemBuilder: (context, index) {
            return Center(
              child: Image.asset(
                bannerImages[index],
                fit: BoxFit.cover,
              ),
            );
          },
        ),
      ),
    );
  }
}