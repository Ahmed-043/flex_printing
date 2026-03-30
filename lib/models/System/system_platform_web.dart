import 'package:web/web.dart' as web;

class PlatformSystem {
  static bool get isMobile => RegExp(
        r'Android|iPhone|iPad|iPod|Opera Mini|IEMobile|Mobile',
        caseSensitive: false,
      ).hasMatch(web.window.navigator.userAgent);
}
