import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../data/medication_repository.dart';
import '../domain/medication_model.dart';

final selectedDateOffsetProvider = StateProvider<int>((ref) => 0);

final medicationListProvider = FutureProvider<List<MedicationModel>>((ref) async {
  final repo = ref.watch(medicationRepositoryProvider);
  return repo.getMedications();
});

class PillReminderScreen extends ConsumerWidget {
  const PillReminderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicationsAsync = ref.watch(medicationListProvider);
    final selectedOffset = ref.watch(selectedDateOffsetProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final now = DateTime.now();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Teal App Bar (Inspired by the Reference UI)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              decoration: const BoxDecoration(
                gradient: AppColors.tealGradient,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => context.pop(),
                      ),
                      const Text(
                        'Pills Reminder',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 26),
                        onPressed: () => context.push('/medications/add'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Horizontal 7-Day Calendar Strip
                  SizedBox(
                    height: 68,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 7,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, idx) {
                        final date = now.add(Duration(days: idx - 2));
                        final isSelected = selectedOffset == (idx - 2);
                        final daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        final dayName = daysOfWeek[date.weekday - 1];

                        return GestureDetector(
                          onTap: () => ref.read(selectedDateOffsetProvider.notifier).state = (idx - 2),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 52,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                              boxShadow: isSelected
                                  ? [const BoxShadow(color: Color(0x1F000000), blurRadius: 6, offset: Offset(0, 2))]
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  dayName,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? AppColors.primaryDark : Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${date.day}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? AppColors.primaryDark : Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Content List
            Expanded(
              child: medicationsAsync.when(
                loading: () => const LoadingIndicator(message: 'Loading your pill schedule...'),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (meds) {
                  if (meds.isEmpty) {
                    return EmptyStateView(
                      icon: Icons.medication_liquid_outlined,
                      title: 'No Medication Scheduled',
                      message: 'Add your first prescription dose reminder to keep track of your health.',
                      actionText: 'Add Pill Reminder',
                      onAction: () => context.push('/medications/add'),
                    );
                  }

                  final morningMeds = meds.where((m) => m.timeOfDay.contains('morning')).toList();
                  final afternoonMeds = meds.where((m) => m.timeOfDay.contains('afternoon')).toList();
                  final nightMeds = meds.where((m) => m.timeOfDay.contains('night')).toList();

                  return ListView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    children: [
                      if (morningMeds.isNotEmpty) ...[
                        _buildSectionHeader(context, 'Morning Schedule', Icons.wb_sunny_outlined, '08:00 AM'),
                        const SizedBox(height: 8),
                        ...morningMeds.map((med) => _buildPillCard(context, ref, med)),
                        const SizedBox(height: 20),
                      ],
                      if (afternoonMeds.isNotEmpty) ...[
                        _buildSectionHeader(context, 'Afternoon Schedule', Icons.wb_cloudy_outlined, '01:00 PM'),
                        const SizedBox(height: 8),
                        ...afternoonMeds.map((med) => _buildPillCard(context, ref, med)),
                        const SizedBox(height: 20),
                      ],
                      if (nightMeds.isNotEmpty) ...[
                        _buildSectionHeader(context, 'Night Schedule', Icons.nightlight_outlined, '09:00 PM'),
                        const SizedBox(height: 8),
                        ...nightMeds.map((med) => _buildPillCard(context, ref, med)),
                        const SizedBox(height: 20),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Pill Reminder'),
        onPressed: () => context.push('/medications/add'),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon, String time) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryDark),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.text),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            time,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
          ),
        ),
      ],
    );
  }

  Widget _buildPillCard(BuildContext context, WidgetRef ref, MedicationModel med) {
    Color pillColor;
    try {
      pillColor = Color(int.parse(med.colorHex.replaceFirst('#', '0xFF')));
    } catch (_) {
      pillColor = AppColors.primary;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        hasShadow: true,
        child: Column(
          children: [
            Row(
              children: [
                // Colorful Pill Icon (Inspired by Reference UI)
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: pillColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.medication_rounded, color: pillColor, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        med.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                          decoration: med.isTakenToday ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${med.dosage} • ${med.form} • ${med.scheduleTimes.join(", ")}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      if (med.instructions != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          med.instructions!,
                          style: const TextStyle(fontSize: 11, color: AppColors.primaryDark),
                        ),
                      ],
                    ],
                  ),
                ),
                // Adherence Checkbox Button
                InkWell(
                  onTap: () async {
                    await ref.read(medicationRepositoryProvider).toggleTakenStatus(med.id);
                    ref.invalidate(medicationListProvider);
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: med.isTakenToday ? AppColors.success : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: med.isTakenToday ? AppColors.success : AppColors.border,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.check,
                      size: 16,
                      color: med.isTakenToday ? Colors.white : AppColors.border,
                    ),
                  ),
                ),
              ],
            ),

            // Refill alert indicator
            if (med.needsRefill) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.warningLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.warning),
                    const SizedBox(width: 6),
                    Text(
                      'Refill Alert: Only ${med.remainingPills} pills left in stock.',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF9A3412)),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => context.push('/pharmacy'),
                      child: const Text('Reorder', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
