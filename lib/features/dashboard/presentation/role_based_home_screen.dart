import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/user_roles.dart';
import '../../../core/widgets/responsive_scaffold.dart';
import '../../auth/presentation/auth_controller.dart';
import 'admin_dashboard_screen.dart';
import 'doctor_dashboard_screen.dart';
import 'nurse_dashboard_screen.dart';
import 'patient_dashboard_screen.dart';

class RoleBasedHomeScreen extends ConsumerStatefulWidget {
  const RoleBasedHomeScreen({super.key});

  @override
  ConsumerState<RoleBasedHomeScreen> createState() => _RoleBasedHomeScreenState();
}

class _RoleBasedHomeScreenState extends ConsumerState<RoleBasedHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;
    final role = user?.role ?? UserRole.patient;

    final destinations = _getNavDestinationsForRole(role);

    return ResponsiveScaffold(
      currentIndex: _currentIndex,
      destinations: destinations,
      userRole: role,
      userName: user?.fullName ?? 'AuraCare User',
      userAvatar: user?.avatarUrl,
      onLogout: () async {
        await ref.read(authControllerProvider.notifier).signOut();
      },
      body: _buildRoleDashboard(role),
    );
  }

  Widget _buildRoleDashboard(UserRole role) {
    switch (role) {
      case UserRole.doctor:
        return const DoctorDashboardScreen();
      case UserRole.nurse:
        return const NurseDashboardScreen();
      case UserRole.hospitalAdmin:
      case UserRole.superAdmin:
      case UserRole.accountant:
      case UserRole.hrManager:
        return const AdminDashboardScreen();
      case UserRole.patient:
      default:
        return const PatientDashboardScreen();
    }
  }

  List<NavDestinationItem> _getNavDestinationsForRole(UserRole role) {
    if (role.isDoctor) {
      return const [
        NavDestinationItem(
          route: '/home',
          label: 'Queue',
          icon: Icons.dashboard_outlined,
          selectedIcon: Icons.dashboard_rounded,
        ),
        NavDestinationItem(
          route: '/appointments',
          label: 'Appointments',
          icon: Icons.calendar_today_outlined,
          selectedIcon: Icons.calendar_today_rounded,
        ),
        NavDestinationItem(
          route: '/patients',
          label: 'Patients',
          icon: Icons.people_outline,
          selectedIcon: Icons.people_rounded,
        ),
        NavDestinationItem(
          route: '/prescriptions',
          label: 'Prescribe',
          icon: Icons.medication_outlined,
          selectedIcon: Icons.medication_rounded,
        ),
        NavDestinationItem(
          route: '/messages',
          label: 'Messages',
          icon: Icons.chat_bubble_outline,
          selectedIcon: Icons.chat_bubble_rounded,
          badgeCount: 2,
        ),
      ];
    }

    if (role.isAdministrative) {
      return const [
        NavDestinationItem(
          route: '/home',
          label: 'Command',
          icon: Icons.analytics_outlined,
          selectedIcon: Icons.analytics_rounded,
        ),
        NavDestinationItem(
          route: '/admissions',
          label: 'Beds',
          icon: Icons.hotel_outlined,
          selectedIcon: Icons.hotel_rounded,
        ),
        NavDestinationItem(
          route: '/staff',
          label: 'Staff',
          icon: Icons.badge_outlined,
          selectedIcon: Icons.badge_rounded,
        ),
        NavDestinationItem(
          route: '/billing',
          label: 'Finances',
          icon: Icons.account_balance_wallet_outlined,
          selectedIcon: Icons.account_balance_wallet_rounded,
        ),
        NavDestinationItem(
          route: '/reports',
          label: 'Reports',
          icon: Icons.insert_chart_outlined,
          selectedIcon: Icons.insert_chart_rounded,
        ),
      ];
    }

    // Default Patient Navigation (Inspired by reference UI)
    return const [
      NavDestinationItem(
        route: '/home',
        label: 'Home',
        icon: Icons.home_outlined,
        selectedIcon: Icons.home_rounded,
      ),
      NavDestinationItem(
        route: '/appointments',
        label: 'Schedule',
        icon: Icons.calendar_month_outlined,
        selectedIcon: Icons.calendar_month_rounded,
      ),
      NavDestinationItem(
        route: '/medications',
        label: 'Pills',
        icon: Icons.medication_outlined,
        selectedIcon: Icons.medication_rounded,
      ),
      NavDestinationItem(
        route: '/messages',
        label: 'Messages',
        icon: Icons.chat_outlined,
        selectedIcon: Icons.chat_rounded,
        badgeCount: 1,
      ),
      NavDestinationItem(
        route: '/profile',
        label: 'Profile',
        icon: Icons.person_outline,
        selectedIcon: Icons.person_rounded,
      ),
    ];
  }
}
