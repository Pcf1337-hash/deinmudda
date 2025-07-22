/// Unit Tests for Entry Service
/// 
/// Phase 6: Testing Implementation - Service Unit Tests
/// Tests the Entry Service with mocked dependencies
/// 
/// Author: Code Quality Improvement Agent
/// Date: Phase 6 - Testing Implementation

import 'package:flutter_test/flutter_test.dart';
import '../../lib/interfaces/service_interfaces.dart';
import '../../lib/models/entry.dart';
import '../../lib/models/substance.dart';
import '../mocks/service_mocks.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('Entry Service Unit Tests', () {
    late MockEntryService entryService;

    setUp(() async {
      await TestSetupHelper.initializeTestEnvironment();
      entryService = MockEntryService();
      TestDataFactory.resetCounters();
    });

    tearDown(() async {
      await TestSetupHelper.cleanupTestEnvironment();
    });

    group('Entry Creation', () {
      test('should create entry with valid data', () async {
        // Arrange
        final entry = TestDataFactory.createTestEntry(
          substanceName: 'Caffeine',
          dosage: 200.0,
          unit: 'mg',
        );

        // Act
        final entryId = await entryService.createEntry(entry);

        // Assert
        expect(entryId, equals(entry.id));
        final allEntries = await entryService.getAllEntries();
        expect(allEntries, hasLength(1));
        TestAssertions.assertEntryProperties(allEntries.first, entry.substanceId, 200.0);
      });

      test('should create entry with timer', () async {
        // Arrange
        final entry = TestDataFactory.createTestEntry(
          substanceName: 'Melatonin',
          dosage: 3.0,
          unit: 'mg',
        );
        final customDuration = const Duration(hours: 8);

        // Act
        final entryWithTimer = await entryService.createEntryWithTimer(
          entry,
          customDuration: customDuration,
          timerService: MockTimerService(),
        );

        // Assert
        TestAssertions.assertTimerActive(entryWithTimer);
        expect(entryWithTimer.duration, equals(customDuration));
        
        final activeTimers = await entryService.getActiveTimerEntries();
        expect(activeTimers, hasLength(1));
        expect(activeTimers.first.id, equals(entryWithTimer.id));
      });

      test('should handle multiple entry creation', () async {
        // Arrange
        final entries = TestDataFactory.createTestEntries(5);

        // Act
        for (final entry in entries) {
          await entryService.createEntry(entry);
        }

        // Assert
        final allEntries = await entryService.getAllEntries();
        expect(allEntries, hasLength(5));
        
        // Verify each entry exists
        for (final originalEntry in entries) {
          final foundEntry = await entryService.getEntryById(originalEntry.id);
          expect(foundEntry, isNotNull);
          expect(foundEntry!.id, equals(originalEntry.id));
        }
      });
    });

    group('Entry Retrieval', () {
      setUp(() async {
        // Add test data
        final entries = TestDataPresets.createRecentEntries();
        for (final entry in entries) {
          await entryService.createEntry(entry);
        }
      });

      test('should get all entries', () async {
        // Act
        final allEntries = await entryService.getAllEntries();

        // Assert
        expect(allEntries, hasLength(3));
        expect(allEntries.every((entry) => entry.id.isNotEmpty), isTrue);
      });

      test('should get entry by id', () async {
        // Arrange
        final allEntries = await entryService.getAllEntries();
        final firstEntry = allEntries.first;

        // Act
        final foundEntry = await entryService.getEntryById(firstEntry.id);

        // Assert
        expect(foundEntry, isNotNull);
        expect(foundEntry!.id, equals(firstEntry.id));
        expect(foundEntry.substanceName, equals(firstEntry.substanceName));
      });

      test('should return null for non-existent entry id', () async {
        // Act
        final foundEntry = await entryService.getEntryById('non-existent-id');

        // Assert
        expect(foundEntry, isNull);
      });

      test('should get entries by substance', () async {
        // Arrange
        final allEntries = await entryService.getAllEntries();
        final firstEntry = allEntries.first;

        // Act
        final substanceEntries = await entryService.getEntriesBySubstance(firstEntry.substanceId);

        // Assert
        expect(substanceEntries, hasLength(1));
        expect(substanceEntries.first.substanceId, equals(firstEntry.substanceId));
      });

      test('should get entries by date range', () async {
        // Arrange
        final now = DateTime.now();
        final startDate = now.subtract(const Duration(hours: 6));
        final endDate = now.add(const Duration(hours: 1));

        // Act
        final entriesInRange = await entryService.getEntriesByDateRange(startDate, endDate);

        // Assert
        expect(entriesInRange, isNotEmpty);
        expect(
          entriesInRange.every((entry) => 
            entry.timestamp.isAfter(startDate) && entry.timestamp.isBefore(endDate)
          ),
          isTrue,
        );
      });
    });

    group('Entry Updates', () {
      late Entry testEntry;

      setUp(() async {
        testEntry = TestDataFactory.createTestEntry(
          substanceName: 'Original Name',
          dosage: 100.0,
        );
        await entryService.createEntry(testEntry);
      });

      test('should update entry properties', () async {
        // Arrange
        final updatedEntry = testEntry.copyWith(
          substanceName: 'Updated Name',
          dosage: 200.0,
          notes: 'Updated notes',
        );

        // Act
        await entryService.updateEntry(updatedEntry);

        // Assert
        final retrievedEntry = await entryService.getEntryById(testEntry.id);
        expect(retrievedEntry, isNotNull);
        expect(retrievedEntry!.substanceName, equals('Updated Name'));
        expect(retrievedEntry.dosage, equals(200.0));
        expect(retrievedEntry.notes, equals('Updated notes'));
      });

      test('should update entry timer', () async {
        // Arrange
        final timerStartTime = DateTime.now();
        final duration = const Duration(hours: 4);

        // Act
        await entryService.updateEntryTimer(testEntry.id, timerStartTime, duration);

        // Assert
        final updatedEntry = await entryService.getEntryById(testEntry.id);
        expect(updatedEntry, isNotNull);
        expect(updatedEntry!.timerStartTime, isNotNull);
        expect(updatedEntry.duration, equals(duration));

        final activeTimers = await entryService.getActiveTimerEntries();
        expect(activeTimers, hasLength(1));
        expect(activeTimers.first.id, equals(testEntry.id));
      });

      test('should remove timer when set to null', () async {
        // Arrange - First add a timer
        await entryService.updateEntryTimer(
          testEntry.id,
          DateTime.now(),
          const Duration(hours: 2),
        );

        // Act - Remove timer
        await entryService.updateEntryTimer(testEntry.id, null, null);

        // Assert
        final updatedEntry = await entryService.getEntryById(testEntry.id);
        expect(updatedEntry, isNotNull);
        expect(updatedEntry!.timerStartTime, isNull);
        expect(updatedEntry.duration, isNull);

        final activeTimers = await entryService.getActiveTimerEntries();
        expect(activeTimers, isEmpty);
      });
    });

    group('Entry Deletion', () {
      late List<Entry> testEntries;

      setUp(() async {
        testEntries = TestDataFactory.createTestEntries(3);
        for (final entry in testEntries) {
          await entryService.createEntry(entry);
        }
      });

      test('should delete entry by id', () async {
        // Arrange
        final entryToDelete = testEntries.first;

        // Act
        await entryService.deleteEntry(entryToDelete.id);

        // Assert
        final deletedEntry = await entryService.getEntryById(entryToDelete.id);
        expect(deletedEntry, isNull);

        final allEntries = await entryService.getAllEntries();
        expect(allEntries, hasLength(2));
        expect(allEntries.any((entry) => entry.id == entryToDelete.id), isFalse);
      });

      test('should remove from active timers when deleted', () async {
        // Arrange
        final entryWithTimer = testEntries.first;
        await entryService.updateEntryTimer(
          entryWithTimer.id,
          DateTime.now(),
          const Duration(hours: 2),
        );

        // Verify timer is active
        final activeTimersBefore = await entryService.getActiveTimerEntries();
        expect(activeTimersBefore, hasLength(1));

        // Act
        await entryService.deleteEntry(entryWithTimer.id);

        // Assert
        final activeTimersAfter = await entryService.getActiveTimerEntries();
        expect(activeTimersAfter, isEmpty);
      });

      test('should handle deletion of non-existent entry gracefully', () async {
        // Act & Assert - Should not throw
        await entryService.deleteEntry('non-existent-id');

        // Verify existing entries are not affected
        final allEntries = await entryService.getAllEntries();
        expect(allEntries, hasLength(3));
      });
    });

    group('Timer Management', () {
      test('should track active timer entries', () async {
        // Arrange
        final entries = TestDataPresets.createActiveTimerEntries();
        for (final entry in entries) {
          await entryService.createEntry(entry);
        }

        // Act
        final activeTimers = await entryService.getActiveTimerEntries();

        // Assert
        expect(activeTimers, hasLength(2));
        expect(activeTimers.every((entry) => entry.isTimerActive), isTrue);
      });

      test('should clear all entries including timers', () async {
        // Arrange
        final entriesWithTimers = TestDataPresets.createActiveTimerEntries();
        for (final entry in entriesWithTimers) {
          await entryService.createEntry(entry);
        }

        // Act
        entryService.clearAllEntries();

        // Assert
        final allEntries = await entryService.getAllEntries();
        final activeTimers = await entryService.getActiveTimerEntries();
        expect(allEntries, isEmpty);
        expect(activeTimers, isEmpty);
      });
    });

    group('Performance Tests', () {
      test('should handle large number of entries efficiently', () async {
        // This test ensures the service can handle a reasonable load
        await PerformanceTestHelper.assertCompletesWithinTime(
          () async {
            final entries = TestDataFactory.createTestEntries(100);
            for (final entry in entries) {
              await entryService.createEntry(entry);
            }
          },
          const Duration(seconds: 2),
        );

        final allEntries = await entryService.getAllEntries();
        expect(allEntries, hasLength(100));
      });

      test('should retrieve entries quickly', () async {
        // Arrange
        final entries = TestDataFactory.createTestEntries(50);
        for (final entry in entries) {
          await entryService.createEntry(entry);
        }

        // Act & Assert
        await PerformanceTestHelper.assertCompletesWithinTime(
          () async {
            await entryService.getAllEntries();
          },
          const Duration(milliseconds: 100),
        );
      });
    });

    group('Notification Integration', () {
      test('should notify listeners on entry creation', () async {
        // Arrange
        bool notified = false;
        entryService.addListener(() {
          notified = true;
        });

        // Act
        final entry = TestDataFactory.createTestEntry();
        await entryService.createEntry(entry);

        // Assert
        expect(notified, isTrue);
      });

      test('should notify listeners on entry update', () async {
        // Arrange
        final entry = TestDataFactory.createTestEntry();
        await entryService.createEntry(entry);

        bool notified = false;
        entryService.addListener(() {
          notified = true;
        });

        // Act
        final updatedEntry = entry.copyWith(dosage: 999.0);
        await entryService.updateEntry(updatedEntry);

        // Assert
        expect(notified, isTrue);
      });

      test('should notify listeners on entry deletion', () async {
        // Arrange
        final entry = TestDataFactory.createTestEntry();
        await entryService.createEntry(entry);

        bool notified = false;
        entryService.addListener(() {
          notified = true;
        });

        // Act
        await entryService.deleteEntry(entry.id);

        // Assert
        expect(notified, isTrue);
      });
    });
  });
}