import 'package:flutter/material.dart';

/// AuraCare Healthcare Design System Color Palette
/// Strict adherence to the turquoise/teal medical design reference
class AppColors {
  AppColors._();

  // Primary Medical Colors
  static const Color primary = Color(0xFF48C9C5);       // Turquoise/Teal
  static const Color secondary = Color(0xFF236B68);     // Secondary Dark Teal
  static const Color primaryDark = Color(0xFF236B68);   // Dark Teal / Deep Forest
  static const Color primaryLight = Color(0xFFE2F7F6);  // Soft Teal Tint
  static const Color primarySurface = Color(0xFFEDFAF9);// Very subtle teal tint

  // Neutral Colors (Light Mode)
  static const Color background = Color(0xFFF5FAFA);    // Clean Medical Background
  static const Color surface = Color(0xFFFFFFFF);       // Pure White Card Surface
  static const Color surfaceVariant = Color(0xFFF0F6F6);// Slightly shaded panel
  static const Color text = Color(0xFF253B3B);          // Deep Charcoal Text
  static const Color textSecondary = Color(0xFF7B9191); // Medical Slate / Secondary
  static const Color textMuted = Color(0xFFA4B6B6);     // Muted Gray
  static const Color border = Color(0xFFE2ECEC);        // Card & Field Border
  static const Color divider = Color(0xFFECF3F3);       // Subtle Divider

  // Neutral Colors (Dark Mode)
  static const Color darkBackground = Color(0xFF0F1A19);
  static const Color darkSurface = Color(0xFF162524);
  static const Color darkSurfaceVariant = Color(0xFF1E3231);
  static const Color darkText = Color(0xFFE8F3F2);
  static const Color darkTextSecondary = Color(0xFFA0B5B4);
  static const Color darkBorder = Color(0xFF263D3B);

  // Status & Feedback Colors
  static const Color success = Color(0xFF48B883);       // Emerald Green
  static const Color successLight = Color(0xFFE8F7F0);
  static const Color warning = Color(0xFFF3B562);       // Warm Amber
  static const Color warningLight = Color(0xFFFDF6EC);
  static const Color error = Color(0xFFE66A6A);         // Coral Red
  static const Color errorLight = Color(0xFFFDF0F0);
  static const Color info = Color(0xFF4EA5D9);          // Ocean Blue
  static const Color infoLight = Color(0xFFEDF6FB);

  // Clinical Triage Colors
  static const Color triageRed = Color(0xFFDC2626);
  static const Color triageOrange = Color(0xFFEA580C);
  static const Color triageYellow = Color(0xFFCA8A04);
  static const Color triageGreen = Color(0xFF16A34A);
  static const Color triageBlue = Color(0xFF2563EB);

  // Gradient Presets
  static const LinearGradient tealGradient = LinearGradient(
    colors: [Color(0xFF48C9C5), Color(0xFF236B68)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardHeaderGradient = LinearGradient(
    colors: [Color(0xFF48C9C5), Color(0xFF35A9A5)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
