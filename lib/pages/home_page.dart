import 'package:flutter/material.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Container(
          height: screenHeight*0.85,
          color: Colors.redAccent,
        ),
        Text(
          'Welcome to Flex Printing Home Page',
          style: TextStyle(fontSize: 22),
        ),
      ],
    );
  }
}