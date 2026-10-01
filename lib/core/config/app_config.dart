import 'env_keys.dart';

class AppConfig {
  static late final String supabaseUrl;
  static late final String supabaseAnonKey;
  static late final String environment;
  static late final bool isOfflineFallbackEnabled;

  static void initialize() {
    supabaseUrl = EnvKeys.supabaseUrl;
    supabaseAnonKey = EnvKeys.supabaseAnonKey;
    environment = EnvKeys.appEnv;
    isOfflineFallbackEnabled = EnvKeys.enableMockFallback;
  }

  static bool get isProduction => environment == 'production';
  static bool get isDevelopment => environment == 'development';
}
