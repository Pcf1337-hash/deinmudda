import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

class QuickButtonConfig {
  final String id;
  final String substanceId;
  final String substanceName;
  final double dosage;
  final String unit;
  final double cost;
  final int position;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? iconCodePoint; // Store icon as codePoint for serialization
  final int? colorValue; // Store color as int value for serialization

  const QuickButtonConfig({
    required this.id,
    required this.substanceId,
    required this.substanceName,
    required this.dosage,
    required this.unit,
    this.cost = 0.0,
    required this.position,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.iconCodePoint,
    this.colorValue,
  });

  // Helper getters for icon and color
  IconData? get icon => iconCodePoint != null ? IconData(iconCodePoint!, fontFamily: 'MaterialIcons') : null;
  Color? get color => colorValue != null ? Color(colorValue!) : null;

  // Factory constructor for creating new quick buttons
  factory QuickButtonConfig.create({
    required String substanceId,
    required String substanceName,
    required double dosage,
    required String unit,
    double cost = 0.0,
    required int position,
    bool isActive = true,
    IconData? icon,
    Color? color,
  }) {
    final now = DateTime.now();
    return QuickButtonConfig(
      id: const Uuid().v4(),
      substanceId: substanceId,
      substanceName: substanceName,
      dosage: dosage,
      unit: unit,
      cost: cost,
      position: position,
      isActive: isActive,
      createdAt: now,
      updatedAt: now,
      iconCodePoint: icon?.codePoint,
      colorValue: color?.value,
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
      'cost': cost,
      'position': position,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'iconCodePoint': iconCodePoint,
      'colorValue': colorValue,
    };
  }

  factory QuickButtonConfig.fromJson(Map<String, dynamic> json) {
    return QuickButtonConfig(
      id: json['id'] as String,
      substanceId: json['substanceId'] as String,
      substanceName: json['substanceName'] as String,
      dosage: (json['dosage'] as num).toDouble(),
      unit: json['unit'] as String,
      cost: (json['cost'] as num?)?.toDouble() ?? 0.0,
      position: json['position'] as int,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      iconCodePoint: json['iconCodePoint'] as int?,
      colorValue: json['colorValue'] as int?,
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
      'cost': cost,
      'position': position,
      'isActive': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'iconCodePoint': iconCodePoint,
      'colorValue': colorValue,
    };
  }

  factory QuickButtonConfig.fromDatabase(Map<String, dynamic> map) {
    return QuickButtonConfig(
      id: map['id'] as String,
      substanceId: map['substanceId'] as String,
      substanceName: map['substanceName'] as String,
      dosage: (map['dosage'] as num).toDouble(),
      unit: map['unit'] as String,
      cost: (map['cost'] as num?)?.toDouble() ?? 0.0,
      position: map['position'] as int,
      isActive: (map['isActive'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      iconCodePoint: map['iconCodePoint'] as int?,
      colorValue: map['colorValue'] as int?,
    );
  }

  // Copy with method
  QuickButtonConfig copyWith({
    String? id,
    String? substanceId,
    String? substanceName,
    double? dosage,
    String? unit,
    double? cost,
    int? position,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? iconCodePoint,
    int? colorValue,
  }) {
    return QuickButtonConfig(
      id: id ?? this.id,
      substanceId: substanceId ?? this.substanceId,
      substanceName: substanceName ?? this.substanceName,
      dosage: dosage ?? this.dosage,
      unit: unit ?? this.unit,
      cost: cost ?? this.cost,
      position: position ?? this.position,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      colorValue: colorValue ?? this.colorValue,
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