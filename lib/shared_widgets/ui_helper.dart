import 'package:flutter/material.dart';

import '../models/System/system.dart';

class UiHelper {
  static Widget button({
    String? title,
    required VoidCallback? callback,
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
      child: ElevatedButton(
        onPressed: callback,
        style: ElevatedButton.styleFrom(
          padding: padding, // removes internal padding

          backgroundColor: filled
              ? color ?? Colors.transparent
              : Colors.transparent,
          overlayColor:  Colors.white, // splash color
          elevation: elevation,
          //white splash

          enableFeedback: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: BorderSide(color: color ?? Colors.transparent),
          ),
        ),
        child: child
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
          fontSize: System.isMobile ? 26 : 55,
          fontWeight: FontWeight.w600,
          letterSpacing: 2,
          fontFamily: "RedHatDisplay",
          color: Theme.of(context).colorScheme.onSecondary,
        ),
      ),
    );
  }
  static Widget inputField({
    required BuildContext context,
    required String label,
    String? hint,
    bool requiredField = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    TextEditingController? controller,
  }) {
    final labelText = requiredField ? '$label *' : label;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
            color: Color(0xFF364153),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          cursorColor: Theme.of(context).colorScheme.onPrimary,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor:Colors.transparent,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Color(0xFFD1D5DC),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Color(0xFF909398),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Color(0xFFD1D5DC),
              ),
            ),
          ),
        ),
      ],
    );
  }
  static Widget compactTextField({
    required TextEditingController controller,
    required String hint,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      style: TextStyle(
        fontSize: 14,
        color: theme.colorScheme.onPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
        isDense: true,
        filled: true,
        fillColor: Colors.transparent,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD1D5DC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF909398)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD1D5DC)),
        ),
      ),
    );
  }
}

