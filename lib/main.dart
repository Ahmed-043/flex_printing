import 'package:flex_printing/pages/contactus_page/contactus_page.dart';
import 'package:flex_printing/config/supabase_config.dart';
import 'package:flex_printing/pages/admin_page/admin_page.dart';
import 'package:flex_printing/pages/home_page/home_page.dart';
import 'package:flex_printing/pages/products_page/products_page.dart';
import 'package:flex_printing/pages/root_layout.dart';
import 'package:flex_printing/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );

    // Confirms initialize() completed successfully.
    debugPrint('Supabase init OK: ${SupabaseConfig.url}');

    // Optional lightweight runtime check:
    final session = Supabase.instance.client.auth.currentSession;
    debugPrint('Current session present: ${session != null}');
  } catch (e, st) {
    debugPrint('Supabase init FAILED: $e');
    debugPrintStack(stackTrace: st);
    rethrow; // keeps failure visible during startup
  }


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
        GoRoute(
          path: 'admin',
          builder: (context, state) => const RootLayout(
            child: AdminPage(),
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