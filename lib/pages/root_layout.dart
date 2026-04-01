import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/System/system.dart';

class RootLayout extends StatefulWidget {
  final Widget child;
  const RootLayout({required this.child, super.key});

  @override
  State<RootLayout> createState() => _RootLayoutState();
}

class _RootLayoutState extends State<RootLayout> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final useCompactNav = System.isMobile || screenWidth < 1050;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: CustomScrollView(
        slivers: [
          SliverLayoutBuilder(
            builder: (context, constraints) {
              final isHome = GoRouterState.of(context).uri.path == '/';
              final isAtTop = constraints.scrollOffset <= 100;
              final shouldRound = !isHome || !isAtTop;
              return SliverAppBar(
                shape: shouldRound
                    ? const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      )
                    : null,
                clipBehavior: Clip.antiAlias,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                pinned: false,
                floating: true,
                snap: true,
                titleSpacing: 0,
                title: const SizedBox.shrink(),
                toolbarHeight: useCompactNav ? 70 : 80,
                leadingWidth: useCompactNav ? 180 : 300,
                actionsPadding: EdgeInsets.symmetric(
                  horizontal: useCompactNav ? 20 : 40,
                ),
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
                        width: useCompactNav ? 48 : 65,
                        height: useCompactNav ? 48 : 65,
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          shape: .circle,
                        ),
                      ),
                      SizedBox(width: 10),
                      Flexible(
                        child: FittedBox(
                          alignment: Alignment.centerLeft,
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'TEX PRINT',
                            style: TextStyle(
                              fontSize: useCompactNav ? 22 : 36,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSecondary,
                            ),
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

              );
            },
          ),
          SliverToBoxAdapter(child: widget.child),
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
    pageBuilder: (_, _, _) => const SizedBox.shrink(),
    transitionDuration: const Duration(milliseconds: 140),
    transitionBuilder: (ctx, anim, _, child) {
      final theme = Theme.of(ctx);
      final bg = theme.colorScheme.secondary;

      // Menu position: directly under the button
      final top = buttonPos.dy + buttonSize.height + 25;
      final left = buttonPos.dx - 60;
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
                        color: Colors.black.withAlpha(90),
                        blurRadius: 5,
                        spreadRadius: 1,
                        offset: const Offset(-1, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _MenuItem(title: 'Home', route: '/'),
                        _MenuItem(title: 'About', route: '/?section=about'),
                        _MenuItem(title: 'Products', route: '/products'),
                        _MenuItem(title: 'Contact', route: '/contact'),
                        _MenuItem(title: 'Events', route: '/?section=events'),
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
      onTap: () {
        Navigator.pop(context, route);
      },
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
            route: '/',
            currentRoute: GoRouterState.of(context).uri.path,
            section: 'about',
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
            route: '/',
            currentRoute: GoRouterState.of(context).uri.path,
            section: 'events',
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
  final String? section;

  const _NavButton({
    required this.title,
    required this.route,
    required this.currentRoute,
    this.section,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    final isSelected = section == null && currentRoute == route;

    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),

        onTap: () {
          if (section != null) {
            context.go('/?section=$section');
            return;
          }
          if (!isSelected) {
            context.go(route);
          }
        },
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
