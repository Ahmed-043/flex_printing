import 'package:flex_printing/pages/root/root_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import '../../models/System/system.dart';

class RootLayout extends StatefulWidget {
  final Widget child;
  const RootLayout({required this.child, super.key});

  @override
  State<RootLayout> createState() => _RootLayoutState();
}

class _RootLayoutState extends State<RootLayout> {
  final ScrollController scrollController = ScrollController();

  void _scrollToTop() {
    if (!scrollController.hasClients) return;
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOut,
    );
  }

  void _handleHomeTap(bool isHome) {
    if (isHome) {
      _scrollToTop();
      return;
    }
    context.go('/');
  }


  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth > 850){
      System.isMobile = false;
    }


    final useCompactNav = System.isMobile;
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: theme.primary,
      body: NestedScrollView(
        controller: scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverLayoutBuilder(
              builder: (context, constraints) {
                final isHome = GoRouterState.of(context).uri.path == '/';
                final shouldRound = !isHome || innerBoxIsScrolled;
                return SliverAppBar(
                  shape: shouldRound
                      ? RoundedRectangleBorder(
                    side: BorderSide(
                      strokeAlign: 0,
                      color: theme.primary,
                      width: 7,
                      style: BorderStyle.solid,

                    ),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(System.isMobile ? 20 : 25),
                            bottomRight: Radius.circular(System.isMobile ? 20 : 25),
                            topLeft: Radius.circular(System.isMobile ? 20 : 25),
                            topRight: Radius.circular(System.isMobile ? 20 : 25),

                          ),
                        )
                      : null,
                  clipBehavior: Clip.antiAlias,
                  backgroundColor: theme.secondaryContainer,
                  pinned: false,
                  floating: true,
                  snap: true,
                  titleSpacing: 0,
                  title: const SizedBox.shrink(),
                  toolbarHeight: useCompactNav ? 70 : 100,
                  leadingWidth: useCompactNav ? 190 : 350,
                  actionsPadding: EdgeInsets.symmetric(
                    horizontal: useCompactNav ? 20 : 80,
                  ),
                  leading: InkWell(
                    hoverColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () => _handleHomeTap(isHome),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(shouldRound ? 15 : 0),
                          child: Container(
                           // margin: EdgeInsets.only(left: System.isMobile ? 20 : 0),
                              width: useCompactNav ? 48 : 65,
                              height: useCompactNav ? 48 : 65,
                              decoration: const BoxDecoration(
                                color: Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                              child: SvgPicture.asset(
                                'assets/images/logo_sharp.svg',
                                width: System.isMobile ? 48 : 65,
                                height: System.isMobile ? 48 : 65,
                              )),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: FittedBox(
                            alignment: Alignment.centerLeft,
                            fit: BoxFit.scaleDown,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'TEX PRINT',
                                  style: TextStyle(
                                    fontSize: useCompactNav ? 22 : 36,
                                    fontWeight: FontWeight.w600,
                                    color: theme.onSecondary,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: useCompactNav ? 4 : 8,
                                      left: useCompactNav ? 2 : 4),
                                  child: SvgPicture.asset(
                                    'assets/images/icons/registered.svg',
                                    width: useCompactNav ? 8 : 12,
                                    height: useCompactNav ? 8 : 12,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    useCompactNav
                        ? Builder(
                            builder: (context) {
                              return SizedBox(
                                height: 60,
                                width: 60,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(18),
                                  onTap: () async {
                                    final box =
                                        context.findRenderObject() as RenderBox;
                                    final pos = box.localToGlobal(Offset.zero);
                                    showTopMenu(
                                      context,
                                      buttonPos: pos,
                                      buttonSize: box.size,
                                      currentRoute: GoRouterState.of(context)
                                          .uri
                                          .toString(),
                                      onHomeTapWhileSelected: _scrollToTop,
                                    );
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(Icons.menu_rounded, size: 30),
                                  ),
                                ),
                              );
                            },
                          )
                        : Navbar(
                            currentRoute:
                                GoRouterState.of(context).uri.toString(),
                            onHomeTapWhileSelected: _scrollToTop,
                          ),
                  ],
                );
              },
            ),
          ];
        },
        body: widget.child,
      ),
    );
  }
}

Future<void> showTopMenu(
  BuildContext context, {
  required Offset buttonPos,
  required Size buttonSize,
  required String currentRoute,
  VoidCallback? onHomeTapWhileSelected,
}) async {
  final route = await showGeneralDialog<String>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'menu',
    barrierColor: Colors.transparent, // no dim, only shadow
    pageBuilder: (_, _, _) => const SizedBox.shrink(),
    transitionDuration: const Duration(milliseconds: 250),
    transitionBuilder: (ctx, anim, _, child) {
      final theme = Theme.of(ctx);
      final bg = theme.colorScheme.onPrimary;

      // Menu position: directly under the button
      final top = buttonPos.dy + buttonSize.height + 25;
      final left = buttonPos.dx - 60;
      const width = 135.0;

      return Stack(
        children: [
          // tap outside to close
          Positioned.fill(
            child: GestureDetector(onTap: () => Navigator.pop(ctx)),
          ),

          Positioned(
            top: top,
            left: left,
            width: width,
            child: SlideTransition(

              position: Tween<Offset>(

                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
              child: Material(
                color: Colors.transparent,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(14),
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: Colors.black.withAlpha(90),
                    //     blurRadius: 5,
                    //     spreadRadius: 1,
                    //     offset: const Offset(-1, 2),
                    //   ),
                    // ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MenuItem(title: 'Home', route: '/'),
                        MenuItem(title: 'Products', route: '/products'),
                        MenuItem(title: 'About', route: '/?section=about'),
                        MenuItem(title: 'Events', route: '/?section=events'),
                        MenuItem(title: 'Contact', route: '/contact'),
                        if(!kIsWeb)
                        MenuItem(title: 'Admin', route: '/admin'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );

  if (route != null && context.mounted) {
    if (route == '/admin') {
      showAdminAuthDialog(context);
    } else if (route == '/' && currentRoute == '/') {
      onHomeTapWhileSelected?.call();
    } else {
      context.go(route);
    }
  }
}

class Navbar extends StatelessWidget {
  const Navbar({
    super.key,
    required this.currentRoute,
    this.onHomeTapWhileSelected,
  });

  final String currentRoute;
  final VoidCallback? onHomeTapWhileSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: .horizontal,
      child: Row(
        children: [
          NavButton(
            title: 'Home',
            route: '/',
            currentRoute: currentRoute,
            onTapWhileSelected: onHomeTapWhileSelected,
          ),

          NavButton(
            title: 'Products',
            route: '/products',
            currentRoute: currentRoute,
          ),
          NavButton(
            title: 'About',
            route: '/',
            currentRoute: currentRoute,
            section: 'about',
          ),
          NavButton(
            title: 'Events',
            route: '/',
            currentRoute: currentRoute,
            section: 'events',
          ),
          NavButton(
            title: 'Contact',
            route: '/contact',
            currentRoute: currentRoute,
          ),
          if(!kIsWeb)
          NavButton(
            title: 'Admin',
            route: '/admin',
            currentRoute: currentRoute,
            onTapOverride: () => showAdminAuthDialog(context),
          ),
        ],
      ),
    );
  }
}
