import 'package:carousel_slider/carousel_slider.dart';
import 'package:flex_printing/models/System/system.dart';
import 'package:flutter/material.dart';

import '../../shared_widgets/ui_helper.dart';


class ClientsEvents extends StatelessWidget {
  final bool isEvents;
  const ClientsEvents({super.key, this.isEvents = false});

  @override
  Widget build(BuildContext context) {
    final double cardWidth = System.isMobile ? 270 : 550;
    final double cardHeight = System.isMobile ? 270 : 650;

    final screenWidth = MediaQuery.of(context).size.width;
    const double desiredGap = 24; // keep card-to-card spacing almost constant

    final double viewportFraction = ((cardWidth + desiredGap) / screenWidth).clamp(
      System.isMobile ? 0.55 : 0.20, // min
      System.isMobile ? 0.60 : 0.75, // max
    );

    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          UiHelper.title(context: context, title: isEvents ? "Satisfied Clients" : "Events"),
          SizedBox(height: System.isMobile ? 58 : 115),
          Center(
            child: CarouselSlider.builder(
              itemCount: 10,
              options: CarouselOptions(
                height: cardHeight,
                viewportFraction: viewportFraction,

                enlargeCenterPage: true,     // ⭐ center zoom
                enlargeFactor: 0.18,         // ≈ your minScale 0.85
                clipBehavior: Clip.none,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 2),
                enableInfiniteScroll: true,
                padEnds: true,
              ),
              itemBuilder: (context, index, realIndex) {
                return Center(
                  child: SizedBox(
                    width: cardWidth,   // STRICT width preserved
                    height: cardHeight,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.image,
                            color: Colors.grey,
                            size: System.isMobile ? 30 : 80,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}