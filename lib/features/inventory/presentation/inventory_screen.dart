import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/search_field.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  final List<Map<String, dynamic>> _items = const [
    {
      'name': 'Sterile Surgical Gloves (Latex Free)',
      'category': 'PPE & Consumables',
      'quantity': 1400,
      'unit': 'pairs',
      'minAlert': 500,
      'location': 'Central Depot Shelf 1',
    },
    {
      'name': 'Ventilator Breathing Circuits',
      'category': 'Critical Care Equipment',
      'quantity': 24,
      'unit': 'kits',
      'minAlert': 40, // Low alert!
      'location': 'ICU Supply Bay',
    },
    {
      'name': 'IV Infusion Sets with Needle-free Ports',
      'category': 'Consumables',
      'quantity': 850,
      'unit': 'sets',
      'minAlert': 200,
      'location': 'Ward Dispensary',
    },
    {
      'name': 'N95 Respirator Masks',
      'category': 'PPE',
      'quantity': 3200,
      'unit': 'pieces',
      'minAlert': 1000,
      'location': 'Warehouse B',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Hospital Medical Inventory'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: SearchField(hint: 'Search medical inventory supplies...'),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, idx) {
                final item = _items[idx];
                final isLow = (item['quantity'] as int) <= (item['minAlert'] as int);

                return AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item['name'] as String,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isLow ? AppColors.errorLight : AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${item['quantity']} ${item['unit']}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isLow ? AppColors.error : AppColors.primaryDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Category: ${item['category']} • Location: ${item['location']}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      if (isLow) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.error),
                            const SizedBox(width: 4),
                            const Text(
                              'Low Stock Alert (Below minimum threshold)',
                              style: TextStyle(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            AppButton(
                              text: 'Create Purchase PO',
                              height: 32,
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Purchase order created for ${item['name']}.')),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
