import 'dart:math';
import 'package:uuid/uuid.dart';

enum Gender {
  male,
  female,
  other,
}

enum DosageStrategy {
  calculated,     // 0% - Errechnete Dosis (Bzgl Gewicht)
  optimal,        // -20% - Optimal  
  safe,           // -40% - Auf nummer sicher
  beginner,       // -60% - Schnupperkurs
}

extension DosageStrategyExtension on DosageStrategy {
  String get displayName {
    switch (this) {
      case DosageStrategy.calculated:
        return 'Errechnete Dosis (Bzgl Gewicht) -0%';
      case DosageStrategy.optimal:
        return 'Optimal -20%';
      case DosageStrategy.safe:
        return 'Auf nummer sicher -40%';
      case DosageStrategy.beginner:
        return 'Schnupperkurs -60%';
    }
  }

  String get shortName {
    switch (this) {
      case DosageStrategy.calculated:
        return 'Errechnete Dosis';
      case DosageStrategy.optimal:
        return 'Optimal';
      case DosageStrategy.safe:
        return 'Auf nummer sicher';
      case DosageStrategy.beginner:
        return 'Schnupperkurs';
    }
  }

  double get reductionPercentage {
    switch (this) {
      case DosageStrategy.calculated:
        return 0.0;
      case DosageStrategy.optimal:
        return 0.2;  // 20%
      case DosageStrategy.safe:
        return 0.4;  // 40%
      case DosageStrategy.beginner:
        return 0.6;  // 60%
    }
  }

  int get percentageDisplay {
    return (reductionPercentage * 100).round();
  }
}

class DosageCalculatorUser {
  final String id;
  final Gender gender;
  final double weightKg;
  final double heightCm;
  final int ageYears;
  final DosageStrategy dosageStrategy;
  final DateTime lastUpdated;
  final DateTime createdAt;

  const DosageCalculatorUser({
    required this.id,
    required this.gender,
    required this.weightKg,
    required this.heightCm,
    required this.ageYears,
    this.dosageStrategy = DosageStrategy.optimal, // Default to -20%
    required this.lastUpdated,
    required this.createdAt,
  });

  // Factory constructor for creating new users
  factory DosageCalculatorUser.create({
    required Gender gender,
    required double weightKg,
    required double heightCm,
    required int ageYears,
    DosageStrategy dosageStrategy = DosageStrategy.optimal,
  }) {
    final now = DateTime.now();
    return DosageCalculatorUser(
      id: const Uuid().v4(),
      gender: gender,
      weightKg: weightKg,
      heightCm: heightCm,
      ageYears: ageYears,
      dosageStrategy: dosageStrategy,
      lastUpdated: now,
      createdAt: now,
    );
  }

  // Getters
  String get genderDisplayName {
    switch (gender) {
      case Gender.male:
        return 'Männlich';
      case Gender.female:
        return 'Weiblich';
      case Gender.other:
        return 'Divers';
    }
  }

