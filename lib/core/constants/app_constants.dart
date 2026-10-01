class AppConstants {
  AppConstants._();

  static const String appName = 'AuraCare HMS';
  static const String appTagline = 'Enterprise Hospital & Patient Care System';
  static const String appVersion = '1.0.0+1';

  // Responsive Breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 1024.0;

  // Pagination defaults
  static const int defaultPageSize = 20;

  // Cache expiration
  static const Duration cacheValidity = Duration(hours: 1);

  // Default Hospital Contact
  static const String emergencyHotline = '+1 (800) 555-ER-911';
  static const String hospitalEmail = 'care@auracarehealth.com';
  static const String hospitalAddress = '100 Medical Center Way, Suite 400';
}
