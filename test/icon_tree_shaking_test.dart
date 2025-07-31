import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/models/quick_button_config.dart';
import '../lib/models/entry.dart';

void main() {
  group('IconData Tree Shaking Fix Tests', () {
    group('QuickButtonConfig', () {
      test('getIconFromCodePoint returns null for null input', () {
        final result = QuickButtonConfig.getIconFromCodePoint(null);
        expect(result, isNull);
      });

      test('getIconFromCodePoint returns constant IconData for known codePoints', () {
        // Test a few known codePoints from our mapping
        final coffeeIcon = QuickButtonConfig.getIconFromCodePoint(0xe3ab);
        expect(coffeeIcon, equals(Icons.local_cafe_rounded));
        expect(coffeeIcon, isA<IconData>());
        
        final flashIcon = QuickButtonConfig.getIconFromCodePoint(0xe1a3);
        expect(flashIcon, equals(Icons.flash_on_rounded));
        expect(flashIcon, isA<IconData>());
        
        final scienceIcon = QuickButtonConfig.getIconFromCodePoint(0xe3f4);
        expect(scienceIcon, equals(Icons.science_rounded));
        expect(scienceIcon, isA<IconData>());
      });

      test('getIconFromCodePoint returns null for zero input', () {
        final result = QuickButtonConfig.getIconFromCodePoint(0);
        expect(result, isNull);
      });

      test('getIconFromCodePoint returns null for unknown codePoints', () {
        // Test with a codePoint not in our mapping - should return null for tree-shake safety
        final unknownIcon = QuickButtonConfig.getIconFromCodePoint(0x999999);
        expect(unknownIcon, isNull);
      });

      test('QuickButtonConfig.getIconFromCodePoint always returns constant IconData instances for valid codePoints', () {
        // Test that the returned IconData instances are compile-time constants
        // This ensures tree shaking compatibility
        final icon1 = QuickButtonConfig.getIconFromCodePoint(0xe3ab);
        final icon2 = QuickButtonConfig.getIconFromCodePoint(0xe3ab);
        
        // Should be the same constant instance
        expect(identical(icon1, icon2), isTrue);
        
        // Should match the Icons class constant
        expect(identical(icon1, Icons.local_cafe_rounded), isTrue);
      });

      test('QuickButtonConfig creation with iconCodePoint works correctly', () {
        // Test that the factory constructor still works with icon codePoints
        final config = QuickButtonConfig.create(
          substanceId: 'test-id',
          substanceName: 'Test Substance',
          dosage: 10.0,
          unit: 'mg',
          position: 0,
          icon: Icons.local_cafe_rounded,
        );

        expect(config.iconCodePoint, equals(Icons.local_cafe_rounded.codePoint));
        
        // Test that getIconFromCodePoint can retrieve the correct icon
        final retrievedIcon = QuickButtonConfig.getIconFromCodePoint(config.iconCodePoint);
        expect(retrievedIcon, equals(Icons.local_cafe_rounded));
      });
    });

    group('Entry', () {
      test('Entry.getIconFromCodePoint returns null for null input', () {
        final result = Entry.getIconFromCodePoint(null);
        expect(result, isNull);
      });

      test('Entry.getIconFromCodePoint returns constant IconData for known codePoints', () {
        // Test a few known codePoints from our mapping
        final coffeeIcon = Entry.getIconFromCodePoint(0xe3ab);
        expect(coffeeIcon, equals(Icons.local_cafe_rounded));
        expect(coffeeIcon, isA<IconData>());
        
        final medicationIcon = Entry.getIconFromCodePoint(0xe3b0);
        expect(medicationIcon, equals(Icons.medication_rounded));
        expect(medicationIcon, isA<IconData>());
      });

      test('Entry.getIconFromCodePoint returns null for zero input', () {
        final result = Entry.getIconFromCodePoint(0);
        expect(result, isNull);
      });

      test('Entry.getIconFromCodePoint returns null for unknown codePoints', () {
        // Test with a codePoint not in our mapping - should return null for tree-shake safety
        final unknownIcon = Entry.getIconFromCodePoint(0x888888);
        expect(unknownIcon, isNull);
      });

      test('Entry.getIconFromCodePoint always returns constant IconData instances for valid codePoints', () {
        // Test that the returned IconData instances are compile-time constants
        final icon1 = Entry.getIconFromCodePoint(0xe3b0);
        final icon2 = Entry.getIconFromCodePoint(0xe3b0);
        
        // Should be the same constant instance
        expect(identical(icon1, icon2), isTrue);
        
        // Should match the Icons class constant
        expect(identical(icon1, Icons.medication_rounded), isTrue);
      });
    });

    test('all mapped codePoints return valid IconData instances', () {
      // Test a representative sample of the codePoints in our mapping
      final testCodePoints = [
        0xe047, // add_rounded
        0xe3ab, // local_cafe_rounded
        0xe1a3, // flash_on_rounded
        0xe30c, // emoji_food_beverage_rounded
        0xe0e8, // local_bar_rounded
        0xe3f4, // science_rounded
        0xe86c, // check_circle_rounded
      ];

      for (final codePoint in testCodePoints) {
        final quickButtonIcon = QuickButtonConfig.getIconFromCodePoint(codePoint);
        final entryIcon = Entry.getIconFromCodePoint(codePoint);
        
        expect(quickButtonIcon, isNotNull);
        expect(quickButtonIcon, isA<IconData>());
        expect(quickButtonIcon!.codePoint, equals(codePoint));
        
        expect(entryIcon, isNotNull);
        expect(entryIcon, isA<IconData>());
        expect(entryIcon!.codePoint, equals(codePoint));
        
        // Both should return the same constant instance
        expect(identical(quickButtonIcon, entryIcon), isTrue);
      }
    });

    test('unknown codePoints return null (tree-shake safety)', () {
      // Test that unknown codePoints return null instead of fallback icons
      final unknownCodePoints = [0x999999, 0x888888, 0x123456];
      
      for (final codePoint in unknownCodePoints) {
        final quickButtonIcon = QuickButtonConfig.getIconFromCodePoint(codePoint);
        final entryIcon = Entry.getIconFromCodePoint(codePoint);
        
        expect(quickButtonIcon, isNull);
        expect(entryIcon, isNull);
      }
    });

    test('icon retrieval preserves functionality for serialization', () {
      // Test the full cycle: create with icon -> serialize -> deserialize -> retrieve icon
      final originalIcon = Icons.medication_rounded;
      
      final config = QuickButtonConfig.create(
        substanceId: 'test-id',
        substanceName: 'Test Medicine',
        dosage: 5.0,
        unit: 'mg',
        position: 0,
        icon: originalIcon,
      );

      // Serialize to JSON
      final json = config.toJson();
      expect(json['iconCodePoint'], equals(originalIcon.codePoint));

      // Deserialize from JSON
      final deserializedConfig = QuickButtonConfig.fromJson(json);
      expect(deserializedConfig.iconCodePoint, equals(originalIcon.codePoint));

      // Retrieve icon using our tree-shake safe method
      final retrievedIcon = QuickButtonConfig.getIconFromCodePoint(deserializedConfig.iconCodePoint);
      expect(retrievedIcon, equals(originalIcon));
    });
  });
}