/// Integration Tests for Use Cases
/// 
/// Phase 6: Testing Implementation - Use Case Integration Tests
/// Tests business logic orchestration with service interactions
/// 
/// Author: Code Quality Improvement Agent
/// Date: Phase 6 - Testing Implementation

import 'package:flutter_test/flutter_test.dart';
import '../../lib/use_cases/entry_use_cases.dart';
import '../../lib/use_cases/substance_use_cases.dart';
import '../../lib/models/entry.dart';
import '../../lib/models/substance.dart';
import '../mocks/service_mocks.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('Use Case Integration Tests', () {
    late MockEntryService entryService;
    late MockSubstanceService substanceService;
    late MockTimerService timerService;
    late MockNotificationService notificationService;

    // Entry Use Cases
    late CreateEntryUseCase createEntryUseCase;
    late CreateEntryWithTimerUseCase createEntryWithTimerUseCase;
    late UpdateEntryUseCase updateEntryUseCase;
    late DeleteEntryUseCase deleteEntryUseCase;
    late GetEntriesUseCase getEntriesUseCase;

    // Substance Use Cases
    late CreateSubstanceUseCase createSubstanceUseCase;
    late UpdateSubstanceUseCase updateSubstanceUseCase;
    late DeleteSubstanceUseCase deleteSubstanceUseCase;
    late GetSubstancesUseCase getSubstancesUseCase;
    late SubstanceStatisticsUseCase substanceStatisticsUseCase;

    setUp(() async {
      await TestSetupHelper.initializeTestEnvironment();
      
      // Initialize mock services
      entryService = MockEntryService();
      substanceService = MockSubstanceService();
      timerService = MockTimerService();
      notificationService = MockNotificationService();

      // Initialize use cases with mock services
      createEntryUseCase = CreateEntryUseCase(entryService);
      createEntryWithTimerUseCase = CreateEntryWithTimerUseCase(entryService, timerService, notificationService);
      updateEntryUseCase = UpdateEntryUseCase(entryService);
      deleteEntryUseCase = DeleteEntryUseCase(entryService, timerService);
      getEntriesUseCase = GetEntriesUseCase(entryService);

      createSubstanceUseCase = CreateSubstanceUseCase(substanceService);
      updateSubstanceUseCase = UpdateSubstanceUseCase(substanceService);
      deleteSubstanceUseCase = DeleteSubstanceUseCase(substanceService, entryService);
      getSubstancesUseCase = GetSubstancesUseCase(substanceService);
      substanceStatisticsUseCase = SubstanceStatisticsUseCase(substanceService, entryService);

      TestDataFactory.resetCounters();
    });

    tearDown(() async {
      await TestSetupHelper.cleanupTestEnvironment();
    });

    group('Entry Use Cases', () {
      group('CreateEntryUseCase', () {
        test('should create entry with valid data', () async {
          // Arrange
          const substanceId = 'test-substance-id';
          const substanceName = 'Test Substance';
          const dosage = 10.0;
          const unit = 'mg';
          const notes = 'Test notes';

          // Act
          final result = await createEntryUseCase.execute(
            substanceId: substanceId,
            substanceName: substanceName,
            dosage: dosage,
            unit: unit,
            notes: notes,
          );

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.data, isNotNull);
          expect(result.data!.substanceId, equals(substanceId));
          expect(result.data!.dosage, equals(dosage));

          final allEntries = await entryService.getAllEntries();
          expect(allEntries, hasLength(1));
        });

        test('should handle validation errors', () async {
          // Act
          final result = await createEntryUseCase.execute(
            substanceId: '', // Invalid empty ID
            substanceName: 'Test',
            dosage: -1.0, // Invalid negative dosage
            unit: 'mg',
          );

          // Assert
          expect(result.isSuccess, isFalse);
          expect(result.error, isNotNull);
          expect(result.error!.contains('Invalid'), isTrue);
        });
      });

      group('CreateEntryWithTimerUseCase', () {
        test('should create entry with timer and schedule notification', () async {
          // Arrange
          const substanceId = 'test-substance-id';
          const substanceName = 'Test Substance';
          const dosage = 10.0;
          const unit = 'mg';
          final duration = const Duration(hours: 2);

          // Act
          final result = await createEntryWithTimerUseCase.execute(
            substanceId: substanceId,
            substanceName: substanceName,
            dosage: dosage,
            unit: unit,
            duration: duration,
          );

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.data, isNotNull);
          
          final entry = result.data!;
          TestAssertions.assertTimerActive(entry);
          expect(entry.duration, equals(duration));

          // Verify timer was created
          expect(timerService.hasActiveTimer(entry.id), isTrue);

          // Verify notification was scheduled
          TestAssertions.assertNotificationSent(notificationService, entry.id);
        });

        test('should handle timer creation failure gracefully', () async {
          // Arrange - Dispose timer service to simulate failure
          await timerService.dispose();

          // Act
          final result = await createEntryWithTimerUseCase.execute(
            substanceId: 'test-substance-id',
            substanceName: 'Test Substance',
            dosage: 10.0,
            unit: 'mg',
            duration: const Duration(hours: 1),
          );

          // Assert
          expect(result.isSuccess, isTrue); // Entry should still be created
          expect(result.data, isNotNull);
          
          // Timer should not be active due to disposed service
          expect(timerService.hasActiveTimer(result.data!.id), isFalse);
        });
      });

      group('UpdateEntryUseCase', () {
        late Entry existingEntry;

        setUp(() async {
          existingEntry = TestDataFactory.createTestEntry();
          await entryService.createEntry(existingEntry);
        });

        test('should update entry with valid changes', () async {
          // Act
          final result = await updateEntryUseCase.execute(
            entryId: existingEntry.id,
            dosage: 20.0,
            notes: 'Updated notes',
          );

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.data, isNotNull);
          expect(result.data!.dosage, equals(20.0));
          expect(result.data!.notes, equals('Updated notes'));

          final updatedEntry = await entryService.getEntryById(existingEntry.id);
          expect(updatedEntry!.dosage, equals(20.0));
        });

        test('should handle update of non-existent entry', () async {
          // Act
          final result = await updateEntryUseCase.execute(
            entryId: 'non-existent-id',
            dosage: 20.0,
          );

          // Assert
          expect(result.isSuccess, isFalse);
          expect(result.error, contains('not found'));
        });
      });

      group('DeleteEntryUseCase', () {
        late Entry entryWithTimer;

        setUp(() async {
          entryWithTimer = TestDataFactory.createTestEntryWithTimer();
          await entryService.createEntry(entryWithTimer);
          await timerService.createEntryWithTimer(entryWithTimer, entryWithTimer.duration!);
        });

        test('should delete entry and cleanup timer', () async {
          // Verify setup
          expect(await entryService.getEntryById(entryWithTimer.id), isNotNull);
          expect(timerService.hasActiveTimer(entryWithTimer.id), isTrue);

          // Act
          final result = await deleteEntryUseCase.execute(entryWithTimer.id);

          // Assert
          expect(result.isSuccess, isTrue);
          expect(await entryService.getEntryById(entryWithTimer.id), isNull);
          expect(timerService.hasActiveTimer(entryWithTimer.id), isFalse);
        });

        test('should handle deletion of non-existent entry', () async {
          // Act
          final result = await deleteEntryUseCase.execute('non-existent-id');

          // Assert
          expect(result.isSuccess, isFalse);
          expect(result.error, contains('not found'));
        });
      });

      group('GetEntriesUseCase', () {
        setUp(() async {
          final entries = TestDataPresets.createRecentEntries();
          for (final entry in entries) {
            await entryService.createEntry(entry);
          }
        });

        test('should get all entries', () async {
          // Act
          final result = await getEntriesUseCase.execute();

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.data, hasLength(3));
        });

        test('should get entries by date range', () async {
          // Arrange
          final now = DateTime.now();
          final startDate = now.subtract(const Duration(hours: 6));
          final endDate = now.add(const Duration(hours: 1));

          // Act
          final result = await getEntriesUseCase.execute(
            startDate: startDate,
            endDate: endDate,
          );

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.data, isNotEmpty);
        });

        test('should get entries by substance', () async {
          // Arrange
          final allEntries = await entryService.getAllEntries();
          final firstEntry = allEntries.first;

          // Act
          final result = await getEntriesUseCase.execute(
            substanceId: firstEntry.substanceId,
          );

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.data, hasLength(1));
          expect(result.data!.first.substanceId, equals(firstEntry.substanceId));
        });
      });
    });

    group('Substance Use Cases', () {
      group('CreateSubstanceUseCase', () {
        test('should create substance with valid data', () async {
          // Act
          final result = await createSubstanceUseCase.execute(
            name: 'Caffeine',
            category: SubstanceCategory.stimulant,
            defaultUnit: 'mg',
            defaultRiskLevel: RiskLevel.low,
            pricePerUnit: 0.01,
            notes: 'Test substance',
          );

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.data, isNotNull);
          expect(result.data!.name, equals('Caffeine'));
          expect(result.data!.category, equals(SubstanceCategory.stimulant));

          final allSubstances = await substanceService.getAllSubstances();
          expect(allSubstances, hasLength(1));
        });

        test('should handle validation errors', () async {
          // Act
          final result = await createSubstanceUseCase.execute(
            name: '', // Invalid empty name
            category: SubstanceCategory.medication,
            defaultUnit: 'mg',
          );

          // Assert
          expect(result.isSuccess, isFalse);
          expect(result.error, contains('Invalid'));
        });

        test('should handle duplicate name', () async {
          // Arrange
          await createSubstanceUseCase.execute(
            name: 'Caffeine',
            category: SubstanceCategory.stimulant,
            defaultUnit: 'mg',
          );

          // Act
          final result = await createSubstanceUseCase.execute(
            name: 'Caffeine', // Duplicate name
            category: SubstanceCategory.medication,
            defaultUnit: 'mg',
          );

          // Assert
          expect(result.isSuccess, isFalse);
          expect(result.error, contains('already exists'));
        });
      });

      group('UpdateSubstanceUseCase', () {
        late Substance existingSubstance;

        setUp(() async {
          existingSubstance = TestDataFactory.createTestSubstance();
          await substanceService.createSubstance(existingSubstance);
        });

        test('should update substance with valid changes', () async {
          // Act
          final result = await updateSubstanceUseCase.execute(
            substanceId: existingSubstance.id,
            name: 'Updated Name',
            notes: 'Updated notes',
          );

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.data, isNotNull);
          expect(result.data!.name, equals('Updated Name'));
          expect(result.data!.notes, equals('Updated notes'));
        });

        test('should handle update of non-existent substance', () async {
          // Act
          final result = await updateSubstanceUseCase.execute(
            substanceId: 'non-existent-id',
            name: 'Updated Name',
          );

          // Assert
          expect(result.isSuccess, isFalse);
          expect(result.error, contains('not found'));
        });

        test('should prevent name conflicts', () async {
          // Arrange
          final secondSubstance = TestDataFactory.createTestSubstance(name: 'Second Substance');
          await substanceService.createSubstance(secondSubstance);

          // Act
          final result = await updateSubstanceUseCase.execute(
            substanceId: secondSubstance.id,
            name: existingSubstance.name, // Conflict with existing name
          );

          // Assert
          expect(result.isSuccess, isFalse);
          expect(result.error, contains('name already exists'));
        });
      });

      group('DeleteSubstanceUseCase', () {
        late Substance substanceWithEntries;
        late Substance substanceWithoutEntries;

        setUp() async {
          substanceWithoutEntries = TestDataFactory.createTestSubstance();
          await substanceService.createSubstance(substanceWithoutEntries);

          substanceWithEntries = TestDataFactory.createTestSubstance();
          await substanceService.createSubstance(substanceWithEntries);

          // Create entry for this substance
          final entry = TestDataFactory.createTestEntry(substanceId: substanceWithEntries.id);
          await entryService.createEntry(entry);
        });

        test('should delete substance without entries', () async {
          // Act
          final result = await deleteSubstanceUseCase.execute(
            substanceWithoutEntries.id,
            forceDelete: false,
          );

          // Assert
          expect(result.isSuccess, isTrue);
          expect(await substanceService.getSubstanceById(substanceWithoutEntries.id), isNull);
        });

        test('should prevent deletion of substance with entries', () async {
          // Act
          final result = await deleteSubstanceUseCase.execute(
            substanceWithEntries.id,
            forceDelete: false,
          );

          // Assert
          expect(result.isSuccess, isFalse);
          expect(result.error, contains('has entries'));
          expect(await substanceService.getSubstanceById(substanceWithEntries.id), isNotNull);
        });

        test('should force delete substance with entries', () async {
          // Act
          final result = await deleteSubstanceUseCase.execute(
            substanceWithEntries.id,
            forceDelete: true,
          );

          // Assert
          expect(result.isSuccess, isTrue);
          expect(await substanceService.getSubstanceById(substanceWithEntries.id), isNull);
          
          // Related entries should also be deleted
          final entries = await entryService.getEntriesBySubstance(substanceWithEntries.id);
          expect(entries, isEmpty);
        });
      });

      group('GetSubstancesUseCase', () {
        setUp(() async {
          final substances = TestDataPresets.createTypicalSubstanceLibrary();
          for (final substance in substances) {
            await substanceService.createSubstance(substance);
          }
        });

        test('should get all substances', () async {
          // Act
          final result = await getSubstancesUseCase.execute();

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.data, hasLength(4));
        });

        test('should get substances by category', () async {
          // Act
          final result = await getSubstancesUseCase.execute(
            category: SubstanceCategory.medication,
          );

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.data, hasLength(1));
          expect(result.data!.first.category, equals(SubstanceCategory.medication));
        });

        test('should search substances', () async {
          // Act
          final result = await getSubstancesUseCase.execute(
            searchQuery: 'Caff',
          );

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.data, hasLength(1));
          expect(result.data!.first.name, equals('Caffeine'));
        });
      });

      group('SubstanceStatisticsUseCase', () {
        setUp() async {
          // Create substances and entries for statistics
          final substances = TestDataPresets.createTypicalSubstanceLibrary();
          for (final substance in substances) {
            await substanceService.createSubstance(substance);
          }

          // Create entries for different substances
          final entries = [
            TestDataFactory.createTestEntry(substanceId: substances[0].id), // Caffeine
            TestDataFactory.createTestEntry(substanceId: substances[0].id), // Caffeine again
            TestDataFactory.createTestEntry(substanceId: substances[1].id), // Melatonin
          ];

          for (final entry in entries) {
            await entryService.createEntry(entry);
          }
        });

        test('should calculate substance usage statistics', () async {
          // Act
          final result = await substanceStatisticsUseCase.execute();

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.data, isNotNull);
          expect(result.data!.totalSubstances, equals(4));
          expect(result.data!.substancesWithEntries, equals(2));
          expect(result.data!.mostUsedSubstances, isNotEmpty);
        });

        test('should get most used substances in correct order', () async {
          // Act
          final result = await substanceStatisticsUseCase.execute(limit: 3);

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.data!.mostUsedSubstances, hasLength(2)); // Only 2 have entries
          
          // Caffeine should be first (2 entries)
          expect(result.data!.mostUsedSubstances.first.entryCount, equals(2));
        });
      });
    });

    group('Cross-Use Case Integration', () {
      test('should handle complete workflow: create substance, create entry with timer', () async {
        // Step 1: Create substance
        final substanceResult = await createSubstanceUseCase.execute(
          name: 'Integration Test Substance',
          category: SubstanceCategory.medication,
          defaultUnit: 'mg',
        );

        expect(substanceResult.isSuccess, isTrue);
        final substance = substanceResult.data!;

        // Step 2: Create entry with timer for this substance
        final entryResult = await createEntryWithTimerUseCase.execute(
          substanceId: substance.id,
          substanceName: substance.name,
          dosage: 100.0,
          unit: substance.defaultUnit,
          duration: const Duration(hours: 4),
        );

        expect(entryResult.isSuccess, isTrue);
        final entry = entryResult.data!;

        // Step 3: Verify all integrations
        expect(timerService.hasActiveTimer(entry.id), isTrue);
        TestAssertions.assertNotificationSent(notificationService, entry.id);

        // Step 4: Get entries for this substance
        final entriesResult = await getEntriesUseCase.execute(substanceId: substance.id);
        expect(entriesResult.isSuccess, isTrue);
        expect(entriesResult.data, hasLength(1));

        // Step 5: Delete entry (should cleanup timer)
        final deleteResult = await deleteEntryUseCase.execute(entry.id);
        expect(deleteResult.isSuccess, isTrue);
        expect(timerService.hasActiveTimer(entry.id), isFalse);
      });

      test('should handle error cascading across use cases', () async {
        // Create entry for non-existent substance
        final entryResult = await createEntryUseCase.execute(
          substanceId: 'non-existent-substance',
          substanceName: 'Ghost Substance',
          dosage: 10.0,
          unit: 'mg',
        );

        // Should still succeed (use case handles missing substance gracefully)
        expect(entryResult.isSuccess, isTrue);

        // But statistics should handle missing substances properly
        final statsResult = await substanceStatisticsUseCase.execute();
        expect(statsResult.isSuccess, isTrue);
        expect(statsResult.data!.orphanedEntries, equals(1));
      });
    });

    group('Performance Integration Tests', () {
      test('should handle bulk operations efficiently', () async {
        await PerformanceTestHelper.assertCompletesWithinTime(
          () async {
            // Create 20 substances
            for (int i = 0; i < 20; i++) {
              await createSubstanceUseCase.execute(
                name: 'Bulk Substance $i',
                category: SubstanceCategory.values[i % SubstanceCategory.values.length],
                defaultUnit: 'mg',
              );
            }

            // Create 50 entries
            final substances = await substanceService.getAllSubstances();
            for (int i = 0; i < 50; i++) {
              final substance = substances[i % substances.length];
              await createEntryUseCase.execute(
                substanceId: substance.id,
                substanceName: substance.name,
                dosage: (i + 1) * 10.0,
                unit: substance.defaultUnit,
              );
            }

            // Get statistics
            await substanceStatisticsUseCase.execute();
          },
          const Duration(seconds: 3),
        );
      });
    });
  });
}