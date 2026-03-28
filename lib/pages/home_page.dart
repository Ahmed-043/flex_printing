import 'package:flutter/material.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  late double screenHeight;

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    return Column(
      children: [
        _banner(),
        Container(height: 1500, color: Theme.of(context).colorScheme.primary),
        Text(
          'Welcome to Flex Printing Home Page',
          style: TextStyle(fontSize: 22),
        ),
      ],
    );
  }

  Widget _banner() {
    return Container(
      height: screenHeight * 0.85,
      color: Theme.of(context).colorScheme.secondary,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'DIGITAL\n',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 135,
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                        ),
                        TextSpan(
                          text: 'PRINTING MACHINERY\nSUPPLER.',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 43,
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: Column(children: [])),
          ],
        ),
      ),
    );
  }
}
