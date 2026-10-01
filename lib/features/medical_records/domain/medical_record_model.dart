class VitalSignsModel {
  final String id;
  final String patientId;
  final int systolicBp;
  final int diastolicBp;
  final int heartRate;
  final double temperatureC;
  final int oxygenSaturation;
  final int? respiratoryRate;
  final double? weightKg;
  final double? heightCm;
  final DateTime recordedAt;
  final String? notes;

  const VitalSignsModel({
    required this.id,
    required this.patientId,
    required this.systolicBp,
    required this.diastolicBp,
    required this.heartRate,
    required this.temperatureC,
    required this.oxygenSaturation,
    this.respiratoryRate,
    this.weightKg,
    this.heightCm,
    required this.recordedAt,
    this.notes,
  });

  double? get bmi {
    if (weightKg == null || heightCm == null || heightCm == 0) return null;
    final heightM = heightCm! / 100.0;
    return weightKg! / (heightM * heightM);
  }

  factory VitalSignsModel.fromJson(Map<String, dynamic> json) {
    return VitalSignsModel(
      id: json['id'] as String,
      patientId: json['patient_id'] as String? ?? '',
      systolicBp: (json['systolic_bp'] as num?)?.toInt() ?? 120,
      diastolicBp: (json['diastolic_bp'] as num?)?.toInt() ?? 80,
      heartRate: (json['heart_rate'] as num?)?.toInt() ?? 72,
      temperatureC: (json['temperature_c'] as num?)?.toDouble() ?? 37.0,
      oxygenSaturation: (json['oxygen_saturation'] as num?)?.toInt() ?? 98,
      respiratoryRate: (json['respiratory_rate'] as num?)?.toInt(),
      weightKg: (json['weight_kg'] as num?)?.toDouble(),
      heightCm: (json['height_cm'] as num?)?.toDouble(),
      recordedAt: json['recorded_at'] != null ? DateTime.parse(json['recorded_at']) : DateTime.now(),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patient_id': patientId,
      'systolic_bp': systolicBp,
      'diastolic_bp': diastolicBp,
      'heart_rate': heartRate,
      'temperature_c': temperatureC,
      'oxygen_saturation': oxygenSaturation,
      'respiratory_rate': respiratoryRate,
      'weight_kg': weightKg,
      'height_cm': heightCm,
      'bmi': bmi,
      'notes': notes,
    };
  }
}

class ClinicalRecordModel {
  final String id;
  final String patientId;
  final String doctorName;
  final String doctorSpecialty;
  final String chiefComplaint;
  final String diagnosis;
  final String treatmentPlan;
  final DateTime recordedDate;
  final DateTime? followUpDate;

  const ClinicalRecordModel({
    required this.id,
    required this.patientId,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.chiefComplaint,
    required this.diagnosis,
    required this.treatmentPlan,
    required this.recordedDate,
    this.followUpDate,
  });

  factory ClinicalRecordModel.fromJson(Map<String, dynamic> json) {
    return ClinicalRecordModel(
      id: json['id'] as String,
      patientId: json['patient_id'] as String? ?? '',
      doctorName: json['doctors']?['profiles']?['full_name'] as String? ?? 'Dr. Physician',
      doctorSpecialty: json['doctors']?['specialty'] as String? ?? 'Medicine',
      chiefComplaint: json['chief_complaint'] as String? ?? '',
      diagnosis: json['diagnosis'] as String? ?? '',
      treatmentPlan: json['treatment_plan'] as String? ?? '',
      recordedDate: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      followUpDate: json['follow_up_date'] != null ? DateTime.tryParse(json['follow_up_date']) : null,
    );
  }
}
