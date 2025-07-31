import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

/// Configuration for quick action buttons on the home screen.
/// 
/// Represents a predefined substance consumption entry that users
/// can quickly add with a single tap, including dosage, cost,
/// and visual customization options.
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

  /// Creates a quick button configuration with all required parameters.
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

  // Helper getters for visual customization
  
  /// Static mapping of common icon codePoints to constant IconData instances.
  /// This ensures tree-shake compatibility by only using constant icons.
  static const Map<int, IconData> _iconCodePointMap = {
    // Material Icons commonly used in the app
    0xe047: Icons.add_rounded,
    0xe3ab: Icons.local_cafe_rounded,
    0xe1a3: Icons.flash_on_rounded,
    0xe30c: Icons.emoji_food_beverage_rounded,
    0xe0e8: Icons.local_bar_rounded,
    0xe3b3: Icons.wine_bar_rounded,
    0xe546: Icons.sports_bar_rounded,
    0xe32a: Icons.smoking_rooms_rounded,
    0xe26a: Icons.local_florist_rounded,
    0xe3b0: Icons.medication_rounded,
    0xe2bd: Icons.healing_rounded,
    0xe2d6: Icons.health_and_safety_rounded,
    0xe1e4: Icons.fitness_center_rounded,
    0xe798: Icons.water_drop_rounded,
    0xe3f4: Icons.science_rounded,
    0xe3ca: Icons.psychology_rounded,
    0xe3e5: Icons.bedtime_rounded,
    0xe52f: Icons.wb_sunny_rounded,
    0xe3c8: Icons.nightlight_rounded,
    0xe86d: Icons.bolt_rounded,
    0xe3b4: Icons.medical_services_rounded,
    0xe86c: Icons.check_circle_rounded,
    0xe002: Icons.warning_rounded,
    0xe000: Icons.error_rounded,
    0xe19c: Icons.dangerous_rounded,
    0xe887: Icons.help_rounded,
  };
  
  /// Gets the MaterialIcon representation of the stored icon code point.
  /// Uses constant IconData instances to ensure tree-shake compatibility.
  static IconData? getIconFromCodePoint(int? iconCodePoint) {
    if (iconCodePoint == null) return null;
    
    // Return constant IconData from our mapping, or fallback to science icon
    return _iconCodePointMap[iconCodePoint] ?? Icons.science_rounded;
  }
  
  /// Gets the Color representation of the stored color value.
  Color? get color => colorValue != null ? Color(colorValue!) : null;

  /// Factory constructor for creating new quick buttons with automatic ID generation.
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

  // Display helpers
  
  /// Returns formatted dosage string with unit.
  String get formattedDosage {
    return '${dosage.toString().replaceAll('.', ',')} $unit';
  }

  /// Returns display text for the button showing substance name and dosage.
  String get displayText {
    return '$substanceName\n$formattedDosage';
  }

  /// Converts quick button configuration to JSON map for serialization.
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

  /// Creates QuickButtonConfig from JSON map.
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

  /// Converts quick button configuration to database map for storage.
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

  /// Creates QuickButtonConfig from database map.
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

  /// Creates a copy of this quick button configuration with updated fields.
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

// hints reduziert durch HintOptimiererAgent