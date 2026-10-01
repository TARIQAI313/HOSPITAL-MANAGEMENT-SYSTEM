import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/supabase_client.dart';
import '../domain/radiology_model.dart';

final radiologyRepositoryProvider = Provider<RadiologyRepository>((ref) {
  return RadiologyRepository();
});

class RadiologyRepository {
  final List<RadiologyOrderModel> _demoOrders = [
    RadiologyOrderModel(
      id: 'rad-1',
      orderCode: 'RAD-2026-104',
      patientName: 'Emma Stonehurst',
      modality: 'X-Ray',
      bodyPart: 'Chest PA View',
      status: 'reported',
      findings: 'Cardiac silhouette within normal size limits. Lung fields clear without active consolidations or effusions.',
      impression: 'No acute cardiopulmonary disease.',
      orderDate: DateTime.now().subtract(const Duration(days: 2)),
    ),
    RadiologyOrderModel(
      id: 'rad-2',
      orderCode: 'RAD-2026-105',
      patientName: 'Lucas Montgomery',
      modality: 'MRI',
      bodyPart: 'Brain with Contrast',
      status: 'scheduled',
      orderDate: DateTime.now().add(const Duration(days: 2)),
    ),
  ];

  Future<List<RadiologyOrderModel>> getOrders() async {
    final client = SupabaseService.client;
    if (client != null && SupabaseService.isInitialized) {
      try {
        final List res = await client.from('radiology_orders').select('*, patients(profiles(full_name))');
        return res.map((e) => RadiologyOrderModel.fromJson(Map<String, dynamic>.from(e))).toList();
      } catch (_) {}
    }
    return _demoOrders;
  }
}
