import 'package:intl/intl.dart';

class AppFormatters {
  AppFormatters._();

  static String formatDate(DateTime? date) {
    if (date == null) return '--';
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatShortDate(DateTime? date) {
    if (date == null) return '--';
    return DateFormat('EEE, d MMM').format(date);
  }

  static String formatTime(DateTime? date) {
    if (date == null) return '--';
    return DateFormat('hh:mm a').format(date);
  }

  static String formatCurrency(num? amount) {
    if (amount == null) return '\$0.00';
    final formatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    return formatter.format(amount);
  }

  static String formatDoctorTitle(String name) {
    if (name.startsWith('Dr.')) return name;
    return 'Dr. $name';
  }

  static String formatPhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) return 'No phone recorded';
    return phone;
  }
}
