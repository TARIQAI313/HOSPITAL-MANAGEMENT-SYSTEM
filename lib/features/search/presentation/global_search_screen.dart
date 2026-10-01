import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/search_field.dart';

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  String _query = '';

  final List<Map<String, String>> _allEntities = const [
    {'title': 'Dr. Sarah Watson', 'subtitle': 'Cardiologist • Harvard Medical', 'type': 'Doctor', 'route': '/doctors'},
    {'title': 'Dr. Marcus Vance', 'subtitle': 'Neurologist • Johns Hopkins', 'type': 'Doctor', 'route': '/doctors'},
    {'title': 'Emma Stonehurst', 'subtitle': 'MR-2026-0001 • Inpatient Ward 3B', 'type': 'Patient', 'route': '/patients'},
    {'title': 'Atorvastatin 20mg', 'subtitle': 'Prescription RX-2026-1001', 'type': 'Prescription', 'route': '/prescriptions'},
    {'title': 'Complete Blood Count (CBC)', 'subtitle': 'Hematology Diagnostic Lab Test', 'type': 'Laboratory', 'route': '/laboratory'},
    {'title': 'Chest PA View X-Ray', 'subtitle': 'Radiology Imaging Study', 'type': 'Radiology', 'route': '/radiology'},
  ];

  @override
  Widget build(BuildContext context) {
    final results = _allEntities.where((item) {
      if (_query.isEmpty) return true;
      return item['title']!.toLowerCase().contains(_query.toLowerCase()) ||
             item['subtitle']!.toLowerCase().contains(_query.toLowerCase()) ||
             item['type']!.toLowerCase().contains(_query.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Global Healthcare Search'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: SearchField(
              hint: 'Search patients, doctors, tests, medicines...',
              onChanged: (val) => setState(() => _query = val),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: results.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, idx) {
                final r = results[idx];
                return AppCard(
                  onTap: () => context.push(r['route']!),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          r['type']!,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.primaryDark),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(r['subtitle']!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.textSecondary),
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
