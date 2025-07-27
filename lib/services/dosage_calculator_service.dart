import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import '../models/dosage_calculator_user.dart';
import '../models/dosage_calculator_substance.dart';
import '../widgets/dosage_calculator/dosage_result_card.dart';
import '../utils/service_locator.dart'; // refactored by ArchitekturAgent
import 'database_service.dart';

class DosageCalculatorService {
  late final DatabaseService _databaseService = ServiceLocator.get<DatabaseService>(); // refactored by ArchitekturAgent

  // User Profile Management
  
  // Create user profile
  Future<String> createUserProfile(DosageCalculatorUser user) async {
    try {
      final db = await _databaseService.database;
      await db.insert(
        'dosage_calculator_users',
        user.toDatabase(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return user.id;
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }

  // Get user profile
  Future<DosageCalculatorUser?> getUserProfile() async {
    try {
      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'dosage_calculator_users',
        orderBy: 'lastUpdated DESC',
        limit: 1,
      );
      
      if (maps.isEmpty) return null;
      return DosageCalculatorUser.fromDatabase(maps.first);
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  // Update user profile
  Future<void> updateUserProfile(DosageCalculatorUser user) async {
    try {
      final db = await _databaseService.database;
      final updatedUser = user.copyWith(lastUpdated: DateTime.now());
      
      await db.update(
        'dosage_calculator_users',
        updatedUser.toDatabase(),
        where: 'id = ?',
        whereArgs: [user.id],
      );
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  // Delete user profile
  Future<void> deleteUserProfile(String id) async {
    try {
      final db = await _databaseService.database;
      await db.delete(
        'dosage_calculator_users',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to delete user profile: $e');
    }
  }

  // BMI Calculations
  
  // Calculate BMI
  double calculateBMI(double weightKg, double heightCm) {
    if (weightKg <= 0 || heightCm <= 0) return 0.0;
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  // Get BMI category
  String getBMICategory(double bmi) {
    if (bmi < 18.5) {
      return 'Untergewicht';
    } else if (bmi < 25.0) {
      return 'Normalgewicht';
    } else if (bmi < 30.0) {
      return 'Übergewicht';
    } else if (bmi < 35.0) {
      return 'Adipositas Grad I';
    } else if (bmi < 40.0) {
      return 'Adipositas Grad II';
    } else {
      return 'Adipositas Grad III';
    }
  }

  // Get BMI color category for UI
  String getBMIColorCategory(double bmi) {
    if (bmi < 18.5) {
      return 'underweight';
    } else if (bmi < 25.0) {
      return 'normal';
    } else if (bmi < 30.0) {
      return 'overweight';
    } else {
      return 'obese';
    }
  }

  // Check if BMI is healthy
  bool isHealthyBMI(double bmi) {
    return bmi >= 18.5 && bmi < 25.0;
  }

  // Dosage Calculator Substances Management
  
  // Get all dosage calculator substances
  Future<List<DosageCalculatorSubstance>> getAllDosageSubstances() async {
    try {
      try {
        // Load from JSON file instead of database
        final jsonString = await rootBundle.loadString('assets/data/dosage_calculator_substances_enhanced.json');
        final List<dynamic> jsonList = jsonDecode(jsonString);
        
        return jsonList.map((json) {
          return DosageCalculatorSubstance(
            name: json['name'] as String,
            lightDosePerKg: (json['lightDosePerKg'] as num).toDouble(),
            normalDosePerKg: (json['normalDosePerKg'] as num).toDouble(),
            strongDosePerKg: (json['strongDosePerKg'] as num).toDouble(),
            administrationRoute: json['administrationRoute'] as String,
            duration: json['duration'] as String,
            safetyNotes: json['safetyNotes'] as String,
          );
        }).toList();
      } catch (e) {
        print('Error loading enhanced substances: $e');
        // Fallback to default substances
        return _getDefaultDosageSubstances();
      }
    } catch (e) {
      print('Critical error in getAllDosageSubstances: $e');
      // Return default substances as fallback
      return _getDefaultDosageSubstances();
    }
  }

  // Get default dosage calculator substances
  List<DosageCalculatorSubstance> _getDefaultDosageSubstances() {
    return [
      DosageCalculatorSubstance(
        name: 'MDMA',
        lightDosePerKg: 1.0,
        normalDosePerKg: 1.5,
        strongDosePerKg: 2.5,
        administrationRoute: 'oral',
        duration: '4-6 Stunden',
        safetyNotes: 'Ausreichend trinken, Pausen einhalten, nicht mit anderen Stimulanzien kombinieren',
      ),
      DosageCalculatorSubstance(
        name: 'LSD',
        lightDosePerKg: 0.7,
        normalDosePerKg: 1.4,
        strongDosePerKg: 2.1,
        administrationRoute: 'oral',
        duration: '8-12 Stunden',
        safetyNotes: 'Set & Setting beachten, Tripsitter empfohlen, nicht bei psychischen Problemen',
      ),
      DosageCalculatorSubstance(
        name: 'Ketamin',
        lightDosePerKg: 0.3,
        normalDosePerKg: 0.6,
        strongDosePerKg: 1.0,
        administrationRoute: 'nasal',
        duration: '45-90 Minuten',
        safetyNotes: 'Nicht im Stehen konsumieren, K-Hole Gefahr bei hohen Dosen',
      ),
      DosageCalculatorSubstance(
        name: 'Kokain',
        lightDosePerKg: 0.4,
        normalDosePerKg: 0.8,
        strongDosePerKg: 1.4,
        administrationRoute: 'nasal',
        duration: '30-60 Minuten',
        safetyNotes: 'Hohes Suchtpotential, Herzprobleme möglich, nicht mit Alkohol',
      ),
    ];
  }

  // Get popular substances
  Future<List<DosageCalculatorSubstance>> getPopularSubstances({int limit = 10}) async {
    try {
      try {
        final substances = await getAllDosageSubstances();
        // For now, return first N substances
        // In the future, this could be based on usage statistics
        return substances.take(limit).toList();
      } catch (e) {
        print('Error getting popular substances: $e');
        // Return default substances as fallback
        return _getDefaultDosageSubstances().take(limit).toList();
      }
    } catch (e) {
      print('Critical error in getPopularSubstances: $e');
      // Return default substances as fallback
      return _getDefaultDosageSubstances().take(limit).toList();
    }
  }

  // Get dosage calculation history (if we implement history tracking)
  Future<List<Map<String, dynamic>>> getDosageCalculationHistory() async {
    // This would require a separate table for calculation history
    // For now, return empty list
    return [];
  }

  // Validate user profile data
  Map<String, String> validateUserProfile({
    required Gender gender,
    required double weightKg,
    required double heightCm,
    required int ageYears,
  }) {
    final Map<String, String> errors = {};
    
    if (weightKg < 30 || weightKg > 300) {
      errors['weight'] = 'Gewicht muss zwischen 30 und 300 kg liegen';
    }
    
    if (heightCm < 100 || heightCm > 250) {
      errors['height'] = 'Größe muss zwischen 100 und 250 cm liegen';
    }
    
    if (ageYears < 18 || ageYears > 100) {
      errors['age'] = 'Alter muss zwischen 18 und 100 Jahren liegen';
    }
    
    final bmi = calculateBMI(weightKg, heightCm);
    if (bmi < 15 || bmi > 50) {
      errors['bmi'] = 'BMI liegt außerhalb des sicheren Bereichs';
    }
    
    return errors;
  }

  // Get safety warnings for dosage
  List<String> getSafetyWarnings(DosageCalculation calculation) {
    final List<String> warnings = [];
    
    // General warnings
    warnings.add('Diese Berechnungen sind nur Richtwerte und ersetzen keine medizinische Beratung.');
    warnings.add('Beginnen Sie immer mit der niedrigsten Dosis.');
    warnings.add('Warten Sie die volle Wirkdauer ab, bevor Sie nachdosieren.');
    
    // Substance-specific warnings
    if (calculation.substance.toLowerCase().contains('mdma')) {
      warnings.add('MDMA: Mindestens 3 Monate Pause zwischen den Anwendungen einhalten.');
      warnings.add('Ausreichend Wasser trinken, aber nicht übertreiben (max. 500ml/Stunde).');
    }
    
    if (calculation.substance.toLowerCase().contains('lsd')) {
      warnings.add('LSD: Set & Setting sind entscheidend für eine sichere Erfahrung.');
      warnings.add('Tripsitter empfohlen, besonders bei höheren Dosen.');
    }
    
    if (calculation.substance.toLowerCase().contains('ketamin')) {
      warnings.add('Ketamin: Nicht im Stehen konsumieren, Sturzgefahr.');
      warnings.add('K-Hole möglich bei hohen Dosen - sichere Umgebung wichtig.');
    }
    
    if (calculation.substance.toLowerCase().contains('kokain')) {
      warnings.add('Kokain: Hohes Suchtpotential und Herzrisiko.');
      warnings.add('Niemals mit Alkohol oder anderen Stimulanzien kombinieren.');
    }
    
    if (calculation.substance.toLowerCase().contains('alkohol')) {
      warnings.add('Alkohol: Nicht fahren oder Maschinen bedienen.');
      warnings.add('Ausreichend essen und Wasser trinken.');
    }
    
    // High dose warnings
    if (calculation.strongDose > calculation.normalDose * 1.5) {
      warnings.add('WARNUNG: Starke Dosis - nur für erfahrene Nutzer empfohlen.');
    }
    
    return warnings;
  }

  // Get administration route recommendations
  Map<String, String> getAdministrationRouteInfo(String route) {
    switch (route.toLowerCase()) {
      case 'oral':
        return {
          'name': 'Oral (Schlucken)',
          'onset': '30-90 Minuten',
          'tips': 'Mit Wasser einnehmen, nicht auf nüchternen Magen',
        };
      case 'nasal':
        return {
          'name': 'Nasal (Schnupfen)',
          'onset': '5-15 Minuten',
          'tips': 'Saubere Utensilien verwenden, Nasenschleimhaut schonen',
        };
      case 'sublingual':
        return {
          'name': 'Sublingual (Unter der Zunge)',
          'onset': '15-30 Minuten',
          'tips': 'Unter der Zunge halten, nicht schlucken',
        };
      case 'inhalation':
        return {
          'name': 'Inhalation (Rauchen/Verdampfen)',
          'onset': '1-5 Minuten',
          'tips': 'Langsam und kontrolliert inhalieren',
        };
      default:
        return {
          'name': route,
          'onset': 'Unbekannt',
          'tips': 'Informieren Sie sich über die sichere Anwendung',
        };
    }
  }

  // Format dosage value
  String formatDosage(double dosage) {
    if (dosage < 1) {
      return '${(dosage * 1000).toStringAsFixed(0)}µg';
    } else if (dosage < 1000) {
      return '${dosage.toStringAsFixed(1)}mg';
    } else {
      return '${(dosage / 1000).toStringAsFixed(2)}g';
    }
  }

  // Check if user profile exists
  Future<bool> hasUserProfile() async {
    try {
      final profile = await getUserProfile();
      return profile != null;
    } catch (e) {
      return false;
    }
  }

  // Get recommended starting dose
  double getRecommendedStartingDose(DosageCalculation calculation) {
    // Always recommend starting with light dose
    return calculation.lightDose;
  }

  // Check if substance requires special precautions
  bool requiresSpecialPrecautions(String substanceName) {
    final highRiskSubstances = [
      'mdma', 'lsd', 'ketamin', 'kokain', '2c-b', 'psilocybin'
    ];
    
    return highRiskSubstances.any(
      (substance) => substanceName.toLowerCase().contains(substance)
    );
  }
}