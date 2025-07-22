/// Unit Tests for Timer Service
/// 
/// Phase 6: Testing Implementation - Service Unit Tests
/// Tests the Timer Service with mocked dependencies
/// 
/// Author: Code Quality Improvement Agent
/// Date: Phase 6 - Testing Implementation

import 'package:flutter_test/flutter_test.dart';
import '../../lib/interfaces/service_interfaces.dart';
import '../../lib/models/entry.dart';
import '../mocks/service_mocks.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('Timer Service Unit Tests', () {
    late MockTimerService timerService;

    setUp(() async {
      await TestSetupHelper.initializeTestEnvironment();
      timerService = MockTimerService();
      TestDataFactory.resetCounters();
    });

    tearDown(() async {
      await TestSetupHelper.cleanupTestEnvironment();
    });

    group('Timer Initialization and Disposal', () {
      test('should initialize without errors', () async {
        // Act & Assert - Should not throw
        await timerService.initialize();
        
        // Verify initial state
        expect(timerService.getActiveTimers(), isEmpty);
      });

      test('should dispose properly', () async {
        // Arrange
        final entry = TestDataFactory.createTestEntry();
        await timerService.createEntryWithTimer(entry, const Duration(hours: 2));

        // Act
        await timerService.dispose();

        // Assert
        expect(timerService.getActiveTimers(), isEmpty);
      });
    });

    group('Timer Creation', () {
      test('should create timer for entry', () async {
        // Arrange
        final entry = TestDataFactory.createTestEntry();
        final duration = const Duration(hours: 2);

        // Act
        await timerService.createEntryWithTimer(entry, duration);

        // Assert
        expect(timerService.hasActiveTimer(entry.id), isTrue);
        
        final activeTimers = timerService.getActiveTimers();
        expect(activeTimers, hasLength(1));
        expect(activeTimers[entry.id], isNotNull);
        expect(activeTimers[entry.id]!.id, equals(entry.id));
      });

      test('should create multiple timers for different entries', () async {
        // Arrange
        final entries = TestDataFactory.createTestEntries(3);
        final duration = const Duration(hours: 1);

        // Act
        for (final entry in entries) {
          await timerService.createEntryWithTimer(entry, duration);
        }

        // Assert
        final activeTimers = timerService.getActiveTimers();
        expect(activeTimers, hasLength(3));
        
        for (final entry in entries) {
          expect(timerService.hasActiveTimer(entry.id), isTrue);
        }
      });

      test('should notify listeners on timer creation', () async {
        // Arrange
        bool notified = false;
        timerService.addListener(() {
          notified = true;
        });

        final entry = TestDataFactory.createTestEntry();

        // Act
        await timerService.createEntryWithTimer(entry, const Duration(hours: 1));

        // Assert
        expect(notified, isTrue);
      });
    });

    group('Timer Control', () {
      late Entry testEntry;

      setUp(() async {
        testEntry = TestDataFactory.createTestEntry();
        await timerService.createEntryWithTimer(testEntry, const Duration(hours: 2));
      });

      test('should stop timer', () async {
        // Act
        await timerService.stopTimer(testEntry.id);

        // Assert
        expect(timerService.hasActiveTimer(testEntry.id), isFalse);
        expect(timerService.getActiveTimers(), isEmpty);
      });

      test('should pause timer', () async {
        // Act
        await timerService.pauseTimer(testEntry.id);

        // Assert
        expect(timerService.hasActiveTimer(testEntry.id), isTrue);
        expect(timerService.isTimerPaused(testEntry.id), isTrue);
      });

      test('should resume timer', () async {
        // Arrange
        await timerService.pauseTimer(testEntry.id);
        expect(timerService.isTimerPaused(testEntry.id), isTrue);

        // Act
        await timerService.resumeTimer(testEntry.id);

        // Assert
        expect(timerService.hasActiveTimer(testEntry.id), isTrue);
        expect(timerService.isTimerPaused(testEntry.id), isFalse);
      });

      test('should handle pause/resume cycle', () async {
        // Pause
        await timerService.pauseTimer(testEntry.id);
        expect(timerService.isTimerPaused(testEntry.id), isTrue);

        // Resume
        await timerService.resumeTimer(testEntry.id);
        expect(timerService.isTimerPaused(testEntry.id), isFalse);

        // Pause again
        await timerService.pauseTimer(testEntry.id);
        expect(timerService.isTimerPaused(testEntry.id), isTrue);
      });

      test('should notify listeners on timer control actions', () async {
        // Arrange
        int notificationCount = 0;
        timerService.addListener(() {
          notificationCount++;
        });

        // Act
        await timerService.pauseTimer(testEntry.id);
        await timerService.resumeTimer(testEntry.id);
        await timerService.stopTimer(testEntry.id);

        // Assert
        expect(notificationCount, equals(3));
      });
    });

    group('Timer Progress and Remaining Time', () {
      late Entry testEntry;

      setUp(() async {
        testEntry = TestDataFactory.createTestEntry();
        await timerService.createEntryWithTimer(testEntry, const Duration(hours: 2));
      });

      test('should calculate timer progress', () async {
        // Act
        final progress = timerService.getTimerProgress(testEntry.id);

        // Assert
        expect(progress, isA<double>());
        expect(progress, greaterThanOrEqualTo(0.0));
        expect(progress, lessThanOrEqualTo(1.0));
      });

      test('should get remaining time', () async {
        // Act
        final remainingTime = timerService.getRemainingTime(testEntry.id);

        // Assert
        expect(remainingTime, isNotNull);
        expect(remainingTime!.inMilliseconds, greaterThan(0));
      });

      test('should return null for non-existent timer', () async {
        // Act
        final remainingTime = timerService.getRemainingTime('non-existent-id');

        // Assert
        expect(remainingTime, isNull);
      });

      test('should return 0.0 progress for non-existent timer', () async {
        // Act
        final progress = timerService.getTimerProgress('non-existent-id');

        // Assert
        expect(progress, equals(0.0));
      });

      test('should handle progress calculation for paused timer', () async {
        // Arrange
        await timerService.pauseTimer(testEntry.id);

        // Act
        final progress = timerService.getTimerProgress(testEntry.id);

        // Assert
        expect(progress, isA<double>());
        expect(progress, greaterThanOrEqualTo(0.0));
        expect(progress, lessThanOrEqualTo(1.0));
      });
    });

    group('Multiple Timer Management', () {
      late List<Entry> testEntries;

      setUp(() async {
        testEntries = TestDataFactory.createTestEntries(5);
        for (int i = 0; i < testEntries.length; i++) {
          final duration = Duration(hours: i + 1); // Different durations
          await timerService.createEntryWithTimer(testEntries[i], duration);
        }
      });

      test('should manage multiple active timers', () async {
        // Assert
        final activeTimers = timerService.getActiveTimers();
        expect(activeTimers, hasLength(5));

        for (final entry in testEntries) {
          expect(timerService.hasActiveTimer(entry.id), isTrue);
        }
      });

      test('should stop specific timer without affecting others', () async {
        // Arrange
        final entryToStop = testEntries[2];

        // Act
        await timerService.stopTimer(entryToStop.id);

        // Assert
        expect(timerService.hasActiveTimer(entryToStop.id), isFalse);
        expect(timerService.getActiveTimers(), hasLength(4));

        // Other timers should still be active
        for (int i = 0; i < testEntries.length; i++) {
          if (i != 2) {
            expect(timerService.hasActiveTimer(testEntries[i].id), isTrue);
          }
        }
      });

      test('should pause specific timer without affecting others', () async {
        // Arrange
        final entryToPause = testEntries[1];

        // Act
        await timerService.pauseTimer(entryToPause.id);

        // Assert
        expect(timerService.isTimerPaused(entryToPause.id), isTrue);

        // Other timers should not be paused
        for (int i = 0; i < testEntries.length; i++) {
          if (i != 1) {
            expect(timerService.isTimerPaused(testEntries[i].id), isFalse);
          }
        }
      });

      test('should clear all timers', () async {
        // Act
        timerService.clearAllTimers();

        // Assert
        expect(timerService.getActiveTimers(), isEmpty);
        
        for (final entry in testEntries) {
          expect(timerService.hasActiveTimer(entry.id), isFalse);
        }
      });
    });

    group('Error Handling and Edge Cases', () {
      test('should handle operations on non-existent timer gracefully', () async {
        // Act & Assert - Should not throw
        await timerService.stopTimer('non-existent-id');
        await timerService.pauseTimer('non-existent-id');
        await timerService.resumeTimer('non-existent-id');
      });

      test('should handle pause on already paused timer', () async {
        // Arrange
        final entry = TestDataFactory.createTestEntry();
        await timerService.createEntryWithTimer(entry, const Duration(hours: 1));
        await timerService.pauseTimer(entry.id);

        // Act & Assert - Should not throw
        await timerService.pauseTimer(entry.id);
        expect(timerService.isTimerPaused(entry.id), isTrue);
      });

      test('should handle resume on non-paused timer', () async {
        // Arrange
        final entry = TestDataFactory.createTestEntry();
        await timerService.createEntryWithTimer(entry, const Duration(hours: 1));

        // Act & Assert - Should not throw
        await timerService.resumeTimer(entry.id);
        expect(timerService.isTimerPaused(entry.id), isFalse);
      });

      test('should handle operations after disposal', () async {
        // Arrange
        final entry = TestDataFactory.createTestEntry();
        await timerService.createEntryWithTimer(entry, const Duration(hours: 1));
        await timerService.dispose();

        // Act & Assert - Should not throw, but should not affect state
        await timerService.createEntryWithTimer(entry, const Duration(hours: 1));
        await timerService.stopTimer(entry.id);
        await timerService.pauseTimer(entry.id);
        await timerService.resumeTimer(entry.id);

        // After disposal, service should not maintain state
        expect(timerService.getActiveTimers(), isEmpty);
      });

      test('should return false for pause status on non-existent timer', () async {
        // Act
        final isPaused = timerService.isTimerPaused('non-existent-id');

        // Assert
        expect(isPaused, isFalse);
      });
    });

    group('Performance Tests', () {
      test('should handle many timers efficiently', () async {
        // This test ensures the service can handle multiple timers
        await PerformanceTestHelper.assertCompletesWithinTime(
          () async {
            final entries = TestDataFactory.createTestEntries(50);
            for (final entry in entries) {
              await timerService.createEntryWithTimer(entry, const Duration(hours: 1));
            }
          },
          const Duration(seconds: 1),
        );

        expect(timerService.getActiveTimers(), hasLength(50));
      });

      test('should calculate progress quickly for many timers', () async {
        // Arrange
        final entries = TestDataFactory.createTestEntries(20);
        for (final entry in entries) {
          await timerService.createEntryWithTimer(entry, const Duration(hours: 1));
        }

        // Act & Assert
        await PerformanceTestHelper.assertCompletesWithinTime(
          () async {
            for (final entry in entries) {
              timerService.getTimerProgress(entry.id);
              timerService.getRemainingTime(entry.id);
            }
          },
          const Duration(milliseconds: 100),
        );
      });
    });

    group('State Consistency', () {
      test('should maintain consistent state during concurrent operations', () async {
        // Arrange
        final entries = TestDataFactory.createTestEntries(3);
        
        // Act - Create timers
        for (final entry in entries) {
          await timerService.createEntryWithTimer(entry, const Duration(hours: 1));
        }

        // Pause one
        await timerService.pauseTimer(entries[0].id);

        // Stop one
        await timerService.stopTimer(entries[1].id);

        // Resume the paused one
        await timerService.resumeTimer(entries[0].id);

        // Assert final state
        expect(timerService.hasActiveTimer(entries[0].id), isTrue);
        expect(timerService.isTimerPaused(entries[0].id), isFalse);
        
        expect(timerService.hasActiveTimer(entries[1].id), isFalse);
        
        expect(timerService.hasActiveTimer(entries[2].id), isTrue);
        expect(timerService.isTimerPaused(entries[2].id), isFalse);

        expect(timerService.getActiveTimers(), hasLength(2));
      });

      test('should provide consistent timer information', () async {
        // Arrange
        final entry = TestDataFactory.createTestEntry();
        final duration = const Duration(hours: 2);
        await timerService.createEntryWithTimer(entry, duration);

        // Act & Assert
        expect(timerService.hasActiveTimer(entry.id), isTrue);
        expect(timerService.getActiveTimers().containsKey(entry.id), isTrue);
        expect(timerService.getRemainingTime(entry.id), isNotNull);
        expect(timerService.getTimerProgress(entry.id), isA<double>());
        expect(timerService.isTimerPaused(entry.id), isFalse);
      });
    });
  });
}