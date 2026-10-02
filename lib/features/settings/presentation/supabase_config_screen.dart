import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/network/supabase_client.dart';
import '../../../core/routing/navigation_helper.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';

class SupabaseConfigScreen extends ConsumerStatefulWidget {
  const SupabaseConfigScreen({super.key});

  @override
  ConsumerState<SupabaseConfigScreen> createState() => _SupabaseConfigScreenState();
}

class _SupabaseConfigScreenState extends ConsumerState<SupabaseConfigScreen> {
  final _urlController = TextEditingController();
  final _keyController = TextEditingController();
  bool _isLoading = false;
  String? _statusFeedback;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _urlController.text = SupabaseService.activeUrl ?? '';
    _keyController.text = SupabaseService.activeKey ?? '';
  }

  @override
  void dispose() {
    _urlController.dispose();
    _keyController.dispose();
    super.dispose();
  }

  void _onConnect() async {
    final url = _urlController.text.trim();
    final key = _keyController.text.trim();

    if (url.isEmpty || key.isEmpty) {
      setState(() {
        _statusFeedback = 'Please enter both Supabase Project URL and Anon Public Key.';
        _isSuccess = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusFeedback = null;
    });

    final result = await SupabaseService.connect(url: url, anonKey: key);

    if (mounted) {
      setState(() {
        _isLoading = false;
        _statusFeedback = result.message;
        _isSuccess = result.success;
      });

      if (result.success) {
        ref.read(supabaseStatusProvider.notifier).state = true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.success,
            content: Text('Supabase Cloud Database connected and synchronized!'),
          ),
        );
      }
    }
  }

  void _onDisconnect() async {
    setState(() => _isLoading = true);
    await SupabaseService.disconnect();
    if (mounted) {
      setState(() {
        _isLoading = false;
        _urlController.clear();
        _keyController.clear();
        _statusFeedback = 'Disconnected from Supabase Cloud. App is running in local persistent mode.';
        _isSuccess = false;
      });
      ref.read(supabaseStatusProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = ref.watch(supabaseStatusProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBackScope(
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
        appBar: AppBar(
          title: const Text('Supabase Cloud Database'),
          backgroundColor: AppColors.primary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.safePop(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Connection Status Card
              AppCard(
                hasShadow: true,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isConnected ? AppColors.successLight : AppColors.warningLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isConnected ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
                        color: isConnected ? AppColors.success : AppColors.warning,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isConnected ? 'Connected to Cloud' : 'Local Persistent Database',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isConnected ? AppColors.success : AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isConnected
                                ? 'Real-time sync is active on: ${SupabaseService.activeUrl}'
                                : 'All emails, appointments & medicines are saving persistently on your device in real-time. Connect Supabase below to sync to cloud.',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Credential Input Form
              AppCard(
                hasShadow: true,
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Supabase Project Credentials',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Enter your Supabase Project URL and Public Anon Key below to establish a real-time connection.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),

                    AppTextField(
                      controller: _urlController,
                      label: 'Supabase Project URL',
                      hint: 'https://xyzcompany.supabase.co',
                      prefixIcon: Icons.link_rounded,
                    ),
                    const SizedBox(height: 16),

                    AppTextField(
                      controller: _keyController,
                      label: 'Supabase Anon Public Key',
                      hint: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
                      prefixIcon: Icons.key_rounded,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 20),

                    if (_statusFeedback != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _isSuccess ? AppColors.successLight : AppColors.errorLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isSuccess ? Icons.check_circle : Icons.error_outline,
                              color: _isSuccess ? AppColors.success : AppColors.error,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _statusFeedback!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _isSuccess ? AppColors.success : AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    AppButton(
                      text: isConnected ? 'Update & Reconnect' : 'Test & Connect Cloud Database',
                      isLoading: _isLoading,
                      onPressed: _onConnect,
                      isFullWidth: true,
                    ),
                    if (isConnected) ...[
                      const SizedBox(height: 10),
                      OutlinedButton(
                        onPressed: _isLoading ? null : _onDisconnect,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          minimumSize: const Size(double.infinity, 44),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Disconnect from Cloud'),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Setup Guide Card
              AppCard(
                hasShadow: true,
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.primaryDark, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'How to get your Supabase keys:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '1. Go to https://supabase.com and create a free project.\n'
                      '2. Open your project and click on "Project Settings" (gear icon) -> "API".\n'
                      '3. Copy the "Project URL" and paste it into "Supabase Project URL".\n'
                      '4. Copy the "Project API keys -> anon public" key and paste it into "Supabase Anon Public Key".\n'
                      '5. Tap "Test & Connect Cloud Database" above.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.5),
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
}
