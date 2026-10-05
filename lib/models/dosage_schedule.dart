class DosageSchedule {
  final String id;
  final String medicineId;
  final List<String> times; // HH:mm format e.g. ["08:00", "20:00"]
  final List<int> daysOfWeek; // 1 = Mon, 7 = Sun
  final DateTime startDate;
  final DateTime endDate;
  final int dosesPerIntake; // number of units per dose (e.g. 1 pill)
  final String? instructions; // e.g. "After meals"

  DosageSchedule({
    required this.id,
    required this.medicineId,
    required this.times,
    required this.daysOfWeek,
    required this.startDate,
    required this.endDate,
    this.dosesPerIntake = 1,
    this.instructions,
  });

  int get totalDosesPerDay => times.length * dosesPerIntake;

  DosageSchedule copyWith({
    String? id,
    String? medicineId,
    List<String>? times,
    List<int>? daysOfWeek,
    DateTime? startDate,
    DateTime? endDate,
    int? dosesPerIntake,
    String? instructions,
  }) {
    return DosageSchedule(
      id: id ?? this.id,
      medicineId: medicineId ?? this.medicineId,
      times: times ?? this.times,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      dosesPerIntake: dosesPerIntake ?? this.dosesPerIntake,
      instructions: instructions ?? this.instructions,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'medicineId': medicineId,
      'times': times,
      'daysOfWeek': daysOfWeek,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'dosesPerIntake': dosesPerIntake,
      'instructions': instructions,
    };
  }

  factory DosageSchedule.fromMap(Map<String, dynamic> map) {
    return DosageSchedule(
      id: map['id'] ?? '',
      medicineId: map['medicineId'] ?? '',
      times: List<String>.from(map['times'] ?? []),
      daysOfWeek: List<int>.from(map['daysOfWeek'] ?? []),
      startDate: map['startDate'] != null
          ? DateTime.tryParse(map['startDate']) ?? DateTime.now()
          : DateTime.now(),
      endDate: map['endDate'] != null
          ? DateTime.tryParse(map['endDate']) ?? DateTime.now().add(const Duration(days: 30))
          : DateTime.now().add(const Duration(days: 30)),
      dosesPerIntake: (map['dosesPerIntake'] as num?)?.toInt() ?? 1,
      instructions: map['instructions'],
    );
  }
}
