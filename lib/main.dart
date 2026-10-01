import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/app_config.dart';
import 'core/constants/app_constants.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/l10n_provider.dart';
import 'core/network/supabase_client.dart';
import 'core/routing/app_router.dart';
import 'core/storage/local_cache_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Environment and Configurations
  AppConfig.initialize();

  // Initialize Local Cache Service
  await LocalCacheService.getInstance();

  // Initialize Supabase Backend
  await SupabaseService.init();

  runApp(
    const ProviderScope(
      child: AuraCareApp(),
    ),
  );
}

class AuraCareApp extends ConsumerWidget {
  const AuraCareApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // Routing
      routerConfig: router,

      // Theming
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      // Localization & RTL Support
      locale: locale,
      supportedLocales: const [
        Locale('en', 'US'), // English
        Locale('ur', 'PK'), // Urdu (RTL)
        Locale('ar', 'SA'), // Arabic (RTL)
      ],
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
