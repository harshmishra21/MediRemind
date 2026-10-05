class Prescription {
  final String id;
  final String? doctorName;
  final DateTime dateAdded;
  final String imagePath; // Path to local image file or asset
  final String notes;

  Prescription({
    required this.id,
    this.doctorName,
    DateTime? dateAdded,
    required this.imagePath,
    required this.notes,
  }) : dateAdded = dateAdded ?? DateTime.now();

  Prescription copyWith({
    String? id,
    String? doctorName,
    DateTime? dateAdded,
    String? imagePath,
    String? notes,
  }) {
    return Prescription(
      id: id ?? this.id,
      doctorName: doctorName ?? this.doctorName,
      dateAdded: dateAdded ?? this.dateAdded,
      imagePath: imagePath ?? this.imagePath,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'doctorName': doctorName,
      'dateAdded': dateAdded.toIso8601String(),
      'imagePath': imagePath,
      'notes': notes,
    };
  }

  factory Prescription.fromMap(Map<String, dynamic> map) {
    return Prescription(
      id: map['id'] ?? '',
      doctorName: map['doctorName'],
      dateAdded: map['dateAdded'] != null
          ? DateTime.tryParse(map['dateAdded']) ?? DateTime.now()
          : DateTime.now(),
      imagePath: map['imagePath'] ?? '',
      notes: map['notes'] ?? '',
    );
  }
}
