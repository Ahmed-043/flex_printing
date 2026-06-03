import 'package:flex_printing/shared_widgets/scaled_container.dart';
import 'package:flex_printing/shared_widgets/ui_helper.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/System/system.dart';

class FooterSection extends StatefulWidget {
  const FooterSection({super.key});

  @override
  State<FooterSection> createState() => _FooterSectionState();
}

class _FooterSectionState extends State<FooterSection> {
  bool hoveredContact = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    Future<void> openSocial(String url) async {
      final uri = Uri.parse(url);
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: '_blank',
      );
    }
    Future<void> openWhatsApp(String phoneNumber) async {
      final normalized = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
      if (normalized.isEmpty) return;
      await openSocial('https://wa.me/$normalized');
    }
    Widget svgIcon(String name) {
      return SvgPicture.asset(
        'assets/images/icons/$name.svg',
        width: System.isMobile ? 24 : 32,
        height: System.isMobile ? 24 : 32,
        //colorFilter: ColorFilter.mode(theme.onSecondary),
      );
    }
    Widget socialIconLink({
      required String assetName,
      required String url,
      required String label,
    }) {
      return ScaledContainer(
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => openSocial(url),
            behavior: HitTestBehavior.opaque,
            child: Semantics(
              button: true,
              label: label,
              child: svgIcon(
                assetName,
              ),
            ),
          ),
        ),
      );
    }
    return Container(
      height: System.isMobile ? 220 : 410,
      width: double.infinity,
      color: theme.secondary,
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
                    color: theme.onSecondary,
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
                    socialIconLink(
                      assetName: 'Icon',
                      url: 'https://www.facebook.com/share/1FQTfiSdT7/',
                      label: 'Facebook',
                    ),
                    SizedBox(width: 30),
                    socialIconLink(
                      assetName: 'Icon-1',
                      url: 'https://www.instagram.com/texprint01?igsh=MWwwaG5pYXY4YzBraA==',
                      label: 'Instagram',
                    ),
                    SizedBox(width: 30),
                    socialIconLink(
                      assetName: 'Icon-2',
                      url: 'https://www.tiktok.com/@user758364154?_r=1&_t=ZS-96CB2Na9yOz',
                      label: 'TikTok',
                    ),
                    // SizedBox(width: 20),
                    // svgIcon(
                    //   'Icon-3',
                    // ),
                  ],
                ),
              ],
            ),
          ),
          if(!System.isMobile && MediaQuery.of(context).size.width > 1100)...[
            SizedBox(
              width: System.isMobile ? 250 : 300,
              child: Column(
                crossAxisAlignment: .center,
                children: [
                  Text(
                    "Quick Links",
                    style: TextStyle(
                      fontSize: System.isMobile ? 20 : 25,
                      fontWeight: FontWeight.w600,
                      color: theme.onSecondary,
                    ),
                  ),
                  SizedBox(height: System.isMobile ? 15 : 20),
                  SizedBox(
                    // width: System.isMobile ? 250 : 300,
                    child: Builder(builder: (context) {
                      final linkStyle = TextStyle(
                        fontSize: 17,
                        letterSpacing: 1,
                        height: 2,
                        fontWeight: FontWeight.w300,
                        color: theme.onSecondary,
                      );

                      TextSpan link(String label, VoidCallback onTap) {
                        return TextSpan(
                          text: label,
                          style: linkStyle,
                          recognizer: TapGestureRecognizer()..onTap = onTap,
                        );
                      }

                      return RichText(
                        text: TextSpan(
                          children: [
                            link('Home', () => context.go('/')),
                            const TextSpan(text: '\n'),
                            link('About Us', () => context.go(Uri(path: '/', queryParameters: {'section': 'about'}).toString())),
                            const TextSpan(text: '\n'),
                            link('Products', () => context.go('/products')),
                            const TextSpan(text: '\n'),
                            link('Services', () => context.go(Uri(path: '/', queryParameters: {'section': 'services'}).toString())),
                            const TextSpan(text: '\n'),
                            link('Contact Us', () => context.go('/contact')),
                          ],
                        ),
                      );
                    }),
                  ),

                ],
              ),
            ),
            //   if(MediaQuery.of(context).size.width > 1280)
            //     SizedBox(
            //   width: System.isMobile ? 250 : 300,
            //   child: Column(
            //     crossAxisAlignment: .start,
            //     children: [
            //       Text(
            //         "Our Services",
            //         style: TextStyle(
            //           fontSize: System.isMobile ? 20 : 25,
            //           fontWeight: FontWeight.w600,
            //           color: theme.onSecondary,
            //         ),
            //       ),
            //       SizedBox(height: System.isMobile ? 15 : 20),
            //       SizedBox(
            //         width: System.isMobile ? 250 : 300,
            //         child: Text(
            //           "Custom T-Shirt Printing\nBusiness Cards\nBanners & Posters\nBrochures & Flyers\nStickers & Labels",
            //           style: TextStyle(
            //             fontSize: 17,
            //             letterSpacing: 1,
            //             height: 2,
            //             fontWeight: FontWeight.w300,
            //           ),
            //         ),
            //       ),
            //
            //     ],
            //   ),
            // ),
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
                    color: theme.onSecondary,
                  ),
                ),
                SizedBox(height: System.isMobile ? 15 : 20),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,color: theme.onSecondary,size: System.isMobile ? 18 : 24,),
                    SizedBox(width: 8,),
                    Flexible(
                      child: Text(
                        "Defence Road Sialkot, Pakistan",
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
                ScaledContainer(
                  child: InkWell(
                    onTap: () => openWhatsApp('+92 312 7665130'),
                    onHover: (e){
                      if (System.isMobile) return;
                      setState(() => hoveredContact = e);
                    },
                    hoverColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: Row(
                      children: [
                        Icon(Icons.phone_outlined,color: theme.onSecondary,size: System.isMobile ? 18 : 24,),
                        SizedBox(width: 8,),
                        Flexible(
                          child: Text(
                            "+92 312 7665130",
                            style: TextStyle(
                              fontSize: System.isMobile ? 12 : 17,
                              letterSpacing: 0.2,
                              height: 1.25,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                        if(hoveredContact)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              "Chat on WhatsApp",
                              style: TextStyle(
                                fontSize: System.isMobile ? 10 : 14,
                                letterSpacing: 0.2,
                                height: 1.25,
                                fontWeight: FontWeight.w300,
                                color: theme.primary,
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: System.isMobile ? 15 : 20),
                Row(
                  children: [
                    Icon(Icons.mail_outline_rounded,color: theme.onSecondary,size: System.isMobile ? 18 : 24,),
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
