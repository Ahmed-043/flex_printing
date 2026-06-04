import 'package:flex_printing/shared_widgets/scaled_container.dart';
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
    double rotation = 2.5,
  }) {
    // Wrap the button with a small hover-rotate widget so on desktop/web
    // it slightly rotates by +12 degrees when hovered.
    return Material(
      color: Colors.transparent,
      child: ScaledContainer(
        child: ElevatedButton(
          onPressed: callback,
          style: ElevatedButton.styleFrom(
            padding: padding, // removes internal padding

            backgroundColor: filled
                ? color ?? Colors.transparent
                : Colors.transparent,
            overlayColor: Colors.white, // splash color
            elevation: elevation,

            enableFeedback: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              side: BorderSide(color: color ?? Colors.transparent),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
  static Widget title({required BuildContext context, required String title}){
    final theme = Theme.of(context).colorScheme;
    return Container(
      color: theme.secondaryContainer,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      child: Text(
        title,
        style: TextStyle(
          fontSize: System.isMobile ? 26 : 55,
          fontWeight: FontWeight.w600,
          letterSpacing: 2,
          fontFamily: "RedHatDisplay",
          color: theme.onSecondary,
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
    void Function(String)? onSubmitted,
  }) {
    final labelText = requiredField ? '$label *' : label;
    final theme = Theme.of(context);
    final selectionColor = theme.colorScheme.secondary.withAlpha(70);

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
        TextSelectionTheme(
          data: TextSelectionThemeData(
            cursorColor: theme.colorScheme.secondary,
            selectionColor: selectionColor,
            selectionHandleColor: theme.colorScheme.secondary,
          ),
          child: TextField(
            onSubmitted: onSubmitted,
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            cursorColor: theme.colorScheme.secondary,
            style: TextStyle(
              color: theme.colorScheme.onPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            contextMenuBuilder: (context, editableTextState) {
              return Theme(
                data: theme.copyWith(
                  colorScheme: theme.colorScheme.copyWith(
                    surface: theme.colorScheme.secondaryContainer,
                    onSurface: theme.colorScheme.onSecondary,
                  ),
                ),
                child: AdaptiveTextSelectionToolbar.buttonItems(
                  anchors: editableTextState.contextMenuAnchors,
                  buttonItems: editableTextState.contextMenuButtonItems,
                ),
              );
            },
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
        ),
      ],
    );
  }
  static Widget compactTextField({
    required TextEditingController controller,
    required String hint,
    required BuildContext context,
    Color color = const Color(0xFFA1A3A8),
    FocusNode? focusNode,
    void Function(String)? onSubmitted,
    TextInputAction? textInputAction,
  }) {
    final theme = Theme.of(context);
    final selectionColor = theme.colorScheme.secondary.withAlpha(70);
    return TextSelectionTheme(
      data: TextSelectionThemeData(
        cursorColor: theme.colorScheme.secondary,
        selectionColor: selectionColor,
        selectionHandleColor: theme.colorScheme.secondary,
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onSubmitted: onSubmitted,
        textInputAction: textInputAction,
        style: TextStyle(
          fontSize: 16,
          color: theme.colorScheme.onPrimary,
        ),
        cursorColor: theme.colorScheme.secondary,
        contextMenuBuilder: (context, editableTextState) {
          return Theme(
            data: theme.copyWith(
              colorScheme: theme.colorScheme.copyWith(
                surface: theme.colorScheme.secondaryContainer,
                onSurface: theme.colorScheme.onSecondary,
              ),
            ),
            child: AdaptiveTextSelectionToolbar.buttonItems(
              anchors: editableTextState.contextMenuAnchors,
              buttonItems: editableTextState.contextMenuButtonItems,
            ),
          );
        },

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
            borderSide: BorderSide(color: color),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:  BorderSide(color: color),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:  BorderSide(color: color),
          ),
        ),
      ),
    );
  }
}

/// Internal helper widget: rotates its child by [degrees] when hovered.
class HoverRotate extends StatefulWidget {
  final Widget child;
  final double degrees;
  final Duration duration;
  final bool enabled;
  final bool uniDirectional;
  const HoverRotate({
    required this.child,
    this.degrees = 1,
    this.duration = const Duration(milliseconds: 120),
    this.enabled = true,
    this.uniDirectional = false,
    super.key,
  });

  @override
  State<HoverRotate> createState() => HoverRotateState();
}

class HoverRotateState extends State<HoverRotate> {
  // current rotation in turns (-1.0..1.0 where 1.0 == 360deg)
  double _turns = 0.0;
  final degrees = 1;

  void _setExit() {
    if (!widget.enabled) return;
    if (mounted) setState(() => _turns = 0.0);
  }

  void _updateFromPointer(PointerEvent e) {
    if (!widget.enabled) return;
    try {
      final box = context.findRenderObject() as RenderBox?;
      if (box == null) return;
      final local = box.globalToLocal(e.position);
      final width = box.size.width;
      // If pointer is left of center, rotate negative; else positive.
      final sign = (local.dx < (width / 2) && !widget.uniDirectional) ? -1.0 : 1.0;
      final targetTurns = (sign * degrees) / 360.0;
      if (mounted) setState(() => _turns = targetTurns);
    } catch (_) {
      // fallback: positive rotation
      if (mounted) setState(() => _turns = (widget.degrees / 360.0));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (e) => _updateFromPointer(e),
      onHover: (e) => _updateFromPointer(e),
      onExit: (_) => _setExit(),
     // child: widget.child,
      child: AnimatedRotation(
        turns: _turns,
        duration: widget.duration,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

