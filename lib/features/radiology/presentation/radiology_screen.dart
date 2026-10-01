import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/status_badge.dart';
import '../data/radiology_repository.dart';

class RadiologyScreen extends ConsumerWidget {
  const RadiologyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(radiologyRepositoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Radiology & Diagnostic Imaging'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: FutureBuilder(
        future: repo.getOrders(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const LoadingIndicator(message: 'Loading imaging studies...');
          final orders = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, idx) {
              final o = orders[idx];

              return AppCard(
                hasShadow: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                o.modality,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryDark),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(o.orderCode, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                        StatusBadge.fromStatus(o.status),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${o.modality} Study: ${o.bodyPart}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ordered: ${AppFormatters.formatShortDate(o.orderDate)} • Patient: ${o.patientName}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    if (o.findings != null) ...[
                      const Divider(height: 20),
                      const Text('Radiologist Findings:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(o.findings!, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4)),
                      if (o.impression != null) ...[
                        const SizedBox(height: 8),
                        Text('Impression: ${o.impression!}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryDark)),
                      ],
                    ],
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.image_outlined, size: 16),
                          label: const Text('View DICOM Scans'),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('DICOM viewer launching in high resolution mode.')),
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
    );
  }
}
