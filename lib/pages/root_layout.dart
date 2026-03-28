import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RootLayout extends StatelessWidget {
  final Widget child;

  const RootLayout({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 1050;

    return Scaffold(
      body: Column(
        children: [
          // Fixed Navigation Bar
          Container(
            color: Theme.of(context).colorScheme.secondary,
            height: 100,
            padding: const EdgeInsets.symmetric(horizontal: 50,vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: .center,
              children: [
                GestureDetector(
                  onTap: () => context.go('/'),
                  child: InkWell(
                    hoverColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onTap: () => context.go('/'),
                    child: Row(
                      crossAxisAlignment: .center,
                      children: [
                        Container(
                          //margin: EdgeInsets.only(top: 10),
                          width: isMobile ? 48 : 78,
                          height: isMobile ? 48 : 78,
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            shape: .circle
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'TEX PRINT',
                          style: TextStyle(
                            fontSize: isMobile ? 22 : 36,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onPrimary
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
               isMobile ?
                   IconButton(
                       onPressed: (){},
                       iconSize: 35,
                       icon: Icon(Icons.menu_rounded)
                   )
                   : Row(
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
              ],
            ),
          ),
          // Content Area
          Expanded(child: child),
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
    final isSelected = currentRoute == route;

    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: InkWell(
        onTap: () => context.go(route),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white60 : Colors.white,
              fontWeight: FontWeight.w200,
              fontSize: 32,
            ),
          ),
        ),
      ),
    );
  }
}
