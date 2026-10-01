class MedicineStockModel {
  final String id;
  final String name;
  final String? genericName;
  final String sku;
  final String category;
  final String form;
  final String strength;
  final double unitPrice;
  final int quantityInStock;
  final int minStockAlert;
  final String batchNumber;
  final DateTime expiryDate;
  final String? supplierName;
  final String? locationShelf;

  const MedicineStockModel({
    required this.id,
    required this.name,
    this.genericName,
    required this.sku,
    required this.category,
    required this.form,
    required this.strength,
    required this.unitPrice,
    required this.quantityInStock,
    this.minStockAlert = 20,
    required this.batchNumber,
    required this.expiryDate,
    this.supplierName,
    this.locationShelf,
  });

  bool get isLowStock => quantityInStock <= minStockAlert;
  bool get isExpired => expiryDate.isBefore(DateTime.now());

  factory MedicineStockModel.fromJson(Map<String, dynamic> json) {
    return MedicineStockModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      genericName: json['generic_name'] as String?,
      sku: json['sku'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      form: json['form'] as String? ?? 'Tablet',
      strength: json['strength'] as String? ?? '',
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      quantityInStock: (json['quantity_in_stock'] as num?)?.toInt() ?? 0,
      minStockAlert: (json['min_stock_alert'] as num?)?.toInt() ?? 20,
      batchNumber: json['batch_number'] as String? ?? 'BATCH-001',
      expiryDate: json['expiry_date'] != null ? DateTime.parse(json['expiry_date']) : DateTime.now().add(const Duration(days: 365)),
      supplierName: json['supplier_name'] as String?,
      locationShelf: json['location_shelf'] as String?,
    );
  }
}
