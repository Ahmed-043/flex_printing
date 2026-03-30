import 'package:flex_printing/models/System/system.dart';
import 'package:flex_printing/shared_widgets/ui_helper.dart';
import 'package:flutter/material.dart';

class AboutEvents extends StatelessWidget {
  const AboutEvents({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      //height: 450,
      child: Column(
        children: [
          UiHelper.title(context: context, title: "About Us"),
          SizedBox(height: System.isMobile ? 30 : 85),
          SizedBox(
              //height: System.isMobile ? 130 : 600,
              width: System.isMobile ? 340 : 1000,
              child: Text(
                  "Main focused on the efficiency we build our equipment using well-known brands,"
                  " delivering the stable-quality products to domestic and abroad customers and thanks to"
                  " our near relations with our supplier's technology team and leading customers we’ve been"
                  " developing innovative engineering solutions",
                  textAlign: .center,
                style: TextStyle(
                  fontSize: System.isMobile ? 15 : 40,
                  height: 1.15,
                  color: Theme.of(context).colorScheme.onPrimary,
                )
              )
          ),
        ],
      ),
    );
  }
}
