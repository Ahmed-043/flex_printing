import 'package:flutter/material.dart';

import '../models/System/system.dart';

class UiHelper {
  static Widget button({
    String? title,
    required VoidCallback callback,
    VoidCallback? rightClick,
    double textSize = 20,
    bool filled = false,
    Color? color,
    Widget? child,
    double borderRadius = 20,
    double? elevation,
    EdgeInsetsGeometry? padding,
  }) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onSecondaryTap: rightClick,
        behavior: HitTestBehavior.opaque,

        child: ElevatedButton(
          onPressed: callback,
          style: ElevatedButton.styleFrom(
            padding: padding, // removes internal padding

            backgroundColor: filled
                ? color ?? Colors.transparent
                : Colors.transparent,
            overlayColor: filled
                ? Colors.transparent
                : color ?? Colors.transparent, // splash color
            elevation: elevation,
            enableFeedback: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              side: BorderSide(color: color ?? Colors.transparent),
            ),
          ),
          child: child
        ),
      ),
    );
  }
  static Widget title({required BuildContext context, required String title}){
    return Container(
      color: Theme.of(context).colorScheme.secondaryContainer,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      child: Text(
        title,
        style: TextStyle(
          fontSize: System.isMobile ? 26 : 36,
          color: Theme.of(context).colorScheme.onSecondary,
        ),
      ),
    );
  }
}
