import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/routing/navigation_helper.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/avatar_widget.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/search_field.dart';
import '../data/patient_repository.dart';
import '../domain/patient_model.dart';

final patientSearchQueryProvider = StateProvider<String>((ref) => '');

final patientListProvider = FutureProvider<List<PatientModel>>((ref) async {
  final repo = ref.watch(patientRepositoryProvider);
  final query = ref.watch(patientSearchQueryProvider);
  return repo.getPatients(query: query);
});

class PatientListScreen extends ConsumerWidget {
  const PatientListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientsAsync = ref.watch(patientListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBackScope(
      fallbackRoute: RoutePaths.home,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
        appBar: AppBar(
          title: const Text('Patient Directory & EMR'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.safePop(null, RoutePaths.home),
          ),
        ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: SearchField(
              hint: 'Search by patient name or MR number...',
              onChanged: (val) => ref.read(patientSearchQueryProvider.notifier).state = val,
            ),
          ),
          Expanded(
            child: patientsAsync.when(
              loading: () => const LoadingIndicator(message: 'Retrieving medical records...'),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (patients) {
                if (patients.isEmpty) {
                  return const EmptyStateView(
                    icon: Icons.person_off_outlined,
                    title: 'No Patients Found',
                    message: 'No patient matched your search query.',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
                  itemCount: patients.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, idx) {
                    final p = patients[idx];
                    return AppCard(
                      onTap: () => context.push('/patients/${p.id}', extra: p),
                      child: Row(
                        children: [
                          AvatarWidget(
                            imageUrl: p.avatarUrl,
                            name: p.fullName,
                            size: 48,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.fullName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryLight,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        p.mrNumber,
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (p.bloodGroup != null)
                                      Text(
                                        'Blood: ${p.bloodGroup}',
                                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                      ),
                                    if (p.age != null) ...[
                                      const SizedBox(width: 8),
                                      Text(
                                        'Age: ${p.age}y',
                                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                        ],
                      ),
                    );
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
}
