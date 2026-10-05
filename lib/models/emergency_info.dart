class EmergencyInfo {
  final String patientName;
  final String bloodGroup;
  final List<String> allergies;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final String primaryDoctorName;
  final String primaryDoctorPhone;

  const EmergencyInfo({
    required this.patientName,
    required this.bloodGroup,
    required this.allergies,
    required this.emergencyContactName,
    required this.emergencyContactPhone,
    required this.primaryDoctorName,
    required this.primaryDoctorPhone,
  });

  static const EmergencyInfo defaultData = EmergencyInfo(
    patientName: 'Harsh Mishra',
    bloodGroup: 'O+ Positive',
    allergies: ['Penicillin', 'Sulfa Drugs'],
    emergencyContactName: 'Pooja Mishra (Mother)',
    emergencyContactPhone: '+91 98765 43210',
    primaryDoctorName: 'Dr. Rajesh Sharma',
    primaryDoctorPhone: '+91 98765 43210',
  );
}
