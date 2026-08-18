import 'package:flutter/cupertino.dart';

class LeftSlopeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.moveTo(size.width * 0.25, 0); // top-left shifted right
    path.lineTo(size.width, 0);        // top-right
    path.lineTo(size.width, size.height); // bottom-right
    path.lineTo(0, size.height);       // bottom-left
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}