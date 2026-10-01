import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';

class SupabaseService {
  static bool _isInitialized = false;

  static bool get isInitialized => _isInitialized;

  static Future<void> init() async {
    try {
      if (AppConfig.supabaseUrl.isNotEmpty && 
          !AppConfig.supabaseUrl.contains('dummy') &&
          !AppConfig.supabaseUrl.contains('demo-hospital')) {
        await Supabase.initialize(
          url: AppConfig.supabaseUrl,
          anonKey: AppConfig.supabaseAnonKey,
          debug: kDebugMode,
        );
        _isInitialized = true;
      }
    } catch (e) {
      debugPrint('Supabase initialization deferred: $e');
      _isInitialized = false;
    }
  }

  static SupabaseClient? get client {
    if (_isInitialized) {
      try {
        return Supabase.instance.client;
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
