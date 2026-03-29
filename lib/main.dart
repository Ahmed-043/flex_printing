import 'package:flex_printing/pages/home_page.dart';
import 'package:flex_printing/pages/root_layout.dart';
import 'package:flex_printing/theme/app_theme.dart';
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
          path: 'products',
          builder: (context, state) => const RootLayout(
            child: DummyPage(title: 'Products'),
          ),
        ),
        GoRoute(
          path: 'contact',
          builder: (context, state) => const RootLayout(
            child: DummyPage(title: 'Contact'),
          ),
        ),
        GoRoute(
          path: 'events',
          builder: (context, state) => const RootLayout(
            child: DummyPage(title: 'Events'),
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
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system, // uses device setting for now
      routerConfig: _router,
    );
  }
}