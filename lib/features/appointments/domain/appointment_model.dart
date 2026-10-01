class AppointmentModel {
  final String id;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final String? doctorAvatar;
  final String? departmentName;
  final DateTime appointmentDate;
  final String startTime;
  final String endTime;
  final String type; // 'in_person', 'telemedicine_video', 'telemedicine_audio', etc.
  final String status; // 'confirmed', 'pending', 'checked_in', 'completed', 'cancelled'
  final String reason;
  final String? symptoms;
  final String? notes;
  final int? queueNumber;

  const AppointmentModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialty,
    this.doctorAvatar,
    this.departmentName,
    required this.appointmentDate,
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.status,
    required this.reason,
    this.symptoms,
    this.notes,
    this.queueNumber,
  });

  bool get isUpcoming =>
      appointmentDate.isAfter(DateTime.now().subtract(const Duration(days: 1))) &&
      status != 'cancelled' &&
      status != 'completed';

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as String,
      patientId: json['patient_id'] as String? ?? '',
      patientName: json['patients']?['profiles']?['full_name'] as String? ??
          (json['patient_name'] as String? ?? 'Patient'),
      doctorId: json['doctor_id'] as String? ?? '',
      doctorName: json['doctors']?['profiles']?['full_name'] as String? ??
          (json['doctor_name'] as String? ?? 'Dr. Specialist'),
      doctorSpecialty: json['doctors']?['specialty'] as String? ??
          (json['doctor_specialty'] as String? ?? 'General Medicine'),
      doctorAvatar: json['doctors']?['profiles']?['avatar_url'] as String? ??
          json['doctor_avatar'] as String?,
      departmentName: json['departments']?['name'] as String?,
      appointmentDate: json['appointment_date'] != null
          ? DateTime.parse(json['appointment_date'])
          : DateTime.now(),
      startTime: json['start_time'] as String? ?? '09:00 AM',
      endTime: json['end_time'] as String? ?? '09:30 AM',
      type: json['type'] as String? ?? 'in_person',
      status: json['status'] as String? ?? 'confirmed',
      reason: json['reason'] as String? ?? 'Routine Checkup',
      symptoms: json['symptoms'] as String?,
      notes: json['notes'] as String?,
      queueNumber: (json['queue_number'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patient_id': patientId,
      'doctor_id': doctorId,
      'appointment_date': appointmentDate.toIso8601String().split('T').first,
      'start_time': startTime,
      'end_time': endTime,
      'type': type,
      'status': status,
      'reason': reason,
      'symptoms': symptoms,
      'notes': notes,
      'queue_number': queueNumber,
    };
  }
}
