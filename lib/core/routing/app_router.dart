import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admissions/presentation/bed_management_screen.dart';
import '../../features/ambulance/presentation/ambulance_dispatch_screen.dart';
import '../../features/appointments/domain/appointment_model.dart';
import '../../features/appointments/presentation/appointment_detail_screen.dart';
import '../../features/appointments/presentation/appointment_list_screen.dart';
import '../../features/appointments/presentation/book_appointment_screen.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/billing/domain/invoice_model.dart';
import '../../features/billing/presentation/billing_dashboard_screen.dart';
import '../../features/billing/presentation/invoice_detail_screen.dart';
import '../../features/dashboard/presentation/role_based_home_screen.dart';
import '../../features/doctors/domain/doctor_model.dart';
import '../../features/doctors/presentation/doctor_directory_screen.dart';
import '../../features/doctors/presentation/doctor_profile_screen.dart';
import '../../features/emergency/presentation/emergency_triage_screen.dart';
import '../../features/inventory/presentation/inventory_screen.dart';
import '../../features/laboratory/presentation/laboratory_screen.dart';
import '../../features/medical_records/presentation/medical_history_screen.dart';
import '../../features/medical_records/presentation/vitals_logging_screen.dart';
import '../../features/medications/presentation/add_medication_screen.dart';
import '../../features/medications/presentation/pill_reminder_screen.dart';
import '../../features/messaging/domain/chat_model.dart';
import '../../features/messaging/presentation/chat_detail_screen.dart';
import '../../features/messaging/presentation/conversation_list_screen.dart';
import '../../features/notifications/presentation/notification_center_screen.dart';
import '../../features/patients/domain/patient_model.dart';
import '../../features/patients/presentation/edit_patient_profile_screen.dart';
import '../../features/patients/presentation/patient_detail_screen.dart';
import '../../features/patients/presentation/patient_list_screen.dart';
import '../../features/payments/presentation/payment_checkout_screen.dart';
import '../../features/pharmacy/presentation/pharmacy_dashboard_screen.dart';
import '../../features/prescriptions/domain/prescription_model.dart';
import '../../features/prescriptions/presentation/create_prescription_screen.dart';
import '../../features/prescriptions/presentation/prescription_detail_screen.dart';
import '../../features/prescriptions/presentation/prescription_list_screen.dart';
import '../../features/radiology/presentation/radiology_screen.dart';
import '../../features/reports/presentation/reports_analytics_screen.dart';
import '../../features/search/presentation/global_search_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/staff/presentation/staff_management_screen.dart';
import '../../features/telemedicine/presentation/video_call_screen.dart';
import 'route_paths.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final isAuth = authState.isAuthenticated;
      final path = state.matchedLocation;

      // Allow public auth screens
      final isPublicRoute = path == RoutePaths.splash ||
          path == RoutePaths.onboarding ||
          path == RoutePaths.login ||
          path == RoutePaths.register ||
          path == RoutePaths.forgotPassword;

      if (!isAuth && !isPublicRoute) {
        return RoutePaths.login;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RoutePaths.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RoutePaths.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RoutePaths.home,
        builder: (context, state) => const RoleBasedHomeScreen(),
      ),

      // Patients
      GoRoute(
        path: RoutePaths.patients,
        builder: (context, state) => const PatientListScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              final extra = state.extra as PatientModel?;
              return PatientDetailScreen(patientId: id, patientExtra: extra);
            },
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.editPatientProfile,
        builder: (context, state) => EditPatientProfileScreen(patient: state.extra as PatientModel?),
      ),

      // Doctors
      GoRoute(
        path: RoutePaths.doctors,
        builder: (context, state) => const DoctorDirectoryScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              final extra = state.extra as DoctorModel?;
              return DoctorProfileScreen(doctorId: id, doctorExtra: extra);
            },
          ),
        ],
      ),

      // Appointments
      GoRoute(
        path: RoutePaths.appointments,
        builder: (context, state) => const AppointmentListScreen(),
        routes: [
          GoRoute(
            path: 'book',
            builder: (context, state) => BookAppointmentScreen(initialDoctor: state.extra as DoctorModel?),
          ),
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              final extra = state.extra as AppointmentModel?;
              return AppointmentDetailScreen(appointmentId: id, appointmentExtra: extra);
            },
          ),
        ],
      ),

      // Medical Records & Vitals
      GoRoute(
        path: RoutePaths.medicalRecords,
        builder: (context, state) => const MedicalHistoryScreen(),
      ),
      GoRoute(
        path: RoutePaths.vitalsLog,
        builder: (context, state) => const VitalsLoggingScreen(),
      ),

      // Prescriptions
      GoRoute(
        path: RoutePaths.prescriptions,
        builder: (context, state) => const PrescriptionListScreen(),
        routes: [
          GoRoute(
            path: 'create',
            builder: (context, state) => const CreatePrescriptionScreen(),
          ),
          GoRoute(
            path: 'detail',
            builder: (context, state) => PrescriptionDetailScreen(prescription: state.extra as PrescriptionModel?),
          ),
        ],
      ),

      // Medications / Pill Reminders
      GoRoute(
        path: RoutePaths.medications,
        builder: (context, state) => const PillReminderScreen(),
        routes: [
          GoRoute(
            path: 'add',
            builder: (context, state) => const AddMedicationScreen(),
          ),
        ],
      ),

      // Clinical Operations
      GoRoute(
        path: RoutePaths.pharmacy,
        builder: (context, state) => const PharmacyDashboardScreen(),
      ),
      GoRoute(
        path: RoutePaths.laboratory,
        builder: (context, state) => const LaboratoryScreen(),
      ),
      GoRoute(
        path: RoutePaths.radiology,
        builder: (context, state) => const RadiologyScreen(),
      ),
      GoRoute(
        path: RoutePaths.emergency,
        builder: (context, state) => const EmergencyTriageScreen(),
      ),
      GoRoute(
        path: RoutePaths.admissions,
        builder: (context, state) => const BedManagementScreen(),
      ),

      // Financials
      GoRoute(
        path: RoutePaths.billing,
        builder: (context, state) => const BillingDashboardScreen(),
        routes: [
          GoRoute(
            path: 'invoice/:id',
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              final extra = state.extra as InvoiceModel?;
              return InvoiceDetailScreen(invoiceId: id, invoiceExtra: extra);
            },
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.paymentCheckout,
        builder: (context, state) => PaymentCheckoutScreen(invoice: state.extra as InvoiceModel?),
      ),

      // Communication
      GoRoute(
        path: RoutePaths.messages,
        builder: (context, state) => const ConversationListScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              final extra = state.extra as ConversationSummaryModel?;
              return ChatDetailScreen(conversationId: id, conversationExtra: extra);
            },
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.telemedicine,
        builder: (context, state) => const VideoCallScreen(),
      ),

      // Operational Support
      GoRoute(
        path: RoutePaths.notifications,
        builder: (context, state) => const NotificationCenterScreen(),
      ),
      GoRoute(
        path: RoutePaths.staff,
        builder: (context, state) => const StaffManagementScreen(),
      ),
      GoRoute(
        path: RoutePaths.inventory,
        builder: (context, state) => const InventoryScreen(),
      ),
      GoRoute(
        path: RoutePaths.ambulance,
        builder: (context, state) => const AmbulanceDispatchScreen(),
      ),
      GoRoute(
        path: RoutePaths.reports,
        builder: (context, state) => const ReportsAnalyticsScreen(),
      ),
      GoRoute(
        path: RoutePaths.search,
        builder: (context, state) => const GlobalSearchScreen(),
      ),
      GoRoute(
        path: RoutePaths.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: RoutePaths.profile,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
});
