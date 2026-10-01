class LabTestModel {
  final String id;
  final String code;
  final String name;
  final String category; // Hematology, Biochemistry, Microbiology, Pathology
  final String sampleType; // Blood, Urine, etc.
  final double price;
  final int turnaroundHours;
  final String? referenceRange;
  final String? units;

  const LabTestModel({
    required this.id,
    required this.code,
    required this.name,
    required this.category,
    required this.sampleType,
    required this.price,
    this.turnaroundHours = 24,
    this.referenceRange,
    this.units,
  });

  factory LabTestModel.fromJson(Map<String, dynamic> json) {
    return LabTestModel(
      id: json['id'] as String,
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? 'Lab Test',
      category: json['category'] as String? ?? 'Biochemistry',
      sampleType: json['sample_type'] as String? ?? 'Blood',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      turnaroundHours: (json['turnaround_hours'] as num?)?.toInt() ?? 24,
      referenceRange: json['reference_range'] as String?,
      units: json['units'] as String?,
    );
  }
}

class LabOrderModel {
  final String id;
  final String orderCode;
  final String testName;
  final String patientName;
  final String status; // ordered, sample_collected, in_analysis, results_ready, verified
  final String? resultValue;
  final bool isAbnormal;
  final DateTime orderDate;

  const LabOrderModel({
    required this.id,
    required this.orderCode,
    required this.testName,
    required this.patientName,
    required this.status,
    this.resultValue,
    this.isAbnormal = false,
    required this.orderDate,
  });

  factory LabOrderModel.fromJson(Map<String, dynamic> json) {
    return LabOrderModel(
      id: json['id'] as String,
      orderCode: json['order_code'] as String? ?? 'LAB-000',
      testName: json['lab_tests']?['name'] as String? ?? 'Diagnostic Test',
      patientName: json['patients']?['profiles']?['full_name'] as String? ?? 'Patient',
      status: json['status'] as String? ?? 'ordered',
      resultValue: json['result_value'] as String?,
      isAbnormal: json['is_abnormal'] as bool? ?? false,
      orderDate: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }
}
