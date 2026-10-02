import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/routing/navigation_helper.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/avatar_widget.dart';
import '../domain/patient_model.dart';

class PatientDetailScreen extends StatelessWidget {
  final String patientId;
  final PatientModel? patientExtra;

  const PatientDetailScreen({
    super.key,
    required this.patientId,
    this.patientExtra,
  });

  @override
  Widget build(BuildContext context) {
    final patient = patientExtra ?? PatientModel(
      id: patientId,
      mrNumber: 'MR-2026-0001',
      fullName: 'Emma Stonehurst',
      email: 'patient1@example.com',
      phone: '+1 (555) 101-0001',
      gender: 'female',
      bloodGroup: 'A+',
      dateOfBirth: DateTime(1992, 4, 12),
      emergencyContactName: 'David Stonehurst',
      emergencyContactPhone: '+1 (555) 9011',
      emergencyContactRelation: 'Spouse',
      insuranceProvider: 'BlueCross BlueShield',
      insurancePolicyNumber: 'BC-8899214',
      allergies: ['Penicillin', 'Peanuts'],
      chronicConditions: ['Mild Asthma'],
      notes: 'Patient exhibits high adherence to medication scheduling.',
    );

    return AppBackScope(
      fallbackRoute: RoutePaths.patients,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Electronic Medical Record'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.safePop(null, RoutePaths.patients),
          ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/profile/edit', extra: patient),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient Header Card
            AppCard(
              hasShadow: true,
              child: Row(
                children: [
                  AvatarWidget(
                    imageUrl: patient.avatarUrl,
                    name: patient.fullName,
                    size: 64,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient.fullName,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                patient.mrNumber,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.primaryDark),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${patient.gender?.toUpperCase() ?? 'FEMALE'} • ${patient.age ?? 34} YRS',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Blood Group: ${patient.bloodGroup ?? "O+"}',
                          style: const TextStyle(fontSize: 12, color: AppColors.primaryDark, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Clinical Allergies Alert Box
            if (patient.allergies.isNotEmpty) ...[
              AppCard(
                color: AppColors.errorLight,
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Known Clinical Allergies',
                          style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: patient.allergies.map((allergy) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.error.withOpacity(0.4)),
                          ),
                          child: Text(
                            allergy,
                            style: const TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Chronic Conditions
            const Text(
              'Chronic Health Conditions',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.text),
            ),
            const SizedBox(height: 8),
            if (patient.chronicConditions.isEmpty)
              const Text('No chronic conditions recorded.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13))
            else
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: patient.chronicConditions.map((cond) {
                  return Chip(
                    label: Text(cond),
                    backgroundColor: AppColors.primaryLight,
                    side: BorderSide.none,
                    labelStyle: const TextStyle(fontSize: 12, color: AppColors.primaryDark, fontWeight: FontWeight.bold),
                  );
                }).toList(),
              ),
            const SizedBox(height: 20),

            // Emergency Contact & Insurance
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Emergency Contact', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text('${patient.emergencyContactName ?? "David Stonehurst"} (${patient.emergencyContactRelation ?? "Spouse"})'),
                  Text(patient.emergencyContactPhone ?? "+1 (555) 9011", style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  const Divider(height: 20),
                  const Text('Insurance Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(patient.insuranceProvider ?? 'BlueCross BlueShield Comprehensive Care'),
                  Text('Policy: ${patient.insurancePolicyNumber ?? "BC-8899214"}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quick Clinical Actions
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Record Vitals',
                    icon: Icons.monitor_heart_outlined,
                    variant: ButtonVariant.secondary,
                    onPressed: () => context.push('/vitals/log'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    text: 'Issue Prescription',
                    icon: Icons.medication_outlined,
                    onPressed: () => context.push('/prescriptions/create'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
}
