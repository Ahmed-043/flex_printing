import 'package:flex_printing/models/System/system.dart';
import 'package:flex_printing/shared_widgets/ui_helper.dart';
import 'package:flutter/material.dart';

class OtherInfo extends StatelessWidget {
  const OtherInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    List<Widget> info() {
      Widget info(IconData icon, String description) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: .center,
            children: [
              SizedBox(
                height: System.isMobile ? 70 : 115,
                width: System.isMobile ? 70 : 115,
                child: Icon(
                  icon,
                  color: theme.onPrimary,
                  size: System.isMobile ? 70 : 115,
                ),
              ),
              SizedBox(height: System.isMobile ? 20 : 32),
              SizedBox(
                width: System.isMobile ? 300 : 360,
                child: Text(
                  description,
                  textAlign: .center,
                  style: TextStyle(
                    height: 1.2,
                    fontSize: System.isMobile ? 15 : 25,
                    color: theme.onPrimary,
                  ),
                ),
              ),
              SizedBox(height: System.isMobile ? 50 : 70),
            ],
          ),
        );
      }

      return [
        info(
          Icons.military_tech_rounded,
          "Tex Print delivers quality products and services,"
          " creating outstanding experiences for customers nationwide.",
        ),
        info(
          Icons.settings,
          "Our expert technical team ensures efficient, customer-focused "
          "service with technician visits as early as possible.",
        ),
        info(
          Icons.lightbulb_outline_rounded,
          "Tex Print provides quality inks and supplies"
          " in one place to help partners grow their business.",
        ),
      ];
    }

    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          UiHelper.title(context: context, title: "Why choose TEX Print?"),
          SizedBox(height: System.isMobile ? 50 : 115),
          if (System.isMobile) ...info(),
          if (!System.isMobile)
            Wrap(
              crossAxisAlignment: .center,
              alignment: .center,
              children: info(),
            ),
        ],
      ),
    );
  }

}

class OurEquipmentsSection extends StatelessWidget {
  const OurEquipmentsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          UiHelper.title(context: context, title: "Our Equipments"),
          SizedBox(height: System.isMobile ? 40 : 80),
          SizedBox(
            width: System.isMobile ? 345 : 1100,
            height: System.isMobile ? 130 : 350,
            child: Image.asset(
              "assets/images/our_equipments.png",
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

