import '../models/substance.dart';

/// Utility class for managing and converting measurement units.
/// 
/// Provides comprehensive unit management including validation,
/// conversion between compatible units, and categorization of
/// different measurement types used in substance tracking.
class UnitManager {
  /// Private constructor to prevent instantiation
  const UnitManager._();
  
  // Common units organized by category
  static const List<String> _massUnits = ['mg', 'g', 'kg'];
  static const List<String> _volumeUnits = ['ml', 'l'];
  static const List<String> _countUnits = ['Stück', 'Tablette', 'Kapsel', 'Tropfen'];
  static const List<String> _internationalUnits = ['IE', 'IU'];
  static const List<String> _customUnits = ['Flasche', 'Bong', 'Joint', 'Zug', 'Portion'];

  /// All predefined valid units available in the system.
  static List<String> get validUnits => [
    ..._massUnits,
    ..._volumeUnits,
    ..._countUnits,
    ..._internationalUnits,
    ..._customUnits,
  ];

  /// Validates if a unit string is among the predefined valid units.
  static bool isValidUnit(String unit) {
    if (unit.trim().isEmpty) return false;
    return validUnits.contains(unit.trim());
  }

  /// Retrieves all units currently used by substances in the database.
  static Future<List<String>> getUsedUnits(List<Substance> substances) async {
    final usedUnits = <String>{};
    
    for (final substance in substances) {
      if (substance.defaultUnit.isNotEmpty) {
        usedUnits.add(substance.defaultUnit);
      }
    }
    
    return usedUnits.toList()..sort();
  }

  /// Provides suggested units combining commonly used and database units.
  /// 
  /// Returns a comprehensive list of units including predefined common units
  /// and any custom units already in use in the database.
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

  /// Checks if a specific unit is already used by any substance in the database.
  static Future<bool> unitExists(String unit, List<Substance> substances) async {
    final usedUnits = await getUsedUnits(substances);
    return usedUnits.contains(unit.trim());
  }

  /// Calculates conversion factor between two compatible units.
  /// 
  /// Returns the multiplication factor to convert from [fromUnit] to [toUnit].
  /// Returns 1.0 for identical units or non-convertible unit pairs.
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

    return 1.0;
  }

  /// Converts an amount from one unit to another compatible unit.
  /// 
  /// Multiplies the [amount] by the conversion factor between [fromUnit] and [toUnit].
  static double convertAmount(double amount, String fromUnit, String toUnit) {
    final factor = getConversionFactor(fromUnit, toUnit);
    return amount * factor;
  }

  /// Determines if two units can be converted between each other.
  /// 
  /// Returns true for identical units or units within the same category
  /// (e.g., both mass units or both volume units).
  static bool areUnitsConvertible(String unit1, String unit2) {
    // Same unit
    if (unit1 == unit2) return true;

    // Mass units
    if (_massUnits.contains(unit1) && _massUnits.contains(unit2)) return true;

    // Volume units
    if (_volumeUnits.contains(unit1) && _volumeUnits.contains(unit2)) return true;

    return false;
  }

  /// Returns the localized category name for a given unit.
  /// 
  /// Categorizes units into groups like 'Masse', 'Volumen', etc.
  /// for better organization in user interfaces.
  static String getUnitCategory(String unit) {
    if (_massUnits.contains(unit)) return 'Masse';
    if (_volumeUnits.contains(unit)) return 'Volumen';
    if (_countUnits.contains(unit)) return 'Anzahl';
    if (_internationalUnits.contains(unit)) return 'Internationale Einheiten';
    if (_customUnits.contains(unit)) return 'Benutzerdefiniert';
    return 'Unbekannt';
  }

  /// Returns a display-friendly name combining unit and category.
  static String getUnitDisplayName(String unit) {
    final category = getUnitCategory(unit);
    return '$unit ($category)';
  }

  /// Validates unit input returning error message or null if valid.
  /// 
  /// Used for form validation to ensure user enters acceptable units.
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

  /// Provides recommended units for specific substance categories.
  /// 
  /// Returns a curated list of the most appropriate units for each
  /// substance category to improve user experience during data entry.
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

  /// Calculates mass unit conversion factor using milligrams as base unit.
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

  /// Calculates volume unit conversion factor using milliliters as base unit.
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

// hints reduziert durch HintOptimiererAgent