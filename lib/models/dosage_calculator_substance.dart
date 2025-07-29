import 'package:uuid/uuid.dart';

class DosageCalculatorSubstance {
  final String? id;
  final String name;
  final double lightDosePerKg;
  final double normalDosePerKg;
  final double strongDosePerKg;
  final String administrationRoute;
  final String duration;
  final String safetyNotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  DosageCalculatorSubstance({
    this.id,
    required this.name,
    required this.lightDosePerKg,
    required this.normalDosePerKg,
    required this.strongDosePerKg,
    required this.administrationRoute,
    required this.duration,
    required this.safetyNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // Computed property for description
  String get description => administrationRouteDisplayName;

  // Factory constructor
  factory DosageCalculatorSubstance.create({
    String? id,
    required String name,
    required double lightDosePerKg,
    required double normalDosePerKg,
    required double strongDosePerKg,
    required String administrationRoute,
    required String duration,
    required String safetyNotes,
  }) {
    final now = DateTime.now();
    return DosageCalculatorSubstance(
      id: id ?? const Uuid().v4(),
      name: name,
      lightDosePerKg: lightDosePerKg,
      normalDosePerKg: normalDosePerKg,
      strongDosePerKg: strongDosePerKg,
      administrationRoute: administrationRoute,
      duration: duration,
      safetyNotes: safetyNotes,
      createdAt: now,
      updatedAt: now,
    );
  }

  // Getters
  String get administrationRouteDisplayName {
    switch (administrationRoute.toLowerCase()) {
      case 'oral':
        return 'Oral (Mund)';
      case 'nasal':
        return 'Nasal (Nase)';
      case 'intravenous':
      case 'iv':
        return 'Intravenös (IV)';
      case 'intramuscular':
      case 'im':
        return 'Intramuskulär (IM)';
      case 'sublingual':
        return 'Sublingual (unter der Zunge)';
      case 'rectal':
        return 'Rektal';
      case 'topical':
        return 'Topisch (auf die Haut)';
      case 'inhalation':
        return 'Inhalation';
      default:
        return administrationRoute;
    }
  }

  // Enhanced duration getter with fallback
  String get durationDisplay {
    if (duration.isEmpty) {
      return 'Unbekannte Dauer';
    }
    return duration;
  }

  // Enhanced duration with icon
  String get durationWithIcon {
    return '⏱ ${durationDisplay}';
  }

  // Parse duration string to Duration object for timer functionality
  Duration get defaultDuration {
    return _parseDurationString(duration);
  }

  // Helper method to parse duration strings like "4-6 Stunden", "30-60 Minuten", etc.
  Duration _parseDurationString(String durationStr) {
    final lowercaseDuration = durationStr.toLowerCase();
    
    // Extract first number from duration string
    final match = RegExp(r'(\d+)').firstMatch(lowercaseDuration);
    if (match == null) {
      // Default to 2 hours if parsing fails
      return const Duration(hours: 2);
    }
    
    final number = int.parse(match.group(1)!);
    
    // Determine unit based on content
    if (lowercaseDuration.contains('minute') || lowercaseDuration.contains('min')) {
      return Duration(minutes: number);
    } else if (lowercaseDuration.contains('stunde') || lowercaseDuration.contains('hour') || lowercaseDuration.contains('h')) {
      return Duration(hours: number);
    } else if (lowercaseDuration.contains('tag') || lowercaseDuration.contains('day') || lowercaseDuration.contains('d')) {
      return Duration(days: number);
    } else {
      // Default to hours for unknown units
      return Duration(hours: number);
    }
  }

  // Calculate dosage for specific user and intensity
  double calculateDosage(double weightKg, DosageIntensity intensity) {
    double dosePerKg;
    
    switch (intensity) {
      case DosageIntensity.light:
        dosePerKg = lightDosePerKg;
        break;
      case DosageIntensity.normal:
        dosePerKg = normalDosePerKg;
        break;
      case DosageIntensity.strong:
        dosePerKg = strongDosePerKg;
        break;
    }
    
    return dosePerKg * weightKg;
  }

  // Get dosage range for user
  Map<DosageIntensity, double> getDosageRange(double weightKg) {
    return {
      DosageIntensity.light: calculateDosage(weightKg, DosageIntensity.light),
      DosageIntensity.normal: calculateDosage(weightKg, DosageIntensity.normal),
      DosageIntensity.strong: calculateDosage(weightKg, DosageIntensity.strong),
    };
  }

  // Get formatted dosage string
  String getFormattedDosage(double weightKg, DosageIntensity intensity) {
    final dosage = calculateDosage(weightKg, intensity);
    return '${dosage.toStringAsFixed(1)} mg';
  }

  // Get all formatted dosages
  Map<String, String> getFormattedDosageRange(double weightKg) {
    return {
      'Leicht': getFormattedDosage(weightKg, DosageIntensity.light),
      'Normal': getFormattedDosage(weightKg, DosageIntensity.normal),
      'Stark': getFormattedDosage(weightKg, DosageIntensity.strong),
    };
  }

  // Check if dosage is within safe range
  bool isDosageSafe(double dosage, double weightKg) {
    final maxSafeDosage = strongDosePerKg * weightKg * 1.2; // 20% buffer
    return dosage <= maxSafeDosage;
  }

  // Get safety warning for dosage
  String? getSafetyWarning(double dosage, double weightKg) {
    final lightDose = calculateDosage(weightKg, DosageIntensity.light);
    final normalDose = calculateDosage(weightKg, DosageIntensity.normal);
    final strongDose = calculateDosage(weightKg, DosageIntensity.strong);
    
    if (dosage > strongDose * 1.5) {
      return 'WARNUNG: Extrem hohe Dosis! Lebensgefahr möglich!';
    } else if (dosage > strongDose * 1.2) {
      return 'ACHTUNG: Sehr hohe Dosis! Erhöhtes Risiko!';
    } else if (dosage > strongDose) {
      return 'Hohe Dosis - Vorsicht geboten';
    } else if (dosage < lightDose * 0.5) {
      return 'Sehr niedrige Dosis - möglicherweise unwirksam';
    }
    
    return null;
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lightDosePerKg': lightDosePerKg,
      'normalDosePerKg': normalDosePerKg,
      'strongDosePerKg': strongDosePerKg,
      'administrationRoute': administrationRoute,
      'duration': duration,
      'safetyNotes': safetyNotes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory DosageCalculatorSubstance.fromJson(Map<String, dynamic> json) {
    return DosageCalculatorSubstance(
      id: json['id'] as String?,
      name: json['name'] as String,
      lightDosePerKg: (json['lightDosePerKg'] as num).toDouble(),
      normalDosePerKg: (json['normalDosePerKg'] as num).toDouble(),
      strongDosePerKg: (json['strongDosePerKg'] as num).toDouble(),
      administrationRoute: json['administrationRoute'] as String,
      duration: json['duration'] as String,
      safetyNotes: json['safetyNotes'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  // Database serialization
  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'name': name,
      'lightDosePerKg': lightDosePerKg,
      'normalDosePerKg': normalDosePerKg,
      'strongDosePerKg': strongDosePerKg,
      'administrationRoute': administrationRoute,
      'duration': duration,
      'safetyNotes': safetyNotes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory DosageCalculatorSubstance.fromDatabase(Map<String, dynamic> map) {
    return DosageCalculatorSubstance(
      id: map['id'] as String?,
      name: map['name'] as String,
      lightDosePerKg: (map['lightDosePerKg'] as num).toDouble(),
      normalDosePerKg: (map['normalDosePerKg'] as num).toDouble(),
      strongDosePerKg: (map['strongDosePerKg'] as num).toDouble(),
      administrationRoute: map['administrationRoute'] as String,
      duration: map['duration'] as String,
      safetyNotes: map['safetyNotes'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  // Copy with method
  DosageCalculatorSubstance copyWith({
    String? id,
    String? name,
    double? lightDosePerKg,
    double? normalDosePerKg,
    double? strongDosePerKg,
    String? administrationRoute,
    String? duration,
    String? safetyNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DosageCalculatorSubstance(
      id: id ?? this.id,
      name: name ?? this.name,
      lightDosePerKg: lightDosePerKg ?? this.lightDosePerKg,
      normalDosePerKg: normalDosePerKg ?? this.normalDosePerKg,
      strongDosePerKg: strongDosePerKg ?? this.strongDosePerKg,
      administrationRoute: administrationRoute ?? this.administrationRoute,
      duration: duration ?? this.duration,
      safetyNotes: safetyNotes ?? this.safetyNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is DosageCalculatorSubstance) {
      // If both have IDs, compare by ID, otherwise compare by name
      if (id != null && other.id != null) {
        return id == other.id;
      }
      return name == other.name;
    }
    return false;
  }

  @override
  int get hashCode => id?.hashCode ?? name.hashCode;

  @override
  String toString() {
    return 'DosageCalculatorSubstance(id: $id, name: $name, route: $administrationRoute, duration: $duration)';
  }
}

enum DosageIntensity {
  light,
  normal,
  strong,
}

extension DosageIntensityExtension on DosageIntensity {
  String get displayName {
    switch (this) {
      case DosageIntensity.light:
        return 'Leicht';
      case DosageIntensity.normal:
        return 'Normal';
      case DosageIntensity.strong:
        return 'Stark';
    }
  }

  String get description {
    switch (this) {
      case DosageIntensity.light:
        return 'Niedrige Dosis für Einsteiger';
      case DosageIntensity.normal:
        return 'Standarddosis für erfahrene Nutzer';
      case DosageIntensity.strong:
        return 'Hohe Dosis nur für sehr erfahrene Nutzer';
    }
  }
}