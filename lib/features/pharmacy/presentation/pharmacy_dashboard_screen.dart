import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/search_field.dart';
import '../data/pharmacy_repository.dart';
import '../domain/medicine_stock_model.dart';

final pharmacyCategoryProvider = StateProvider<String>((ref) => 'All');

final pharmacyInventoryProvider = FutureProvider<List<MedicineStockModel>>((ref) async {
  final repo = ref.watch(pharmacyRepositoryProvider);
  final cat = ref.watch(pharmacyCategoryProvider);
  return repo.getInventory(category: cat);
});

class PharmacyDashboardScreen extends ConsumerWidget {
  const PharmacyDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryAsync = ref.watch(pharmacyInventoryProvider);
    final selectedCategory = ref.watch(pharmacyCategoryProvider);

    final categories = ['All', 'Cardiology', 'Antibiotics', 'Gastroenterology'];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Hospital Pharmacy & Dispensary'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                const SearchField(hint: 'Search medicine, generic, or SKU...'),
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, idx) {
                      final cat = categories[idx];
                      final isSelected = selectedCategory == cat;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.text,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                        onSelected: (_) => ref.read(pharmacyCategoryProvider.notifier).state = cat,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: inventoryAsync.when(
              loading: () => const LoadingIndicator(message: 'Querying dispensary stock...'),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (list) {
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, idx) {
                    final med = list[idx];
                    return AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  med.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ),
                              Text(
                                '\$${med.unitPrice.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Generic: ${med.genericName ?? "Proprietary"} • SKU: ${med.sku}',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: med.isLowStock ? AppColors.errorLight : AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'In Stock: ${med.quantityInStock} units',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: med.isLowStock ? AppColors.error : AppColors.primaryDark,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                med.locationShelf ?? 'Main Storage',
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                              const Spacer(),
                              Text(
                                'Batch: ${med.batchNumber}',
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              AppButton(
                                text: 'Dispense 1 Pack',
                                height: 34,
                                onPressed: () async {
                                  await ref.read(pharmacyRepositoryProvider).dispenseMedicine(med.id, 1);
                                  ref.invalidate(pharmacyInventoryProvider);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Dispensed 1 pack of ${med.name}.')),
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
    );
  }
}
