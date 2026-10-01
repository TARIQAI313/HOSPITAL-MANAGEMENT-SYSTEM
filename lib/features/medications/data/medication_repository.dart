import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/supabase_client.dart';
import '../domain/medication_model.dart';

final medicationRepositoryProvider = Provider<MedicationRepository>((ref) {
  return MedicationRepository();
});

class MedicationRepository {
  final List<MedicationModel> _demoMedications = [
    MedicationModel(
      id: 'med-1',
      patientId: '30000000-0000-0000-0000-000000000001',
      name: 'Atorvastatin (Lipitor)',
      form: 'Pill',
      dosage: '20mg',
      colorHex: '#48C9C5',
      startDate: DateTime.now().subtract(const Duration(days: 10)),
      scheduleTimes: ['09:00 PM'],
      timeOfDay: ['night'],
      remainingPills: 20,
      refillThreshold: 5,
      isTakenToday: false,
      instructions: 'Take once daily before bedtime with water',
    ),
    MedicationModel(
      id: 'med-2',
      patientId: '30000000-0000-0000-0000-000000000001',
      name: 'Lisinopril',
      form: 'Tablet',
      dosage: '10mg',
      colorHex: '#F3B562',
      startDate: DateTime.now().subtract(const Duration(days: 15)),
      scheduleTimes: ['08:00 AM'],
      timeOfDay: ['morning'],
      remainingPills: 15,
      refillThreshold: 5,
      isTakenToday: true,
      instructions: 'Take in the morning with breakfast',
    ),
    MedicationModel(
      id: 'med-3',
      patientId: '30000000-0000-0000-0000-000000000001',
      name: 'Metformin HCl',
      form: 'Tablet',
      dosage: '500mg',
      colorHex: '#48B883',
      startDate: DateTime.now().subtract(const Duration(days: 5)),
      scheduleTimes: ['08:00 AM', '08:00 PM'],
      timeOfDay: ['morning', 'night'],
      remainingPills: 40,
      refillThreshold: 10,
      isTakenToday: true,
      instructions: 'Take with main meals',
    ),
    MedicationModel(
      id: 'med-4',
      patientId: '30000000-0000-0000-0000-000000000001',
      name: 'Vitamin D3 & Calcium',
      form: 'Capsule',
      dosage: '1000 IU',
      colorHex: '#7B9191',
      startDate: DateTime.now().subtract(const Duration(days: 20)),
      scheduleTimes: ['01:30 PM'],
      timeOfDay: ['afternoon'],
      remainingPills: 4, // Triggers low refill alert!
      refillThreshold: 5,
      isTakenToday: false,
      instructions: 'Take after lunch for bone wellness',
    ),
  ];

  Future<List<MedicationModel>> getMedications({String? patientId}) async {
    final client = SupabaseService.client;
    if (client != null && SupabaseService.isInitialized) {
      try {
        final List res = await client
            .from('medications')
            .select()
            .eq('is_active', true)
            .order('created_at', ascending: false);
        return res.map((e) => MedicationModel.fromJson(Map<String, dynamic>.from(e))).toList();
      } catch (_) {}
    }
    return _demoMedications;
  }

  Future<void> toggleTakenStatus(String medicationId) async {
    final idx = _demoMedications.indexWhere((m) => m.id == medicationId);
    if (idx != -1) {
      final current = _demoMedications[idx];
      final newStatus = !current.isTakenToday;
      final newPills = newStatus ? (current.remainingPills - 1).clamp(0, 999) : current.remainingPills;
      _demoMedications[idx] = current.copyWith(
        isTakenToday: newStatus,
        remainingPills: newPills,
      );

      final client = SupabaseService.client;
      if (client != null && SupabaseService.isInitialized) {
        try {
          await client.from('medications').update({
            'remaining_pills': newPills,
          }).eq('id', medicationId);
        } catch (_) {}
      }
    }
  }

  Future<void> addMedication(MedicationModel medication) async {
    final client = SupabaseService.client;
    if (client != null && SupabaseService.isInitialized) {
      try {
        await client.from('medications').insert(medication.toJson());
      } catch (_) {}
    }
    _demoMedications.insert(0, medication);
  }
}
