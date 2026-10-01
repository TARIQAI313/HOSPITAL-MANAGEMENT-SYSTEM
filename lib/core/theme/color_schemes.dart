import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppColorSchemes {
  AppColorSchemes._();

  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: AppColors.primaryLight,
    onPrimaryContainer: AppColors.primaryDark,
    secondary: AppColors.secondary,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFE5ECEC),
    onSecondaryContainer: Color(0xFF1D3232),
    tertiary: AppColors.primaryDark,
    onTertiary: Colors.white,
    error: AppColors.error,
    onError: Colors.white,
    errorContainer: AppColors.errorLight,
    onErrorContainer: Color(0xFF670001),
    surface: AppColors.surface,
    onSurface: AppColors.text,
    surfaceVariant: AppColors.surfaceVariant,
    onSurfaceVariant: AppColors.textSecondary,
    outline: AppColors.border,
    outlineVariant: AppColors.divider,
    shadow: Color(0x0C000000),
  );

  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primary,
    onPrimary: Color(0xFF003736),
    primaryContainer: Color(0xFF004F4E),
    onPrimaryContainer: Color(0xFF70F5F1),
    secondary: Color(0xFFA1B7B7),
    onSecondary: Color(0xFF132A29),
    secondaryContainer: Color(0xFF263F3E),
    onSecondaryContainer: Color(0xFFBDE0DF),
    tertiary: Color(0xFF48C9C5),
    onTertiary: Color(0xFF003736),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: AppColors.darkSurface,
    onSurface: AppColors.darkText,
    surfaceVariant: AppColors.darkSurfaceVariant,
    onSurfaceVariant: AppColors.darkTextSecondary,
    outline: AppColors.darkBorder,
    outlineVariant: Color(0xFF1C2C2B),
    shadow: Color(0x33000000),
  );
}
