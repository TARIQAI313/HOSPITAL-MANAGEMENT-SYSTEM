import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/routing/navigation_helper.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../data/medication_repository.dart';
import '../domain/medication_model.dart';
import 'pill_reminder_screen.dart';

class AddMedicationScreen extends ConsumerStatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  ConsumerState<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends ConsumerState<AddMedicationScreen> {
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController(text: '1 tablet');
  final _pillsCountController = TextEditingController(text: '30');
  final _instructionsController = TextEditingController();
  String _selectedForm = 'Pill';
  final List<String> _selectedTimesOfDay = ['morning'];
  TimeOfDay _reminderTime = const TimeOfDay(hour: 8, minute: 0);
  bool _isSaving = false;

  final List<String> _forms = ['Pill', 'Capsule', 'Tablet', 'Syrup', 'Injection'];

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _pillsCountController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _onSaveMedication() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter medication name.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final repo = ref.read(medicationRepositoryProvider);

    final med = MedicationModel(
      id: 'med-${DateTime.now().millisecondsSinceEpoch}',
      patientId: '30000000-0000-0000-0000-000000000001',
      name: _nameController.text.trim(),
      form: _selectedForm,
      dosage: _dosageController.text.trim(),
      startDate: DateTime.now(),
      scheduleTimes: [_reminderTime.format(context)],
      timeOfDay: _selectedTimesOfDay,
      remainingPills: int.tryParse(_pillsCountController.text) ?? 30,
      instructions: _instructionsController.text.trim(),
    );

    await repo.addMedication(med);
    ref.invalidate(medicationListProvider);

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medication reminder scheduled successfully.')),
      );
      context.safePop(null, RoutePaths.medications);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBackScope(
      fallbackRoute: RoutePaths.medications,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Add Pill Reminder'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.safePop(null, RoutePaths.medications),
          ),
        ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              controller: _nameController,
              label: 'Medication Name',
              hint: 'e.g. Lisinopril, Metformin...',
            ),
            const SizedBox(height: 16),

            // Form Selector
            const Text('Medication Form', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _forms.map((f) {
                final isSelected = _selectedForm == f;
                return ChoiceChip(
                  label: Text(f),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.text,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                  onSelected: (_) => setState(() => _selectedForm = f),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _dosageController,
                    label: 'Dosage / Strength',
                    hint: 'e.g. 500mg or 1 tab',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    controller: _pillsCountController,
                    label: 'Total Pack Quantity',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Time of Day
            const Text('Schedule Intake Period', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['morning', 'afternoon', 'evening', 'night'].map((tod) {
                final isSelected = _selectedTimesOfDay.contains(tod);
                return FilterChip(
                  label: Text(tod.toUpperCase()),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.text,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 12,
                  ),
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        _selectedTimesOfDay.add(tod);
                      } else {
                        if (_selectedTimesOfDay.length > 1) {
                          _selectedTimesOfDay.remove(tod);
                        }
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Time Picker
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Reminder Alert Time', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                TextButton.icon(
                  icon: const Icon(Icons.access_time, color: AppColors.primaryDark),
                  label: Text(
                    _reminderTime.format(context),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                  ),
                  onPressed: () async {
                    final picked = await showTimePicker(context: context, initialTime: _reminderTime);
                    if (picked != null) setState(() => _reminderTime = picked);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            AppTextField(
              controller: _instructionsController,
              label: 'Instructions / Food Requirement',
              hint: 'e.g. Take with warm milk after meal...',
            ),
            const SizedBox(height: 28),

            AppButton(
              text: 'Save Pill Schedule',
              isFullWidth: true,
              isLoading: _isSaving,
              onPressed: _onSaveMedication,
            ),
          ],
        ),
      ),
    ),
  );
}
}
