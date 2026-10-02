import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/supabase_client.dart';
import '../../../core/storage/local_cache_service.dart';
import '../domain/appointment_model.dart';

final appointmentRepositoryProvider = Provider<AppointmentRepository>((ref) {
  return AppointmentRepository.instance;
});

final activeAppointmentsStreamProvider = StreamProvider.autoDispose<List<AppointmentModel>>((ref) {
  final repo = ref.watch(appointmentRepositoryProvider);
  return repo.watchAppointments();
});

class AppointmentRepository {
  static const String _storageKey = 'auracare_appointments_db';
  static AppointmentRepository? _instance;

  static AppointmentRepository get instance {
    _instance ??= AppointmentRepository._();
    return _instance!;
  }

  AppointmentRepository._() {
    _loadFromCache();
  }

  final StreamController<List<AppointmentModel>> _streamController =
      StreamController<List<AppointmentModel>>.broadcast();

  List<AppointmentModel> _appointments = [];
  bool _isLoaded = false;

  Stream<List<AppointmentModel>> watchAppointments({String? status, String? patientId}) async* {
    if (!_isLoaded) {
      await _loadFromCache();
    }
    // Yield current cached/local appointments first
    yield _filterAppointments(_appointments, status: status, patientId: patientId);

    // If Supabase is connected, listen to live Supabase stream
    final client = SupabaseService.client;
    if (client != null && SupabaseService.isInitialized) {
      try {
        final stream = client.from('appointments').stream(primaryKey: ['id']);
        stream.listen((data) {
          final cloudList = data.map((json) => AppointmentModel.fromJson(json)).toList();
          if (cloudList.isNotEmpty) {
            _mergeAppointments(cloudList);
          }
        }, onError: (err) {
          debugPrint('Supabase appointments stream notice: $err');
        });
      } catch (e) {
        debugPrint('Failed to attach Supabase appointment stream: $e');
      }
    }

    yield* _streamController.stream.map((list) {
      return _filterAppointments(list, status: status, patientId: patientId);
    });
  }

  Future<List<AppointmentModel>> getAppointments({String? status, String? patientId}) async {
    if (!_isLoaded) {
      await _loadFromCache();
    }

    final client = SupabaseService.client;
    if (client != null && SupabaseService.isInitialized) {
      try {
        var query = client.from('appointments').select(
          '*, doctors(specialty, profiles(full_name, avatar_url)), patients(profiles(full_name)), departments(name)'
        );
        if (patientId != null) query = query.eq('patient_id', patientId);
        if (status != null && status != 'all') query = query.eq('status', status);

        final List res = await query.order('appointment_date', ascending: false);
        final cloudItems = res.map((e) => AppointmentModel.fromJson(Map<String, dynamic>.from(e))).toList();
        if (cloudItems.isNotEmpty) {
          _mergeAppointments(cloudItems);
        }
      } catch (e) {
        debugPrint('Supabase getAppointments note: $e');
      }
    }

    return _filterAppointments(_appointments, status: status, patientId: patientId);
  }

  Future<AppointmentModel> bookAppointment(AppointmentModel appointment) async {
    if (!_isLoaded) {
      await _loadFromCache();
    }

    AppointmentModel finalAppointment = appointment;
    final client = SupabaseService.client;

    if (client != null && SupabaseService.isInitialized) {
      try {
        final res = await client
            .from('appointments')
            .insert(appointment.toJsonForSupabase())
            .select()
            .single();
        finalAppointment = AppointmentModel.fromJson(res);
      } catch (e) {
        debugPrint('Error inserting to Supabase appointments: $e. Saved to local persistent database.');
      }
    }

    _appointments.insert(0, finalAppointment);
    await _saveToCache();
    _streamController.add(List.from(_appointments));
    return finalAppointment;
  }

  Future<void> cancelAppointment(String id, String reason) async {
    if (!_isLoaded) {
      await _loadFromCache();
    }

    final client = SupabaseService.client;
    if (client != null && SupabaseService.isInitialized) {
      try {
        await client.from('appointments').update({
          'status': 'cancelled',
          'cancellation_reason': reason,
        }).eq('id', id);
      } catch (e) {
        debugPrint('Error updating Supabase appointment: $e');
      }
    }

    final index = _appointments.indexWhere((a) => a.id == id);
    if (index != -1) {
      final existing = _appointments[index];
      _appointments[index] = AppointmentModel(
        id: existing.id,
        patientId: existing.patientId,
        patientName: existing.patientName,
        doctorId: existing.doctorId,
        doctorName: existing.doctorName,
        doctorSpecialty: existing.doctorSpecialty,
        doctorAvatar: existing.doctorAvatar,
        departmentName: existing.departmentName,
        appointmentDate: existing.appointmentDate,
        startTime: existing.startTime,
        endTime: existing.endTime,
        type: existing.type,
        status: 'cancelled',
        reason: existing.reason,
        symptoms: existing.symptoms,
        notes: 'Cancelled: $reason',
        queueNumber: existing.queueNumber,
      );
      await _saveToCache();
      _streamController.add(List.from(_appointments));
    }
  }

  List<AppointmentModel> _filterAppointments(List<AppointmentModel> list, {String? status, String? patientId}) {
    return list.where((app) {
      if (patientId != null && app.patientId.isNotEmpty && app.patientId != patientId) {
        return false;
      }
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

  void _mergeAppointments(List<AppointmentModel> cloudItems) {
    for (final cloud in cloudItems) {
      final idx = _appointments.indexWhere((a) => a.id == cloud.id);
      if (idx != -1) {
        _appointments[idx] = cloud;
      } else {
        _appointments.add(cloud);
      }
    }
    _saveToCache();
    _streamController.add(List.from(_appointments));
  }

  Future<void> _loadFromCache() async {
    final cache = await LocalCacheService.getInstance();
    final jsonList = cache.getJson(_storageKey);
    if (jsonList != null && jsonList is List) {
      _appointments = jsonList
          .map((item) => AppointmentModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } else {
      _appointments = _generateInitialAppointments();
      await _saveToCache();
    }
    _isLoaded = true;
    _streamController.add(List.from(_appointments));
  }

  Future<void> _saveToCache() async {
    final cache = await LocalCacheService.getInstance();
    final jsonList = _appointments.map((a) => a.toFullJson()).toList();
    await cache.saveJson(_storageKey, jsonList);
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
