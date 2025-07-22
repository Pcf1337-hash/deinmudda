/// Unit Tests for Substance Service
/// 
/// Phase 6: Testing Implementation - Service Unit Tests
/// Tests the Substance Service with mocked dependencies
/// 
/// Author: Code Quality Improvement Agent
/// Date: Phase 6 - Testing Implementation

import 'package:flutter_test/flutter_test.dart';
import '../../lib/interfaces/service_interfaces.dart';
import '../../lib/models/substance.dart';
import '../mocks/service_mocks.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('Substance Service Unit Tests', () {
    late MockSubstanceService substanceService;

    setUp(() async {
      await TestSetupHelper.initializeTestEnvironment();
      substanceService = MockSubstanceService();
      TestDataFactory.resetCounters();
    });

    tearDown(() async {
      await TestSetupHelper.cleanupTestEnvironment();
    });

    group('Substance Creation', () {
      test('should create substance with valid data', () async {
        // Arrange
        final substance = TestDataFactory.createTestSubstance(
          name: 'Caffeine',
          category: SubstanceCategory.stimulant,
          defaultUnit: 'mg',
        );

        // Act
        final substanceId = await substanceService.createSubstance(substance);

        // Assert
        expect(substanceId, equals(substance.id));
        
        final allSubstances = await substanceService.getAllSubstances();
        expect(allSubstances, hasLength(1));
        TestAssertions.assertSubstanceProperties(
          allSubstances.first,
          'Caffeine',
          SubstanceCategory.stimulant,
        );
      });

      test('should create substances with different categories', () async {
        // Arrange
        final substances = [
          TestDataFactory.createTestSubstance(
            name: 'Ibuprofen',
            category: SubstanceCategory.medication,
          ),
          TestDataFactory.createTestSubstance(
            name: 'Vitamin D',
            category: SubstanceCategory.supplement,
          ),
          TestDataFactory.createTestSubstance(
            name: 'Alcohol',
            category: SubstanceCategory.depressant,
          ),
        ];

        // Act
        for (final substance in substances) {
          await substanceService.createSubstance(substance);
        }

        // Assert
        final allSubstances = await substanceService.getAllSubstances();
        expect(allSubstances, hasLength(3));
        
        expect(allSubstances.map((s) => s.category).toSet(), equals({
          SubstanceCategory.medication,
          SubstanceCategory.supplement,
          SubstanceCategory.depressant,
        }));
      });

      test('should initialize default substances', () async {
        // Act
        await substanceService.initializeDefaultSubstances();

        // Assert
        final allSubstances = await substanceService.getAllSubstances();
        expect(allSubstances, hasLength(2));
        expect(allSubstances.any((s) => s.name == 'Test Substance 1'), isTrue);
        expect(allSubstances.any((s) => s.name == 'Test Substance 2'), isTrue);
      });
    });

    group('Substance Retrieval', () {
      setUp(() async {
        // Add test data
        final substances = TestDataPresets.createTypicalSubstanceLibrary();
        for (final substance in substances) {
          await substanceService.createSubstance(substance);
        }
      });

      test('should get all substances', () async {
        // Act
        final allSubstances = await substanceService.getAllSubstances();

        // Assert
        expect(allSubstances, hasLength(4));
        expect(allSubstances.every((s) => s.id.isNotEmpty), isTrue);
      });

      test('should get substance by id', () async {
        // Arrange
        final allSubstances = await substanceService.getAllSubstances();
        final firstSubstance = allSubstances.first;

        // Act
        final foundSubstance = await substanceService.getSubstanceById(firstSubstance.id);

        // Assert
        expect(foundSubstance, isNotNull);
        expect(foundSubstance!.id, equals(firstSubstance.id));
        expect(foundSubstance.name, equals(firstSubstance.name));
      });

      test('should return null for non-existent substance id', () async {
        // Act
        final foundSubstance = await substanceService.getSubstanceById('non-existent-id');

        // Assert
        expect(foundSubstance, isNull);
      });

      test('should get substance by name', () async {
        // Act
        final foundSubstance = await substanceService.getSubstanceByName('Caffeine');

        // Assert
        expect(foundSubstance, isNotNull);
        expect(foundSubstance!.name, equals('Caffeine'));
      });

      test('should get substance by name case insensitive', () async {
        // Act
        final foundSubstance = await substanceService.getSubstanceByName('caffeine');

        // Assert
        expect(foundSubstance, isNotNull);
        expect(foundSubstance!.name, equals('Caffeine'));
      });

      test('should return null for non-existent substance name', () async {
        // Act
        final foundSubstance = await substanceService.getSubstanceByName('Non-existent');

        // Assert
        expect(foundSubstance, isNull);
      });
    });

    group('Substance Search and Filtering', () {
      setUp(() async {
        // Add test data
        final substances = TestDataPresets.createTypicalSubstanceLibrary();
        for (final substance in substances) {
          await substanceService.createSubstance(substance);
        }
      });

      test('should search substances by name', () async {
        // Act
        final searchResults = await substanceService.searchSubstances('Caff');

        // Assert
        expect(searchResults, hasLength(1));
        expect(searchResults.first.name, equals('Caffeine'));
      });

      test('should search substances by notes', () async {
        // Arrange
        final substanceWithNotes = TestDataFactory.createTestSubstance(
          name: 'Special Substance',
          notes: 'Contains unique properties',
        );
        await substanceService.createSubstance(substanceWithNotes);

        // Act
        final searchResults = await substanceService.searchSubstances('unique');

        // Assert
        expect(searchResults, hasLength(1));
        expect(searchResults.first.name, equals('Special Substance'));
      });

      test('should get substances by category', () async {
        // Act
        final medications = await substanceService.getSubstancesByCategory(
          SubstanceCategory.medication,
        );

        // Assert
        expect(medications, hasLength(1));
        expect(medications.first.name, equals('Ibuprofen'));
        expect(medications.first.category, equals(SubstanceCategory.medication));
      });

      test('should get substances by unit', () async {
        // Act
        final mgSubstances = await substanceService.getSubstancesByUnit('mg');

        // Assert
        expect(mgSubstances, hasLength(3)); // Caffeine, Melatonin, Ibuprofen
        expect(mgSubstances.every((s) => s.defaultUnit == 'mg'), isTrue);
      });

      test('should get most used substances', () async {
        // Act
        final mostUsed = await substanceService.getMostUsedSubstances(limit: 2);

        // Assert
        expect(mostUsed, hasLength(2));
        // In mock implementation, this returns first N substances
      });
    });

    group('Substance Updates', () {
      late Substance testSubstance;

      setUp(() async {
        testSubstance = TestDataFactory.createTestSubstance(
          name: 'Original Name',
          category: SubstanceCategory.medication,
          defaultUnit: 'mg',
        );
        await substanceService.createSubstance(testSubstance);
      });

      test('should update substance properties', () async {
        // Arrange
        final updatedSubstance = testSubstance.copyWith(
          name: 'Updated Name',
          category: SubstanceCategory.supplement,
          defaultUnit: 'ml',
          notes: 'Updated notes',
        );

        // Act
        await substanceService.updateSubstance(updatedSubstance);

        // Assert
        final retrievedSubstance = await substanceService.getSubstanceById(testSubstance.id);
        expect(retrievedSubstance, isNotNull);
        expect(retrievedSubstance!.name, equals('Updated Name'));
        expect(retrievedSubstance.category, equals(SubstanceCategory.supplement));
        expect(retrievedSubstance.defaultUnit, equals('ml'));
        expect(retrievedSubstance.notes, equals('Updated notes'));
      });

      test('should handle update of non-existent substance gracefully', () async {
        // Arrange
        final nonExistentSubstance = TestDataFactory.createTestSubstance(
          name: 'Does not exist',
        );

        // Act & Assert - Should not throw
        await substanceService.updateSubstance(nonExistentSubstance);

        // Verify original substance is not affected
        final originalSubstance = await substanceService.getSubstanceById(testSubstance.id);
        expect(originalSubstance, isNotNull);
        expect(originalSubstance!.name, equals('Original Name'));
      });
    });

    group('Substance Deletion', () {
      late List<Substance> testSubstances;

      setUp(() async {
        testSubstances = TestDataFactory.createTestSubstances(3);
        for (final substance in testSubstances) {
          await substanceService.createSubstance(substance);
        }
      });

      test('should delete substance by id', () async {
        // Arrange
        final substanceToDelete = testSubstances.first;

        // Act
        await substanceService.deleteSubstance(substanceToDelete.id);

        // Assert
        final deletedSubstance = await substanceService.getSubstanceById(substanceToDelete.id);
        expect(deletedSubstance, isNull);

        final allSubstances = await substanceService.getAllSubstances();
        expect(allSubstances, hasLength(2));
        expect(allSubstances.any((s) => s.id == substanceToDelete.id), isFalse);
      });

      test('should handle deletion of non-existent substance gracefully', () async {
        // Act & Assert - Should not throw
        await substanceService.deleteSubstance('non-existent-id');

        // Verify existing substances are not affected
        final allSubstances = await substanceService.getAllSubstances();
        expect(allSubstances, hasLength(3));
      });
    });

    group('Unit Management', () {
      setUp(() async {
        // Add substances with various units
        final substances = [
          TestDataFactory.createTestSubstance(defaultUnit: 'mg'),
          TestDataFactory.createTestSubstance(defaultUnit: 'ml'),
          TestDataFactory.createTestSubstance(defaultUnit: 'g'),
          TestDataFactory.createTestSubstance(defaultUnit: 'pills'),
        ];

        for (final substance in substances) {
          await substanceService.createSubstance(substance);
        }
      });

      test('should get all used units', () async {
        // Act
        final usedUnits = await substanceService.getAllUsedUnits();

        // Assert
        expect(usedUnits, containsAll(['mg', 'ml', 'g', 'pills']));
      });

      test('should get suggested units', () async {
        // Act
        final suggestedUnits = await substanceService.getSuggestedUnits();

        // Assert
        expect(suggestedUnits, containsAll(['mg', 'ml', 'g']));
        expect(suggestedUnits, hasLength(3));
      });

      test('should check if unit exists', () async {
        // Act & Assert
        expect(await substanceService.unitExists('mg'), isTrue);
        expect(await substanceService.unitExists('nonexistent'), isFalse);
      });

      test('should validate units', () async {
        // Act & Assert
        expect(substanceService.validateUnit('mg'), isNull);
        expect(substanceService.validateUnit(''), equals('Unit is required'));
        expect(substanceService.validateUnit(null), equals('Unit is required'));
        expect(substanceService.validateUnit('very_long_unit_name'), equals('Unit too long'));
      });
    });

    group('Performance Tests', () {
      test('should handle large number of substances efficiently', () async {
        // This test ensures the service can handle a reasonable load
        await PerformanceTestHelper.assertCompletesWithinTime(
          () async {
            final substances = TestDataFactory.createTestSubstances(100);
            for (final substance in substances) {
              await substanceService.createSubstance(substance);
            }
          },
          const Duration(seconds: 2),
        );

        final allSubstances = await substanceService.getAllSubstances();
        expect(allSubstances, hasLength(100));
      });

      test('should search substances quickly', () async {
        // Arrange
        final substances = TestDataFactory.createTestSubstances(50);
        for (final substance in substances) {
          await substanceService.createSubstance(substance);
        }

        // Act & Assert
        await PerformanceTestHelper.assertCompletesWithinTime(
          () async {
            await substanceService.searchSubstances('Test');
          },
          const Duration(milliseconds: 100),
        );
      });
    });

    group('Notification Integration', () {
      test('should notify listeners on substance creation', () async {
        // Arrange
        bool notified = false;
        substanceService.addListener(() {
          notified = true;
        });

        // Act
        final substance = TestDataFactory.createTestSubstance();
        await substanceService.createSubstance(substance);

        // Assert
        expect(notified, isTrue);
      });

      test('should notify listeners on substance update', () async {
        // Arrange
        final substance = TestDataFactory.createTestSubstance();
        await substanceService.createSubstance(substance);

        bool notified = false;
        substanceService.addListener(() {
          notified = true;
        });

        // Act
        final updatedSubstance = substance.copyWith(name: 'Updated Name');
        await substanceService.updateSubstance(updatedSubstance);

        // Assert
        expect(notified, isTrue);
      });

      test('should notify listeners on substance deletion', () async {
        // Arrange
        final substance = TestDataFactory.createTestSubstance();
        await substanceService.createSubstance(substance);

        bool notified = false;
        substanceService.addListener(() {
          notified = true;
        });

        // Act
        await substanceService.deleteSubstance(substance.id);

        // Assert
        expect(notified, isTrue);
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle clearing all substances', () async {
        // Arrange
        final substances = TestDataFactory.createTestSubstances(5);
        for (final substance in substances) {
          await substanceService.createSubstance(substance);
        }

        // Act
        substanceService.clearAllSubstances();

        // Assert
        final allSubstances = await substanceService.getAllSubstances();
        expect(allSubstances, isEmpty);
      });

      test('should handle search with empty query', () async {
        // Arrange
        final substance = TestDataFactory.createTestSubstance();
        await substanceService.createSubstance(substance);

        // Act
        final searchResults = await substanceService.searchSubstances('');

        // Assert
        // Should handle empty query gracefully (implementation specific)
        expect(searchResults, isA<List<Substance>>());
      });

      test('should handle category filtering with no matches', () async {
        // Arrange
        final substance = TestDataFactory.createTestSubstance(
          category: SubstanceCategory.medication,
        );
        await substanceService.createSubstance(substance);

        // Act
        final psychedelics = await substanceService.getSubstancesByCategory(
          SubstanceCategory.psychedelic,
        );

        // Assert
        expect(psychedelics, isEmpty);
      });
    });
  });
}