import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_management/core/constants/user_roles.dart';

void main() {
  group('Enterprise Role-Based Access Control (RBAC) Tests', () {
    test('Super Admin & Hospital Admin have full administrative privileges', () {
      expect(UserRole.superAdmin.isAdministrative, isTrue);
      expect(UserRole.hospitalAdmin.isAdministrative, isTrue);
      expect(UserRole.patient.isAdministrative, isFalse);
      expect(UserRole.doctor.isAdministrative, isFalse);
    });

    test('Doctor role has clinical and prescribing authority', () {
      expect(UserRole.doctor.isDoctor, isTrue);
      expect(UserRole.doctor.isClinical, isTrue);
      expect(UserRole.doctor.canWritePrescriptions, isTrue);
      expect(UserRole.patient.canWritePrescriptions, isFalse);
    });

    test('Nurse has clinical observation and emergency triage capabilities', () {
      expect(UserRole.nurse.isNurse, isTrue);
      expect(UserRole.nurse.isClinical, isTrue);
      expect(UserRole.nurse.canTriageEmergency, isTrue);
    });

    test('Pharmacist has exclusive dispensing permission', () {
      expect(UserRole.pharmacist.canDispenseMedicine, isTrue);
      expect(UserRole.patient.canDispenseMedicine, isFalse);
      expect(UserRole.doctor.canDispenseMedicine, isFalse);
    });

    test('All 13 enterprise roles parse accurately from code strings', () {
      expect(UserRole.fromCode('super_admin'), equals(UserRole.superAdmin));
      expect(UserRole.fromCode('hospital_admin'), equals(UserRole.hospitalAdmin));
      expect(UserRole.fromCode('receptionist'), equals(UserRole.receptionist));
      expect(UserRole.fromCode('doctor'), equals(UserRole.doctor));
      expect(UserRole.fromCode('nurse'), equals(UserRole.nurse));
      expect(UserRole.fromCode('pharmacist'), equals(UserRole.pharmacist));
      expect(UserRole.fromCode('lab_technician'), equals(UserRole.labTechnician));
      expect(UserRole.fromCode('radiologist'), equals(UserRole.radiologist));
      expect(UserRole.fromCode('patient'), equals(UserRole.patient));
      expect(UserRole.fromCode('accountant'), equals(UserRole.accountant));
      expect(UserRole.fromCode('hr_manager'), equals(UserRole.hrManager));
      expect(UserRole.fromCode('ambulance_staff'), equals(UserRole.ambulanceStaff));
      expect(UserRole.fromCode('support_staff'), equals(UserRole.supportStaff));
    });
  });
}
