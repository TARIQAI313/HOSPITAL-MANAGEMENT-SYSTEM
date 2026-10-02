import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/localization/l10n_provider.dart';
import '../../../core/network/supabase_client.dart';
import '../../../core/routing/navigation_helper.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../auth/presentation/auth_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final authState = ref.watch(authControllerProvider);
    final isDark = themeMode == ThemeMode.dark;

    return AppBackScope(
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
        appBar: AppBar(
          title: const Text('Settings & Preferences'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.safePop(),
          ),
        ),
        body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Card
            AppCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      authState.user?.fullName.isNotEmpty == true ? authState.user!.fullName[0].toUpperCase() : 'U',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.primaryDark),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authState.user?.fullName ?? 'AuraCare User',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          authState.user?.email ?? 'patient1@example.com',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Role: ${authState.user?.role.label ?? "Patient"}',
                          style: const TextStyle(color: AppColors.primaryDark, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Appearance Settings
            const Text('Appearance', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            AppCard(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Dark Mode', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Enable low-light dark medical theme', style: TextStyle(fontSize: 12)),
                    value: isDark,
                    activeColor: AppColors.primary,
                    onChanged: (val) {
                      ref.read(themeModeProvider.notifier).setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Language & Localization (Multi-Language: English, Urdu, Arabic RTL)
            const Text('Language & Localization', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            AppCard(
              child: Column(
                children: [
                  _buildLanguageOption(ref, label: 'English (US)', code: 'en', currentCode: locale.languageCode),
                  const Divider(height: 1),
                  _buildLanguageOption(ref, label: 'Urdu (اردو)', code: 'ur', currentCode: locale.languageCode),
                  const Divider(height: 1),
                  _buildLanguageOption(ref, label: 'Arabic (العربية)', code: 'ar', currentCode: locale.languageCode),
                ],
              ),
            ),
            // Database & Cloud Synchronization
            const Text('Database & Cloud Integration', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            AppCard(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.cloud_sync, color: AppColors.primary, size: 22),
                    title: const Text('Supabase Cloud Database', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      ref.watch(supabaseStatusProvider)
                          ? 'Connected: Real-time Cloud Sync Active'
                          : 'Persistent Local Mode: Tap to connect Cloud',
                      style: TextStyle(
                        fontSize: 12,
                        color: ref.watch(supabaseStatusProvider) ? AppColors.success : AppColors.warning,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 18),
                    onTap: () => context.push(RoutePaths.supabaseConfig),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Security & Privacy
            const Text('Security & Compliance', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            AppCard(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.lock_outline, size: 20),
                    title: const Text('Change Password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.chevron_right, size: 18),
                    onTap: () => context.push('/forgot-password'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.shield_outlined, size: 20),
                    title: const Text('HIPAA Privacy & Consent', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.chevron_right, size: 18),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Your medical records are encrypted under 256-bit AES encryption.')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Sign Out Button
            AppButton(
              text: 'Sign Out',
              icon: Icons.logout,
              variant: ButtonVariant.danger,
              isFullWidth: true,
              onPressed: () {
                ConfirmationDialog.show(
                  context,
                  title: 'Sign Out?',
                  content: 'Are you sure you want to end your current clinical session?',
                  onConfirm: () async {
                    await ref.read(authControllerProvider.notifier).signOut();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 24),

            Center(
              child: Column(
                children: [
                  Text(
                    '${AppConstants.appName} v${AppConstants.appVersion}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Enterprise Hospital Management & Patient Care Application',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildLanguageOption(WidgetRef ref, {required String label, required String code, required String currentCode}) {
    final isSelected = code == currentCode;

    return ListTile(
      title: Text(label, style: const TextStyle(fontSize: 14)),
      trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.primaryDark) : null,
      onTap: () => ref.read(localeProvider.notifier).setLocale(code),
    );
  }
}
