class MedicationModel {
  final String id;
  final String patientId;
  final String name;
  final String form; // Pill, Capsule, Tablet, Syrup, Injection
  final String dosage; // 20mg
  final String colorHex;
  final DateTime startDate;
  final DateTime? endDate;
  final List<String> scheduleTimes; // ["08:00 AM", "08:00 PM"]
  final List<String> timeOfDay; // ["morning", "afternoon", "evening", "night"]
  final int remainingPills;
  final int refillThreshold;
  final bool isTakenToday;
  final String? instructions;

  const MedicationModel({
    required this.id,
    required this.patientId,
    required this.name,
    this.form = 'Pill',
    required this.dosage,
    this.colorHex = '#48C9C5',
    required this.startDate,
    this.endDate,
    required this.scheduleTimes,
    required this.timeOfDay,
    this.remainingPills = 30,
    this.refillThreshold = 5,
    this.isTakenToday = false,
    this.instructions,
  });

  bool get needsRefill => remainingPills <= refillThreshold;

  MedicationModel copyWith({
    bool? isTakenToday,
    int? remainingPills,
  }) {
    return MedicationModel(
      id: id,
      patientId: patientId,
      name: name,
      form: form,
      dosage: dosage,
      colorHex: colorHex,
      startDate: startDate,
      endDate: endDate,
      scheduleTimes: scheduleTimes,
      timeOfDay: timeOfDay,
      remainingPills: remainingPills ?? this.remainingPills,
      refillThreshold: refillThreshold,
      isTakenToday: isTakenToday ?? this.isTakenToday,
      instructions: instructions,
    );
  }

  factory MedicationModel.fromJson(Map<String, dynamic> json) {
    return MedicationModel(
      id: json['id'] as String,
      patientId: json['patient_id'] as String? ?? '',
      name: json['name'] as String? ?? 'Medication',
      form: json['form'] as String? ?? 'Pill',
      dosage: json['dosage'] as String? ?? '',
      colorHex: json['color_hex'] as String? ?? '#48C9C5',
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date']) : DateTime.now(),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      scheduleTimes: (json['schedule_times'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? ['08:00 AM'],
      timeOfDay: (json['time_of_day'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? ['morning'],
      remainingPills: (json['remaining_pills'] as num?)?.toInt() ?? 30,
      refillThreshold: (json['refill_threshold'] as num?)?.toInt() ?? 5,
      isTakenToday: json['is_taken_today'] as bool? ?? false,
      instructions: json['instructions'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patient_id': patientId,
      'name': name,
      'form': form,
      'dosage': dosage,
      'color_hex': colorHex,
      'start_date': startDate.toIso8601String().split('T').first,
      'schedule_times': scheduleTimes,
      'time_of_day': timeOfDay,
      'remaining_pills': remainingPills,
      'refill_threshold': refillThreshold,
      'instructions': instructions,
    };
  }
}
