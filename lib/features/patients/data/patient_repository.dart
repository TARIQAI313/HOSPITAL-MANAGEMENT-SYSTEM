import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/supabase_client.dart';
import '../domain/patient_model.dart';

final patientRepositoryProvider = Provider<PatientRepository>((ref) {
  return PatientRepository();
});

class PatientRepository {
  Future<List<PatientModel>> getPatients({String? query}) async {
    final client = SupabaseService.client;
    if (client != null && SupabaseService.isInitialized) {
      try {
        var req = client.from('patients').select('*, profiles(*)');
        if (query != null && query.isNotEmpty) {
          req = req.ilike('profiles.full_name', '%$query%');
        }
        final List res = await req.limit(50);
        return res.map((e) => PatientModel.fromJson(Map<String, dynamic>.from(e))).toList();
      } catch (_) {}
    }

    // Demo realistic patients
    return _getDemoPatients().where((p) {
      if (query == null || query.isEmpty) return true;
      return p.fullName.toLowerCase().contains(query.toLowerCase()) ||
             p.mrNumber.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  Future<PatientModel?> getPatientById(String id) async {
    final client = SupabaseService.client;
    if (client != null && SupabaseService.isInitialized) {
      try {
        final res = await client.from('patients').select('*, profiles(*)').eq('id', id).maybeSingle();
        if (res != null) return PatientModel.fromJson(res);
      } catch (_) {}
    }

    return _getDemoPatients().firstWhere(
      (p) => p.id == id,
      orElse: () => _getDemoPatients().first,
    );
  }

  Future<void> updatePatientProfile(PatientModel patient) async {
    final client = SupabaseService.client;
    if (client != null && SupabaseService.isInitialized) {
      await client.from('patients').update(patient.toJson()).eq('id', patient.id);
    }
  }

  List<PatientModel> _getDemoPatients() {
    return [
      PatientModel(
        id: '30000000-0000-0000-0000-000000000001',
        mrNumber: 'MR-2026-0001',
        fullName: 'Emma Stonehurst',
        email: 'patient1@example.com',
        phone: '+1 (555) 101-0001',
        gender: 'female',
        bloodGroup: 'A+',
        dateOfBirth: DateTime(1992, 4, 12),
        emergencyContactName: 'David Stonehurst',
        emergencyContactPhone: '+1 (555) 9011',
        emergencyContactRelation: 'Spouse',
        insuranceProvider: 'BlueCross BlueShield',
        insurancePolicyNumber: 'BC-8899214',
        allergies: ['Penicillin', 'Peanuts'],
        chronicConditions: ['Mild Asthma'],
        notes: 'Patient exhibits high adherence to medication scheduling.',
      ),
      PatientModel(
        id: '30000000-0000-0000-0000-000000000002',
        mrNumber: 'MR-2026-0002',
        fullName: 'Lucas Montgomery',
        email: 'patient2@example.com',
        phone: '+1 (555) 101-0002',
        gender: 'male',
        bloodGroup: 'O+',
        dateOfBirth: DateTime(1985, 8, 25),
        emergencyContactName: 'Sarah Montgomery',
        emergencyContactPhone: '+1 (555) 9012',
        insuranceProvider: 'Aetna Healthcare',
        insurancePolicyNumber: 'AET-401928',
        chronicConditions: ['Hypertension'],
      ),
      PatientModel(
        id: '30000000-0000-0000-0000-000000000003',
        mrNumber: 'MR-2026-0003',
        fullName: 'Aaliyah Peterson',
        email: 'patient3@example.com',
        phone: '+1 (555) 101-0003',
        gender: 'female',
        bloodGroup: 'B-',
        dateOfBirth: DateTime(1998, 11, 3),
        allergies: ['Sulfa Drugs'],
        insuranceProvider: 'UnitedHealthcare',
        insurancePolicyNumber: 'UHC-772910',
      ),
      PatientModel(
        id: '30000000-0000-0000-0000-000000000004',
        mrNumber: 'MR-2026-0004',
        fullName: 'Ethan Harper',
        email: 'patient4@example.com',
        phone: '+1 (555) 101-0004',
        gender: 'male',
        bloodGroup: 'AB+',
        dateOfBirth: DateTime(1979, 2, 18),
        chronicConditions: ['Type 2 Diabetes'],
        insuranceProvider: 'Cigna Global',
        insurancePolicyNumber: 'CG-118274',
      ),
      PatientModel(
        id: '30000000-0000-0000-0000-000000000005',
        mrNumber: 'MR-2026-0005',
        fullName: 'Sophia Ramirez',
        email: 'patient5@example.com',
        phone: '+1 (555) 101-0005',
        gender: 'female',
        bloodGroup: 'O-',
        dateOfBirth: DateTime(2001, 9, 14),
        allergies: ['Latex'],
        insuranceProvider: 'Humana Health',
        insurancePolicyNumber: 'HUM-992812',
      ),
    ];
  }
}
