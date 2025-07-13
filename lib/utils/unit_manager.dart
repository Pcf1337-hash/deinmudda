import '../models/substance.dart';

/// Utility class for managing units in the substance tracker
class UnitManager {
  // Common units organized by category
  static const List<String> _massUnits = ['mg', 'g', 'kg'];
  static const List<String> _volumeUnits = ['ml', 'l'];
  static const List<String> _countUnits = ['Stück', 'Tablette', 'Kapsel', 'Tropfen'];
  static const List<String> _internationalUnits = ['IE', 'IU'];
  static const List<String> _customUnits = ['Flasche', 'Bong', 'Joint', 'Zug', 'Portion'];

  /// All predefined valid units
  static List<String> get validUnits => [
    ..._massUnits,
    ..._volumeUnits,
    ..._countUnits,
    ..._internationalUnits,
    ..._customUnits,
  ];

  /// Check if a unit is valid
  static bool isValidUnit(String unit) {
    if (unit.trim().isEmpty) return false;
    return validUnits.contains(unit.trim());
  }

  /// Get all units currently used in the database
  static Future<List<String>> getUsedUnits(List<Substance> substances) async {
    final usedUnits = <String>{};
    
    for (final substance in substances) {
      if (substance.defaultUnit.isNotEmpty) {
        usedUnits.add(substance.defaultUnit);
      }
    }
    
    return usedUnits.toList()..sort();
  }

  /// Get suggested units (combination of used and common units)
  static Future<List<String>> getSuggestedUnits(List<Substance> substances) async {
    final usedUnits = await getUsedUnits(substances);
    final suggested = <String>{};
    
    // Add commonly used units first
    suggested.addAll(_massUnits);
    suggested.addAll(_volumeUnits);
    suggested.addAll(_countUnits);
    suggested.addAll(_internationalUnits);
    
    // Add units that are already in use
    suggested.addAll(usedUnits);
    
    // Add custom units
    suggested.addAll(_customUnits);
    
    return suggested.toList()..sort();
  }

  /// Check if a unit already exists in the database
  static Future<bool> unitExists(String unit, List<Substance> substances) async {
    final usedUnits = await getUsedUnits(substances);
    return usedUnits.contains(unit.trim());
  }

  /// Get conversion factor between two units
  static double getConversionFactor(String fromUnit, String toUnit) {
    // Handle same unit
    if (fromUnit == toUnit) return 1.0;

    // Mass conversions
    if (_massUnits.contains(fromUnit) && _massUnits.contains(toUnit)) {
      return _getMassConversion(fromUnit, toUnit);
    }

    // Volume conversions
    if (_volumeUnits.contains(fromUnit) && _volumeUnits.contains(toUnit)) {
      return _getVolumeConversion(fromUnit, toUnit);
    }

    // For non-convertible units, return 1.0 (no conversion)
    return 1.0;
  }

  /// Convert amount from one unit to another
  static double convertAmount(double amount, String fromUnit, String toUnit) {
    final factor = getConversionFactor(fromUnit, toUnit);
    return amount * factor;
  }

  /// Check if two units are convertible
  static bool areUnitsConvertible(String unit1, String unit2) {
    // Same unit
    if (unit1 == unit2) return true;

    // Mass units
    if (_massUnits.contains(unit1) && _massUnits.contains(unit2)) return true;

    // Volume units
    if (_volumeUnits.contains(unit1) && _volumeUnits.contains(unit2)) return true;

    // Non-convertible units
    return false;
  }

  /// Get unit category for display purposes
  static String getUnitCategory(String unit) {
    if (_massUnits.contains(unit)) return 'Masse';
    if (_volumeUnits.contains(unit)) return 'Volumen';
    if (_countUnits.contains(unit)) return 'Anzahl';
    if (_internationalUnits.contains(unit)) return 'Internationale Einheiten';
    if (_customUnits.contains(unit)) return 'Benutzerdefiniert';
    return 'Unbekannt';
  }

  /// Get unit display name with category
  static String getUnitDisplayName(String unit) {
    final category = getUnitCategory(unit);
    return '$unit ($category)';
  }

  /// Validate unit input
  static String? validateUnit(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bitte geben Sie eine Einheit an';
    }

    final unit = value.trim();
    
    if (!isValidUnit(unit)) {
      return 'Ungültige Einheit. Erlaubte Einheiten: ${validUnits.join(', ')}';
    }

    return null;
  }

  /// Get recommended units for a substance category
  static List<String> getRecommendedUnitsForCategory(SubstanceCategory category) {
    switch (category) {
      case SubstanceCategory.medication:
        return ['mg', 'g', 'ml', 'Tablette', 'Kapsel', 'Tropfen'];
      case SubstanceCategory.supplement:
        return ['mg', 'g', 'IE', 'Tablette', 'Kapsel'];
      case SubstanceCategory.stimulant:
        return ['mg', 'g', 'ml', 'Tablette'];
      case SubstanceCategory.depressant:
        return ['mg', 'g', 'ml'];
      case SubstanceCategory.recreational:
        return ['mg', 'g', 'ml', 'Stück', 'Joint', 'Bong'];
      case SubstanceCategory.other:
        return ['mg', 'g', 'ml', 'Stück'];
    }
  }

  // Private helper methods
  static double _getMassConversion(String fromUnit, String toUnit) {
    const Map<String, double> massToMg = {
      'mg': 1.0,
      'g': 1000.0,
      'kg': 1000000.0,
    };

    final fromFactor = massToMg[fromUnit] ?? 1.0;
    final toFactor = massToMg[toUnit] ?? 1.0;

    return fromFactor / toFactor;
  }

  static double _getVolumeConversion(String fromUnit, String toUnit) {
    const Map<String, double> volumeToMl = {
      'ml': 1.0,
      'l': 1000.0,
    };

    final fromFactor = volumeToMl[fromUnit] ?? 1.0;
    final toFactor = volumeToMl[toUnit] ?? 1.0;

    return fromFactor / toFactor;
  }
}