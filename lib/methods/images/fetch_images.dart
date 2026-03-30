import 'package:flex_printing/models/banner_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const String _bannerFolder = 'assets/images/banner_images/';

Future<List<String>> getBannerImagePaths() async {
  try {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);

    final paths = manifest
        .listAssets()
        .where((path) => path.startsWith(_bannerFolder))
        .toList()
      ..sort();

    return paths;
  } catch (e, st) {
    debugPrint('Failed to read banner images: $e');
    debugPrint('$st');
    return <String>[];
  }
}

/// Main API: returns banner images as objects with {path, name}.
/// - First tries dynamic lookup via AssetManifest (working method)
/// - If fails/empty -> fallback to manual list
Future<List<BannerImage>> getBannerImages() async {
  // 1) Try dynamic
  try {
    final paths = await getBannerImagePaths();
    if (paths.isNotEmpty) {
      debugPrint('Paths Found Dynamically (${paths.length})');
      return paths.map(_toBannerImage).toList();
    }
  } catch (e, st) {
    debugPrint('getBannerImagePaths() failed: $e');
    debugPrint('$st');
  }

  // 2) Manual fallback
  const fallback = <String>[
    'assets/images/banner_images/1sublimation_printers.png',
    'assets/images/banner_images/2roll_to_roll_transfer.png',
    'assets/images/banner_images/3dtf_printer_+_shaker.png',
    'assets/images/banner_images/4uv_dtf_fabric.png',
    'assets/images/banner_images/5dtg_printer.png',
    'assets/images/banner_images/6laser_cutter_fabric.png',
  ];

  debugPrint('Using banner image fallback list (${fallback.length})');
  return fallback.map(_toBannerImage).toList();
}

BannerImage _toBannerImage(String path) {
  return BannerImage(
    path: path,
    name: bannerNameFromPath(path),
  );
}
/// Rules:
/// - take filename only (no folders)
/// - remove extension
/// - remove leading number(s)
/// - replace '_' with ' '
/// - make whole text UPPERCASE
/// Example:
///   3dtf_printer_+_shaker.png -> "DTF PRINTER + SHAKER"
String bannerNameFromPath(String path) {
  final file = path.split('/').last;
  final noExt = file.replaceFirst(RegExp(r'\.[^\.]+$'), '');

  // remove ONLY leading digits (e.g. "3dtf..." -> "dtf...")
  final withoutLeadingNumbers = noExt.replaceFirst(RegExp(r'^\d+'), '');

  final spaced = withoutLeadingNumbers.replaceAll('_', ' ').trim();
  return spaced.toUpperCase();
}