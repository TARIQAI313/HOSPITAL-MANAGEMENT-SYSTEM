import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_management/features/appointments/data/appointment_repository.dart';
import 'package:hospital_management/features/appointments/domain/appointment_model.dart';

void main() {
  group('Appointment Lifecycle & Booking Tests', () {
    late AppointmentRepository repository;

    setUp(() {
      repository = AppointmentRepository();
    });

    test('Retrieves default appointments list', () async {
      final appointments = await repository.getAppointments();
      expect(appointments, isNotEmpty);
    });

    test('Books a new appointment and updates queue', () async {
      final newApp = AppointmentModel(
        id: 'test-app-100',
        patientId: '30000000-0000-0000-0000-000000000001',
        patientName: 'Emma Stonehurst',
        doctorId: '20000000-0000-0000-0000-000000000001',
        doctorName: 'Dr. Sarah Watson',
        doctorSpecialty: 'Cardiologist',
        appointmentDate: DateTime.now().add(const Duration(days: 2)),
        startTime: '11:00 AM',
        endTime: '11:30 AM',
        type: 'in_person',
        status: 'confirmed',
        reason: 'Hypertension evaluation',
        queueNumber: 5,
      );

      final booked = await repository.bookAppointment(newApp);
      expect(booked.id, equals('test-app-100'));

      final list = await repository.getAppointments();
      expect(list.any((a) => a.id == 'test-app-100'), isTrue);
    });

    test('Cancels an appointment with stated reason', () async {
      await repository.cancelAppointment('test-app-100', 'Patient requested reschedule');
      final cancelledList = await repository.getAppointments(status: 'cancelled');
      expect(cancelledList.any((a) => a.id == 'test-app-100'), isTrue);
    });
  });
}
