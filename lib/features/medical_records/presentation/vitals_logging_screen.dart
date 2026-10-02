import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/routing/navigation_helper.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../data/medical_record_repository.dart';
import '../domain/medical_record_model.dart';

class VitalsLoggingScreen extends ConsumerStatefulWidget {
  final String? patientId;

  const VitalsLoggingScreen({super.key, this.patientId});

  @override
  ConsumerState<VitalsLoggingScreen> createState() => _VitalsLoggingScreenState();
}

class _VitalsLoggingScreenState extends ConsumerState<VitalsLoggingScreen> {
  final _systolicController = TextEditingController(text: '120');
  final _diastolicController = TextEditingController(text: '80');
  final _heartRateController = TextEditingController(text: '72');
  final _tempController = TextEditingController(text: '37.0');
  final _spo2Controller = TextEditingController(text: '98');
  final _weightController = TextEditingController(text: '65.0');
  final _heightController = TextEditingController(text: '170.0');
  final _notesController = TextEditingController();
  bool _isSaving = false;

  double? _calculatedBmi;

  @override
  void initState() {
    super.initState();
    _recalculateBmi();
    _weightController.addListener(_recalculateBmi);
    _heightController.addListener(_recalculateBmi);
  }

  void _recalculateBmi() {
    final w = double.tryParse(_weightController.text);
    final h = double.tryParse(_heightController.text);
    if (w != null && h != null && h > 0) {
      final hM = h / 100.0;
      setState(() => _calculatedBmi = w / (hM * hM));
    }
  }

  @override
  void dispose() {
    _systolicController.dispose();
    _diastolicController.dispose();
    _heartRateController.dispose();
    _tempController.dispose();
    _spo2Controller.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onSaveVitals() async {
    setState(() => _isSaving = true);
    final repo = ref.read(medicalRecordRepositoryProvider);

    final vitals = VitalSignsModel(
      id: 'v-${DateTime.now().millisecondsSinceEpoch}',
      patientId: widget.patientId ?? '30000000-0000-0000-0000-000000000001',
      systolicBp: int.tryParse(_systolicController.text) ?? 120,
      diastolicBp: int.tryParse(_diastolicController.text) ?? 80,
      heartRate: int.tryParse(_heartRateController.text) ?? 72,
      temperatureC: double.tryParse(_tempController.text) ?? 37.0,
      oxygenSaturation: int.tryParse(_spo2Controller.text) ?? 98,
      weightKg: double.tryParse(_weightController.text),
      heightCm: double.tryParse(_heightController.text),
      recordedAt: DateTime.now(),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    await repo.logVitalSigns(vitals);

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vital signs logged successfully.')),
      );
      context.safePop(null, RoutePaths.medicalHistory);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBackScope(
      fallbackRoute: RoutePaths.medicalHistory,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Log Patient Vitals'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.safePop(null, RoutePaths.medicalHistory),
          ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // BP Card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Blood Pressure (mmHg)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _systolicController,
                          label: 'Systolic',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          controller: _diastolicController,
                          label: 'Diastolic',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Heart Rate & Oxygen
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Cardiopulmonary Metrics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _heartRateController,
                          label: 'Heart Rate (bpm)',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          controller: _spo2Controller,
                          label: 'SpO2 Oxygen (%)',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _tempController,
                    label: 'Body Temperature (°C)',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Body Metrics & BMI
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Body Weight & Height', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _weightController,
                          label: 'Weight (kg)',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          controller: _heightController,
                          label: 'Height (cm)',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                    ],
                  ),
                  if (_calculatedBmi != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Calculated BMI:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryDark)),
                          Text(
                            '${_calculatedBmi!.toStringAsFixed(1)} kg/m²',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryDark),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),

            AppTextField(
              controller: _notesController,
              label: 'Clinical Observation Notes (Optional)',
              hint: 'e.g. Patient rested 10 mins before reading...',
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            AppButton(
              text: 'Save Vital Signs',
              isFullWidth: true,
              isLoading: _isSaving,
              onPressed: _onSaveVitals,
            ),
          ],
        ),
      ),
    ),
  );
}
}
