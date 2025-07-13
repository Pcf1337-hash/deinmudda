// Simple verification script to check the implementation
// This simulates the main functionality without running the full app

class MockSubstance {
  final String name;
  final String defaultUnit;
  
  MockSubstance({required this.name, required this.defaultUnit});
}

class MockUnitManager {
  static const List<String> _massUnits = ['mg', 'g', 'kg'];
  static const List<String> _volumeUnits = ['ml', 'l'];
  static const List<String> _countUnits = ['Stück', 'Tablette', 'Kapsel', 'Tropfen'];
  static const List<String> _internationalUnits = ['IE', 'IU'];
  static const List<String> _customUnits = ['Flasche', 'Bong', 'Joint', 'Zug', 'Portion'];

  static List<String> get validUnits => [
    ..._massUnits,
    ..._volumeUnits,
    ..._countUnits,
    ..._internationalUnits,
    ..._customUnits,
  ];

  static bool isValidUnit(String unit) {
    if (unit.trim().isEmpty) return false;
    return validUnits.contains(unit.trim());
  }

  static double convertAmount(double amount, String fromUnit, String toUnit) {
    if (fromUnit == toUnit) return amount;
    
    if (_massUnits.contains(fromUnit) && _massUnits.contains(toUnit)) {
      return _getMassConversion(amount, fromUnit, toUnit);
    }
    
    if (_volumeUnits.contains(fromUnit) && _volumeUnits.contains(toUnit)) {
      return _getVolumeConversion(amount, fromUnit, toUnit);
    }
    
    return amount;
  }

  static double _getMassConversion(double amount, String fromUnit, String toUnit) {
    const Map<String, double> massToMg = {
      'mg': 1.0,
      'g': 1000.0,
      'kg': 1000000.0,
    };

    final fromFactor = massToMg[fromUnit] ?? 1.0;
    final toFactor = massToMg[toUnit] ?? 1.0;

    return amount * fromFactor / toFactor;
  }

  static double _getVolumeConversion(double amount, String fromUnit, String toUnit) {
    const Map<String, double> volumeToMl = {
      'ml': 1.0,
      'l': 1000.0,
    };

    final fromFactor = volumeToMl[fromUnit] ?? 1.0;
    final toFactor = volumeToMl[toUnit] ?? 1.0;

    return amount * fromFactor / toFactor;
  }
}

void runTests() {
  print('Running Unit Manager Verification...\n');

  // Test 1: Valid unit validation
  print('Test 1: Valid unit validation');
  final validUnits = ['mg', 'g', 'ml', 'Stück', 'IE', 'Tablette'];
  for (final unit in validUnits) {
    final isValid = MockUnitManager.isValidUnit(unit);
    print('  $unit: $isValid ${isValid ? "✓" : "✗"}');
  }
  print('');

  // Test 2: Invalid unit validation
  print('Test 2: Invalid unit validation');
  final invalidUnits = ['', 'invalid', '123', 'xyz'];
  for (final unit in invalidUnits) {
    final isValid = MockUnitManager.isValidUnit(unit);
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
    final result = MockUnitManager.convertAmount(
      conversion[1] as double, 
      conversion[2] as String, 
      conversion[3] as String
    );
    final expected = conversion[4] as double;
    final success = (result - expected).abs() < 0.0001;
    print('  ${conversion[0]}: $result (expected: $expected) ${success ? "✓" : "✗"}');
  }
  print('');

  // Test 4: Valid units list
  print('Test 4: Valid units list');
  final allValidUnits = MockUnitManager.validUnits;
  print('  Valid units: ${allValidUnits.join(', ')}');
  print('  Total count: ${allValidUnits.length}');
  print('  Has IE: ${allValidUnits.contains('IE')} ${allValidUnits.contains('IE') ? "✓" : "✗"}');
  print('  Has Stück: ${allValidUnits.contains('Stück')} ${allValidUnits.contains('Stück') ? "✓" : "✗"}');
  print('');

  print('All tests completed!');
}

void main() {
  runTests();
}