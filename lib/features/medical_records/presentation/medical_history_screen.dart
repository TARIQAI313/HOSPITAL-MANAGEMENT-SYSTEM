import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../data/medical_record_repository.dart';
import '../domain/medical_record_model.dart';

class MedicalHistoryScreen extends ConsumerWidget {
  const MedicalHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(medicalRecordRepositoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Electronic Medical Records'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_chart_rounded),
            tooltip: 'Record Vitals',
            onPressed: () => context.push('/vitals/log'),
          ),
        ],
      ),
      body: FutureBuilder(
        future: Future.wait([
          repo.getVitalsHistory(),
          repo.getClinicalHistory(),
        ]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (!snapshot.hasData) {
            return const LoadingIndicator(message: 'Loading clinical records & vitals...');
          }

          final vitals = snapshot.data![0] as List<VitalSignsModel>;
          final records = snapshot.data![1] as List<ClinicalRecordModel>;
          final latestVital = vitals.isNotEmpty ? vitals.first : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Latest Vitals Snapshot Cards
                const Text(
                  'Latest Vital Signs',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text),
                ),
                const SizedBox(height: 10),
                if (latestVital != null) ...[
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.6,
                    children: [
                      _buildVitalTile(
                        icon: Icons.speed_rounded,
                        color: AppColors.primaryDark,
                        title: 'Blood Pressure',
                        value: '${latestVital.systolicBp}/${latestVital.diastolicBp}',
                        unit: 'mmHg',
                        status: 'Optimal',
                      ),
                      _buildVitalTile(
                        icon: Icons.favorite_rounded,
                        color: AppColors.error,
                        title: 'Heart Rate',
                        value: '${latestVital.heartRate}',
                        unit: 'bpm',
                        status: 'Normal',
                      ),
                      _buildVitalTile(
                        icon: Icons.air_rounded,
                        color: AppColors.info,
                        title: 'Blood Oxygen',
                        value: '${latestVital.oxygenSaturation}',
                        unit: '% SpO2',
                        status: 'Normal',
                      ),
                      _buildVitalTile(
                        icon: Icons.thermostat_rounded,
                        color: AppColors.warning,
                        title: 'Body Temp',
                        value: '${latestVital.temperatureC}',
                        unit: '°C',
                        status: 'Normal',
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (latestVital.bmi != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.monitor_weight_outlined, color: AppColors.primaryDark, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            'BMI Index: ${latestVital.bmi!.toStringAsFixed(1)} kg/m²',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                          ),
                          const Spacer(),
                          const Text(
                            'Healthy Weight',
                            style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                ],
                const SizedBox(height: 24),

                // Clinical Consultations Timeline
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Clinical Consultations Timeline',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text),
                    ),
                    Text(
                      '${records.length} records',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...records.map((rec) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                rec.doctorName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              Text(
                                AppFormatters.formatShortDate(rec.recordedDate),
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                              ),
                            ],
                          ),
                          Text(
                            rec.doctorSpecialty,
                            style: const TextStyle(color: AppColors.primaryDark, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          const Divider(height: 20),
                          _buildRecordField('Diagnosis', rec.diagnosis, isBold: true),
                          const SizedBox(height: 6),
                          _buildRecordField('Chief Complaint', rec.chiefComplaint),
                          const SizedBox(height: 6),
                          _buildRecordField('Treatment Plan', rec.treatmentPlan),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildVitalTile({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
    required String unit,
    required String status,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              Icon(icon, size: 18, color: color),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.text)),
              const SizedBox(width: 4),
              Text(unit, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
          Text(status, style: const TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRecordField(String label, String value, {bool isBold = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: AppColors.text,
            ),
          ),
        ),
      ],
    );
  }
}
