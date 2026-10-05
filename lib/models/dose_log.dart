enum DoseStatus {
  pending,
  taken,
  missed,
  skipped,
}

extension DoseStatusX on DoseStatus {
  String get name {
    switch (this) {
      case DoseStatus.pending: return 'pending';
      case DoseStatus.taken: return 'taken';
      case DoseStatus.missed: return 'missed';
      case DoseStatus.skipped: return 'skipped';
    }
  }

  String get label {
    switch (this) {
      case DoseStatus.pending: return 'Upcoming';
      case DoseStatus.taken: return 'Taken';
      case DoseStatus.missed: return 'Missed';
      case DoseStatus.skipped: return 'Skipped';
    }
  }
}

class DoseLog {
  final String id;
  final String medicineId;
  final DateTime scheduledDateTime;
  final DoseStatus status;
  final DateTime? actionDateTime; // Time when marked taken or skipped
  final String? notes;

  DoseLog({
    required this.id,
    required this.medicineId,
    required this.scheduledDateTime,
    required this.status,
    this.actionDateTime,
    this.notes,
  });

  DoseLog copyWith({
    String? id,
    String? medicineId,
    DateTime? scheduledDateTime,
    DoseStatus? status,
    DateTime? actionDateTime,
    String? notes,
  }) {
    return DoseLog(
      id: id ?? this.id,
      medicineId: medicineId ?? this.medicineId,
      scheduledDateTime: scheduledDateTime ?? this.scheduledDateTime,
      status: status ?? this.status,
      actionDateTime: actionDateTime ?? this.actionDateTime,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'medicineId': medicineId,
      'scheduledDateTime': scheduledDateTime.toIso8601String(),
      'status': status.name,
      'actionDateTime': actionDateTime?.toIso8601String(),
      'notes': notes,
    };
  }

  factory DoseLog.fromMap(Map<String, dynamic> map) {
    return DoseLog(
      id: map['id'] ?? '',
      medicineId: map['medicineId'] ?? '',
      scheduledDateTime: map['scheduledDateTime'] != null
          ? DateTime.tryParse(map['scheduledDateTime']) ?? DateTime.now()
          : DateTime.now(),
      status: DoseStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => DoseStatus.pending,
      ),
      actionDateTime: map['actionDateTime'] != null
          ? DateTime.tryParse(map['actionDateTime'])
          : null,
      notes: map['notes'],
    );
  }
}
