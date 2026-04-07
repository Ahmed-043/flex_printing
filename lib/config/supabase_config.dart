import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> printCategories({int limit = 100}) async {
  final client = Supabase.instance.client;

  try {
    final rows = await client
        .from('categories')
        .select('id, name, created_at')
        .order('name', ascending: true)
        .limit(limit);

    debugPrint('=== categories (rows=${(rows as List).length}) ===');
    debugPrint(const JsonEncoder.withIndent('  ').convert(rows));
  } on PostgrestException catch (e) {
    debugPrint('printCategories failed: ${e.message}');
    debugPrint('details: ${e.details}');
    debugPrint('hint: ${e.hint}');
    debugPrint('code: ${e.code}');
  } catch (e) {
    debugPrint('printCategories failed (unknown): $e');
  }
}

class SupabaseConfig {
  static const String url = 'https://apadmbgopvunfhelqnyv.supabase.co';
  static const String anonKey =
      'sb_publishable_vMpRtPP560rjA3_TPjxN6Q_XghQlnBY';
}

