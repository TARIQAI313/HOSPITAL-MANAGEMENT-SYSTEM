import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';

class ReportsAnalyticsScreen extends StatelessWidget {
  const ReportsAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Clinical Analytics & Financial Reports'),
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
            // Export Actions Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Fiscal Month Reports',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text),
                ),
                Row(
                  children: [
                    AppButton(
                      text: 'Export CSV',
                      icon: Icons.table_chart_outlined,
                      variant: ButtonVariant.secondary,
                      height: 36,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Hospital analytics exported as CSV spreadsheet.')),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    AppButton(
                      text: 'Export PDF',
                      icon: Icons.picture_as_pdf_outlined,
                      height: 36,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Executive summary exported as PDF report.')),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Department Revenue Distribution Card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Revenue Breakdown by Department', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 14),
                  _buildProgressBar('Cardiology', 0.35, '\$52,400', AppColors.primary),
                  const SizedBox(height: 10),
                  _buildProgressBar('General Surgery', 0.25, '\$37,050', AppColors.primaryDark),
                  const SizedBox(height: 10),
                  _buildProgressBar('Radiology & MRI', 0.20, '\$29,640', AppColors.info),
                  const SizedBox(height: 10),
                  _buildProgressBar('Central Pharmacy', 0.12, '\$17,784', AppColors.warning),
                  const SizedBox(height: 10),
                  _buildProgressBar('Pathology Lab', 0.08, '\$11,326', AppColors.success),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Patient Census & Occupancy
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Patient Volume & Admission Metrics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 12),
                  _buildMetricRow('Average Length of Stay (ALOS)', '3.4 days'),
                  const SizedBox(height: 8),
                  _buildMetricRow('Bed Turnover Interval', '4.2 hours'),
                  const SizedBox(height: 8),
                  _buildMetricRow('Inpatient Readmission Rate (30 Days)', '2.1% (Low)'),
                  const SizedBox(height: 8),
                  _buildMetricRow('Outpatient Satisfaction Index', '96.4% Positive'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(String label, double ratio, String amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            Text(amount, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.text)),
      ],
    );
  }
}
