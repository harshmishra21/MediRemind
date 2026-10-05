class Medicine {
  final String id;
  final String name;
  final String type; // Tablet, Capsule, Syrup, Injection, Drops, Topical, Other
  final String strengthLabel; // e.g. "500 mg", "10 ml"
  final int stock; // current stock remaining
  final int refillThreshold; // alert when stock <= refillThreshold
  final DateTime createdAt;

  Medicine({
    required this.id,
    required this.name,
    required this.type,
    required this.strengthLabel,
    required this.stock,
    required this.refillThreshold,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Medicine copyWith({
    String? id,
    String? name,
    String? type,
    String? strengthLabel,
    int? stock,
    int? refillThreshold,
    DateTime? createdAt,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      strengthLabel: strengthLabel ?? this.strengthLabel,
      stock: stock ?? this.stock,
      refillThreshold: refillThreshold ?? this.refillThreshold,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'strengthLabel': strengthLabel,
      'stock': stock,
      'refillThreshold': refillThreshold,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Medicine.fromMap(Map<String, dynamic> map) {
    return Medicine(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: map['type'] ?? 'Tablet',
      strengthLabel: map['strengthLabel'] ?? '',
      stock: (map['stock'] as num?)?.toInt() ?? 0,
      refillThreshold: (map['refillThreshold'] as num?)?.toInt() ?? 0,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
