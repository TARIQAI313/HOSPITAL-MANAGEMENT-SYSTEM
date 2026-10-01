import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/status_badge.dart';
import '../data/billing_repository.dart';
import '../domain/invoice_model.dart';

class BillingDashboardScreen extends ConsumerWidget {
  const BillingDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoicesAsync = ref.watch(invoiceListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Billing & Invoices'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: invoicesAsync.when(
        loading: () => const LoadingIndicator(message: 'Loading financial statements...'),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (invoices) {
          if (invoices.isEmpty) {
            return const EmptyStateView(
              icon: Icons.receipt_long_outlined,
              title: 'No Invoices Found',
              message: 'You have no outstanding or settled clinical statements.',
            );
          }

          final totalOutstanding = invoices
              .where((i) => i.status != 'paid')
              .fold(0.0, (acc, curr) => acc + curr.balanceDue);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Outstanding Balance Banner
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    gradient: AppColors.cardHeaderGradient,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Outstanding Balance',
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppFormatters.formatCurrency(totalOutstanding),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      if (totalOutstanding > 0)
                        AppButton(
                          text: 'Pay All Now',
                          variant: ButtonVariant.secondary,
                          height: 38,
                          onPressed: () => context.push('/payment/checkout', extra: invoices.first),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'Recent Invoices & Receipts',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text),
                ),
                const SizedBox(height: 12),

                ...invoices.map((inv) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AppCard(
                      hasShadow: true,
                      onTap: () => context.push('/billing/invoice/${inv.id}', extra: inv),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                inv.invoiceNumber,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryDark),
                              ),
                              StatusBadge.fromStatus(inv.status),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Due Date: ${AppFormatters.formatShortDate(inv.dueDate)}',
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                              Text(
                                AppFormatters.formatCurrency(inv.totalAmount),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${inv.items.length} billable items • Paid: ${AppFormatters.formatCurrency(inv.paidAmount)}',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          if (inv.balanceDue > 0) ...[
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Balance Due: ${AppFormatters.formatCurrency(inv.balanceDue)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.error),
                                ),
                                AppButton(
                                  text: 'Pay Balance',
                                  height: 34,
                                  onPressed: () => context.push('/payment/checkout', extra: inv),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
