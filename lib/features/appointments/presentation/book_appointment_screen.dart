import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/routing/navigation_helper.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/avatar_widget.dart';
import '../../../core/widgets/time_slot_selector.dart';
import '../../doctors/data/doctor_repository.dart';
import '../../doctors/domain/doctor_model.dart';
import '../data/appointment_repository.dart';
import '../domain/appointment_model.dart';
import 'appointment_list_screen.dart';

class BookAppointmentScreen extends ConsumerStatefulWidget {
  final DoctorModel? initialDoctor;

  const BookAppointmentScreen({
    super.key,
    this.initialDoctor,
  });

  @override
  ConsumerState<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends ConsumerState<BookAppointmentScreen> {
  DoctorModel? _selectedDoctor;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedSlot = '09:30 AM';
  String _selectedType = 'in_person'; // 'in_person', 'telemedicine_video', 'telemedicine_audio'
  final _reasonController = TextEditingController(text: 'Routine medical consultation');
  bool _isBooking = false;

  final List<String> _timeSlots = const [
    '09:00 AM',
    '09:30 AM',
    '10:00 AM',
    '10:30 AM',
    '11:00 AM',
    '11:30 AM',
    '02:00 PM',
    '02:30 PM',
    '03:00 PM',
    '03:30 PM',
    '04:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDoctor = widget.initialDoctor;
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _onConfirmBooking() async {
    if (_selectedDoctor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a doctor to continue.')),
      );
      return;
    }
    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose an available appointment slot.')),
      );
      return;
    }

    setState(() => _isBooking = true);
    final repo = ref.read(appointmentRepositoryProvider);

    final appointment = AppointmentModel(
      id: 'app-${DateTime.now().millisecondsSinceEpoch}',
      patientId: '30000000-0000-0000-0000-000000000001',
      patientName: 'Emma Stonehurst',
      doctorId: _selectedDoctor!.id,
      doctorName: _selectedDoctor!.fullName,
      doctorSpecialty: _selectedDoctor!.specialty,
      doctorAvatar: _selectedDoctor!.avatarUrl,
      departmentName: _selectedDoctor!.departmentName,
      appointmentDate: _selectedDate,
      startTime: _selectedSlot!,
      endTime: '${_selectedSlot!.split(' ')[0].split(':')[0]}:45 ${_selectedSlot!.split(' ')[1]}',
      type: _selectedType,
      status: 'confirmed',
      reason: _reasonController.text.trim().isEmpty ? 'Clinical Consult' : _reasonController.text.trim(),
      queueNumber: 3,
    );

    await repo.bookAppointment(appointment);
    ref.invalidate(appointmentListProvider);

    if (mounted) {
      setState(() => _isBooking = false);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.successLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 48, color: AppColors.success),
              ),
              const SizedBox(height: 16),
              const Text(
                'Appointment Confirmed!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Your session with ${_selectedDoctor!.fullName} is booked for ${AppFormatters.formatShortDate(_selectedDate)} at $_selectedSlot.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              AppButton(
                text: 'View Appointments',
                isFullWidth: true,
                onPressed: () {
                  Navigator.of(ctx).pop();
                  context.go('/appointments');
                },
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctorsAsync = ref.watch(doctorRepositoryProvider).getDoctors();

    return AppBackScope(
      fallbackRoute: RoutePaths.appointments,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Book Appointment'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.safePop(null, RoutePaths.appointments),
          ),
        ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selected Doctor or Doctor Picker
            const Text(
              'Select Physician',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.text),
            ),
            const SizedBox(height: 10),
            if (_selectedDoctor != null) ...[
              AppCard(
                child: Row(
                  children: [
                    AvatarWidget(
                      imageUrl: _selectedDoctor!.avatarUrl,
                      name: _selectedDoctor!.fullName,
                      size: 54,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedDoctor!.fullName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          Text(
                            _selectedDoctor!.specialty,
                            style: const TextStyle(color: AppColors.primaryDark, fontSize: 13),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Consultation Fee: \$${_selectedDoctor!.consultationFee.toStringAsFixed(0)}',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _selectedDoctor = null),
                      child: const Text('Change', style: TextStyle(color: AppColors.primaryDark)),
                    ),
                  ],
                ),
              ),
            ] else ...[
              FutureBuilder<List<DoctorModel>>(
                future: doctorsAsync,
                builder: (context, snapshot) {
                  final list = snapshot.data ?? [];
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<DoctorModel>(
                        hint: const Text('Select a doctor'),
                        isExpanded: true,
                        value: _selectedDoctor,
                        items: list.map((doc) {
                          return DropdownMenuItem(
                            value: doc,
                            child: Text('${doc.fullName} - ${doc.specialty}'),
                          );
                        }).toList(),
                        onChanged: (doc) => setState(() => _selectedDoctor = doc),
                      ),
                    ),
                  );
                },
              ),
            ],
            const SizedBox(height: 24),

            // Consultation Mode
            const Text(
              'Consultation Mode',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.text),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildModeCard(
                  type: 'in_person',
                  icon: Icons.local_hospital_outlined,
                  title: 'In-Person',
                  subtitle: 'Hospital Visit',
                ),
                const SizedBox(width: 10),
                _buildModeCard(
                  type: 'telemedicine_video',
                  icon: Icons.videocam_outlined,
                  title: 'Video Call',
                  subtitle: 'Online Clinic',
                ),
                const SizedBox(width: 10),
                _buildModeCard(
                  type: 'telemedicine_audio',
                  icon: Icons.phone_in_talk_outlined,
                  title: 'Audio Call',
                  subtitle: 'Quick Advice',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Appointment Date Picker
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Date',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.text),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.edit_calendar, size: 16, color: AppColors.primaryDark),
                  label: Text(
                    AppFormatters.formatShortDate(_selectedDate),
                    style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                    );
                    if (picked != null) setState(() => _selectedDate = picked);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Time Slots Selection (Inspired by Reference)
            const Text(
              'Available Time Slots',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.text),
            ),
            const SizedBox(height: 12),
            TimeSlotSelector(
              availableSlots: _timeSlots,
              selectedSlot: _selectedSlot,
              onSelectSlot: (slot) => setState(() => _selectedSlot = slot),
            ),
            const SizedBox(height: 24),

            // Reason / Symptoms
            const Text(
              'Reason for Visit / Symptoms',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.text),
            ),
            const SizedBox(height: 10),
            AppTextField(
              controller: _reasonController,
              hint: 'Briefly describe your symptoms or consultation requirement...',
              maxLines: 3,
            ),
            const SizedBox(height: 32),

            // Confirm Button
            AppButton(
              text: 'Confirm & Book Appointment',
              isFullWidth: true,
              isLoading: _isBooking,
              onPressed: _onConfirmBooking,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildModeCard({
    required String type,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedType == type;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedType = type),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryLight : Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: isSelected ? AppColors.primaryDark : AppColors.border,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 24, color: isSelected ? AppColors.primaryDark : AppColors.textSecondary),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? AppColors.primaryDark : AppColors.text,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
