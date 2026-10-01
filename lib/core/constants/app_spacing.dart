import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();

  // Spacing Units
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double giant = 48.0;

  // Border Radii
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusRound = 999.0;

  // Standard EdgeInsets
  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);
  static const EdgeInsets paddingXxl = EdgeInsets.all(xxl);

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: lg, vertical: lg);
  static const EdgeInsets screenPaddingWide = EdgeInsets.symmetric(horizontal: xxxl, vertical: xxl);

  // Common Gap Widgets
  static const Widget gapH4 = SizedBox(width: xs);
  static const Widget gapH8 = SizedBox(width: sm);
  static const Widget gapH12 = SizedBox(width: md);
  static const Widget gapH16 = SizedBox(width: lg);
  static const Widget gapH24 = SizedBox(width: xxl);

  static const Widget gapV4 = SizedBox(height: xs);
  static const Widget gapV8 = SizedBox(height: sm);
  static const Widget gapV12 = SizedBox(height: md);
  static const Widget gapV16 = SizedBox(height: lg);
  static const Widget gapV20 = SizedBox(height: xl);
  static const Widget gapV24 = SizedBox(height: xxl);
  static const Widget gapV32 = SizedBox(height: xxxl);
}
