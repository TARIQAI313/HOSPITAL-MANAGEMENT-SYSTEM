class PrescriptionItemModel {
  final String medicineName;
  final String form; // Tablet, Capsule, Syrup, Injection
  final String dosage; // 500mg
  final String frequency; // 1-0-1, Once daily, Every 8 hours
  final String timing; // after_meal, before_meal
  final int durationDays;
  final String? instructions;

  const PrescriptionItemModel({
    required this.medicineName,
    this.form = 'Tablet',
    required this.dosage,
    required this.frequency,
    this.timing = 'after_meal',
    this.durationDays = 7,
    this.instructions,
  });

  factory PrescriptionItemModel.fromJson(Map<String, dynamic> json) {
    return PrescriptionItemModel(
      medicineName: json['medicine_name'] as String? ?? 'Medicine',
      form: json['form'] as String? ?? 'Tablet',
      dosage: json['dosage'] as String? ?? '',
      frequency: json['frequency'] as String? ?? 'Once daily',
      timing: json['timing'] as String? ?? 'after_meal',
      durationDays: (json['duration_days'] as num?)?.toInt() ?? 7,
      instructions: json['instructions'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medicine_name': medicineName,
      'form': form,
      'dosage': dosage,
      'frequency': frequency,
      'timing': timing,
      'duration_days': durationDays,
      'instructions': instructions,
    };
  }
}

class PrescriptionModel {
  final String id;
  final String prescriptionCode; // RX-2026-1001
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final String status; // active, dispensed, expired
  final List<PrescriptionItemModel> items;
  final String? generalInstructions;
  final String? doctorSignature;
  final DateTime issuedDate;

  const PrescriptionModel({
    required this.id,
    required this.prescriptionCode,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialty,
    this.status = 'active',
    this.items = const [],
    this.generalInstructions,
    this.doctorSignature,
    required this.issuedDate,
  });

  factory PrescriptionModel.fromJson(Map<String, dynamic> json) {
    return PrescriptionModel(
      id: json['id'] as String,
      prescriptionCode: json['prescription_code'] as String? ?? 'RX-2026-0000',
      patientId: json['patient_id'] as String? ?? '',
      patientName: json['patients']?['profiles']?['full_name'] as String? ??
          (json['patient_name'] as String? ?? 'Patient'),
      doctorId: json['doctor_id'] as String? ?? '',
      doctorName: json['doctors']?['profiles']?['full_name'] as String? ??
          (json['doctor_name'] as String? ?? 'Dr. Specialist'),
      doctorSpecialty: json['doctors']?['specialty'] as String? ??
          (json['doctor_specialty'] as String? ?? 'General Medicine'),
      status: json['status'] as String? ?? 'active',
      items: (json['prescription_items'] as List<dynamic>?)
              ?.map((e) => PrescriptionItemModel.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      generalInstructions: json['general_instructions'] as String?,
      doctorSignature: json['doctor_signature'] as String?,
      issuedDate: json['issued_date'] != null ? DateTime.parse(json['issued_date']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prescription_code': prescriptionCode,
      'patient_id': patientId,
      'doctor_id': doctorId,
      'status': status,
      'general_instructions': generalInstructions,
      'doctor_signature': doctorSignature,
      'issued_date': issuedDate.toIso8601String().split('T').first,
    };
  }
}
