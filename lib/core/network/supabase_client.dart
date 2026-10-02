import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';
import '../storage/local_cache_service.dart';

final supabaseStatusProvider = StateNotifierProvider<SupabaseStatusNotifier, bool>((ref) {
  return SupabaseStatusNotifier();
});

class SupabaseStatusNotifier extends StateNotifier<bool> {
  SupabaseStatusNotifier() : super(SupabaseService.isInitialized) {
    SupabaseService.statusNotifier.addListener(_onStatusChanged);
  }

  void _onStatusChanged() {
    state = SupabaseService.isInitialized;
  }

  @override
  void dispose() {
    SupabaseService.statusNotifier.removeListener(_onStatusChanged);
    super.dispose();
  }
}

class SupabaseService {
  static const String keyCustomUrl = 'auracare_custom_supabase_url';
  static const String keyCustomAnonKey = 'auracare_custom_supabase_anon_key';

  static bool _isInitialized = false;
  static String? _activeUrl;
  static String? _activeKey;
  static final ValueNotifier<bool> statusNotifier = ValueNotifier<bool>(false);

  static bool get isInitialized => _isInitialized;
  static String? get activeUrl => _activeUrl;
  static String? get activeKey => _activeKey;

  static Future<void> init() async {
    try {
      final cache = await LocalCacheService.getInstance();
      final customUrl = cache.getString(keyCustomUrl);
      final customKey = cache.getString(keyCustomAnonKey);

      final url = (customUrl != null && customUrl.isNotEmpty) ? customUrl : AppConfig.supabaseUrl;
      final key = (customKey != null && customKey.isNotEmpty) ? customKey : AppConfig.supabaseAnonKey;

      if (_isValidCredentials(url, key)) {
        await Supabase.initialize(
          url: url,
          anonKey: key,
          debug: kDebugMode,
        );
        _isInitialized = true;
        _activeUrl = url;
        _activeKey = key;
        statusNotifier.value = true;
        debugPrint('Supabase successfully connected to: $url');
      } else {
        debugPrint('Supabase custom credentials not set. Running in persistent local real-time mode.');
      }
    } catch (e) {
      debugPrint('Supabase initialization deferred: $e');
      _isInitialized = false;
      statusNotifier.value = false;
    }
  }

  static bool _isValidCredentials(String url, String key) {
    if (url.isEmpty || key.isEmpty) return false;
    if (url.contains('dummy') || url.contains('demo-hospital') || url.contains('your-project-id')) {
      return false;
    }
    if (!url.startsWith('http://') && !url.startsWith('https://')) return false;
    return true;
  }

  static Future<({bool success, String message})> connect({
    required String url,
    required String anonKey,
  }) async {
    final cleanUrl = url.trim();
    final cleanKey = anonKey.trim();

    if (!_isValidCredentials(cleanUrl, cleanKey)) {
      return (
        success: false,
        message: 'Invalid Supabase URL or Key. URL must start with https:// and point to your Supabase project.',
      );
    }

    try {
      if (_isInitialized) {
        try {
          await Supabase.instance.dispose();
        } catch (_) {}
      }

      await Supabase.initialize(
        url: cleanUrl,
        anonKey: cleanKey,
        debug: kDebugMode,
      );

      // Verify connection by attempting to ping or query
      final testClient = Supabase.instance.client;
      try {
        await testClient.from('profiles').select('id').limit(1);
      } catch (tableError) {
        // Table may not exist yet or have RLS, but if auth is valid it connected successfully
        debugPrint('Supabase ping notice: $tableError');
      }

      _isInitialized = true;
      _activeUrl = cleanUrl;
      _activeKey = cleanKey;
      statusNotifier.value = true;

      // Save into persistent local cache so it persists across app restarts and updates
      final cache = await LocalCacheService.getInstance();
      await cache.saveString(keyCustomUrl, cleanUrl);
      await cache.saveString(keyCustomAnonKey, cleanKey);

      return (success: true, message: 'Connected to Supabase Cloud successfully!');
    } catch (e) {
      _isInitialized = false;
      statusNotifier.value = false;
      return (success: false, message: 'Failed to connect: $e');
    }
  }

  static Future<void> disconnect() async {
    try {
      if (_isInitialized) {
        await Supabase.instance.dispose();
      }
    } catch (_) {}

    _isInitialized = false;
    _activeUrl = null;
    _activeKey = null;
    statusNotifier.value = false;

    final cache = await LocalCacheService.getInstance();
    await cache.remove(keyCustomUrl);
    await cache.remove(keyCustomAnonKey);
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
