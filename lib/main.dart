import 'package:flex_printing/pages/admin_page/clients_manager_page.dart';
import 'package:flex_printing/pages/admin_page/create_product_page.dart';
import 'package:flex_printing/pages/admin_page/events_manager_page.dart';
import 'package:flex_printing/pages/admin_page/materials_manager_page.dart';
import 'package:flex_printing/pages/contactus_page/contactus_page.dart';
import 'package:flex_printing/config/supabase_config.dart';
import 'package:flex_printing/pages/admin_page/admin_page.dart';
import 'package:flex_printing/pages/home_page/home_page.dart';
import 'package:flex_printing/pages/products_page/product_details_page.dart';
import 'package:flex_printing/pages/products_page/products_page.dart';
import 'package:flex_printing/pages/root/root_layout.dart';
import 'package:flex_printing/models/product/product_record.dart';
import 'package:flex_printing/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String? startupError;
  try {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  } catch (e, st) {
    debugPrint('Supabase init FAILED: $e');
    debugPrintStack(stackTrace: st);
    startupError = _friendlyStartupError(e);
  }
  runApp(MyApp(startupError: startupError));
}

String _friendlyStartupError(Object error) {
  final message = error.toString();
  if (message.contains('Failed host lookup') ||
      message.contains('No such host is known')) {
    return 'Could not reach Supabase host. Check the project URL in Supabase settings and your DNS/network connection.';
  }
  if (message.contains('timed out') || message.contains('TimeoutException')) {
    return 'Supabase startup timed out. Check your internet connection and try again.';
  }
  return 'Supabase failed to initialize. Please verify your Supabase URL and anon key.';
}

ProductRecord? _productFromExtra(Object? extra, {int? expectedId}) {
  if (extra == null) return null;

  if (extra is ProductRecord) {
    if (expectedId != null && extra.id != expectedId) return null;
    return extra;
  }

  if (extra is Map) {
    try {
      final json = Map<String, dynamic>.from(extra as Map);
      final firstImage = json['first_image'];
      if (firstImage is Map) {
        json['first_image'] = Map<String, dynamic>.from(firstImage as Map);
      }

      final parsed = ProductRecord.fromJson(json);
      if (expectedId != null && parsed.id != expectedId) return null;
      return parsed;
    } catch (_) {
      return null;
    }
  }

  return null;
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
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) {
                final productId = int.tryParse(state.pathParameters['id'] ?? '');
                final product = _productFromExtra(
                  state.extra,
                  expectedId: productId,
                );
                return RootLayout(
                  child: ProductDetailsPage(
                    product: product,
                    productId: productId,
                  ),
                );
              },
            ),
          ],
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
        GoRoute(
          path: 'admin/create-product',
          builder: (context, state) => const RootLayout(
            child: CreateProductPage(),
          ),
        ),
        GoRoute(
          path: 'admin/events',
          builder: (context, state) => const RootLayout(
            child: EventsManagerPage(),
          ),
        ),
        GoRoute(
          path: 'admin/materials',
          builder: (context, state) => const RootLayout(
            child: MaterialsManagerPage(),
          ),
        ),
        GoRoute(
          path: 'admin/clients',
          builder: (context, state) => const RootLayout(
            child: ClientsManagerPage(),
          ),
        ),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.startupError});

  final String? startupError;

  @override
  Widget build(BuildContext context) {
    if (startupError != null) {
      return MaterialApp(
        title: 'TEX PRINT',
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        home: _StartupErrorScreen(message: startupError!),
      );
    }

    return MaterialApp.router(
      title: 'TEX PRINT',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system, // uses device setting for now
      routerConfig: _router,
    );
  }
}

class _StartupErrorScreen extends StatelessWidget {
  const _StartupErrorScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.cloud_off, color: theme.colorScheme.secondary),
                        const SizedBox(width: 10),
                        const Text(
                          'Startup Error',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(message),
                    const SizedBox(height: 16),
                    Text(
                      'After fixing config/network, restart the app.',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
