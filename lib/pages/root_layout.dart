import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/System/system.dart';

class RootLayout extends StatelessWidget {
  final Widget child;
  const RootLayout({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),

            backgroundColor: Theme.of(context).colorScheme.secondary,
            pinned: false,
            floating: true,
            snap: true,
            titleSpacing: 0,
            title: const SizedBox.shrink(),
            toolbarHeight: System.isMobile ? 70 : 80,
            leadingWidth: System.isMobile ? 180 : 300,
            actionsPadding: EdgeInsets.symmetric(horizontal:System.isMobile ? 20 : 40),
            leading: InkWell(
              hoverColor: Colors.transparent,
              splashColor: Colors.transparent,
              onTap: () => context.go('/'),
              child: Row(
                crossAxisAlignment: .center,
                mainAxisAlignment: .end,
                children: [
                  Container(
                    //margin: EdgeInsets.only(top: 10),
                    width: System.isMobile ? 48 : 65,
                    height: System.isMobile ? 48 : 65,
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      shape: .circle,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'TEX PRINT',
                    style: TextStyle(
                      fontSize: System.isMobile ? 22 : 36,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              System.isMobile
                  ? Builder(
                builder: (context) {
                  return InkWell(
                    onTap: () async {
                      final box =
                      context.findRenderObject() as RenderBox;
                      final pos = box.localToGlobal(Offset.zero);
                      showTopMenu(
                        context,
                        buttonPos: pos,
                        buttonSize: box.size,
                      );
                    },
                    child: const Icon(Icons.menu_rounded, size: 30),
                  );
                },
              )
                  : Navbar(),
            ],

          ),
          SliverToBoxAdapter(child: child),
        ],
      ),
    );
  }
}

Future<void> showTopMenu(
  BuildContext context, {
  required Offset buttonPos,
  required Size buttonSize,
}) async {
  final route = await showGeneralDialog<String>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'menu',
    barrierColor: Colors.transparent, // no dim, only shadow
    pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    transitionDuration: const Duration(milliseconds: 140),
    transitionBuilder: (ctx, anim, __, child) {
      final theme = Theme.of(ctx);
      final bg = theme.colorScheme.secondary;

      // Menu position: directly under the button
      final top = buttonPos.dy + buttonSize.height + 8;
      final left = buttonPos.dx - 50;
      const width = 100.0;

      return FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
        child: Stack(
          children: [
            // tap outside to close
            Positioned.fill(
              child: GestureDetector(onTap: () => Navigator.pop(ctx)),
            ),

            Positioned(
              top: top,
              left: left,
              width: width,
              child: Material(
                color: Colors.transparent,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.35),
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _MenuItem(title: 'Home', route: '/'),
                        _MenuItem(title: 'About', route: '/about'),
                        _MenuItem(title: 'Products', route: '/products'),
                        _MenuItem(title: 'Contact', route: '/contact'),
                        _MenuItem(title: 'Events', route: '/events'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );

  if (route != null && context.mounted) {
    context.go(route);
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({required this.title, required this.route});
  final String title;
  final String route;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pop(context, route),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class Navbar extends StatelessWidget {
  const Navbar({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: .horizontal,
      child: Row(
        children: [
          _NavButton(
            title: 'Home',
            route: '/',
            currentRoute: GoRouterState.of(context).uri.path,
          ),
          _NavButton(
            title: 'About',
            route: '/about',
            currentRoute: GoRouterState.of(context).uri.path,
          ),
          _NavButton(
            title: 'Products',
            route: '/products',
            currentRoute: GoRouterState.of(context).uri.path,
          ),
          _NavButton(
            title: 'Contact',
            route: '/contact',
            currentRoute: GoRouterState.of(context).uri.path,
          ),
          _NavButton(
            title: 'Events',
            route: '/events',
            currentRoute: GoRouterState.of(context).uri.path,
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String title;
  final String route;
  final String currentRoute;

  const _NavButton({
    required this.title,
    required this.route,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    final isSelected = currentRoute == route;

    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: InkWell(
        onTap: () => isSelected ? null : context.go(route),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white60 : Colors.white,
              fontWeight: FontWeight.w200,
              fontSize: screenWidth < 1050 ? 25 : 32,
            ),
          ),
        ),
      ),
    );
  }
}
