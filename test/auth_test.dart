import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_management/core/constants/user_roles.dart';
import 'package:hospital_management/features/auth/data/auth_repository.dart';

void main() {
  group('Authentication & Session Persistence Tests', () {
    late AuthRepository authRepository;

    setUp(() {
      authRepository = SupabaseAuthRepository();
    });

    test('Local developer authentication succeeds with designated role', () async {
      final user = await authRepository.signInWithEmail('dr.sarah.watson@auracare.com', 'password123');
      expect(user.email, equals('dr.sarah.watson@auracare.com'));
      expect(user.role, equals(UserRole.doctor));
    });

    test('Patient sign up persists initial profile', () async {
      final newUser = await authRepository.signUp(
        email: 'new.patient@example.com',
        password: 'password123',
        fullName: 'New Test Patient',
        role: UserRole.patient,
      );

      expect(newUser.email, equals('new.patient@example.com'));
      expect(newUser.fullName, equals('New Test Patient'));
      expect(newUser.role, equals(UserRole.patient));
    });

    test('Sign out clears user session', () async {
      await authRepository.signOut();
      final current = await authRepository.getCurrentUser();
      expect(current, isNull);
    });
  });
}
