import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/stats_kpi_card.dart';

class NurseDashboardScreen extends ConsumerWidget {
  const NurseDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nurse Inpatient Station'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_chart_rounded),
            tooltip: 'Record Vitals',
            onPressed: () => context.push('/vitals/log'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KPI Summary
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                const StatsKpiCard(
                  title: 'Assigned Patients',
                  value: '12',
                  icon: Icons.hotel_rounded,
                  subtitle: 'Ward 3B - Cardiac Care',
                ),
                StatsKpiCard(
                  title: 'Medication Doses',
                  value: '8 / 14',
                  icon: Icons.medication_rounded,
                  subtitle: '6 pending afternoon round',
                  onTap: () => context.push('/medications'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Patient Bed Rounds List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Assigned Bed Rounds (Ward 3B)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text),
                ),
                TextButton(
                  onPressed: () => context.push('/admissions'),
                  child: const Text('All Wards', style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            _buildBedRoundCard(
              context,
              bed: 'Bed 301-A',
              patient: 'Emma Stonehurst',
              condition: 'Post Cardiac Catheterization',
              vitals: 'BP: 122/78 | HR: 68 | SpO2: 98%',
              isCritical: false,
            ),
            const SizedBox(height: 10),
            _buildBedRoundCard(
              context,
              bed: 'Bed 302-B',
              patient: 'Ethan Harper',
              condition: 'Type 2 Diabetes Glycemic Control',
              vitals: 'BP: 138/88 | HR: 82 | SpO2: 96%',
              isCritical: false,
            ),
            const SizedBox(height: 10),
            _buildBedRoundCard(
              context,
              bed: 'Bed 305-ICU',
              patient: 'Noah Sinclair',
              condition: 'Post Laparotomy Recovery',
              vitals: 'BP: 110/70 | HR: 94 | SpO2: 94%',
              isCritical: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBedRoundCard(
    BuildContext context, {
    required String bed,
    required String patient,
    required String condition,
    required String vitals,
    required bool isCritical,
  }) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isCritical ? AppColors.errorLight : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  bed,
                  style: TextStyle(
                    color: isCritical ? AppColors.error : AppColors.primaryDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              if (isCritical)
                const Text(
                  'ATTENTION REQUIRED',
                  style: TextStyle(color: AppColors.error, fontSize: 10, fontWeight: FontWeight.bold),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(patient, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 2),
          Text(condition, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                const Icon(Icons.favorite_rounded, size: 14, color: AppColors.error),
                const SizedBox(width: 6),
                Text(vitals, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () => context.push('/vitals/log'),
                child: const Text('Update Vitals', style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 8),
              AppButton(
                text: 'Administer Meds',
                height: 36,
                onPressed: () => context.push('/medications'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
