import 'package:web/web.dart' as web;

class System {
  static final bool isMobile = RegExp(
    r'Android|iPhone|iPad|iPod|Opera Mini|IEMobile|Mobile',
    caseSensitive: false,
  ).hasMatch(web.window.navigator.userAgent);
}