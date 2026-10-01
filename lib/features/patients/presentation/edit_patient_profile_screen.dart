import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../data/patient_repository.dart';
import '../domain/patient_model.dart';
import 'patient_list_screen.dart';

class EditPatientProfileScreen extends ConsumerStatefulWidget {
  final PatientModel? patient;

  const EditPatientProfileScreen({
    super.key,
    this.patient,
  });

  @override
  ConsumerState<EditPatientProfileScreen> createState() => _EditPatientProfileScreenState();
}

class _EditPatientProfileScreenState extends ConsumerState<EditPatientProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emergencyContactController;
  late final TextEditingController _emergencyPhoneController;
  late final TextEditingController _insuranceProviderController;
  late final TextEditingController _insurancePolicyController;
  String _selectedBloodGroup = 'A+';
  bool _isSaving = false;

  final List<String> _bloodGroups = const ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  void initState() {
    super.initState();
    final p = widget.patient;
    _nameController = TextEditingController(text: p?.fullName ?? 'Emma Stonehurst');
    _phoneController = TextEditingController(text: p?.phone ?? '+1 (555) 101-0001');
    _emergencyContactController = TextEditingController(text: p?.emergencyContactName ?? 'David Stonehurst');
    _emergencyPhoneController = TextEditingController(text: p?.emergencyContactPhone ?? '+1 (555) 9011');
    _insuranceProviderController = TextEditingController(text: p?.insuranceProvider ?? 'BlueCross BlueShield');
    _insurancePolicyController = TextEditingController(text: p?.insurancePolicyNumber ?? 'BC-8899214');
    _selectedBloodGroup = p?.bloodGroup ?? 'A+';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emergencyContactController.dispose();
    _emergencyPhoneController.dispose();
    _insuranceProviderController.dispose();
    _insurancePolicyController.dispose();
    super.dispose();
  }

  void _onSave() async {
    setState(() => _isSaving = true);
    final repo = ref.read(patientRepositoryProvider);

    final updated = PatientModel(
      id: widget.patient?.id ?? '30000000-0000-0000-0000-000000000001',
      mrNumber: widget.patient?.mrNumber ?? 'MR-2026-0001',
      fullName: _nameController.text.trim(),
      email: widget.patient?.email ?? 'patient1@example.com',
      phone: _phoneController.text.trim(),
      bloodGroup: _selectedBloodGroup,
      emergencyContactName: _emergencyContactController.text.trim(),
      emergencyContactPhone: _emergencyPhoneController.text.trim(),
      insuranceProvider: _insuranceProviderController.text.trim(),
      insurancePolicyNumber: _insurancePolicyController.text.trim(),
      allergies: widget.patient?.allergies ?? [],
      chronicConditions: widget.patient?.chronicConditions ?? [],
    );

    await repo.updatePatientProfile(updated);
    ref.invalidate(patientListProvider);

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile information updated successfully.')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Patient Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            AppTextField(
              controller: _nameController,
              label: 'Full Legal Name',
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _phoneController,
              label: 'Phone Number',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Blood Group', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedBloodGroup,
                      isExpanded: true,
                      items: _bloodGroups.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedBloodGroup = val);
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _emergencyContactController,
              label: 'Emergency Contact Person',
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _emergencyPhoneController,
              label: 'Emergency Contact Phone',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _insuranceProviderController,
              label: 'Insurance Provider',
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _insurancePolicyController,
              label: 'Insurance Policy Number',
            ),
            const SizedBox(height: 28),
            AppButton(
              text: 'Save Patient Details',
              isFullWidth: true,
              isLoading: _isSaving,
              onPressed: _onSave,
            ),
          ],
        ),
      ),
    );
  }
}
