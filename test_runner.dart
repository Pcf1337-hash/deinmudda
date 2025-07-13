import 'dart:io';
import '../lib/utils/unit_manager.dart';
import '../lib/models/substance.dart';

void main() {
  print('Running Unit Manager Tests...\n');

  // Test 1: Valid unit validation
  print('Test 1: Valid unit validation');
  final validUnits = ['mg', 'g', 'ml', 'Stück', 'IE', 'Tablette'];
  for (final unit in validUnits) {
    final isValid = UnitManager.isValidUnit(unit);
    print('  $unit: $isValid ${isValid ? "✓" : "✗"}');
  }
  print('');

  // Test 2: Invalid unit validation
  print('Test 2: Invalid unit validation');
  final invalidUnits = ['', 'invalid', '123', 'xyz'];
  for (final unit in invalidUnits) {
    final isValid = UnitManager.isValidUnit(unit);
    print('  "$unit": $isValid ${!isValid ? "✓" : "✗"}');
  }
  print('');

  // Test 3: Unit conversion
  print('Test 3: Unit conversion');
  final conversions = [
    ['1000 mg to g', 1000.0, 'mg', 'g', 1.0],
    ['1 g to mg', 1.0, 'g', 'mg', 1000.0],
    ['1000 ml to l', 1000.0, 'ml', 'l', 1.0],
    ['1 l to ml', 1.0, 'l', 'ml', 1000.0],
  ];
  
  for (final conversion in conversions) {
    final result = UnitManager.convertAmount(
      conversion[1] as double, 
      conversion[2] as String, 
      conversion[3] as String
    );
    final expected = conversion[4] as double;
    final success = (result - expected).abs() < 0.0001;
    print('  ${conversion[0]}: $result (expected: $expected) ${success ? "✓" : "✗"}');
  }
  print('');

  // Test 4: Unit categories
  print('Test 4: Unit categories');
  final unitCategories = {
    'mg': 'Masse',
    'ml': 'Volumen',
    'Stück': 'Anzahl',
    'IE': 'Internationale Einheiten',
    'Bong': 'Benutzerdefiniert',
  };
  
  for (final entry in unitCategories.entries) {
    final category = UnitManager.getUnitCategory(entry.key);
    final expected = entry.value;
    final success = category == expected;
    print('  ${entry.key}: $category (expected: $expected) ${success ? "✓" : "✗"}');
  }
  print('');

  // Test 5: Recommended units for categories
  print('Test 5: Recommended units for categories');
  final categoryTests = {
    SubstanceCategory.medication: ['mg', 'Tablette'],
    SubstanceCategory.supplement: ['IE', 'mg'],
    SubstanceCategory.recreational: ['Joint', 'Bong'],
  };
  
  for (final entry in categoryTests.entries) {
    final recommended = UnitManager.getRecommendedUnitsForCategory(entry.key);
    final requiredUnits = entry.value;
    final hasAll = requiredUnits.every((unit) => recommended.contains(unit));
    print('  ${entry.key.name}: ${recommended.join(', ')} ${hasAll ? "✓" : "✗"}');
  }
  print('');

  // Test 6: Default substances with new units
  print('Test 6: Default substances with new units');
  final defaultSubstances = Substance.getDefaultSubstances();
  final unitsUsed = defaultSubstances.map((s) => s.defaultUnit).toSet().toList()..sort();
  print('  Units used in default substances: ${unitsUsed.join(', ')}');
  
  // Check if IE and Stück are present
  final hasIE = unitsUsed.contains('IE');
  final hasStück = unitsUsed.contains('Stück');
  print('  Has IE: $hasIE ${hasIE ? "✓" : "✗"}');
  print('  Has Stück: $hasStück ${hasStück ? "✓" : "✗"}');
  print('');

  // Test 7: Unit validation
  print('Test 7: Unit validation');
  final validationTests = {
    'mg': null,
    'Stück': null,
    'IE': null,
    '': 'should have error',
    'invalid': 'should have error',
  };
  
  for (final entry in validationTests.entries) {
    final error = UnitManager.validateUnit(entry.key);
    final expectError = entry.value != null;
    final success = expectError ? (error != null) : (error == null);
    print('  "${entry.key}": ${error ?? "null"} ${success ? "✓" : "✗"}');
  }
  print('');

  print('All tests completed!');
}