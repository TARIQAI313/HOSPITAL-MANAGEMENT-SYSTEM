import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/avatar_widget.dart';
import '../../appointments/data/appointment_repository.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../medications/data/medication_repository.dart';

class PatientDashboardScreen extends ConsumerWidget {
  const PatientDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final appointmentsAsync = ref.watch(appointmentRepositoryProvider).getAppointments(status: 'upcoming');
    final medicationsAsync = ref.watch(medicationRepositoryProvider).getMedications();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final userName = authState.user?.fullName ?? 'Emma Stonehurst';

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Branded Teal Header (Inspired by reference UI)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
                decoration: const BoxDecoration(
                  gradient: AppColors.tealGradient,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(AppSpacing.radiusXl)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            AvatarWidget(
                              imageUrl: authState.user?.avatarUrl,
                              name: userName,
                              size: 46,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Welcome back,',
                                  style: TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                                Text(
                                  userName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.emergency_rounded, color: Colors.white),
                              onPressed: () => context.push('/emergency'),
                            ),
                            IconButton(
                              icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
                              onPressed: () => context.push('/notifications'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Search Tap bar
                    GestureDetector(
                      onTap: () => context.push('/search'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          boxShadow: const [
                            BoxShadow(color: Color(0x0F000000), blurRadius: 6, offset: Offset(0, 2)),
                          ],
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.search, color: AppColors.primary, size: 20),
                            SizedBox(width: 10),
                            Text(
                              'Search doctors, prescriptions, tests...',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Upcoming Consultation Card
                    FutureBuilder(
                      future: appointmentsAsync,
                      builder: (context, snapshot) {
                        final list = snapshot.data ?? [];
                        if (list.isEmpty) return const SizedBox.shrink();
                        final app = list.first;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Upcoming Consultation',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text),
                                ),
                                TextButton(
                                  onPressed: () => context.push('/appointments'),
                                  child: const Text('See All', style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            AppCard(
                              hasShadow: true,
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      AvatarWidget(
                                        imageUrl: app.doctorAvatar,
                                        name: app.doctorName,
                                        size: 50,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              app.doctorName,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                            ),
                                            Text(
                                              app.doctorSpecialty,
                                              style: const TextStyle(color: AppColors.primaryDark, fontSize: 12, fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (app.type.contains('telemedicine'))
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryLight,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(Icons.videocam, color: AppColors.primaryDark, size: 20),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.calendar_today, size: 14, color: AppColors.primaryDark),
                                        const SizedBox(width: 6),
                                        Text(
                                          AppFormatters.formatShortDate(app.appointmentDate),
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryDark),
                                        ),
                                        const SizedBox(width: 16),
                                        const Icon(Icons.access_time, size: 14, color: AppColors.primaryDark),
                                        const SizedBox(width: 6),
                                        Text(
                                          app.startTime,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryDark),
                                        ),
                                        const Spacer(),
                                        GestureDetector(
                                          onTap: () => context.push('/appointments/${app.id}', extra: app),
                                          child: const Text('View Slip', style: TextStyle(color: AppColors.primaryDark, fontSize: 11, fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        );
                      },
                    ),

                    // Pills Reminder Quick Card (Directly inspired by Reference UI)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Pills Reminder',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text),
                        ),
                        TextButton(
                          onPressed: () => context.push('/medications'),
                          child: const Text('View All', style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder(
                      future: medicationsAsync,
                      builder: (context, snapshot) {
                        final meds = snapshot.data ?? [];
                        final activeMeds = meds.take(2).toList();

                        return AppCard(
                          hasShadow: true,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: AppColors.primaryLight,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.medication_rounded, color: AppColors.primaryDark, size: 20),
                                  ),
                                  const SizedBox(width: 10),
                                  const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Today Dosage Plan',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      Text(
                                        '2 scheduled doses remaining',
                                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ...activeMeds.map((med) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '${med.name} (${med.dosage})',
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      Text(
                                        med.scheduleTimes.first,
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Quick Hospital Services Grid
                    const Text(
                      'Hospital Services',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      children: [
                        _buildServiceIcon(
                          context,
                          icon: Icons.person_search_rounded,
                          label: 'Doctors',
                          route: '/doctors',
                        ),
                        _buildServiceIcon(
                          context,
                          icon: Icons.medication_liquid_rounded,
                          label: 'Pills',
                          route: '/medications',
                        ),
                        _buildServiceIcon(
                          context,
                          icon: Icons.biotech_rounded,
                          label: 'Lab Tests',
                          route: '/laboratory',
                        ),
                        _buildServiceIcon(
                          context,
                          icon: Icons.receipt_long_rounded,
                          label: 'Billing',
                          route: '/billing',
                        ),
                        _buildServiceIcon(
                          context,
                          icon: Icons.videocam_rounded,
                          label: 'Telehealth',
                          route: '/telemedicine',
                        ),
                        _buildServiceIcon(
                          context,
                          icon: Icons.description_rounded,
                          label: 'Records',
                          route: '/medical-records',
                        ),
                        _buildServiceIcon(
                          context,
                          icon: Icons.local_pharmacy_rounded,
                          label: 'Pharmacy',
                          route: '/pharmacy',
                        ),
                        _buildServiceIcon(
                          context,
                          icon: Icons.emergency_rounded,
                          label: 'ER / 24-7',
                          route: '/emergency',
                          isEmergency: true,
                        ),
                      ],
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

  Widget _buildServiceIcon(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
    bool isEmergency = false,
  }) {
    return InkWell(
      onTap: () => context.push(route),
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isEmergency ? AppColors.errorLight : AppColors.primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              size: 24,
              color: isEmergency ? AppColors.error : AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isEmergency ? AppColors.error : AppColors.text,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
