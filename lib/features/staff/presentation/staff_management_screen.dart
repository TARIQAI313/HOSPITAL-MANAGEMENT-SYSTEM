import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/avatar_widget.dart';
import '../../../core/widgets/status_badge.dart';

class StaffManagementScreen extends StatelessWidget {
  const StaffManagementScreen({super.key});

  final List<Map<String, dynamic>> _staffList = const [
    {
      'name': 'Dr. Sarah Watson',
      'role': 'Lead Cardiologist',
      'department': 'Cardiology',
      'shift': 'Morning (08:00 - 16:00)',
      'status': 'on_duty',
      'avatar': 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&q=80&w=300',
    },
    {
      'name': 'Nurse Clara Oswald',
      'role': 'Senior Ward Sister',
      'department': 'Inpatient Ward 3B',
      'shift': 'Morning (08:00 - 16:00)',
      'status': 'on_duty',
      'avatar': null,
    },
    {
      'name': 'Dr. Marcus Vance',
      'role': 'Senior Neurologist',
      'department': 'Neurology',
      'shift': 'Evening (16:00 - 00:00)',
      'status': 'off_duty',
      'avatar': 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?auto=format&fit=crop&q=80&w=300',
    },
    {
      'name': 'Tariq Al-Mansoor',
      'role': 'Senior Lab Technologist',
      'department': 'Pathology',
      'shift': 'Night (00:00 - 08:00)',
      'status': 'on_duty',
      'avatar': null,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Hospital Staff & Roster'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: _staffList.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, idx) {
          final s = _staffList[idx];
          final isOnDuty = s['status'] == 'on_duty';

          return AppCard(
            hasShadow: true,
            child: Row(
              children: [
                AvatarWidget(
                  name: s['name'] as String,
                  imageUrl: s['avatar'] as String?,
                  size: 48,
                  showBadge: true,
                  isOnline: isOnDuty,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(
                        '${s['role']} • ${s['department']}',
                        style: const TextStyle(fontSize: 12, color: AppColors.primaryDark, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Shift: ${s['shift']}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                StatusBadge(
                  label: isOnDuty ? 'ON DUTY' : 'OFF DUTY',
                  backgroundColor: isOnDuty ? AppColors.successLight : AppColors.surfaceVariant,
                  textColor: isOnDuty ? AppColors.success : AppColors.textSecondary,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
