import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../billing/data/billing_repository.dart';
import '../../billing/domain/invoice_model.dart';

class PaymentCheckoutScreen extends ConsumerStatefulWidget {
  final InvoiceModel? invoice;

  const PaymentCheckoutScreen({super.key, this.invoice});

  @override
  ConsumerState<PaymentCheckoutScreen> createState() => _PaymentCheckoutScreenState();
}

class _PaymentCheckoutScreenState extends ConsumerState<PaymentCheckoutScreen> {
  String _selectedMethod = 'credit_card'; // credit_card, online_gateway, bank_transfer, insurance
  bool _isProcessing = false;
  final _cardNumberController = TextEditingController(text: '4242 •••• •••• 4242');
  final _expiryController = TextEditingController(text: '12/28');
  final _cvvController = TextEditingController(text: '888');

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _onProcessPayment() async {
    setState(() => _isProcessing = true);
    final repo = ref.read(billingRepositoryProvider);

    final amountToPay = widget.invoice?.balanceDue ?? 157.50;
    final invoiceId = widget.invoice?.id ?? 'inv-1';

    await repo.recordPayment(invoiceId, amountToPay, _selectedMethod);
    ref.invalidate(invoiceListProvider);

    if (mounted) {
      setState(() => _isProcessing = false);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.successLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 48, color: AppColors.success),
              ),
              const SizedBox(height: 16),
              const Text('Payment Successful!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'Received payment of ${AppFormatters.formatCurrency(amountToPay)} via ${_selectedMethod.replaceAll('_', ' ').toUpperCase()}.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              AppButton(
                text: 'Done',
                isFullWidth: true,
                onPressed: () {
                  Navigator.of(ctx).pop();
                  context.go('/billing');
                },
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final amountToPay = widget.invoice?.balanceDue ?? 157.50;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Checkout & Payment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount Summary Card
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Payment Amount:', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                  Text(
                    AppFormatters.formatCurrency(amountToPay),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text('Select Payment Method', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.text)),
            const SizedBox(height: 12),

            _buildMethodOption('credit_card', 'Credit / Debit Card (Stripe)', Icons.credit_card),
            const SizedBox(height: 10),
            _buildMethodOption('online_gateway', 'Online Healthcare Gateway', Icons.account_balance_wallet_outlined),
            const SizedBox(height: 10),
            _buildMethodOption('bank_transfer', 'Direct Hospital Bank Wire', Icons.account_balance_outlined),
            const SizedBox(height: 10),
            _buildMethodOption('insurance', 'Direct Insurance Copay Claim', Icons.health_and_safety_outlined),
            const SizedBox(height: 20),

            if (_selectedMethod == 'credit_card') ...[
              AppCard(
                child: Column(
                  children: [
                    AppTextField(
                      controller: _cardNumberController,
                      label: 'Card Number',
                      prefixIcon: Icons.payment,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: _expiryController,
                            label: 'Expiry Date',
                            hint: 'MM/YY',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppTextField(
                            controller: _cvvController,
                            label: 'Security Code',
                            hint: 'CVV',
                            obscureText: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            AppButton(
              text: 'Authorize & Pay ${AppFormatters.formatCurrency(amountToPay)}',
              isFullWidth: true,
              isLoading: _isProcessing,
              onPressed: _onProcessPayment,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodOption(String key, String label, IconData icon) {
    final isSelected = _selectedMethod == key;

    return AppCard(
      onTap: () => setState(() => _selectedMethod = key),
      child: Row(
        children: [
          Icon(icon, color: isSelected ? AppColors.primaryDark : AppColors.textSecondary, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.primaryDark : AppColors.text,
              ),
            ),
          ),
          Radio<String>(
            value: key,
            groupValue: _selectedMethod,
            activeColor: AppColors.primaryDark,
            onChanged: (v) => setState(() => _selectedMethod = v!),
          ),
        ],
      ),
    );
  }
}
