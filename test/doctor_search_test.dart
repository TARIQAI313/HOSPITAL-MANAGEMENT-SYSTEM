import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_management/features/doctors/data/doctor_repository.dart';

void main() {
  group('Doctor Search & Discovery Directory Tests', () {
    late DoctorRepository repository;

    setUp(() {
      repository = DoctorRepository();
    });

    test('Retrieves all doctors when no filter applied', () async {
      final doctors = await repository.getDoctors();
      expect(doctors, isNotEmpty);
      expect(doctors.length, greaterThanOrEqualTo(6));
    });

    test('Filters doctors correctly by specialty', () async {
      final cardiologists = await repository.getDoctors(specialty: 'Cardiologist');
      expect(cardiologists.every((doc) => doc.specialty.contains('Cardiologist')), isTrue);
    });

    test('Filters doctors correctly by keyword search', () async {
      final searchResults = await repository.getDoctors(query: 'Watson');
      expect(searchResults.length, equals(1));
      expect(searchResults.first.fullName, contains('Watson'));
    });

    test('Fetches specific doctor details by ID', () async {
      final doctor = await repository.getDoctorById('20000000-0000-0000-0000-000000000001');
      expect(doctor, isNotNull);
      expect(doctor!.fullName, equals('Dr. Sarah Watson'));
      expect(doctor.rating, greaterThanOrEqualTo(4.5));
    });
  });
}
