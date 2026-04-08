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
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFwYWRtYmdvcHZ1bmZoZWxxbnl2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUzOTE4MzgsImV4cCI6MjA5MDk2NzgzOH0.FmlEf0zKpuIw_RhV3ZSk3LPtpOeP-0w9AfOm1jvZbfM';
}

