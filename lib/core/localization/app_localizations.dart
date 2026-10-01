import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  static const _supportedLocales = ['en', 'ur', 'ar'];

  static bool isSupported(Locale locale) =>
      _supportedLocales.contains(locale.languageCode);

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appName': 'AuraCare HMS',
      'welcomeBack': 'Welcome back',
      'login': 'Sign In',
      'register': 'Create Account',
      'email': 'Email Address',
      'password': 'Password',
      'fullName': 'Full Name',
      'role': 'Hospital Role',
      'dashboard': 'Dashboard',
      'appointments': 'Appointments',
      'doctors': 'Find Doctors',
      'patients': 'Patients Directory',
      'medicalRecords': 'Medical Records',
      'prescriptions': 'Prescriptions',
      'pillsReminder': 'Pill Reminders',
      'pharmacy': 'Pharmacy',
      'laboratory': 'Laboratory',
      'radiology': 'Radiology',
      'emergency': 'Emergency / ER',
      'admissions': 'Bed Management',
      'billing': 'Billing & Invoices',
      'messages': 'Chat & Support',
      'telemedicine': 'Telemedicine',
      'notifications': 'Notifications',
      'settings': 'Settings',
      'bookAppointment': 'Book Appointment',
      'emergencyHotline': '24/7 Emergency Line',
      'takeMedication': 'Mark as Taken',
      'viewDetails': 'View Details',
      'saveChanges': 'Save Changes',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'logout': 'Sign Out',
      'searchHint': 'Search doctors, tests, medicines, or patients...',
      'upcomingAppointments': 'Upcoming Appointments',
      'morning': 'Morning',
      'afternoon': 'Afternoon',
      'evening': 'Evening',
      'night': 'Night',
      'vitals': 'Vital Signs',
      'bp': 'Blood Pressure',
      'heartRate': 'Heart Rate',
      'temp': 'Temperature',
      'spO2': 'Oxygen (SpO2)',
    },
    'ur': {
      'appName': 'اورا کیئر ہسپتال',
      'welcomeBack': 'خوش آمدید',
      'login': 'لاگ ان کریں',
      'register': 'اکاؤنٹ بنائیں',
      'email': 'ای میل ایڈریس',
      'password': 'پاس ورڈ',
      'fullName': 'مکمل نام',
      'role': 'کردار',
      'dashboard': 'ڈیش بورڈ',
      'appointments': 'ملاقاتیں',
      'doctors': 'ڈاکٹرز تلاش کریں',
      'patients': 'مریضوں کی فہرست',
      'medicalRecords': 'طبی ریکارڈ',
      'prescriptions': 'نسخہ جات',
      'pillsReminder': 'دوائیوں کی یاد دہانی',
      'pharmacy': 'فارمیسی',
      'laboratory': 'لیبارٹری',
      'radiology': 'ریڈیالوجی',
      'emergency': 'ایمرجنسی وارڈ',
      'admissions': 'داخلہ و بیڈز',
      'billing': 'بلنگ اور رسیدیں',
      'messages': 'پیغامات اور رابطہ',
      'telemedicine': 'ٹیلی میڈیسن',
      'notifications': 'اطلاعات',
      'settings': 'ترتیبات',
      'bookAppointment': 'ملاقات بک کریں',
      'emergencyHotline': '24/7 ایمرجنسی لائن',
      'takeMedication': 'دوائی لے لی گئی',
      'viewDetails': 'تفصیلات دیکھیں',
      'saveChanges': 'تبدیلیاں محفوظ کریں',
      'cancel': 'منسوخ کریں',
      'confirm': 'تصدیق کریں',
      'logout': 'لاگ آؤٹ کریں',
      'searchHint': 'ڈاکٹر، ٹیسٹ یا دوا تلاش کریں...',
      'upcomingAppointments': 'آنے والی ملاقاتیں',
      'morning': 'صبح',
      'afternoon': 'دوپہر',
      'evening': 'شام',
      'night': 'رات',
      'vitals': 'اہم علامات',
      'bp': 'بلڈ پریشر',
      'heartRate': 'نبض کی رفتار',
      'temp': 'درجہ حرارت',
      'spO2': 'آکسیجن',
    },
    'ar': {
      'appName': 'أورا كير للمستشفيات',
      'welcomeBack': 'مرحباً بعودتك',
      'login': 'تسجيل الدخول',
      'register': 'إنشاء حساب جديد',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'fullName': 'الاسم الكامل',
      'role': 'الدور في المستشفى',
      'dashboard': 'لوحة التحكم',
      'appointments': 'المواعيد',
      'doctors': 'دليل الأطباء',
      'patients': 'سجل المرضى',
      'medicalRecords': 'السجلات الطبية',
      'prescriptions': 'الوصفات الطبية',
      'pillsReminder': 'منبه الأدوية',
      'pharmacy': 'الصيدلية',
      'laboratory': 'المختبر والتحاليل',
      'radiology': 'قسم الأشعة',
      'emergency': 'الطوارئ والإسعاف',
      'admissions': 'إدارة الأسرّة',
      'billing': 'الفواتير والمدفوعات',
      'messages': 'المحادثات والدعم',
      'telemedicine': 'الاستشارات المرئية',
      'notifications': 'الإشعارات',
      'settings': 'الإعدادات',
      'bookAppointment': 'حجز موعد',
      'emergencyHotline': 'خط الطوارئ 24/7',
      'takeMedication': 'تم أخذ الدواء',
      'viewDetails': 'عرض التفاصيل',
      'saveChanges': 'حفظ التغييرات',
      'cancel': 'إلغاء',
      'confirm': 'تأكيد',
      'logout': 'تسجيل الخروج',
      'searchHint': 'ابحث عن طبيب أو فحص أو دواء...',
      'upcomingAppointments': 'المواعيد القادمة',
      'morning': 'الصباح',
      'afternoon': 'الظهيرة',
      'evening': 'المساء',
      'night': 'الليل',
      'vitals': 'العلامات الحيوية',
      'bp': 'ضغط الدم',
      'heartRate': 'نبضات القلب',
      'temp': 'حرارة الجسم',
      'spO2': 'نسبة الأكسجين',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.isSupported(locale);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
