import 'package:flex_printing/models/System/system.dart';
import 'package:flex_printing/shared_widgets/ui_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class OtherInfo extends StatelessWidget {
  const OtherInfo({super.key});

  @override
  Widget build(BuildContext context) {
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
                  color: Theme.of(context).colorScheme.onPrimary,
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
                    color: Theme.of(context).colorScheme.onPrimary,
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

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: System.isMobile ? 220 : 410,
      width: double.infinity,
      color: Theme.of(context).colorScheme.secondary,
      padding: EdgeInsets.only(top: System.isMobile ? 40 : 100,left: System.isMobile ? 0 : 40,right: System.isMobile ? 0 : 40),
      child: Wrap(
        alignment: .spaceEvenly,

        children: [
          SizedBox(
            width: System.isMobile ? 180 : 300,
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  "TEX Print",
                  style: TextStyle(
                    fontSize: System.isMobile ? 20 : 25,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
                SizedBox(height: System.isMobile ? 15 : 20),
                SizedBox(
                  child: Text(
                    "Your trusted partner for professional printing solutions. Quality products delivered on time",
                    style: TextStyle(
                      fontSize: System.isMobile ? 12 : 17,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
                SizedBox(height: System.isMobile ? 12 : 22),
                Row(
                  children: [
                    svgIcon(
                      'Icon',
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                    SizedBox(width: 20),
                    svgIcon(
                      'Icon-1',
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                    SizedBox(width: 20),
                    svgIcon(
                      'Icon-2',
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                    SizedBox(width: 20),
                    svgIcon(
                      'Icon-3',
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if(!System.isMobile && MediaQuery.of(context).size.width > 1100)...[
          SizedBox(
            width: System.isMobile ? 250 : 300,
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  "Quick Links",
                  style: TextStyle(
                    fontSize: System.isMobile ? 20 : 25,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
                SizedBox(height: System.isMobile ? 15 : 20),
                SizedBox(
                  width: System.isMobile ? 250 : 300,
                  child: Text(
                    "Home\nAbout Us\nProducts\nServices\nContact",
                    style: TextStyle(
                      fontSize: 17,
                      letterSpacing: 1,
                      height: 2,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),

              ],
            ),
          ),
            if(MediaQuery.of(context).size.width > 1280)
              SizedBox(
            width: System.isMobile ? 250 : 300,
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  "Our Services",
                  style: TextStyle(
                    fontSize: System.isMobile ? 20 : 25,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
                SizedBox(height: System.isMobile ? 15 : 20),
                SizedBox(
                  width: System.isMobile ? 250 : 300,
                  child: Text(
                    "Custom T-Shirt Printing\nBusiness Cards\nBanners & Posters\nBrochures & Flyers\nStickers & Labels",
                    style: TextStyle(
                      fontSize: 17,
                      letterSpacing: 1,
                      height: 2,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),

              ],
            ),
          ),
          ],
          SizedBox(
            width: System.isMobile ? 185 : 300,
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  "Contact Us",
                  style: TextStyle(
                    fontSize: System.isMobile ? 20 : 25,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
                SizedBox(height: System.isMobile ? 15 : 20),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,color: Theme.of(context).colorScheme.onSecondary,size: System.isMobile ? 18 : 24,),
                    SizedBox(width: 8,),
                    Flexible(
                      child: Text(
                        "123 Print Street, Design City,\nDC 12345",
                        style: TextStyle(
                          fontSize:System.isMobile ? 12 : 17,
                          letterSpacing: 0.2,
                          height: 1.25,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: System.isMobile ? 15 : 20),
                Row(
                  children: [
                    Icon(Icons.phone_outlined,color: Theme.of(context).colorScheme.onSecondary,size: System.isMobile ? 18 : 24,),
                    SizedBox(width: 8,),
                    Flexible(
                      child: Text(
                        "+1 (555) 123-4567",
                        style: TextStyle(
                          fontSize: System.isMobile ? 12 : 17,
                          letterSpacing: 0.2,
                          height: 1.25,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: System.isMobile ? 15 : 20),
                Row(
                  children: [
                    Icon(Icons.mail_outline_rounded,color: Theme.of(context).colorScheme.onSecondary,size: System.isMobile ? 18 : 24,),
                    SizedBox(width: 8,),
                    Flexible(
                      child: Text(
                        "info@texprint.com",
                        style: TextStyle(
                          fontSize: System.isMobile ? 12 : 17,
                          letterSpacing: 0.2,
                          height: 1.25,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget svgIcon(String name, {Color? color}) {
    return SvgPicture.asset(
      'assets/images/icons/$name.svg',
      width: System.isMobile ? 18 : 24,
      height: System.isMobile ? 18 : 24,
      colorFilter: color == null
          ? null
          : ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
