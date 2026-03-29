import 'package:flutter/material.dart';

class HomeBannerCarousel extends StatelessWidget {
  const HomeBannerCarousel({
    super.key,
    required this.controller,
    this.itemCount = 10,
  });

  final PageController controller;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: PageView.builder(
          controller: controller,
          itemCount: itemCount,
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