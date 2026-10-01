class DoctorModel {
  final String id;
  final String fullName;
  final String specialty;
  final String? departmentName;
  final String licenseNumber;
  final List<String> qualifications;
  final int experienceYears;
  final List<String> languages;
  final double consultationFee;
  final double rating;
  final int reviewsCount;
  final String? bio;
  final String? avatarUrl;
  final bool isAvailable;
  final List<String> availableDays;
  final String workingHoursStart;
  final String workingHoursEnd;

  const DoctorModel({
    required this.id,
    required this.fullName,
    required this.specialty,
    this.departmentName,
    required this.licenseNumber,
    this.qualifications = const [],
    this.experienceYears = 0,
    this.languages = const ['English'],
    required this.consultationFee,
    this.rating = 5.0,
    this.reviewsCount = 0,
    this.bio,
    this.avatarUrl,
    this.isAvailable = true,
    this.availableDays = const ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
    this.workingHoursStart = '09:00 AM',
    this.workingHoursEnd = '05:00 PM',
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String? ?? (json['profiles']?['full_name'] as String? ?? 'Doctor'),
      specialty: json['specialty'] as String? ?? 'General Medicine',
      departmentName: json['departments']?['name'] as String?,
      licenseNumber: json['license_number'] as String? ?? '',
      qualifications: (json['qualifications'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      experienceYears: (json['experience_years'] as num?)?.toInt() ?? 0,
      languages: (json['languages'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? ['English'],
      consultationFee: (json['consultation_fee'] as num?)?.toDouble() ?? 100.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      reviewsCount: (json['reviews_count'] as num?)?.toInt() ?? 0,
      bio: json['bio'] as String?,
      avatarUrl: json['avatar_url'] as String? ?? json['profiles']?['avatar_url'] as String?,
      isAvailable: json['is_available'] as bool? ?? true,
      availableDays: (json['available_days'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
      workingHoursStart: json['working_hours_start'] as String? ?? '09:00 AM',
      workingHoursEnd: json['working_hours_end'] as String? ?? '05:00 PM',
    );
  }
}
