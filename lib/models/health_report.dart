enum ReportFileType {
  pdf,
  image,
}

class HealthReport {
  final String id;
  final String title;
  final String category; // e.g. "Lab Test", "Blood Report", "X-Ray", "General"
  final String filePath;
  final ReportFileType type;
  final DateTime dateAdded;
  final String? notes;

  HealthReport({
    required this.id,
    required this.title,
    required this.category,
    required this.filePath,
    required this.type,
    DateTime? dateAdded,
    this.notes,
  }) : dateAdded = dateAdded ?? DateTime.now();

  HealthReport copyWith({
    String? id,
    String? title,
    String? category,
    String? filePath,
    ReportFileType? type,
    DateTime? dateAdded,
    String? notes,
  }) {
    return HealthReport(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      filePath: filePath ?? this.filePath,
      type: type ?? this.type,
      dateAdded: dateAdded ?? this.dateAdded,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'filePath': filePath,
      'type': type.name,
      'dateAdded': dateAdded.toIso8601String(),
      'notes': notes,
    };
  }

  factory HealthReport.fromMap(Map<String, dynamic> map) {
    return HealthReport(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      category: map['category'] ?? 'General',
      filePath: map['filePath'] ?? '',
      type: map['type'] == 'pdf' ? ReportFileType.pdf : ReportFileType.image,
      dateAdded: map['dateAdded'] != null
          ? DateTime.tryParse(map['dateAdded']) ?? DateTime.now()
          : DateTime.now(),
      notes: map['notes'],
    );
  }
}
