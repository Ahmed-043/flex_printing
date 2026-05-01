import 'system_platform_stub.dart'
if (dart.library.html) 'system_platform_web.dart'
if (dart.library.io) 'system_platform_io.dart';

class System {
  static bool get isMobile => PlatformSystem.isMobile;
}

// class System {
//   static bool isMobile = true;
// }
