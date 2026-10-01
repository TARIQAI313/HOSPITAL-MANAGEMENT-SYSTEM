import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/supabase_client.dart';
import '../domain/doctor_model.dart';

final doctorRepositoryProvider = Provider<DoctorRepository>((ref) {
  return DoctorRepository();
});

class DoctorRepository {
  Future<List<DoctorModel>> getDoctors({
    String? query,
    String? specialty,
  }) async {
    final client = SupabaseService.client;
    if (client != null && SupabaseService.isInitialized) {
      try {
        var req = client.from('doctors').select('*, profiles(*), departments(name)');
        if (specialty != null && specialty != 'All') {
          req = req.eq('specialty', specialty);
        }
        final List res = await req;
        return res.map((e) => DoctorModel.fromJson(Map<String, dynamic>.from(e))).toList();
      } catch (_) {}
    }

    return _getDemoDoctors().where((doc) {
      if (specialty != null && specialty != 'All' && !doc.specialty.toLowerCase().contains(specialty.toLowerCase())) {
        return false;
      }
      if (query != null && query.isNotEmpty) {
        return doc.fullName.toLowerCase().contains(query.toLowerCase()) ||
               doc.specialty.toLowerCase().contains(query.toLowerCase());
      }
      return true;
    }).toList();
  }

  Future<DoctorModel?> getDoctorById(String id) async {
    final client = SupabaseService.client;
    if (client != null && SupabaseService.isInitialized) {
      try {
        final res = await client
            .from('doctors')
            .select('*, profiles(*), departments(name)')
            .eq('id', id)
            .maybeSingle();
        if (res != null) return DoctorModel.fromJson(res);
      } catch (_) {}
    }

    return _getDemoDoctors().firstWhere(
      (doc) => doc.id == id,
      orElse: () => _getDemoDoctors().first,
    );
  }

  List<DoctorModel> _getDemoDoctors() {
    return const [
      DoctorModel(
        id: '20000000-0000-0000-0000-000000000001',
        fullName: 'Dr. Sarah Watson',
        specialty: 'Cardiologist',
        departmentName: 'Cardiology',
        licenseNumber: 'MD-CARD-9841',
        qualifications: ['MD (Harvard Medical)', 'FACC', 'Board Certified'],
        experienceYears: 14,
        consultationFee: 150.00,
        rating: 4.95,
        reviewsCount: 238,
        bio: 'Specialist in non-invasive cardiac imaging, heart failure prevention and coronary interventions.',
        avatarUrl: 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&q=80&w=300',
      ),
      DoctorModel(
        id: '20000000-0000-0000-0000-000000000002',
        fullName: 'Dr. Marcus Vance',
        specialty: 'Neurologist',
        departmentName: 'Neurology',
        licenseNumber: 'MD-NEUR-7712',
        qualifications: ['MD (Johns Hopkins)', 'FAAN'],
        experienceYears: 12,
        consultationFee: 175.00,
        rating: 4.88,
        reviewsCount: 184,
        bio: 'Expert in migraine management, cerebrovascular diseases, epilepsy and neuro-rehabilitation.',
        avatarUrl: 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?auto=format&fit=crop&q=80&w=300',
      ),
      DoctorModel(
        id: '20000000-0000-0000-0000-000000000003',
        fullName: 'Dr. Elena Rostova',
        specialty: 'Dermatologist',
        departmentName: 'Dermatology',
        licenseNumber: 'MD-DERM-4491',
        qualifications: ['MD (Columbia)', 'FAAD'],
        experienceYears: 9,
        consultationFee: 120.00,
        rating: 4.92,
        reviewsCount: 310,
        bio: 'Leading specialist in clinical dermatology, acne treatments, eczema therapies and laser skin rejuvenation.',
        avatarUrl: 'https://images.unsplash.com/photo-1594824813571-638f02634417?auto=format&fit=crop&q=80&w=300',
      ),
      DoctorModel(
        id: '20000000-0000-0000-0000-000000000004',
        fullName: 'Dr. James Chen',
        specialty: 'Pediatrician',
        departmentName: 'Pediatrics',
        licenseNumber: 'MD-PED-5521',
        qualifications: ['MD (Stanford)', 'FAAP'],
        experienceYears: 11,
        consultationFee: 100.00,
        rating: 4.98,
        reviewsCount: 412,
        bio: 'Gentle, compassionate pediatric doctor dedicated to newborn care, adolescent health and preventative wellness.',
        avatarUrl: 'https://images.unsplash.com/photo-1537368910025-700350fe46c7?auto=format&fit=crop&q=80&w=300',
      ),
      DoctorModel(
        id: '20000000-0000-0000-0000-000000000005',
        fullName: 'Dr. Amira Khan',
        specialty: 'Gynecologist',
        departmentName: 'Gynecology & Obstetrics',
        licenseNumber: 'MD-GYN-8812',
        qualifications: ['MD (Oxford)', 'FRCOG'],
        experienceYears: 15,
        consultationFee: 140.00,
        rating: 4.91,
        reviewsCount: 275,
        bio: 'Comprehensive prenatal care, high-risk obstetrics, endocrine gynecology and fertility consultation.',
        avatarUrl: 'https://images.unsplash.com/photo-1614608682850-e0d6ed316d47?auto=format&fit=crop&q=80&w=300',
      ),
      DoctorModel(
        id: '20000000-0000-0000-0000-000000000006',
        fullName: 'Dr. David Miller',
        specialty: 'Orthopedic Surgeon',
        departmentName: 'Orthopedics',
        licenseNumber: 'MD-ORTH-3310',
        qualifications: ['MS Ortho (Mayo Clinic)', 'AAOS'],
        experienceYears: 16,
        consultationFee: 160.00,
        rating: 4.87,
        reviewsCount: 195,
        bio: 'Specialized in arthroscopic joint replacement, sports injury surgery and spine reconstruction.',
        avatarUrl: 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?auto=format&fit=crop&q=80&w=300',
      ),
    ];
  }
}
