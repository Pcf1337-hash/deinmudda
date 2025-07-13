import 'package:flutter_test/flutter_test.dart';
import 'package:konsum_tracker_pro/utils/unit_manager.dart';
import 'package:konsum_tracker_pro/models/substance.dart';

void main() {
  group('UnitManager Tests', () {
    test('should validate valid units', () {
      expect(UnitManager.isValidUnit('mg'), true);
      expect(UnitManager.isValidUnit('g'), true);
      expect(UnitManager.isValidUnit('ml'), true);
      expect(UnitManager.isValidUnit('Stück'), true);
      expect(UnitManager.isValidUnit('IE'), true);
      expect(UnitManager.isValidUnit('Tablette'), true);
    });

    test('should reject invalid units', () {
      expect(UnitManager.isValidUnit(''), false);
      expect(UnitManager.isValidUnit('invalid'), false);
      expect(UnitManager.isValidUnit('123'), false);
    });

    test('should convert units correctly', () {
      expect(UnitManager.convertAmount(1000, 'mg', 'g'), 1.0);
      expect(UnitManager.convertAmount(1, 'g', 'mg'), 1000.0);
      expect(UnitManager.convertAmount(1000, 'ml', 'l'), 1.0);
      expect(UnitManager.convertAmount(1, 'l', 'ml'), 1000.0);
    });

    test('should handle same unit conversion', () {
      expect(UnitManager.convertAmount(100, 'mg', 'mg'), 100.0);
      expect(UnitManager.convertAmount(50, 'Stück', 'Stück'), 50.0);
    });

    test('should check if units are convertible', () {
      expect(UnitManager.areUnitsConvertible('mg', 'g'), true);
      expect(UnitManager.areUnitsConvertible('ml', 'l'), true);
      expect(UnitManager.areUnitsConvertible('mg', 'ml'), false);
      expect(UnitManager.areUnitsConvertible('Stück', 'Tablette'), false);
    });

    test('should get recommended units for categories', () {
      final medicationUnits = UnitManager.getRecommendedUnitsForCategory(SubstanceCategory.medication);
      expect(medicationUnits.contains('mg'), true);
      expect(medicationUnits.contains('Tablette'), true);
      
      final supplementUnits = UnitManager.getRecommendedUnitsForCategory(SubstanceCategory.supplement);
      expect(supplementUnits.contains('IE'), true);
      expect(supplementUnits.contains('mg'), true);
      
      final recreationalUnits = UnitManager.getRecommendedUnitsForCategory(SubstanceCategory.recreational);
      expect(recreationalUnits.contains('Joint'), true);
      expect(recreationalUnits.contains('Bong'), true);
    });

    test('should validate units properly', () {
      expect(UnitManager.validateUnit('mg'), null);
      expect(UnitManager.validateUnit('Stück'), null);
      expect(UnitManager.validateUnit('IE'), null);
      expect(UnitManager.validateUnit(''), isNotNull);
      expect(UnitManager.validateUnit('invalid'), isNotNull);
    });

    test('should get unit categories', () {
      expect(UnitManager.getUnitCategory('mg'), 'Masse');
      expect(UnitManager.getUnitCategory('ml'), 'Volumen');
      expect(UnitManager.getUnitCategory('Stück'), 'Anzahl');
      expect(UnitManager.getUnitCategory('IE'), 'Internationale Einheiten');
      expect(UnitManager.getUnitCategory('Bong'), 'Benutzerdefiniert');
    });
  });

  group('Substance Model Tests', () {
    test('should create substance with valid units', () {
      final substance = Substance.create(
        name: 'Test Substance',
        category: SubstanceCategory.medication,
        defaultRiskLevel: RiskLevel.low,
        pricePerUnit: 0.1,
        defaultUnit: 'mg',
      );

      expect(substance.defaultUnit, 'mg');
      expect(substance.name, 'Test Substance');
    });

    test('should handle unit conversion in substance model', () {
      final substance = Substance.create(
        name: 'Test Substance',
        category: SubstanceCategory.medication,
        defaultRiskLevel: RiskLevel.low,
        pricePerUnit: 0.1,
        defaultUnit: 'g',
      );

      expect(substance.convertToStandardUnit(1000, 'mg'), 1.0);
      expect(substance.convertToStandardUnit(1, 'g'), 1.0);
    });
  });
}