import 'package:uuid/uuid.dart';

class QuickButtonConfig {
  final String id;
  final String substanceId;
  final String substanceName;
  final double dosage;
  final String unit;
  final int position;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const QuickButtonConfig({
    required this.id,
    required this.substanceId,
    required this.substanceName,
    required this.dosage,
    required this.unit,
    required this.position,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor for creating new quick buttons
  factory QuickButtonConfig.create({
    required String substanceId,
    required String substanceName,
    required double dosage,
    required String unit,
    required int position,
    bool isActive = true,
  }) {
    final now = DateTime.now();
    return QuickButtonConfig(
      id: const Uuid().v4(),
      substanceId: substanceId,
      substanceName: substanceName,
      dosage: dosage,
      unit: unit,
      position: position,
      isActive: isActive,
      createdAt: now,
      updatedAt: now,
    );
  }

  // Getters
  String get formattedDosage {
    return '${dosage.toString().replaceAll('.', ',')} $unit';
  }

  String get displayText {
    return '$substanceName\n$formattedDosage';
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'substanceId': substanceId,
      'substanceName': substanceName,
      'dosage': dosage,
      'unit': unit,
      'position': position,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory QuickButtonConfig.fromJson(Map<String, dynamic> json) {
    return QuickButtonConfig(
      id: json['id'] as String,
      substanceId: json['substanceId'] as String,
      substanceName: json['substanceName'] as String,
      dosage: (json['dosage'] as num).toDouble(),
      unit: json['unit'] as String,
      position: json['position'] as int,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  // Database serialization
  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'substanceId': substanceId,
      'substanceName': substanceName,
      'dosage': dosage,
      'unit': unit,
      'position': position,
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory QuickButtonConfig.fromDatabase(Map<String, dynamic> map) {
    return QuickButtonConfig(
      id: map['id'] as String,
      substanceId: map['substanceId'] as String,
      substanceName: map['substanceName'] as String,
      dosage: (map['dosage'] as num).toDouble(),
      unit: map['unit'] as String,
      position: map['position'] as int,
      isActive: (map['isActive'] as int) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  // Copy with method
  QuickButtonConfig copyWith({
    String? id,
    String? substanceId,
    String? substanceName,
    double? dosage,
    String? unit,
    int? position,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return QuickButtonConfig(
      id: id ?? this.id,
      substanceId: substanceId ?? this.substanceId,
      substanceName: substanceName ?? this.substanceName,
      dosage: dosage ?? this.dosage,
      unit: unit ?? this.unit,
      position: position ?? this.position,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuickButtonConfig && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'QuickButtonConfig(id: $id, substance: $substanceName, dosage: $formattedDosage, position: $position)';
  }
}