import 'package:flutter/material.dart';
import 'dosage_calculator_substance.dart';

/// Enhanced substance model that includes additional information
/// from the enhanced substances JSON file for richer dosage tiles
class EnhancedSubstance extends DosageCalculatorSubstance {
  final String chemicalEffect;
  final List<String> interactions;
  final List<String> sideEffects;

  EnhancedSubstance({
    required super.name,
    required super.lightDosePerKg,
    required super.normalDosePerKg,
    required super.strongDosePerKg,
    required super.administrationRoute,
    required super.duration,
    required super.safetyNotes,
    required this.chemicalEffect,
    required this.interactions,
    required this.sideEffects,
    super.createdAt,
    super.updatedAt,
  });

  /// Get abbreviated chemical effect for display on tiles
  String get abbreviatedChemicalEffect {
    if (chemicalEffect.length <= 80) return chemicalEffect;
    
    // Find last complete sentence within 80 characters
    int cutoff = chemicalEffect.substring(0, 80).lastIndexOf('.');
    if (cutoff == -1) {
      cutoff = chemicalEffect.substring(0, 80).lastIndexOf(' ');
    }
    
    return cutoff > 0 
        ? chemicalEffect.substring(0, cutoff + 1)
        : '${chemicalEffect.substring(0, 77)}...';
  }

  /// Get the most critical side effects (first 2-3)
  List<String> get keySideEffects {
    return sideEffects.take(3).toList();
  }

  /// Get the most important interactions (first 2)
  List<String> get keyInteractions {
    return interactions.take(2).toList();
  }

  /// Get risk level based on substance characteristics
  RiskLevel get riskLevel {
    final substanceName = name.toLowerCase();
    
    // High risk substances
    if (substanceName.contains('kokain') || 
        substanceName.contains('cocaine') ||
        substanceName.contains('heroin') ||
        substanceName.contains('fentanyl')) {
      return RiskLevel.high;
    }
    
    // Medium-high risk
    if (substanceName.contains('ketamin') ||
        substanceName.contains('mdma') ||
        substanceName.contains('amphetamin')) {
      return RiskLevel.mediumHigh;
    }
    
    // Medium risk
    if (substanceName.contains('lsd') ||
        substanceName.contains('cannabis') ||
        substanceName.contains('psilocybin')) {
      return RiskLevel.medium;
    }
    
    // Low risk for things like caffeine, paracetamol
    return RiskLevel.low;
  }

  /// Get abbreviated safety notes for display
  String get abbreviatedSafetyNotes {
    if (safetyNotes.length <= 100) return safetyNotes;
    
    int cutoff = safetyNotes.substring(0, 100).lastIndexOf('.');
    if (cutoff == -1) {
      cutoff = safetyNotes.substring(0, 100).lastIndexOf(' ');
    }
    
    return cutoff > 0 
        ? safetyNotes.substring(0, cutoff + 1)
        : '${safetyNotes.substring(0, 97)}...';
  }

  /// Factory constructor from enhanced JSON data
  factory EnhancedSubstance.fromEnhancedJson(Map<String, dynamic> json) {
    return EnhancedSubstance(
      name: json['name'] as String,
      lightDosePerKg: (json['lightDosePerKg'] as num).toDouble(),
      normalDosePerKg: (json['normalDosePerKg'] as num).toDouble(),
      strongDosePerKg: (json['strongDosePerKg'] as num).toDouble(),
      administrationRoute: json['administrationRoute'] as String,
      duration: json['duration'] as String,
      safetyNotes: json['safetyNotes'] as String,
      chemicalEffect: json['chemicalEffect'] as String? ?? '',
      interactions: List<String>.from(json['interactions'] as List? ?? []),
      sideEffects: List<String>.from(json['sideEffects'] as List? ?? []),
    );
  }

  /// Convert to JSON including enhanced data
  @override
  Map<String, dynamic> toJson() {
    final base = super.toJson();
    base.addAll({
      'chemicalEffect': chemicalEffect,
      'interactions': interactions,
      'sideEffects': sideEffects,
    });
    return base;
  }
}

/// Risk levels for substances
enum RiskLevel {
  low,
  medium,
  mediumHigh,
  high;

  /// Get display name for risk level
  String get displayName {
    switch (this) {
      case RiskLevel.low:
        return 'Niedrig';
      case RiskLevel.medium:
        return 'Mittel';
      case RiskLevel.mediumHigh:
        return 'Mittel-Hoch';
      case RiskLevel.high:
        return 'Hoch';
    }
  }

  /// Get color for risk level
  Color get color {
    switch (this) {
      case RiskLevel.low:
        return const Color(0xFF4CAF50); // Green
      case RiskLevel.medium:
        return const Color(0xFFFF9800); // Orange
      case RiskLevel.mediumHigh:
        return const Color(0xFFFF5722); // Deep Orange
      case RiskLevel.high:
        return const Color(0xFFF44336); // Red
    }
  }

  /// Get icon for risk level
  IconData get icon {
    switch (this) {
      case RiskLevel.low:
        return Icons.check_circle;
      case RiskLevel.medium:
        return Icons.warning_amber;
      case RiskLevel.mediumHigh:
        return Icons.warning;
      case RiskLevel.high:
        return Icons.dangerous;
    }
  }
}