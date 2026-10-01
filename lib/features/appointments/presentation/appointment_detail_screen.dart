import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/avatar_widget.dart';
import '../../../core/widgets/status_badge.dart';
import '../domain/appointment_model.dart';

class AppointmentDetailScreen extends StatelessWidget {
  final String appointmentId;
  final AppointmentModel? appointmentExtra;

  const AppointmentDetailScreen({
    super.key,
    required this.appointmentId,
    this.appointmentExtra,
  });

  @override
  Widget build(BuildContext context) {
    final item = appointmentExtra ?? AppointmentModel(
      id: appointmentId,
      patientId: '30000000-0000-0000-0000-000000000001',
      patientName: 'Emma Stonehurst',
      doctorId: '20000000-0000-0000-0000-000000000001',
      doctorName: 'Dr. Sarah Watson',
      doctorSpecialty: 'Cardiologist',
      departmentName: 'Cardiology',
      appointmentDate: DateTime.now().add(const Duration(days: 1)),
      startTime: '09:30 AM',
      endTime: '10:00 AM',
      type: 'in_person',
      status: 'confirmed',
      reason: 'Annual cardiac checkup & ECG review',
      queueNumber: 1,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Appointment Confirmation'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // E-Ticket Card
            AppCard(
              hasShadow: true,
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Queue Pass',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          Text(
                            item.queueNumber != null ? '#00${item.queueNumber}' : '#-- ',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ],
                      ),
                      StatusBadge.fromStatus(item.status),
                    ],
                  ),
                  const Divider(height: 28),

                  // Doctor Row
                  Row(
                    children: [
                      AvatarWidget(
                        imageUrl: item.doctorAvatar,
                        name: item.doctorName,
                        size: 56,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.doctorName,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text),
                            ),
                            Text(
                              item.doctorSpecialty,
                              style: const TextStyle(fontSize: 13, color: AppColors.primaryDark, fontWeight: FontWeight.w600),
                            ),
                            if (item.departmentName != null)
                              Text(
                                item.departmentName!,
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Date and Time Box
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text('DATE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                            const SizedBox(height: 4),
                            Text(
                              AppFormatters.formatShortDate(item.appointmentDate),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 28,
                          child: VerticalDivider(color: AppColors.border, thickness: 1),
                        ),
                        Column(
                          children: [
                            const Text('TIME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                            const SizedBox(height: 4),
                            Text(
                              item.startTime,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 28,
                          child: VerticalDivider(color: AppColors.border, thickness: 1),
                        ),
                        Column(
                          children: [
                            const Text('TYPE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                            const SizedBox(height: 4),
                            Text(
                              item.type.replaceAll('_', ' ').toUpperCase(),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Patient & Purpose Info
                  _buildDetailRow('Patient Name', item.patientName),
                  const SizedBox(height: 10),
                  _buildDetailRow('Reason', item.reason),
                  const SizedBox(height: 10),
                  _buildDetailRow('Hospital Campus', 'Main Medical Tower, 3rd Floor'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            if (item.type.contains('telemedicine')) ...[
              AppButton(
                text: 'Enter Telemedicine Consultation Room',
                icon: Icons.videocam,
                isFullWidth: true,
                onPressed: () => context.push('/telemedicine'),
              ),
              const SizedBox(height: 12),
            ],

            AppButton(
              text: 'Message Specialist',
              icon: Icons.chat_outlined,
              variant: ButtonVariant.secondary,
              isFullWidth: true,
              onPressed: () => context.push('/messages/chat-dr-${item.doctorId}'),
            ),
            const SizedBox(height: 12),

            AppButton(
              text: 'Back to Appointments',
              variant: ButtonVariant.outline,
              isFullWidth: true,
              onPressed: () => context.go('/appointments'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.text)),
      ],
    );
  }
}
