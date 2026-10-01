import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../domain/emergency_case_model.dart';

class EmergencyTriageScreen extends StatelessWidget {
  const EmergencyTriageScreen({super.key});

  final List<EmergencyCaseModel> _cases = const [
    EmergencyCaseModel(
      id: 'er-1',
      patientName: 'Unknown Trauma Male #1',
      triageLevel: 'resuscitation_red',
      chiefComplaint: 'Motor vehicle accident with severe thoracic trauma',
      arrivalTime: '10 mins ago',
      assignedDoctor: 'Dr. Tariq Mahmood (Trauma Lead)',
    ),
    EmergencyCaseModel(
      id: 'er-2',
      patientName: 'Sophia Ramirez',
      triageLevel: 'urgent_yellow',
      chiefComplaint: 'Acute severe asthma exacerbation with low SpO2',
      arrivalTime: '25 mins ago',
      assignedDoctor: 'Dr. Sarah Watson',
    ),
    EmergencyCaseModel(
      id: 'er-3',
      patientName: 'Liam Gallagher',
      triageLevel: 'less_urgent_green',
      chiefComplaint: 'Right wrist fracture after fall',
      arrivalTime: '40 mins ago',
      assignedDoctor: 'Dr. David Miller',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Emergency & Trauma Department (ER)'),
        backgroundColor: AppColors.error,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rapid SOS Hotline Banner
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: AppColors.error.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.emergency, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '24/7 Trauma Emergency Hotline',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.error),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          AppConstants.emergencyHotline,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text('Level 1 Resuscitation, Cardiac & Stroke Teams on Standby', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Active ER Triage Queue
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Active ER Triage Queue',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${_cases.length} in Bay',
                    style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            ..._cases.map((c) {
              Color badgeColor;
              String badgeLabel;

              switch (c.triageLevel) {
                case 'resuscitation_red':
                  badgeColor = AppColors.triageRed;
                  badgeLabel = 'PRIORITY 1: RED';
                  break;
                case 'urgent_yellow':
                  badgeColor = AppColors.triageYellow;
                  badgeLabel = 'PRIORITY 2: YELLOW';
                  break;
                default:
                  badgeColor = AppColors.triageGreen;
                  badgeLabel = 'PRIORITY 3: GREEN';
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppCard(
                  hasShadow: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: badgeColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              badgeLabel,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: badgeColor),
                            ),
                          ),
                          Text(
                            'Arrived ${c.arrivalTime}',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        c.patientName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        c.chiefComplaint,
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.medical_services_outlined, size: 14, color: AppColors.primaryDark),
                          const SizedBox(width: 6),
                          Text(
                            c.assignedDoctor,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => context.push('/vitals/log'),
                            child: const Text('Record Vitals', style: TextStyle(fontSize: 12)),
                          ),
                          const SizedBox(width: 8),
                          AppButton(
                            text: 'Admit to ICU/Ward',
                            height: 36,
                            onPressed: () => context.push('/admissions'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
