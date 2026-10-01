import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../domain/invoice_model.dart';

class InvoiceDetailScreen extends StatelessWidget {
  final String invoiceId;
  final InvoiceModel? invoiceExtra;

  const InvoiceDetailScreen({
    super.key,
    required this.invoiceId,
    this.invoiceExtra,
  });

  @override
  Widget build(BuildContext context) {
    final inv = invoiceExtra ?? InvoiceModel(
      id: invoiceId,
      invoiceNumber: 'INV-2026-0001',
      patientId: '30000000-0000-0000-0000-000000000001',
      patientName: 'Emma Stonehurst',
      subtotal: 150.00,
      tax: 7.50,
      discount: 0.0,
      totalAmount: 157.50,
      paidAmount: 157.50,
      status: 'paid',
      dueDate: DateTime.now(),
      items: const [
        InvoiceItemModel(
          description: 'Specialist Consultation - Dr. Sarah Watson',
          category: 'consultation',
          unitPrice: 150.00,
          quantity: 1,
          totalPrice: 150.00,
        ),
      ],
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Invoice ${inv.invoiceNumber}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            tooltip: 'Download Invoice PDF',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Invoice PDF generated and downloaded.')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            AppCard(
              hasShadow: true,
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AuraCare Hospital',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                          ),
                          const Text('Enterprise Healthcare Billing', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                      StatusBadge.fromStatus(inv.status),
                    ],
                  ),
                  const Divider(height: 28),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Billed To:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          Text(inv.patientName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Due Date:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          Text(AppFormatters.formatShortDate(inv.dueDate), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  const Text('Itemized Hospital Charges:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.text)),
                  const SizedBox(height: 10),

                  ...inv.items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.description, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                Text('Qty: ${item.quantity} • ${item.category.toUpperCase()}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          Text(AppFormatters.formatCurrency(item.totalPrice), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                    );
                  }),
                  const Divider(height: 28),

                  _buildCostRow('Subtotal', AppFormatters.formatCurrency(inv.subtotal)),
                  const SizedBox(height: 6),
                  _buildCostRow('Hospital Tax (5%)', AppFormatters.formatCurrency(inv.tax)),
                  if (inv.discount > 0) ...[
                    const SizedBox(height: 6),
                    _buildCostRow('Insurance Discount', '-${AppFormatters.formatCurrency(inv.discount)}', isDiscount: true),
                  ],
                  const Divider(height: 20),
                  _buildCostRow('Total Amount', AppFormatters.formatCurrency(inv.totalAmount), isBold: true),
                  const SizedBox(height: 6),
                  _buildCostRow('Paid to Date', AppFormatters.formatCurrency(inv.paidAmount)),
                  const Divider(height: 20),
                  _buildCostRow('Remaining Balance Due', AppFormatters.formatCurrency(inv.balanceDue), isDue: true),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (inv.balanceDue > 0) ...[
              AppButton(
                text: 'Pay Remaining Balance',
                isFullWidth: true,
                onPressed: () => context.push('/payment/checkout', extra: inv),
              ),
              const SizedBox(height: 12),
            ],

            AppButton(
              text: 'Back to Billing',
              variant: ButtonVariant.outline,
              isFullWidth: true,
              onPressed: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostRow(String label, String value, {bool isBold = false, bool isDue = false, bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold || isDue ? FontWeight.bold : FontWeight.normal,
            color: isDue ? AppColors.error : AppColors.text,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold || isDue ? FontWeight.bold : FontWeight.w600,
            color: isDue ? AppColors.error : (isDiscount ? AppColors.success : AppColors.text),
          ),
        ),
      ],
    );
  }
}
