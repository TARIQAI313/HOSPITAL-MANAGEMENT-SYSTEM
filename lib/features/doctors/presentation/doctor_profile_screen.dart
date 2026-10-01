import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/avatar_widget.dart';
import '../data/doctor_repository.dart';
import '../domain/doctor_model.dart';

class DoctorProfileScreen extends ConsumerWidget {
  final String doctorId;
  final DoctorModel? doctorExtra;

  const DoctorProfileScreen({
    super.key,
    required this.doctorId,
    this.doctorExtra,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(doctorRepositoryProvider);

    return FutureBuilder<DoctorModel?>(
      future: doctorExtra != null ? Future.value(doctorExtra) : repo.getDoctorById(doctorId),
      builder: (context, snapshot) {
        final doc = snapshot.data ?? doctorExtra;

        if (doc == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              // Teal Header
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                backgroundColor: AppColors.primary,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.favorite_border, color: Colors.white),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Added to your favorite specialists.')),
                      );
                    },
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.tealGradient,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 30),
                          AvatarWidget(
                            imageUrl: doc.avatarUrl,
                            name: doc.fullName,
                            size: 80,
                            showBadge: true,
                            isOnline: doc.isAvailable,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            doc.fullName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            doc.specialty,
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Doctor Information Details
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats Row
                      Row(
                        children: [
                          _buildStatBadge(
                            context,
                            icon: Icons.star,
                            iconColor: const Color(0xFFFBBF24),
                            value: '${doc.rating}',
                            label: '${doc.reviewsCount} reviews',
                          ),
                          const SizedBox(width: 12),
                          _buildStatBadge(
                            context,
                            icon: Icons.work_outline,
                            iconColor: AppColors.primaryDark,
                            value: '${doc.experienceYears}+ Yrs',
                            label: 'Experience',
                          ),
                          const SizedBox(width: 12),
                          _buildStatBadge(
                            context,
                            icon: Icons.attach_money,
                            iconColor: AppColors.success,
                            value: '\$${doc.consultationFee.toStringAsFixed(0)}',
                            label: 'Per Visit',
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // About Section
                      const Text(
                        'About Specialist',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        doc.bio ?? 'Experienced certified clinical consultant committed to holistic patient wellness.',
                        style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                      ),
                      const SizedBox(height: 20),

                      // Qualifications
                      const Text(
                        'Credentials & Board Certifications',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: doc.qualifications.map((q) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              q,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // Working Hours & Schedule
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.schedule, size: 18, color: AppColors.primaryDark),
                                SizedBox(width: 8),
                                Text(
                                  'Clinic Consultation Hours',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Available Days: ${doc.availableDays.join(", ")}',
                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Hours: ${doc.workingHoursStart} - ${doc.workingHoursEnd}',
                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Communication Quick Actions
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              text: 'Send Message',
                              icon: Icons.chat_bubble_outline,
                              variant: ButtonVariant.secondary,
                              onPressed: () => context.push('/messages/chat-dr-${doc.id}'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppButton(
                              text: 'Telehealth Call',
                              icon: Icons.videocam_outlined,
                              variant: ButtonVariant.outline,
                              onPressed: () => context.push('/telemedicine'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Book Appointment Main Button
                      AppButton(
                        text: 'Book Consultation Appointment',
                        icon: Icons.calendar_today_rounded,
                        isFullWidth: true,
                        onPressed: () => context.push('/appointments/book', extra: doc),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatBadge(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.text)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
