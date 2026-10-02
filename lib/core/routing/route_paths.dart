class RoutePaths {
  RoutePaths._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  static const String home = '/home';
  static const String patientDashboard = '/patient-dashboard';
  static const String doctorDashboard = '/doctor-dashboard';
  static const String adminDashboard = '/admin-dashboard';

  static const String patients = '/patients';
  static const String patientDetail = '/patients/:id';
  static const String editPatientProfile = '/profile/edit';

  static const String doctors = '/doctors';
  static const String doctorDetail = '/doctors/:id';

  static const String appointments = '/appointments';
  static const String bookAppointment = '/appointments/book';
  static const String appointmentDetail = '/appointments/:id';

  static const String medicalRecords = '/medical-records';
  static const String vitalsLog = '/vitals/log';

  static const String prescriptions = '/prescriptions';
  static const String createPrescription = '/prescriptions/create';

  static const String medications = '/medications';
  static const String addMedication = '/medications/add';

  static const String pharmacy = '/pharmacy';
  static const String laboratory = '/laboratory';
  static const String radiology = '/radiology';
  static const String nursing = '/nursing';
  static const String emergency = '/emergency';
  static const String admissions = '/admissions';

  static const String billing = '/billing';
  static const String invoiceDetail = '/billing/invoice/:id';
  static const String paymentCheckout = '/payment/checkout';

  static const String messages = '/messages';
  static const String chatDetail = '/messages/:id';
  static const String telemedicine = '/telemedicine';

  static const String notifications = '/notifications';
  static const String staff = '/staff';
  static const String inventory = '/inventory';
  static const String ambulance = '/ambulance';
  static const String reports = '/reports';
  static const String search = '/search';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String supabaseConfig = '/settings/supabase';
}