  double get bmi {
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  String get bmiCategory {
    final bmiValue = bmi;
    if (bmiValue < 18.5) {
      return 'Untergewicht';
    } else if (bmiValue < 25) {
      return 'Normalgewicht';
    } else if (bmiValue < 30) {
      return 'Übergewicht';
    } else {
      return 'Adipositas';
    }
  }

  String get formattedWeight => '${weightKg.toStringAsFixed(1)} kg';
  String get formattedHeight => '${heightCm.toStringAsFixed(0)} cm';
  String get formattedAge => '$ageYears Jahre';
  String get formattedBmi => bmi.toStringAsFixed(1);

  // Calculate body surface area (BSA) using Mosteller formula
  double get bodySurfaceArea {
    return sqrt(weightKg * heightCm / 3600);
  }

  // Calculate lean body mass (LBM) using Boer formula
  double get leanBodyMass {
    switch (gender) {
      case Gender.male:
        return (0.407 * weightKg) + (0.267 * heightCm) - 19.2;
      case Gender.female:
        return (0.252 * weightKg) + (0.473 * heightCm) - 48.3;
      case Gender.other:
        // Use average of male and female formulas
        final male = (0.407 * weightKg) + (0.267 * heightCm) - 19.2;
        final female = (0.252 * weightKg) + (0.473 * heightCm) - 48.3;
        return (male + female) / 2;
    }
  }

  // Calculate ideal body weight using Devine formula
  double get idealBodyWeight {
    final heightCmAdjusted = heightCm - 152.4; // Convert to inches equivalent
    switch (gender) {
      case Gender.male:
        return 50 + (2.3 * (heightCmAdjusted / 2.54));
      case Gender.female:
        return 45.5 + (2.3 * (heightCmAdjusted / 2.54));
      case Gender.other:
        // Use average of male and female formulas
        final male = 50 + (2.3 * (heightCmAdjusted / 2.54));
        final female = 45.5 + (2.3 * (heightCmAdjusted / 2.54));
        return (male + female) / 2;
    }
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gender': gender.index,
      'weightKg': weightKg,
      'heightCm': heightCm,
      'ageYears': ageYears,
      'dosageStrategy': dosageStrategy.index,
      'lastUpdated': lastUpdated.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory DosageCalculatorUser.fromJson(Map<String, dynamic> json) {
    return DosageCalculatorUser(
      id: json['id'] as String,
      gender: Gender.values[json['gender'] as int],
      weightKg: (json['weightKg'] as num).toDouble(),
      heightCm: (json['heightCm'] as num).toDouble(),
      ageYears: json['ageYears'] as int,
      dosageStrategy: json['dosageStrategy'] != null 
          ? DosageStrategy.values[json['dosageStrategy'] as int]
          : DosageStrategy.optimal, // Default for backward compatibility
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  // Database serialization
  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'gender': gender.index,
      'weightKg': weightKg,
      'heightCm': heightCm,
      'ageYears': ageYears,
      'dosageStrategy': dosageStrategy.index,
      'lastUpdated': lastUpdated.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory DosageCalculatorUser.fromDatabase(Map<String, dynamic> map) {
    return DosageCalculatorUser(
      id: map['id'] as String,
      gender: Gender.values[map['gender'] as int],
      weightKg: (map['weightKg'] as num).toDouble(),
      heightCm: (map['heightCm'] as num).toDouble(),
      ageYears: map['ageYears'] as int,
      dosageStrategy: map['dosageStrategy'] != null 
          ? DosageStrategy.values[map['dosageStrategy'] as int]
          : DosageStrategy.optimal, // Default for backward compatibility
      lastUpdated: DateTime.parse(map['lastUpdated'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  // Copy with method
  DosageCalculatorUser copyWith({
    String? id,
    Gender? gender,
    double? weightKg,
    double? heightCm,
    int? ageYears,
    DosageStrategy? dosageStrategy,
    DateTime? lastUpdated,
    DateTime? createdAt,
  }) {
    return DosageCalculatorUser(
      id: id ?? this.id,
      gender: gender ?? this.gender,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      ageYears: ageYears ?? this.ageYears,
      dosageStrategy: dosageStrategy ?? this.dosageStrategy,
      lastUpdated: lastUpdated ?? DateTime.now(),
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DosageCalculatorUser && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'DosageCalculatorUser(id: $id, gender: $genderDisplayName, weight: $formattedWeight, height: $formattedHeight, age: $formattedAge)';
  }

  // Validation methods
  bool get isValidWeight => weightKg >= 20 && weightKg <= 300;
  bool get isValidHeight => heightCm >= 100 && heightCm <= 250;
  bool get isValidAge => ageYears >= 18 && ageYears <= 120;
  bool get isValid => isValidWeight && isValidHeight && isValidAge;

  // Risk assessment based on age and BMI
  String get healthRiskAssessment {
    final bmiValue = bmi;
    
    if (ageYears >= 65) {
      return 'Erhöhtes Risiko aufgrund des Alters';
    }
    
    if (bmiValue < 18.5 || bmiValue >= 30) {
      return 'Erhöhtes Risiko aufgrund des BMI';
    }
    
    return 'Normales Risiko';
  }

  // Get dosage adjustment factor based on user characteristics
  double getDosageAdjustmentFactor() {
    double factor = 1.0;
    
    // Age adjustment
    if (ageYears >= 65) {
      factor *= 0.8; // Reduce dosage for elderly
    } else if (ageYears < 25) {
      factor *= 1.1; // Slightly increase for young adults
    }
    
    // BMI adjustment
    final bmiValue = bmi;
    if (bmiValue < 18.5) {
      factor *= 0.9; // Reduce for underweight
    } else if (bmiValue >= 30) {
      factor *= 1.1; // Increase for obese
    }
    
    // Gender adjustment (for certain substances)
    if (gender == Gender.female) {
      factor *= 0.9; // Generally lower dosage for females
    }
    
    return factor.clamp(0.5, 1.5); // Limit adjustment range
  }

  // Calculate recommended dose with strategy applied
  double getRecommendedDose(double calculatedDose) {
    return calculatedDose * (1.0 - dosageStrategy.reductionPercentage);
  }

  // Get formatted recommended dose string with percentage
  String getFormattedRecommendedDose(double calculatedDose) {
    final recommendedDose = getRecommendedDose(calculatedDose);
    final percentage = dosageStrategy.percentageDisplay;
    return '${recommendedDose.toStringAsFixed(1)} mg';
  }

  // Get dosage label with percentage
  String getDosageLabel() {
    final percentage = dosageStrategy.percentageDisplay;
    if (percentage == 0) {
      return 'Optimale Dosis:';
    }
    return 'Optimale Dosis (-$percentage%):';
  }
}