class RadiologyOrderModel {
  final String id;
  final String orderCode;
  final String patientName;
  final String modality; // X-Ray, CT Scan, MRI, Ultrasound, Mammography
  final String bodyPart;
  final String status; // requested, scheduled, completed, reported
  final String? findings;
  final String? impression;
  final DateTime orderDate;

  const RadiologyOrderModel({
    required this.id,
    required this.orderCode,
    required this.patientName,
    required this.modality,
    required this.bodyPart,
    required this.status,
    this.findings,
    this.impression,
    required this.orderDate,
  });

  factory RadiologyOrderModel.fromJson(Map<String, dynamic> json) {
    return RadiologyOrderModel(
      id: json['id'] as String,
      orderCode: json['order_code'] as String? ?? 'RAD-000',
      patientName: json['patients']?['profiles']?['full_name'] as String? ?? 'Patient',
      modality: json['modality'] as String? ?? 'X-Ray',
      bodyPart: json['body_part'] as String? ?? 'Chest',
      status: json['status'] as String? ?? 'requested',
      findings: json['findings'] as String?,
      impression: json['impression'] as String?,
      orderDate: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }
}
