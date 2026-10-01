import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/supabase_client.dart';
import '../domain/medicine_stock_model.dart';

final pharmacyRepositoryProvider = Provider<PharmacyRepository>((ref) {
  return PharmacyRepository();
});

class PharmacyRepository {
  final List<MedicineStockModel> _demoStock = [
    MedicineStockModel(
      id: 'ph-1',
      name: 'Atorvastatin 20mg',
      genericName: 'Atorvastatin Calcium',
      sku: 'SKU-CARD-001',
      category: 'Cardiology',
      form: 'Tablet',
      strength: '20mg',
      unitPrice: 12.50,
      quantityInStock: 240,
      minStockAlert: 50,
      batchNumber: 'ATV-2026-X1',
      expiryDate: DateTime.now().add(const Duration(days: 420)),
      locationShelf: 'Shelf C-04',
      supplierName: 'Pfizer Healthcare Direct',
    ),
    MedicineStockModel(
      id: 'ph-2',
      name: 'Amoxicillin 500mg',
      genericName: 'Amoxicillin Trihydrate',
      sku: 'SKU-ANTI-002',
      category: 'Antibiotics',
      form: 'Capsule',
      strength: '500mg',
      unitPrice: 8.75,
      quantityInStock: 18, // Low stock alert!
      minStockAlert: 30,
      batchNumber: 'AMX-2026-B8',
      expiryDate: DateTime.now().add(const Duration(days: 180)),
      locationShelf: 'Shelf A-12',
      supplierName: 'Novartis Pharma Supply',
    ),
    MedicineStockModel(
      id: 'ph-3',
      name: 'Lisinopril 10mg',
      genericName: 'Lisinopril Anhydrous',
      sku: 'SKU-CARD-003',
      category: 'Cardiology',
      form: 'Tablet',
      strength: '10mg',
      unitPrice: 9.00,
      quantityInStock: 120,
      minStockAlert: 40,
      batchNumber: 'LSN-2026-D4',
      expiryDate: DateTime.now().add(const Duration(days: 300)),
      locationShelf: 'Shelf C-06',
    ),
    MedicineStockModel(
      id: 'ph-4',
      name: 'Omeprazole 20mg',
      genericName: 'Omeprazole Delayed Release',
      sku: 'SKU-GAST-004',
      category: 'Gastroenterology',
      form: 'Capsule',
      strength: '20mg',
      unitPrice: 11.20,
      quantityInStock: 80,
      minStockAlert: 25,
      batchNumber: 'OMP-2026-M2',
      expiryDate: DateTime.now().add(const Duration(days: 260)),
      locationShelf: 'Shelf B-02',
    ),
  ];

  Future<List<MedicineStockModel>> getInventory({String? category}) async {
    final client = SupabaseService.client;
    if (client != null && SupabaseService.isInitialized) {
      try {
        var query = client.from('pharmacy_inventory').select();
        if (category != null && category != 'All') {
          query = query.eq('category', category);
        }
        final List res = await query;
        return res.map((e) => MedicineStockModel.fromJson(Map<String, dynamic>.from(e))).toList();
      } catch (_) {}
    }
    return _demoStock.where((item) {
      if (category == null || category == 'All') return true;
      return item.category == category;
    }).toList();
  }

  Future<void> dispenseMedicine(String id, int quantity) async {
    final idx = _demoStock.indexWhere((e) => e.id == id);
    if (idx != -1) {
      final current = _demoStock[idx];
      final newQty = (current.quantityInStock - quantity).clamp(0, 99999);
      _demoStock[idx] = MedicineStockModel(
        id: current.id,
        name: current.name,
        genericName: current.genericName,
        sku: current.sku,
        category: current.category,
        form: current.form,
        strength: current.strength,
        unitPrice: current.unitPrice,
        quantityInStock: newQty,
        minStockAlert: current.minStockAlert,
        batchNumber: current.batchNumber,
        expiryDate: current.expiryDate,
        locationShelf: current.locationShelf,
      );
    }
  }
}
