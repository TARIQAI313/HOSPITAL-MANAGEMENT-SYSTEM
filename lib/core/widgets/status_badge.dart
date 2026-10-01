import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.icon,
  });

  factory StatusBadge.fromStatus(String status) {
    Color bg;
    Color fg;
    String display = status.replaceAll('_', ' ').toUpperCase();

    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'completed':
      case 'paid':
      case 'available':
      case 'verified':
      case 'active':
        bg = AppColors.successLight;
        fg = AppColors.success;
        break;
      case 'pending':
      case 'checked_in':
      case 'partial':
      case 'ordered':
      case 'urgent':
        bg = AppColors.warningLight;
        fg = const Color(0xFFB45309);
        break;
      case 'cancelled':
      case 'unpaid':
      case 'no_show':
      case 'critical':
      case 'occupied':
        bg = AppColors.errorLight;
        fg = AppColors.error;
        break;
      case 'in_consultation':
      case 'in_analysis':
      case 'dispatched':
        bg = AppColors.infoLight;
        fg = AppColors.info;
        break;
      default:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF475569);
    }

    return StatusBadge(
      label: display,
      backgroundColor: bg,
      textColor: fg,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor ?? AppColors.primaryDark),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: textColor ?? AppColors.primaryDark,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
