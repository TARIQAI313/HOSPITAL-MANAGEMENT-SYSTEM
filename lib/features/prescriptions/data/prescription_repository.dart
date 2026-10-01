import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/supabase_client.dart';
import '../domain/prescription_model.dart';

final prescriptionRepositoryProvider = Provider<PrescriptionRepository>((ref) {
  return PrescriptionRepository();
});

class PrescriptionRepository {
  final List<PrescriptionModel> _demoPrescriptions = [
    PrescriptionModel(
      id: 'rx-1',
      prescriptionCode: 'RX-2026-1001',
      patientId: '30000000-0000-0000-0000-000000000001',
      patientName: 'Emma Stonehurst',
      doctorId: '20000000-0000-0000-0000-000000000001',
      doctorName: 'Dr. Sarah Watson',
      doctorSpecialty: 'Cardiologist',
      status: 'active',
      doctorSignature: 'Dr. Sarah Watson, MD, FACC',
      issuedDate: DateTime.now().subtract(const Duration(days: 2)),
      generalInstructions: 'Take medications with a full glass of water. Avoid skipping doses.',
      items: const [
        PrescriptionItemModel(
          medicineName: 'Atorvastatin (Lipitor)',
          form: 'Tablet',
          dosage: '20mg',
          frequency: 'Once daily before bedtime',
          timing: 'after_meal',
          durationDays: 30,
          instructions: 'For lipid and plaque regulation',
        ),
        PrescriptionItemModel(
          medicineName: 'Lisinopril',
          form: 'Tablet',
          dosage: '10mg',
          frequency: 'Once daily in the morning',
          timing: 'after_meal',
          durationDays: 30,
          instructions: 'For arterial hypertension control',
        ),
      ],
    ),
    PrescriptionModel(
      id: 'rx-2',
      prescriptionCode: 'RX-2026-0942',
      patientId: '30000000-0000-0000-0000-000000000001',
      patientName: 'Emma Stonehurst',
      doctorId: '20000000-0000-0000-0000-000000000003',
      doctorName: 'Dr. Elena Rostova',
      doctorSpecialty: 'Dermatologist',
      status: 'dispensed',
      doctorSignature: 'Dr. Elena Rostova, MD, FAAD',
      issuedDate: DateTime.now().subtract(const Duration(days: 24)),
      generalInstructions: 'Apply topically on clean, dry affected skin areas.',
      items: const [
        PrescriptionItemModel(
          medicineName: 'Hydrocortisone 1% Cream',
          form: 'Cream',
          dosage: '15g tube',
          frequency: 'Twice daily',
          timing: 'after_meal',
          durationDays: 7,
          instructions: 'Apply thin layer gently',
        ),
      ],
    ),
  ];

  Future<List<PrescriptionModel>> getPrescriptions({String? patientId}) async {
    final client = SupabaseService.client;
    if (client != null && SupabaseService.isInitialized) {
      try {
        final List res = await client
            .from('prescriptions')
            .select('*, prescription_items(*), doctors(specialty, profiles(full_name)), patients(profiles(full_name))')
            .order('issued_date', ascending: false);
        return res.map((e) => PrescriptionModel.fromJson(Map<String, dynamic>.from(e))).toList();
      } catch (_) {}
    }
    return _demoPrescriptions;
  }

  Future<void> createPrescription(PrescriptionModel prescription) async {
    final client = SupabaseService.client;
    if (client != null && SupabaseService.isInitialized) {
      try {
        final res = await client.from('prescriptions').insert(prescription.toJson()).select().single();
        for (final item in prescription.items) {
          final itemJson = item.toJson();
          itemJson['prescription_id'] = res['id'];
          await client.from('prescription_items').insert(itemJson);
        }
      } catch (_) {}
    }
    _demoPrescriptions.insert(0, prescription);
  }
}
