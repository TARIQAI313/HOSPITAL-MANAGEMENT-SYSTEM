class EmergencyCaseModel {
  final String id;
  final String patientName;
  final String triageLevel; // resuscitation_red, emergent_orange, urgent_yellow, less_urgent_green
  final String chiefComplaint;
  final String arrivalTime;
  final String assignedDoctor;
  final String status; // active, admitted, discharged

  const EmergencyCaseModel({
    required this.id,
    required this.patientName,
    required this.triageLevel,
    required this.chiefComplaint,
    required this.arrivalTime,
    required this.assignedDoctor,
    this.status = 'active',
  });
}
