import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flex Printing',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
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
                  Row(
                    children: [
                      _NavButton(label: 'About', pageTitle: 'About'),
                      _NavButton(label: 'Services', pageTitle: 'Services'),
                      _NavButton(label: 'Contact', pageTitle: 'Contact'),
                    ],
                  ),
                ],
              ),
            ),
            const Expanded(
              child: Center(
                child: Text(
                  'Welcome to Flex Printing Home Page',
                  style: TextStyle(fontSize: 22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.label, required this.pageTitle});

  final String label;
  final String pageTitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: TextButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => DummyPage(title: pageTitle),
            ),
          );
        },
        child: Text(label),
      ),
    );
  }
}

class DummyPage extends StatelessWidget {
  const DummyPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          '$title Page',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
