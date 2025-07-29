// Test for cost functionality in dosage calculator
import 'package:flutter_test/flutter_test.dart';
import 'package:konsum_tracker_pro/models/entry.dart';
import 'package:konsum_tracker_pro/use_cases/entry_use_cases.dart';

void main() {
  group('Dosage Calculator Cost Tests', () {
    test('Entry model should support cost field', () {
      // Test that Entry model properly handles cost
      final entry = Entry.create(
        substanceId: 'test-id',
        substanceName: 'Test Substance',
        dosage: 10.0,
        unit: 'mg',
        dateTime: DateTime.now(),
        cost: 25.50,
      );
      
      expect(entry.cost, equals(25.50));
      expect(entry.hasCostData, isTrue);
      expect(entry.formattedCost, equals('25,50€'));
    });

    test('Entry model should handle zero cost', () {
      final entry = Entry.create(
        substanceId: 'test-id',
        substanceName: 'Test Substance',
        dosage: 10.0,
        unit: 'mg',
        dateTime: DateTime.now(),
        cost: 0.0,
      );
      
      expect(entry.cost, equals(0.0));
      expect(entry.hasCostData, isFalse);
      expect(entry.formattedCost, equals('0,00€'));
    });

    test('Entry should serialize cost to database correctly', () {
      final entry = Entry.create(
        substanceId: 'test-id',
        substanceName: 'Test Substance',
        dosage: 10.0,
        unit: 'mg',
        dateTime: DateTime.now(),
        cost: 15.75,
      );
      
      final dbMap = entry.toDatabase();
      expect(dbMap['cost'], equals(15.75));
      
      // Test deserialization
      final deserializedEntry = Entry.fromDatabase(dbMap);
      expect(deserializedEntry.cost, equals(15.75));
      expect(deserializedEntry.formattedCost, equals('15,75€'));
    });

    test('Entry should serialize cost to JSON correctly', () {
      final entry = Entry.create(
        substanceId: 'test-id',
        substanceName: 'Test Substance',
        dosage: 10.0,
        unit: 'mg',
        dateTime: DateTime.now(),
        cost: 20.25,
      );
      
      final jsonMap = entry.toJson();
      expect(jsonMap['cost'], equals(20.25));
      
      // Test deserialization
      final deserializedEntry = Entry.fromJson(jsonMap);
      expect(deserializedEntry.cost, equals(20.25));
      expect(deserializedEntry.formattedCost, equals('20,25€'));
    });

    test('Cost formatting should use German decimal format', () {
      final entry1 = Entry.create(
        substanceId: 'test-id',
        substanceName: 'Test Substance',
        dosage: 10.0,
        unit: 'mg',
        dateTime: DateTime.now(),
        cost: 1.50,
      );
      
      final entry2 = Entry.create(
        substanceId: 'test-id',
        substanceName: 'Test Substance',
        dosage: 10.0,
        unit: 'mg',
        dateTime: DateTime.now(),
        cost: 123.99,
      );
      
      expect(entry1.formattedCost, equals('1,50€'));
      expect(entry2.formattedCost, equals('123,99€'));
    });

    test('Cost validation should work for different input formats', () {
      // Test different cost input formats that might come from user input
      final testCases = {
        '10.50': 10.50,
        '10,50': 10.50, // German decimal format
        '0': 0.0,
        '0.00': 0.0,
        '': 0.0, // Empty should default to 0
      };
      
      testCases.forEach((input, expectedCost) {
        final normalizedInput = input.replaceAll(',', '.');
        final parsedCost = normalizedInput.isEmpty ? 0.0 : double.tryParse(normalizedInput) ?? 0.0;
        expect(parsedCost, equals(expectedCost), reason: 'Input "$input" should parse to $expectedCost');
      });
    });
  });
}