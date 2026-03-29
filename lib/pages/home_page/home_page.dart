import 'dart:math';

import 'package:flex_printing/models/system.dart';
import 'package:flex_printing/pages/home_page/home_banner_carousel.dart';
import 'package:flex_printing/pages/home_page/products_section.dart';
import 'package:flex_printing/shared_widgets/ui_helper.dart';
import 'package:flutter/material.dart';


class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  late double screenHeight, screenWidth;


  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      child: SizedBox(
        width: 1500,
        child: Column(
          children: [
            _banner(),
            Container(height: 200, color: Theme.of(context).colorScheme.primary),
            ProductsSection(),
            const Text(
              'Welcome to Flex Printing Home Page',
              style: TextStyle(fontSize: 22),
            ),
          ],
        ),
      ),
    );
  }

  Widget _banner() {
    double containerHeight = max(500, screenHeight - (System.isMobile ? 70 : 80));
    if(!System.isMobile){
      containerHeight = min(containerHeight,900);
    }else{
      containerHeight = min(containerHeight,1000);
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