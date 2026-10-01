class PatientModel {
  final String id;
  final String mrNumber;
  final String fullName;
  final String email;
  final String? phone;
  final String? gender;
  final String? bloodGroup;
  final DateTime? dateOfBirth;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? emergencyContactRelation;
  final String? insuranceProvider;
  final String? insurancePolicyNumber;
  final List<String> allergies;
  final List<String> chronicConditions;
  final List<String> pastSurgeries;
  final String? familyMedicalHistory;
  final String? notes;
  final String? avatarUrl;

  const PatientModel({
    required this.id,
    required this.mrNumber,
    required this.fullName,
    required this.email,
    this.phone,
    this.gender,
    this.bloodGroup,
    this.dateOfBirth,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.emergencyContactRelation,
    this.insuranceProvider,
    this.insurancePolicyNumber,
    this.allergies = const [],
    this.chronicConditions = const [],
    this.pastSurgeries = const [],
    this.familyMedicalHistory,
    this.notes,
    this.avatarUrl,
  });

  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month || (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id'] as String,
      mrNumber: json['mr_number'] as String? ?? 'MR-2026-0000',
      fullName: json['full_name'] as String? ?? (json['profiles']?['full_name'] as String? ?? 'Patient'),
      email: json['email'] as String? ?? (json['profiles']?['email'] as String? ?? ''),
      phone: json['phone'] as String? ?? json['profiles']?['phone'] as String?,
      gender: json['gender'] as String? ?? json['profiles']?['gender'] as String?,
      bloodGroup: json['blood_group'] as String? ?? json['profiles']?['blood_group'] as String?,
      dateOfBirth: json['date_of_birth'] != null 
          ? DateTime.tryParse(json['date_of_birth']) 
          : (json['profiles']?['date_of_birth'] != null ? DateTime.tryParse(json['profiles']['date_of_birth']) : null),
      emergencyContactName: json['emergency_contact_name'] as String?,
      emergencyContactPhone: json['emergency_contact_phone'] as String?,
      emergencyContactRelation: json['emergency_contact_relation'] as String?,
      insuranceProvider: json['insurance_provider'] as String?,
      insurancePolicyNumber: json['insurance_policy_number'] as String?,
      allergies: (json['allergies'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      chronicConditions: (json['chronic_conditions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      pastSurgeries: (json['past_surgeries'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      familyMedicalHistory: json['family_medical_history'] as String?,
      notes: json['notes'] as String?,
      avatarUrl: json['avatar_url'] as String? ?? json['profiles']?['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mr_number': mrNumber,
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_phone': emergencyContactPhone,
      'insurance_provider': insuranceProvider,
      'insurance_policy_number': insurancePolicyNumber,
      'allergies': allergies,
      'chronic_conditions': chronicConditions,
      'past_surgeries': pastSurgeries,
      'family_medical_history': familyMedicalHistory,
      'notes': notes,
    };
  }
}
