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
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/status_badge.dart';
import '../data/laboratory_repository.dart';
import '../domain/lab_test_model.dart';

final labTabProvider = StateProvider<int>((ref) => 0); // 0 = Catalog, 1 = Orders

class LaboratoryScreen extends ConsumerWidget {
  const LaboratoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(labTabProvider);
    final repo = ref.watch(laboratoryRepositoryProvider);

    return AppBackScope(
      fallbackRoute: RoutePaths.home,
      child: Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Laboratory & Pathology'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.safePop(null, RoutePaths.home),
        ),
      ),
      body: Column(
        children: [
          // Segmented Tabs
          Container(
            margin: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => ref.read(labTabProvider.notifier).state = 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: currentTab == 0 ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd - 2),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Test Catalog',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: currentTab == 0 ? FontWeight.bold : FontWeight.w500,
                          color: currentTab == 0 ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => ref.read(labTabProvider.notifier).state = 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: currentTab == 1 ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd - 2),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Diagnostic Orders (2)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: currentTab == 1 ? FontWeight.bold : FontWeight.w500,
                          color: currentTab == 1 ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: currentTab == 0
                ? FutureBuilder<List<LabTestModel>>(
                    future: repo.getCatalog(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const LoadingIndicator();
                      final list = snapshot.data!;

                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
                        itemCount: list.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, idx) {
                          final t = list[idx];
                          return AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        t.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                    ),
                                    Text(
                                      '\$${t.price.toStringAsFixed(2)}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryDark),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      '${t.category} • Sample: ${t.sampleType}',
                                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                    ),
                                    const Spacer(),
                                    Text(
                                      'Results in ${t.turnaroundHours}h',
                                      style: const TextStyle(fontSize: 11, color: AppColors.primaryDark, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                if (t.referenceRange != null) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceVariant,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Normal Range: ${t.referenceRange}',
                                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    AppButton(
                                      text: 'Book Test',
                                      height: 34,
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('${t.name} scheduled for sample collection.')),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  )
                : FutureBuilder<List<LabOrderModel>>(
                    future: repo.getOrders(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const LoadingIndicator();
                      final orders = snapshot.data!;

                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
                        itemCount: orders.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, idx) {
                          final o = orders[idx];
                          return AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      o.orderCode,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryDark),
                                    ),
                                    StatusBadge.fromStatus(o.status),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  o.testName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                Text(
                                  'Ordered: ${AppFormatters.formatShortDate(o.orderDate)}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                                if (o.resultValue != null) ...[
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.check_circle_outline, color: AppColors.success, size: 18),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            o.resultValue!,
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      icon: const Icon(Icons.download_rounded, size: 16),
                                      label: const Text('Verified Report PDF'),
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Downloading verified laboratory report PDF...')),
                                        );
                                      },
                                    ),
                                  ],
                                ),
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
