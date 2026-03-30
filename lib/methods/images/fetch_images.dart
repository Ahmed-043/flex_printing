import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';


Future<List<String>> getBannerImagePaths() async {
  const folder = 'assets/images/banner_images/';
  try {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);

    final paths = manifest
        .listAssets()
        .where((path) => path.startsWith(folder))
        .toList()
      ..sort();

    return paths;
  } catch (e, st) {
    debugPrint('Failed to read banner images: $e');
    debugPrint('$st');
    return <String>[];
  }
}


Future<List<String>> getBannerImagesPaths() async {
  try {

    final bannerImages = await getBannerImagePaths();
    for (final path in bannerImages) {
      debugPrint(path);
    }
    if (bannerImages.isNotEmpty) {
      debugPrint("Paths Found Dynamically");
      return bannerImages;
    }
  } catch (e) {
    debugPrint('AssetManifest not available, using fallback: $e');
  }

  // Fallback: hardcode paths for web and cases where manifest fails
  // This still allows easy future additions—just add more lines here
  return [
    'assets/images/banner_images/1sublimation_printers.png',
    'assets/images/banner_images/2roll_to_roll_transfer.png',
    'assets/images/banner_images/3dtf_printer_+_shaker.png',
    'assets/images/banner_images/4uv_dtf_fabric.png',
    'assets/images/banner_images/5dtg_printer.png',
    'assets/images/banner_images/6laser_cutter_fabric.png',
  ];
}
