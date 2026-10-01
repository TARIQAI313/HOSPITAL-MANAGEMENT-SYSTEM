class HospitalBedModel {
  final String id;
  final String roomNumber;
  final String bedNumber;
  final String wardType; // general, semi_private, private, icu, emergency
  final int floor;
  final String status; // available, occupied, reserved, cleaning, maintenance
  final String? patientName;
  final String? admissionReason;
  final double dailyRate;

  const HospitalBedModel({
    required this.id,
    required this.roomNumber,
    required this.bedNumber,
    required this.wardType,
    required this.floor,
    required this.status,
    this.patientName,
    this.admissionReason,
    this.dailyRate = 120.0,
  });

  bool get isAvailable => status == 'available';
}
