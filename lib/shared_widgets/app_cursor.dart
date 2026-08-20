import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';

class AppCursor extends StatefulWidget {
  const AppCursor({super.key, required this.child});

  final Widget child;

  @override
  State<AppCursor> createState() => _AppCursorState();
}

class _AppCursorState extends State<AppCursor> {
  static const double _cursorSize = 34;

  final GlobalKey _stackKey = GlobalKey();
  Offset? _cursorPosition;
  bool _isHovering = false;
  bool _isOverClickable = false;
  bool _isTouching = false;

  bool _isClickableCursor(MouseCursor cursor) {
    if (cursor == SystemMouseCursors.click) return true;
    if (cursor is MaterialStateMouseCursor) {
      final resolved = cursor.resolve({MaterialState.hovered});
      return resolved == SystemMouseCursors.click;
    }
    return false;
  }

  bool _hitTestIsClickable(Offset globalPosition) {
    final result = HitTestResult();
    RendererBinding.instance.hitTest(result, globalPosition);
    for (final entry in result.path) {
      final target = entry.target;
      if (target is RenderMouseRegion && _isClickableCursor(target.cursor)) {
        return true;
      }
    }
    return false;
  }

  bool get _supportsCustomCursor {
    if (kIsWeb) {
      return defaultTargetPlatform != TargetPlatform.android &&
          defaultTargetPlatform != TargetPlatform.iOS;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        return false;
      case TargetPlatform.fuchsia:
        return false;
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return true;
    }
  }

  void _updateCursorPosition(Offset globalPosition) {
    final renderObject = _stackKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox) return;
    final isClickable = _hitTestIsClickable(globalPosition);

    setState(() {
      _cursorPosition = renderObject.globalToLocal(globalPosition);
      _isHovering = true;
      _isOverClickable = isClickable;
    });
  }

  void _handleEnter(PointerEnterEvent event) {
    if (!_supportsCustomCursor || _isTouching) return;
    _updateCursorPosition(event.position);
  }

  void _handleHover(PointerHoverEvent event) {
    if (!_supportsCustomCursor || _isTouching) return;
    _updateCursorPosition(event.position);
  }

  void _handleExit(PointerExitEvent event) {
    if (!_supportsCustomCursor) return;
    setState(() {
      _isHovering = false;
      _isOverClickable = false;
    });
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (event.kind == PointerDeviceKind.touch) {
      setState(() {
        _isTouching = true;
        _isHovering = false;
        _isOverClickable = false;
      });
    } else {
      _updateCursorPosition(event.position);
    }
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (!_supportsCustomCursor || _isTouching) return;
    _updateCursorPosition(event.position);
  }

  void _handlePointerUpOrCancel(PointerEvent event) {
    if (event.kind == PointerDeviceKind.touch) {
      setState(() {
        _isTouching = false;
      });
    } else if (event is PointerUpEvent) {
      _updateCursorPosition(event.position);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_supportsCustomCursor) {
      return widget.child;
    }

    return Listener(
      onPointerDown: _handlePointerDown,
      onPointerMove: _handlePointerMove,
      onPointerUp: _handlePointerUpOrCancel,
      onPointerCancel: _handlePointerUpOrCancel,
      child: MouseRegion(
        cursor: SystemMouseCursors.none,
        onEnter: _handleEnter,
        onHover: _handleHover,
        onExit: _handleExit,
        child: Stack(
          key: _stackKey,
          fit: StackFit.expand,
          children: [
            widget.child,
            if (_isHovering && !_isTouching && _cursorPosition != null)
              Positioned(
                left: _cursorPosition!.dx - (_cursorSize / 2),
                top: _cursorPosition!.dy - (_cursorSize / 2),
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    opacity: _isHovering ? (_isOverClickable ? 0 : 1) : 0,
                    duration: const Duration(milliseconds: 80),
                    child: SizedBox(
                      width: _cursorSize,
                      height: _cursorSize,
                      child: SvgPicture.asset(
                        'assets/images/logo.svg',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
