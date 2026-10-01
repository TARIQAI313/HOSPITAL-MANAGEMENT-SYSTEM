import 'package:flutter/material.dart';

/// 13 Enterprise Roles for AuraCare Hospital Management
enum UserRole {
  superAdmin('super_admin', 'Super Admin', Icons.admin_panel_settings),
  hospitalAdmin('hospital_admin', 'Hospital Admin', Icons.local_hospital),
  receptionist('receptionist', 'Receptionist', Icons.person_pin),
  doctor('doctor', 'Doctor', Icons.medical_services),
  nurse('nurse', 'Nurse', Icons.health_and_safety),
  pharmacist('pharmacist', 'Pharmacist', Icons.medication),
  labTechnician('lab_technician', 'Lab Technician', Icons.biotech),
  radiologist('radiologist', 'Radiologist', Icons.camera_alt),
  patient('patient', 'Patient', Icons.person),
  accountant('accountant', 'Accountant', Icons.receipt_long),
  hrManager('hr_manager', 'HR Manager', Icons.badge),
  ambulanceStaff('ambulance_staff', 'Ambulance Staff', Icons.emergency),
  supportStaff('support_staff', 'Support Staff', Icons.support_agent);

  final String code;
  final String label;
  final IconData icon;

  const UserRole(this.code, this.label, this.icon);

  static UserRole fromCode(String? code) {
    if (code == null) return UserRole.patient;
    return UserRole.values.firstWhere(
      (role) => role.code == code.toLowerCase() || role.name.toLowerCase() == code.toLowerCase(),
      orElse: () => UserRole.patient,
    );
  }

  // Capability Flags
  bool get isAdministrative => this == superAdmin || this == hospitalAdmin;
  bool get isDoctor => this == doctor;
  bool get isPatient => this == patient;
  bool get isNurse => this == nurse;
  bool get isClinical => this == doctor || this == nurse || this == radiologist || this == labTechnician;
  bool get canWritePrescriptions => this == doctor || isAdministrative;
  bool get canDispenseMedicine => this == pharmacist || isAdministrative;
  bool get canPerformLabTests => this == labTechnician || isAdministrative;
  bool get canPerformRadiology => this == radiologist || isAdministrative;
  bool get canManageBilling => this == accountant || this == receptionist || isAdministrative;
  bool get canTriageEmergency => this == nurse || this == doctor || this == ambulanceStaff || isAdministrative;
  bool get canManageStaff => this == hrManager || isAdministrative;
}
