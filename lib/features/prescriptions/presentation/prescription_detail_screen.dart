import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../domain/prescription_model.dart';

class PrescriptionDetailScreen extends StatelessWidget {
  final PrescriptionModel? prescription;

  const PrescriptionDetailScreen({
    super.key,
    this.prescription,
  });

  @override
  Widget build(BuildContext context) {
    final rx = prescription ?? PrescriptionModel(
      id: 'rx-1',
      prescriptionCode: 'RX-2026-1001',
      patientId: '30000000-0000-0000-0000-000000000001',
      patientName: 'Emma Stonehurst',
      doctorId: '20000000-0000-0000-0000-000000000001',
      doctorName: 'Dr. Sarah Watson',
      doctorSpecialty: 'Cardiologist',
      status: 'active',
      doctorSignature: 'Dr. Sarah Watson, MD, FACC',
      issuedDate: DateTime.now(),
      generalInstructions: 'Take medications with plenty of water. Avoid skipping scheduled doses.',
      items: const [
        PrescriptionItemModel(
          medicineName: 'Atorvastatin (Lipitor)',
          form: 'Tablet',
          dosage: '20mg',
          frequency: 'Once daily before bedtime',
          timing: 'after_meal',
          durationDays: 30,
          instructions: 'For lipid and arterial plaque control',
        ),
        PrescriptionItemModel(
          medicineName: 'Lisinopril',
          form: 'Tablet',
          dosage: '10mg',
          frequency: 'Once daily in the morning',
          timing: 'after_meal',
          durationDays: 30,
          instructions: 'For blood pressure maintenance',
        ),
      ],
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Prescription ${rx.prescriptionCode}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined),
            tooltip: 'Print Prescription',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Prescription sent to print queue.')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            AppCard(
              hasShadow: true,
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AuraCare Medical Center',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                          ),
                          const Text(
                            'Official Digital Healthcare Prescription',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      StatusBadge.fromStatus(rx.status),
                    ],
                  ),
                  const Divider(height: 28),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Patient Name:', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          Text(rx.patientName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Issued Date:', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          Text(AppFormatters.formatShortDate(rx.issuedDate), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Prescribing Doctor: ${rx.doctorName} (${rx.doctorSpecialty})', style: const TextStyle(fontSize: 13, color: AppColors.primaryDark, fontWeight: FontWeight.w600)),
                  const Divider(height: 28),

                  // Rx Symbol Header
                  const Row(
                    children: [
                      Text(
                        '℞',
                        style: TextStyle(
                          fontSize: 28,
                          fontFamily: 'serif',
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Medications & Dosages:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  ...rx.items.asMap().entries.map((entry) {
                    final idx = entry.key + 1;
                    final item = entry.value;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$idx. ${item.medicineName}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              Text(
                                item.dosage,
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark, fontSize: 13),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Frequency: ${item.frequency} • Timing: ${item.timing.replaceAll('_', ' ')} • For ${item.durationDays} days',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          if (item.instructions != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Directions: ${item.instructions}',
                              style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.text),
                            ),
                          ],
                        ],
                      ),
                    );
                  }),

                  if (rx.generalInstructions != null) ...[
                    const SizedBox(height: 12),
                    const Text('General Instructions:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text(rx.generalInstructions!, style: const TextStyle(fontSize: 13, height: 1.4)),
                  ],
                  const Divider(height: 28),

                  // Doctor Signature Block
                  Align(
                    alignment: Alignment.centerRight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Signed & Cryptographically Verified:',
                          style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          rx.doctorSignature ?? rx.doctorName,
                          style: const TextStyle(
                            fontFamily: 'serif',
                            fontStyle: FontStyle.italic,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text('GMC / State Board Regulated', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            AppButton(
              text: 'Download Digital PDF Rx',
              icon: Icons.download_rounded,
              isFullWidth: true,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Prescription PDF saved.')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
