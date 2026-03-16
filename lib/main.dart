import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flex_printing/pages/dummy_page.dart';

void main() {
  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const RootLayout(child: HomeContent()),
      routes: [
        GoRoute(
          path: 'about',
          builder: (context, state) => const RootLayout(
            child: DummyPage(title: 'About'),
          ),
        ),
        GoRoute(
          path: 'services',
          builder: (context, state) => const RootLayout(
            child: DummyPage(title: 'Services'),
          ),
        ),
        GoRoute(
          path: 'contact',
          builder: (context, state) => const RootLayout(
            child: DummyPage(title: 'Contact'),
          ),
        ),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flex Printing',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routerConfig: _router,
    );
  }
}

// Shared layout with persistent navbar
class RootLayout extends StatelessWidget {
  final Widget child;

  const RootLayout({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Navigation Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context.go('/'),
                    child: const Row(
                      children: [
                        FlutterLogo(size: 36),
                        SizedBox(width: 10),
                        Text(
                          'Flex Printing',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
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
                        title: 'Services',
                        route: '/services',
                        currentRoute: GoRouterState.of(context).uri.path,
                      ),
                      _NavButton(
                        title: 'Contact',
                        route: '/contact',
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
      child: TextButton(
        onPressed: () => context.go(route),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.deepPurple : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Welcome to Flex Printing Home Page',
        style: TextStyle(fontSize: 22),
      ),
    );
  }
}