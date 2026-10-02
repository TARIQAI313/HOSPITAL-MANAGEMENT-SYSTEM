import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/supabase_client.dart';
import '../../../core/storage/local_cache_service.dart';
import '../domain/medication_model.dart';

final medicationRepositoryProvider = Provider<MedicationRepository>((ref) {
  return MedicationRepository.instance;
});

final activeMedicationsStreamProvider = StreamProvider.autoDispose<List<MedicationModel>>((ref) {
  final repo = ref.watch(medicationRepositoryProvider);
  return repo.watchMedications();
});

class MedicationRepository {
  static const String _storageKey = 'auracare_medications_db';
  static MedicationRepository? _instance;

  static MedicationRepository get instance {
    _instance ??= MedicationRepository._();
    return _instance!;
  }

  MedicationRepository._() {
    _loadFromCache();
  }

  final StreamController<List<MedicationModel>> _streamController =
      StreamController<List<MedicationModel>>.broadcast();

  List<MedicationModel> _medications = [];
  bool _isLoaded = false;

  Stream<List<MedicationModel>> watchMedications({String? patientId}) async* {
    if (!_isLoaded) {
      await _loadFromCache();
    }
    yield _filterMedications(_medications, patientId: patientId);

    // If Supabase is connected, listen to live Supabase stream
    final client = SupabaseService.client;
    if (client != null && SupabaseService.isInitialized) {
      try {
        final stream = client.from('medications').stream(primaryKey: ['id']);
        stream.listen((data) {
          final cloudList = data.map((json) => MedicationModel.fromJson(json)).toList();
          if (cloudList.isNotEmpty) {
            _mergeMedications(cloudList);
          }
        }, onError: (err) {
          debugPrint('Supabase medications stream notice: $err');
        });
      } catch (e) {
        debugPrint('Failed to attach Supabase medication stream: $e');
      }
    }

    yield* _streamController.stream.map((list) {
      return _filterMedications(list, patientId: patientId);
    });
  }

  Future<List<MedicationModel>> getMedications({String? patientId}) async {
    if (!_isLoaded) {
      await _loadFromCache();
    }

    final client = SupabaseService.client;
    if (client != null && SupabaseService.isInitialized) {
      try {
        final List res = await client
            .from('medications')
            .select()
            .order('created_at', ascending: false);
        final cloudList = res.map((e) => MedicationModel.fromJson(Map<String, dynamic>.from(e))).toList();
        if (cloudList.isNotEmpty) {
          _mergeMedications(cloudList);
        }
      } catch (e) {
        debugPrint('Supabase getMedications note: $e');
      }
    }

    return _filterMedications(_medications, patientId: patientId);
  }

  Future<void> toggleTakenStatus(String medicationId) async {
    if (!_isLoaded) {
      await _loadFromCache();
    }

    final idx = _medications.indexWhere((m) => m.id == medicationId);
    if (idx != -1) {
      final current = _medications[idx];
      final newStatus = !current.isTakenToday;
      final newPills = newStatus ? (current.remainingPills - 1).clamp(0, 999) : current.remainingPills;

      _medications[idx] = current.copyWith(
        isTakenToday: newStatus,
        remainingPills: newPills,
      );

      await _saveToCache();
      _streamController.add(List.from(_medications));

      final client = SupabaseService.client;
      if (client != null && SupabaseService.isInitialized) {
        try {
          await client.from('medications').update({
            'remaining_pills': newPills,
            'is_taken_today': newStatus,
          }).eq('id', medicationId);
        } catch (e) {
          debugPrint('Error updating medication status in Supabase: $e');
        }
      }
    }
  }

  Future<void> addMedication(MedicationModel medication) async {
    if (!_isLoaded) {
      await _loadFromCache();
    }

    MedicationModel finalMed = medication;
    final client = SupabaseService.client;

    if (client != null && SupabaseService.isInitialized) {
      try {
        final res = await client
            .from('medications')
            .insert(medication.toJsonForSupabase())
            .select()
            .single();
        finalMed = MedicationModel.fromJson(res);
      } catch (e) {
        debugPrint('Error inserting medication to Supabase: $e. Saved to local persistent database.');
      }
    }

    _medications.insert(0, finalMed);
    await _saveToCache();
    _streamController.add(List.from(_medications));
  }

  List<MedicationModel> _filterMedications(List<MedicationModel> list, {String? patientId}) {
    if (patientId == null || patientId.isEmpty) return list;
    return list.where((m) => m.patientId == patientId || m.patientId.isEmpty).toList();
  }

  void _mergeMedications(List<MedicationModel> cloudItems) {
    for (final cloud in cloudItems) {
      final idx = _medications.indexWhere((m) => m.id == cloud.id);
      if (idx != -1) {
        _medications[idx] = cloud;
      } else {
        _medications.add(cloud);
      }
    }
    _saveToCache();
    _streamController.add(List.from(_medications));
  }

  Future<void> _loadFromCache() async {
    final cache = await LocalCacheService.getInstance();
    final jsonList = cache.getJson(_storageKey);
    if (jsonList != null && jsonList is List) {
      _medications = jsonList
          .map((item) => MedicationModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } else {
      _medications = _generateInitialMedications();
      await _saveToCache();
    }
    _isLoaded = true;
    _streamController.add(List.from(_medications));
  }

  Future<void> _saveToCache() async {
    final cache = await LocalCacheService.getInstance();
    final jsonList = _medications.map((m) => m.toFullJson()).toList();
    await cache.saveJson(_storageKey, jsonList);
  }

  static List<MedicationModel> _generateInitialMedications() {
    return [
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
        remainingPills: 4,
        refillThreshold: 5,
        isTakenToday: false,
        instructions: 'Take after lunch for bone wellness',
      ),
    ];
  }
}
