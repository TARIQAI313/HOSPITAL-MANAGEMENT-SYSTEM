import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/routing/navigation_helper.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/avatar_widget.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/status_badge.dart';
import '../data/appointment_repository.dart';
import '../domain/appointment_model.dart';

final appointmentTabFilterProvider = StateProvider<String>((ref) => 'upcoming');

final appointmentListProvider = FutureProvider<List<AppointmentModel>>((ref) async {
  final repo = ref.watch(appointmentRepositoryProvider);
  final filter = ref.watch(appointmentTabFilterProvider);
  return repo.getAppointments(status: filter);
});

class AppointmentListScreen extends ConsumerWidget {
  const AppointmentListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsync = ref.watch(appointmentListProvider);
    final activeTab = ref.watch(appointmentTabFilterProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBackScope(
      fallbackRoute: RoutePaths.home,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // Top Teal App Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                decoration: const BoxDecoration(
                  gradient: AppColors.tealGradient,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => context.safePop(null, RoutePaths.home),
                    ),
                  const Text(
                    'Appointments',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 26),
                    onPressed: () => context.push('/appointments/book'),
                  ),
                ],
              ),
            ),

            // Tab Selector (Upcoming / Past / Cancelled)
            Container(
              margin: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
              ),
              child: Row(
                children: [
                  _buildTabItem(ref, title: 'Upcoming', filterKey: 'upcoming', isActive: activeTab == 'upcoming'),
                  _buildTabItem(ref, title: 'Past', filterKey: 'past', isActive: activeTab == 'past'),
                  _buildTabItem(ref, title: 'Cancelled', filterKey: 'cancelled', isActive: activeTab == 'cancelled'),
                ],
              ),
            ),

            // Appointments List
            Expanded(
              child: appointmentsAsync.when(
                loading: () => const LoadingIndicator(message: 'Loading clinical appointments...'),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (appointments) {
                  if (appointments.isEmpty) {
                    return EmptyStateView(
                      icon: Icons.event_busy_rounded,
                      title: 'No Appointments Found',
                      message: 'You have no $activeTab consultation bookings recorded.',
                      actionText: 'Book New Appointment',
                      onAction: () => context.push('/appointments/book'),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                    itemCount: appointments.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, idx) {
                      final item = appointments[idx];
                      return _buildAppointmentCard(context, ref, item);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildTabItem(
    WidgetRef ref, {
    required String title,
    required String filterKey,
    required bool isActive,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(appointmentTabFilterProvider.notifier).state = filterKey,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd - 2),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(BuildContext context, WidgetRef ref, AppointmentModel item) {
    return AppCard(
      hasShadow: true,
      onTap: () => context.push('/appointments/${item.id}', extra: item),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AvatarWidget(
                imageUrl: item.doctorAvatar,
                name: item.doctorName,
                size: 48,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.doctorName,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.text),
                    ),
                    Text(
                      item.doctorSpecialty,
                      style: const TextStyle(fontSize: 12, color: AppColors.primaryDark, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              StatusBadge.fromStatus(item.status),
            ],
          ),
          const SizedBox(height: 14),

          // Date and Time Row (styled like reference)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: AppColors.primaryDark),
                const SizedBox(width: 6),
                Text(
                  AppFormatters.formatShortDate(item.appointmentDate),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.access_time_rounded, size: 14, color: AppColors.primaryDark),
                const SizedBox(width: 6),
                Text(
                  item.startTime,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
                ),
                if (item.type.contains('telemedicine')) ...[
                  const Spacer(),
                  const Icon(Icons.videocam, size: 16, color: AppColors.primaryDark),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Reason note
          Text(
            'Reason: ${item.reason}',
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (item.isUpcoming) ...[
                OutlinedButton(
                  onPressed: () {
                    ConfirmationDialog.show(
                      context,
                      title: 'Cancel Appointment?',
                      content: 'Are you sure you want to cancel this scheduled consultation with ${item.doctorName}?',
                      isDestructive: true,
                      onConfirm: () async {
                        await ref.read(appointmentRepositoryProvider).cancelAppointment(item.id, 'Patient request');
                        ref.invalidate(appointmentListProvider);
                      },
                    );
                  },
                  child: const Text('Cancel', style: TextStyle(color: AppColors.error, fontSize: 13)),
                ),
                const SizedBox(width: 10),
                if (item.type.contains('telemedicine'))
                  AppButton(
                    text: 'Join Call',
                    icon: Icons.videocam,
                    height: 38,
                    onPressed: () => context.push('/telemedicine'),
                  )
                else
                  AppButton(
                    text: 'View Details',
                    height: 38,
                    onPressed: () => context.push('/appointments/${item.id}', extra: item),
                  ),
              ] else ...[
                AppButton(
                  text: 'Book Again',
                  variant: ButtonVariant.secondary,
                  height: 38,
                  onPressed: () => context.push('/appointments/book'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
