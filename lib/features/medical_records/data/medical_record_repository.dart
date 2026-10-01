import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/supabase_client.dart';
import '../domain/medical_record_model.dart';

final medicalRecordRepositoryProvider = Provider<MedicalRecordRepository>((ref) {
  return MedicalRecordRepository();
});

class MedicalRecordRepository {
  final List<VitalSignsModel> _demoVitals = [
    VitalSignsModel(
      id: 'v-1',
      patientId: '30000000-0000-0000-0000-000000000001',
      systolicBp: 122,
      diastolicBp: 78,
      heartRate: 68,
      temperatureC: 36.8,
      oxygenSaturation: 98,
      weightKg: 64.5,
      heightCm: 168.0,
      recordedAt: DateTime.now().subtract(const Duration(hours: 3)),
      notes: 'Optimal resting blood pressure and regular rhythm.',
    ),
    VitalSignsModel(
      id: 'v-2',
      patientId: '30000000-0000-0000-0000-000000000001',
      systolicBp: 128,
      diastolicBp: 82,
      heartRate: 74,
      temperatureC: 37.0,
      oxygenSaturation: 99,
      weightKg: 64.8,
      heightCm: 168.0,
      recordedAt: DateTime.now().subtract(const Duration(days: 3)),
      notes: 'Morning routine check after walking.',
    ),
  ];

  final List<ClinicalRecordModel> _demoRecords = [
    ClinicalRecordModel(
      id: 'cr-1',
      patientId: '30000000-0000-0000-0000-000000000001',
      doctorName: 'Dr. Sarah Watson',
      doctorSpecialty: 'Cardiologist',
      chiefComplaint: 'Mild chest tightness upon prolonged cardio exercises',
      diagnosis: 'Benign exertion palpitations, well-compensated',
      treatmentPlan: 'Maintain Lisinopril 10mg daily. Hydrate with electrolyte replenishment.',
      recordedDate: DateTime.now().subtract(const Duration(days: 7)),
      followUpDate: DateTime.now().add(const Duration(days: 60)),
    ),
    ClinicalRecordModel(
      id: 'cr-2',
      patientId: '30000000-0000-0000-0000-000000000001',
      doctorName: 'Dr. Elena Rostova',
      doctorSpecialty: 'Dermatologist',
      chiefComplaint: 'Skin redness and itching on left inner forearm',
      diagnosis: 'Contact dermatitis secondary to mild allergen exposure',
      treatmentPlan: 'Topical hydrocortisone cream twice daily for 7 days. Avoid scented soaps.',
      recordedDate: DateTime.now().subtract(const Duration(days: 25)),
    ),
  ];

  Future<List<VitalSignsModel>> getVitalsHistory({String? patientId}) async {
    final client = SupabaseService.client;
    if (client != null && SupabaseService.isInitialized) {
      try {
        final List res = await client
            .from('vital_signs')
            .select()
            .order('recorded_at', ascending: false);
        return res.map((e) => VitalSignsModel.fromJson(Map<String, dynamic>.from(e))).toList();
      } catch (_) {}
    }
    return _demoVitals;
  }

  Future<List<ClinicalRecordModel>> getClinicalHistory({String? patientId}) async {
    final client = SupabaseService.client;
    if (client != null && SupabaseService.isInitialized) {
      try {
        final List res = await client
            .from('medical_records')
            .select('*, doctors(specialty, profiles(full_name))')
            .order('created_at', ascending: false);
        return res.map((e) => ClinicalRecordModel.fromJson(Map<String, dynamic>.from(e))).toList();
      } catch (_) {}
    }
    return _demoRecords;
  }

  Future<void> logVitalSigns(VitalSignsModel vitals) async {
    final client = SupabaseService.client;
    if (client != null && SupabaseService.isInitialized) {
      try {
        await client.from('vital_signs').insert(vitals.toJson());
      } catch (_) {}
    }
    _demoVitals.insert(0, vitals);
  }
}
