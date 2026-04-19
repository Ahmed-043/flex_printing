import 'dart:async';

import 'package:flex_printing/models/System/system.dart';
import 'package:flex_printing/models/banner_image.dart';
import 'package:flutter/material.dart';

import '../../methods/images/fetch_images.dart';

class HomeBannerCarousel extends StatefulWidget {
  const HomeBannerCarousel({super.key, this.isActive = true});

  final bool isActive;

  @override
  State<HomeBannerCarousel> createState() => _HomeBannerCarouselState();
}

class _HomeBannerCarouselState extends State<HomeBannerCarousel> {
  final PageController scrollController = PageController();

  List<BannerImage> bannerImages = const [];
  int _bannerCount = 0;

  int _currentIndex = 0;

  Timer? _autoTimer;
  bool _autoAnimating = false;

  @override
  void initState() {
    super.initState();
    _loadBannerImages();

    // Update name when user scrolls manually (settled page changes)
    scrollController.addListener(_handleScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoPlay();
    });
  }

  @override
  void didUpdateWidget(covariant HomeBannerCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isActive && oldWidget.isActive) {
      _autoTimer?.cancel();
      return;
    }
    if (widget.isActive && !oldWidget.isActive) {
      _startAutoPlay();
    }
  }

  void _handleScroll() {
    if (!scrollController.hasClients) return;
    final page = scrollController.page;
    if (page == null) return;

    // only update when close to a full page (reduces flicker)
    final int idx = page.round();
    if (idx != _currentIndex && idx >= 0 && idx < _bannerCount) {
      setState(() => _currentIndex = idx);
    }
  }

  Future<void> _loadBannerImages() async {
    final images = await getBannerImages();
    if (!mounted) return;

    setState(() {
      bannerImages = images;
      _bannerCount = images.length;
      _currentIndex = 0;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoPlay();
    });
  }

  void _startAutoPlay() {
    _autoTimer?.cancel();
    if (_bannerCount == 0 || !widget.isActive) return;

    _autoTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (!mounted || !scrollController.hasClients || _autoAnimating) return;
      if (!widget.isActive) return;

      final page = scrollController.page;
      if (page == null) return;

      final settled = (page - page.round()).abs() < 0.001;
      if (!settled) return;

      final current = page.round();
      final next = (current + 1) % _bannerCount;

      _autoAnimating = true;
      try {
        if (next == 0 && current != 0) {
          scrollController.jumpToPage(0);
          if (mounted) setState(() => _currentIndex = 0);
        } else {
          await scrollController.animateToPage(
            next,
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOut,
          );
          if (mounted) setState(() => _currentIndex = next);
        }
      } finally {
        _autoAnimating = false;
      }
    });
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    scrollController.removeListener(_handleScroll);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_bannerCount == 0) {
      return const Expanded(
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (System.isMobile) {
      return Expanded(
        flex: 2,
        child: OverflowBox(
          maxWidth: MediaQuery.of(context).size.width + 60,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(1000),
              topRight: Radius.circular(1000),
            ),
            child: Container(
              padding: const EdgeInsets.only(top: 10),
              decoration: _decoration(context),
              child: Column(
                children: [
                  _pages(),
                  SizedBox(
                    height: 50,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _nameBar(),
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

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 10, top: 60),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(1000),
            topRight: Radius.circular(1000),
          ),
          child: Container(
            padding: const EdgeInsets.only(top: 10,),
            decoration: _decoration(context),
            child: Column(
              children: [
                _pages(),
                SizedBox(
                 // height: 55,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 25,right: 20,left: 20),
                    child: Row(
                      mainAxisAlignment: .center,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: IconButton(
                              padding: const EdgeInsets.all(0),
                              onPressed: () {
                                /// reset the timer
                                _startAutoPlay();
                                scrollController.previousPage(
                                  duration: const Duration(seconds: 1),
                                  curve: Curves.easeInOut,
                                );
                              },
                              iconSize: 25,
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                shape: const CircleBorder(),
                              ),
                              icon: const Icon(Icons.arrow_back_ios_rounded),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 8,
                            child: _nameBar()),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: IconButton(
                              padding: const EdgeInsets.all(0),

                              onPressed: () {
                                /// reset the timer
                                _startAutoPlay();
                                scrollController.nextPage(
                                  duration: const Duration(seconds: 1),
                                  curve: Curves.easeInOut,
                                );
                              },
                              iconSize: 25,
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                shape: const CircleBorder(),
                              ),
                              icon: const Icon(Icons.arrow_forward_ios_rounded),
                            ),
                          ),
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

  Widget _nameBar() {
    final String name =
    (_currentIndex >= 0 && _currentIndex < bannerImages.length)
        ? bannerImages[_currentIndex].name
        : '';
    bool small = false;
    if(MediaQuery.of(context).size.width < 1210){
      small = true;
    }
    return Container(
      margin: EdgeInsets.symmetric(horizontal: System.isMobile || small ? 15 : 20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: .center,
            style: TextStyle(
              fontSize: System.isMobile || small ? 20 : 25,
              fontWeight: FontWeight.normal,
              fontFamily: 'PaytoneOne',
              wordSpacing: 5,
              letterSpacing: 1,

              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _decoration(BuildContext context) {
    return BoxDecoration(
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
    );
  }

  Widget _pages() {
    return Expanded(
      child: PageView.builder(
        controller: scrollController,
        itemCount: _bannerCount,
        itemBuilder: (context, index) {
          final banner = bannerImages[index];
          return Padding(
            padding: EdgeInsets.symmetric(vertical: System.isMobile ? 50 : 80.0,horizontal: System.isMobile ? 40 : 20.0 ),
            child: Image.asset(
              banner.path,
              fit: BoxFit.contain,
            ),
          );
        },
      ),
    );
  }
}