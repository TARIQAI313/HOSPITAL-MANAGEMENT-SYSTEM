import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_management/features/medications/data/medication_repository.dart';
import 'package:hospital_management/features/medications/domain/medication_model.dart';

void main() {
  group('Medication & Pill Reminder Tests', () {
    late MedicationRepository repository;

    setUp(() {
      repository = MedicationRepository();
    });

    test('Retrieves initial scheduled medications', () async {
      final list = await repository.getMedications();
      expect(list, isNotEmpty);
    });

    test('Toggles medication taken adherence status and decrements pills', () async {
      final initial = await repository.getMedications();
      final target = initial.firstWhere((m) => m.id == 'med-1');
      final initialCount = target.remainingPills;
      final initialTaken = target.isTakenToday;

      await repository.toggleTakenStatus('med-1');
      final updated = await repository.getMedications();
      final updatedTarget = updated.firstWhere((m) => m.id == 'med-1');

      expect(updatedTarget.isTakenToday, equals(!initialTaken));
      if (!initialTaken) {
        expect(updatedTarget.remainingPills, equals(initialCount - 1));
      }
    });

    test('Detects low refill threshold flag correctly', () {
      final lowStockMed = MedicationModel(
        id: 'test-low',
        patientId: 'p-1',
        name: 'Insulin Glargine',
        dosage: '10 units',
        startDate: DateTime(2026, 1, 1),
        scheduleTimes: const ['08:00 AM'],
        timeOfDay: const ['morning'],
        remainingPills: 3,
        refillThreshold: 5,
      );

      expect(lowStockMed.needsRefill, isTrue);

      final ampleStockMed = MedicationModel(
        id: 'test-ample',
        patientId: 'p-1',
        name: 'Multivitamin',
        dosage: '1 tab',
        startDate: DateTime(2026, 1, 1),
        scheduleTimes: const ['08:00 AM'],
        timeOfDay: const ['morning'],
        remainingPills: 30,
        refillThreshold: 5,
      );

      expect(ampleStockMed.needsRefill, isFalse);
    });
  });
}
