import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/supabase_client.dart';
import '../../../core/storage/offline_queue_service.dart';
import '../domain/appointment_model.dart';

final appointmentRepositoryProvider = Provider<AppointmentRepository>((ref) {
  return AppointmentRepository();
});

class AppointmentRepository {
  final List<AppointmentModel> _localAppointments = _generateInitialAppointments();

  Future<List<AppointmentModel>> getAppointments({String? status, String? patientId}) async {
    final client = SupabaseService.client;
    if (client != null && SupabaseService.isInitialized) {
      try {
        var query = client.from('appointments').select(
          '*, doctors(specialty, profiles(full_name, avatar_url)), patients(profiles(full_name)), departments(name)'
        );
        if (patientId != null) query = query.eq('patient_id', patientId);
        if (status != null && status != 'all') query = query.eq('status', status);

        final List res = await query.order('appointment_date', ascending: false);
        return res.map((e) => AppointmentModel.fromJson(Map<String, dynamic>.from(e))).toList();
      } catch (_) {}
    }

    return _localAppointments.where((app) {
      if (status != null && status != 'all') {
        if (status == 'upcoming') {
          return app.isUpcoming;
        } else if (status == 'past') {
          return !app.isUpcoming && app.status != 'cancelled';
        } else {
          return app.status == status;
        }
      }
      return true;
    }).toList();
  }

  Future<AppointmentModel> bookAppointment(AppointmentModel appointment) async {
    final client = SupabaseService.client;
    if (client != null && SupabaseService.isInitialized) {
      try {
        final res = await client.from('appointments').insert(appointment.toJson()).select().single();
        return AppointmentModel.fromJson(res);
      } catch (e) {
        // Enqueue offline write
        await OfflineQueueService.enqueue('book_appointment', appointment.toJson());
      }
    }

    _localAppointments.insert(0, appointment);
    return appointment;
  }

  Future<void> cancelAppointment(String id, String reason) async {
    final client = SupabaseService.client;
    if (client != null && SupabaseService.isInitialized) {
      try {
        await client.from('appointments').update({
          'status': 'cancelled',
          'cancellation_reason': reason,
        }).eq('id', id);
      } catch (_) {}
    }

    final index = _localAppointments.indexWhere((a) => a.id == id);
    if (index != -1) {
      final existing = _localAppointments[index];
      _localAppointments[index] = AppointmentModel(
        id: existing.id,
        patientId: existing.patientId,
        patientName: existing.patientName,
        doctorId: existing.doctorId,
        doctorName: existing.doctorName,
        doctorSpecialty: existing.doctorSpecialty,
        appointmentDate: existing.appointmentDate,
        startTime: existing.startTime,
        endTime: existing.endTime,
        type: existing.type,
        status: 'cancelled',
        reason: existing.reason,
        notes: 'Cancelled: $reason',
      );
    }
  }

  static List<AppointmentModel> _generateInitialAppointments() {
    final now = DateTime.now();
    return [
      AppointmentModel(
        id: '40000000-0000-0000-0000-000000000001',
        patientId: '30000000-0000-0000-0000-000000000001',
        patientName: 'Emma Stonehurst',
        doctorId: '20000000-0000-0000-0000-000000000001',
        doctorName: 'Dr. Sarah Watson',
        doctorSpecialty: 'Cardiologist',
        doctorAvatar: 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&q=80&w=300',
        departmentName: 'Cardiology',
        appointmentDate: now.add(const Duration(days: 1)),
        startTime: '09:30 AM',
        endTime: '10:00 AM',
        type: 'in_person',
        status: 'confirmed',
        reason: 'Annual cardiac checkup & ECG review',
        queueNumber: 1,
      ),
      AppointmentModel(
        id: '40000000-0000-0000-0000-000000000002',
        patientId: '30000000-0000-0000-0000-000000000001',
        patientName: 'Emma Stonehurst',
        doctorId: '20000000-0000-0000-0000-000000000002',
        doctorName: 'Dr. Marcus Vance',
        doctorSpecialty: 'Neurologist',
        doctorAvatar: 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?auto=format&fit=crop&q=80&w=300',
        departmentName: 'Neurology',
        appointmentDate: now.add(const Duration(days: 3)),
        startTime: '10:00 AM',
        endTime: '10:30 AM',
        type: 'telemedicine_video',
        status: 'confirmed',
        reason: 'Chronic migraine aura follow-up',
        queueNumber: 2,
      ),
      AppointmentModel(
        id: '40000000-0000-0000-0000-000000000003',
        patientId: '30000000-0000-0000-0000-000000000001',
        patientName: 'Emma Stonehurst',
        doctorId: '20000000-0000-0000-0000-000000000003',
        doctorName: 'Dr. Elena Rostova',
        doctorSpecialty: 'Dermatologist',
        doctorAvatar: 'https://images.unsplash.com/photo-1594824813571-638f02634417?auto=format&fit=crop&q=80&w=300',
        departmentName: 'Dermatology',
        appointmentDate: now.subtract(const Duration(days: 4)),
        startTime: '02:00 PM',
        endTime: '02:30 PM',
        type: 'in_person',
        status: 'completed',
        reason: 'Eczema skin examination',
      ),
    ];
  }
}
