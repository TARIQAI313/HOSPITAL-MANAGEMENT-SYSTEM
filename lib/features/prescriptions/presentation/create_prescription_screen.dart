import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../data/prescription_repository.dart';
import '../domain/prescription_model.dart';
import 'prescription_list_screen.dart';

class CreatePrescriptionScreen extends ConsumerStatefulWidget {
  const CreatePrescriptionScreen({super.key});

  @override
  ConsumerState<CreatePrescriptionScreen> createState() => _CreatePrescriptionScreenState();
}

class _CreatePrescriptionScreenState extends ConsumerState<CreatePrescriptionScreen> {
  final _instructionsController = TextEditingController();
  final List<PrescriptionItemModel> _items = [
    const PrescriptionItemModel(
      medicineName: 'Amoxicillin Trihydrate',
      form: 'Capsule',
      dosage: '500mg',
      frequency: 'Every 8 hours',
      timing: 'after_meal',
      durationDays: 7,
      instructions: 'Complete entire course',
    ),
  ];

  final _medNameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _frequencyController = TextEditingController();
  String _selectedTiming = 'after_meal';
  bool _isSaving = false;

  @override
  void dispose() {
    _instructionsController.dispose();
    _medNameController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    super.dispose();
  }

  void _addMedicine() {
    if (_medNameController.text.trim().isEmpty) return;
    setState(() {
      _items.add(
        PrescriptionItemModel(
          medicineName: _medNameController.text.trim(),
          dosage: _dosageController.text.trim().isEmpty ? '1 unit' : _dosageController.text.trim(),
          frequency: _frequencyController.text.trim().isEmpty ? 'Once daily' : _frequencyController.text.trim(),
          timing: _selectedTiming,
          durationDays: 7,
        ),
      );
      _medNameController.clear();
      _dosageController.clear();
      _frequencyController.clear();
    });
  }

  void _onSavePrescription() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one medication to the prescription.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final repo = ref.read(prescriptionRepositoryProvider);

    final rx = PrescriptionModel(
      id: 'rx-${DateTime.now().millisecondsSinceEpoch}',
      prescriptionCode: 'RX-2026-${(DateTime.now().millisecondsSinceEpoch % 10000)}',
      patientId: '30000000-0000-0000-0000-000000000001',
      patientName: 'Emma Stonehurst',
      doctorId: '20000000-0000-0000-0000-000000000001',
      doctorName: 'Dr. Sarah Watson',
      doctorSpecialty: 'Cardiologist',
      doctorSignature: 'Dr. Sarah Watson, MD (Digital Verified)',
      issuedDate: DateTime.now(),
      generalInstructions: _instructionsController.text.trim(),
      items: _items,
    );

    await repo.createPrescription(rx);
    ref.invalidate(prescriptionListProvider);

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digital Prescription created and signed.')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Write Digital Prescription'),
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
            // Patient Banner
            AppCard(
              child: Row(
                children: [
                  const Icon(Icons.person, color: AppColors.primaryDark),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Emma Stonehurst (MR-2026-0001)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('Age: 34y • Female • Blood: A+', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Medicines List
            const Text(
              'Prescribed Medications',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text),
            ),
            const SizedBox(height: 10),
            ..._items.asMap().entries.map((entry) {
              final idx = entry.key;
              final med = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AppCard(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.medication_outlined, color: AppColors.primaryDark, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${med.medicineName} (${med.dosage})',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              '${med.frequency} • ${med.timing.replaceAll('_', ' ')} • ${med.durationDays} days',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                        onPressed: () => setState(() => _items.removeAt(idx)),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),

            // Add Medicine Sub-form
            AppCard(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Add Medicine', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _medNameController,
                    label: 'Medicine Name & Brand',
                    hint: 'e.g. Paracetamol / Panadol',
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _dosageController,
                          label: 'Dosage',
                          hint: '500mg',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          controller: _frequencyController,
                          label: 'Frequency',
                          hint: '1-0-1 or 8 hourly',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text('Timing: ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      ChoiceChip(
                        label: const Text('After Meal'),
                        selected: _selectedTiming == 'after_meal',
                        onSelected: (_) => setState(() => _selectedTiming = 'after_meal'),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Before Meal'),
                        selected: _selectedTiming == 'before_meal',
                        onSelected: (_) => setState(() => _selectedTiming = 'before_meal'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  AppButton(
                    text: '+ Add Medication Item',
                    variant: ButtonVariant.secondary,
                    isFullWidth: true,
                    onPressed: _addMedicine,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            AppTextField(
              controller: _instructionsController,
              label: 'General Clinical Advice / Diet Directions',
              hint: 'e.g. Drink warm fluids, avoid heavy physical exertion...',
              maxLines: 3,
            ),
            const SizedBox(height: 28),

            AppButton(
              text: 'Sign & Issue Digital Prescription',
              icon: Icons.draw_outlined,
              isFullWidth: true,
              isLoading: _isSaving,
              onPressed: _onSavePrescription,
            ),
          ],
        ),
      ),
    );
  }
}
