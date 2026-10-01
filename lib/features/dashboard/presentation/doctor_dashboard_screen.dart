import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/avatar_widget.dart';
import '../../../core/widgets/stats_kpi_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../appointments/data/appointment_repository.dart';
import '../../auth/presentation/auth_controller.dart';

class DoctorDashboardScreen extends ConsumerWidget {
  const DoctorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final appointmentsAsync = ref.watch(appointmentRepositoryProvider).getAppointments();
    final doctorName = authState.user?.fullName ?? 'Dr. Sarah Watson';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Doctor Header Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      AvatarWidget(
                        imageUrl: authState.user?.avatarUrl,
                        name: doctorName,
                        size: 50,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Doctor Clinical Portal',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                          Text(
                            doctorName,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded),
                    onPressed: () => context.push('/notifications'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // KPI Stats Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: const [
                  StatsKpiCard(
                    title: "Today's Consultations",
                    value: "14",
                    icon: Icons.calendar_today_rounded,
                    subtitle: "4 remaining in queue",
                  ),
                  StatsKpiCard(
                    title: "Active Inpatients",
                    value: "8",
                    icon: Icons.hotel_rounded,
                    subtitle: "2 ICU rounds pending",
                  ),
                  StatsKpiCard(
                    title: "Prescriptions Written",
                    value: "26",
                    icon: Icons.medication_rounded,
                    subtitle: "100% digital signed",
                  ),
                  StatsKpiCard(
                    title: "Consultation Earnings",
                    value: "\$1,850",
                    icon: Icons.payments_rounded,
                    subtitle: "+18% from last week",
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Today's Patient Queue
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Today's Patient Queue",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text),
                  ),
                  TextButton(
                    onPressed: () => context.push('/appointments'),
                    child: const Text('All Appointments', style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              FutureBuilder(
                future: appointmentsAsync,
                builder: (context, snapshot) {
                  final list = snapshot.data ?? [];
                  if (list.isEmpty) {
                    return const AppCard(
                      child: Text('No active patients in clinic queue right now.'),
                    );
                  }

                  return Column(
                    children: list.take(3).map((app) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: AppColors.primaryLight,
                                    child: Text(
                                      app.queueNumber != null ? '${app.queueNumber}' : 'Q',
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          app.patientName,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                        Text(
                                          'Reason: ${app.reason}',
                                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  StatusBadge.fromStatus(app.status),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton(
                                    onPressed: () => context.push('/medical-records'),
                                    child: const Text('View History', style: TextStyle(fontSize: 12)),
                                  ),
                                  const SizedBox(width: 8),
                                  AppButton(
                                    text: 'Consult & Prescribe',
                                    height: 36,
                                    onPressed: () => context.push('/prescriptions/create', extra: app),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
