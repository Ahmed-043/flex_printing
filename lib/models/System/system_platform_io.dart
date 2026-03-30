import 'dart:io' show Platform;

class PlatformSystem {
  static bool get isMobile => Platform.isAndroid || Platform.isIOS;
}

