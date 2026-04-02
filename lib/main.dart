import 'package:flex_printing/pages/contactus_page/contactus_page.dart';
import 'package:flex_printing/pages/home_page/home_page.dart';
import 'package:flex_printing/pages/products_page/products_page.dart';
import 'package:flex_printing/pages/root_layout.dart';
import 'package:flex_printing/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => RootLayout(
        child: HomeContent(
          initialSection: state.uri.queryParameters['section'],
        ),
      ),
      routes: [
        GoRoute(
          path: 'products',
          builder: (context, state) => const RootLayout(
            child: ProductsPage(),
          ),
        ),
        GoRoute(
          path: 'contact',
          builder: (context, state) => const RootLayout(
            child: ContactusPage(),
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