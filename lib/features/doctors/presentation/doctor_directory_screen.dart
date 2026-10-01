import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/avatar_widget.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/search_field.dart';
import '../data/doctor_repository.dart';
import '../domain/doctor_model.dart';

final selectedSpecialtyProvider = StateProvider<String>((ref) => 'All');
final searchQueryProvider = StateProvider<String>((ref) => '');

final doctorListProvider = FutureProvider<List<DoctorModel>>((ref) async {
  final repo = ref.watch(doctorRepositoryProvider);
  final specialty = ref.watch(selectedSpecialtyProvider);
  final query = ref.watch(searchQueryProvider);
  return repo.getDoctors(specialty: specialty, query: query);
});

class DoctorDirectoryScreen extends ConsumerWidget {
  const DoctorDirectoryScreen({super.key});

  final List<String> _specialties = const [
    'All',
    'Cardiologist',
    'Neurologist',
    'Dermatologist',
    'Pediatrician',
    'Gynecologist',
    'Orthopedic Surgeon',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorsAsync = ref.watch(doctorListProvider);
    final selectedSpecialty = ref.watch(selectedSpecialtyProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Teal App Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              decoration: const BoxDecoration(
                gradient: AppColors.tealGradient,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => context.pop(),
                      ),
                      const Text(
                        'Find Healthcare Specialists',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SearchField(
                    hint: 'Search by doctor name or specialty...',
                    onChanged: (val) => ref.read(searchQueryProvider.notifier).state = val,
                  ),
                ],
              ),
            ),

            // Horizontal Specialty Categories
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                scrollDirection: Axis.horizontal,
                itemCount: _specialties.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, idx) {
                  final spec = _specialties[idx];
                  final isSelected = spec == selectedSpecialty;
                  return ChoiceChip(
                    label: Text(spec),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: isDark ? AppColors.darkSurfaceVariant : Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : (isDark ? AppColors.darkText : AppColors.text),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 13,
                    ),
                    side: BorderSide(
                      color: isSelected ? AppColors.primaryDark : (isDark ? AppColors.darkBorder : AppColors.border),
                    ),
                    onSelected: (_) => ref.read(selectedSpecialtyProvider.notifier).state = spec,
                  );
                },
              ),
            ),

            // Doctor List Content
            Expanded(
              child: doctorsAsync.when(
                loading: () => const LoadingIndicator(message: 'Finding verified physicians...'),
                error: (err, _) => Center(child: Text('Error loading specialists: $err')),
                data: (doctors) {
                  if (doctors.isEmpty) {
                    return const EmptyStateView(
                      icon: Icons.person_search_rounded,
                      title: 'No Specialists Found',
                      message: 'Try changing your specialty filter or search keywords.',
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: doctors.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, idx) {
                      final doc = doctors[idx];
                      return _buildDoctorCard(context, doc);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorCard(BuildContext context, DoctorModel doc) {
    return AppCard(
      hasShadow: true,
      onTap: () => context.push('/doctors/${doc.id}', extra: doc),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AvatarWidget(
                imageUrl: doc.avatarUrl,
                name: doc.fullName,
                size: 64,
                showBadge: doc.isAvailable,
                isOnline: doc.isAvailable,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.fullName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      doc.specialty,
                      style: const TextStyle(fontSize: 13, color: AppColors.primaryDark, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Color(0xFFFBBF24)),
                        const SizedBox(width: 4),
                        Text(
                          '${doc.rating}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Text(
                          ' (${doc.reviewsCount} reviews)',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                        const Spacer(),
                        Text(
                          '\$${doc.consultationFee.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.verified_user_outlined, size: 14, color: AppColors.success),
                  const SizedBox(width: 4),
                  Text(
                    '${doc.experienceYears}+ Years Exp',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
              AppButton(
                text: 'Book Visit',
                height: 36,
                onPressed: () => context.push('/appointments/book', extra: doc),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
