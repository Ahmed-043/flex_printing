import 'package:flutter/material.dart';

class DummyPage extends StatelessWidget {
  const DummyPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$title Page',
        style: const TextStyle(fontSize: 24),
      ),
    );
  }
}