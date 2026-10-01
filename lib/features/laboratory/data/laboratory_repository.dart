import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/supabase_client.dart';
import '../domain/lab_test_model.dart';

final laboratoryRepositoryProvider = Provider<LaboratoryRepository>((ref) {
  return LaboratoryRepository();
});

class LaboratoryRepository {
  final List<LabTestModel> _demoCatalog = const [
    LabTestModel(
      id: '60000000-0000-0000-0000-000000000001',
      code: 'CBC-01',
      name: 'Complete Blood Count (CBC) with Differential',
      category: 'Hematology',
      sampleType: 'Whole Blood (EDTA)',
      price: 35.00,
      turnaroundHours: 4,
      referenceRange: 'WBC: 4.5-11.0, RBC: 4.2-5.9',
      units: '10^3/uL',
    ),
    LabTestModel(
      id: '60000000-0000-0000-0000-000000000002',
      code: 'LIPID-02',
      name: 'Comprehensive Lipid Panel',
      category: 'Biochemistry',
      sampleType: 'Serum Fasting',
      price: 45.00,
      turnaroundHours: 6,
      referenceRange: 'Total Chol: < 200, LDL: < 100, HDL: > 40',
      units: 'mg/dL',
    ),
    LabTestModel(
      id: '60000000-0000-0000-0000-000000000003',
      code: 'HBA1C-03',
      name: 'Glycated Hemoglobin (HbA1c)',
      category: 'Biochemistry',
      sampleType: 'Whole Blood',
      price: 40.00,
      turnaroundHours: 6,
      referenceRange: '< 5.7 Normal, 5.7-6.4 Pre-diabetes, >= 6.5 Diabetes',
      units: '%',
    ),
    LabTestModel(
      id: '60000000-0000-0000-0000-000000000004',
      code: 'LFT-04',
      name: 'Liver Function Panel (LFT)',
      category: 'Biochemistry',
      sampleType: 'Serum',
      price: 55.00,
      turnaroundHours: 8,
      referenceRange: 'ALT: 7-56, AST: 10-40, Bilirubin: 0.1-1.2',
      units: 'U/L',
    ),
  ];

  final List<LabOrderModel> _demoOrders = [
    LabOrderModel(
      id: 'lo-1',
      orderCode: 'LAB-2026-901',
      testName: 'Complete Blood Count (CBC)',
      patientName: 'Emma Stonehurst',
      status: 'verified',
      resultValue: 'WBC: 6.8 | RBC: 4.6 | Platelets: 280k',
      isAbnormal: false,
      orderDate: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    LabOrderModel(
      id: 'lo-2',
      orderCode: 'LAB-2026-902',
      testName: 'Comprehensive Lipid Panel',
      patientName: 'Emma Stonehurst',
      status: 'in_analysis',
      resultValue: null,
      isAbnormal: false,
      orderDate: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

  Future<List<LabTestModel>> getCatalog() async {
    final client = SupabaseService.client;
    if (client != null && SupabaseService.isInitialized) {
      try {
        final List res = await client.from('lab_tests').select().eq('is_active', true);
        return res.map((e) => LabTestModel.fromJson(Map<String, dynamic>.from(e))).toList();
      } catch (_) {}
    }
    return _demoCatalog;
  }

  Future<List<LabOrderModel>> getOrders() async {
    final client = SupabaseService.client;
    if (client != null && SupabaseService.isInitialized) {
      try {
        final List res = await client.from('lab_orders').select('*, lab_tests(name), patients(profiles(full_name))');
        return res.map((e) => LabOrderModel.fromJson(Map<String, dynamic>.from(e))).toList();
      } catch (_) {}
    }
    return _demoOrders;
  }
}
