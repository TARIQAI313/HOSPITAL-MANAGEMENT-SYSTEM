import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/stats_kpi_card.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Hospital Operations Command Center'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: () => context.push('/reports'),
            tooltip: 'Export Reports',
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KPI Summary Cards
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                StatsKpiCard(
                  title: 'Total Inpatients',
                  value: '142',
                  icon: Icons.hotel_rounded,
                  subtitle: '82% Bed Occupancy',
                  onTap: () => context.push('/admissions'),
                ),
                StatsKpiCard(
                  title: 'Daily Outpatients',
                  value: '380',
                  icon: Icons.people_alt_rounded,
                  subtitle: '+12% from yesterday',
                  onTap: () => context.push('/patients'),
                ),
                StatsKpiCard(
                  title: 'Monthly Revenue',
                  value: '\$148,200',
                  icon: Icons.account_balance_wallet_rounded,
                  subtitle: '94% collected',
                  onTap: () => context.push('/billing'),
                ),
                StatsKpiCard(
                  title: 'Active Ambulances',
                  value: '6 / 8',
                  icon: Icons.emergency_rounded,
                  subtitle: '2 Dispatched in field',
                  iconColor: AppColors.error,
                  iconBackground: AppColors.errorLight,
                  onTap: () => context.push('/ambulance'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Emergency Department Live Triage Card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Emergency & Trauma Live Triage',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () => context.push('/emergency'),
                        child: const Text('Manage ER', style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildTriagePill('Level 1: Red (Critical)', '2', AppColors.triageRed),
                      const SizedBox(width: 8),
                      _buildTriagePill('Level 2: Yellow (Urgent)', '5', AppColors.triageYellow),
                      const SizedBox(width: 8),
                      _buildTriagePill('Level 3: Green (Stable)', '11', AppColors.triageGreen),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Operational Modules Quick Links
            const Text(
              'Hospital Operational Management',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text),
            ),
            const SizedBox(height: 12),
            _buildAdminMenuTile(
              context,
              icon: Icons.badge_outlined,
              title: 'Staff Management & Shifts',
              subtitle: '124 Doctors, Nurses, and Clinical Technicians',
              route: '/staff',
            ),
            const SizedBox(height: 8),
            _buildAdminMenuTile(
              context,
              icon: Icons.inventory_2_outlined,
              title: 'Medical Inventory & Supplies',
              subtitle: 'PPE, Surgical consumables & Equipment monitoring',
              route: '/inventory',
            ),
            const SizedBox(height: 8),
            _buildAdminMenuTile(
              context,
              icon: Icons.hotel_outlined,
              title: 'Wards & Bed Capacity Allocation',
              subtitle: 'General, ICU, Neonatal, and Private suites',
              route: '/admissions',
            ),
            const SizedBox(height: 8),
            _buildAdminMenuTile(
              context,
              icon: Icons.analytics_outlined,
              title: 'Clinical Analytics & Financial Reports',
              subtitle: 'Revenue metrics, patient flow, and CSV exports',
              route: '/reports',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTriagePill(String title, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(count, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(title, textAlign: TextAlign.center, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminMenuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
  }) {
    return AppCard(
      onTap: () => context.push(route),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primaryDark, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
