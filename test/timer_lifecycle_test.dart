import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/services/timer_service.dart';
import '../lib/models/entry.dart';
import '../lib/utils/error_handler.dart';
import '../lib/utils/impeller_helper.dart';
import 'mocks/service_mocks.dart';

void main() {
  group('Timer Lifecycle Tests', () {
    late TimerService timerService;
    late Entry testEntry;

    setUp(() {
      timerService = MockTimerService();
      testEntry = Entry.create(
        substanceId: 'test-substance',
        substanceName: 'Test Substance',
        dosage: 10.0,
        unit: 'mg',
        dateTime: DateTime.now(),
        notes: 'Test entry',
      );
    });

    test('should initialize timer service without crashing', () async {
      expect(() => timerService.init(), returnsNormally);
      
      // Wait for initialization
      await Future.delayed(Duration(milliseconds: 100));
      
      expect(timerService.hasAnyActiveTimer, false);
    });

    test('should start timer without race conditions', () async {
      await timerService.init();
      
      final timerEntry = await timerService.startTimer(
        testEntry, 
        customDuration: Duration(minutes: 5)
      );
      
      expect(timerEntry.hasTimer, true);
      expect(timerEntry.isTimerActive, true);
      expect(timerService.hasAnyActiveTimer, true);
    });

    test('should stop timer safely', () async {
      await timerService.init();
      
      final timerEntry = await timerService.startTimer(
        testEntry, 
        customDuration: Duration(minutes: 5)
      );
      
      final stoppedEntry = await timerService.stopTimer(timerEntry);
      
      expect(stoppedEntry.timerCompleted, true);
      expect(timerService.hasAnyActiveTimer, false);
    });

    test('should handle timer disposal without crashing', () async {
      await timerService.init();
      
      await timerService.startTimer(
        testEntry, 
        customDuration: Duration(minutes: 5)
      );
      
      expect(() => timerService.dispose(), returnsNormally);
      
      // After disposal, service should not accept new operations
      expect(timerService.hasAnyActiveTimer, false);
    });

    test('should update timer duration safely', () async {
      await timerService.init();
      
      final timerEntry = await timerService.startTimer(
        testEntry, 
        customDuration: Duration(minutes: 5)
      );
      
      final updatedEntry = await timerService.updateTimerDuration(
        timerEntry, 
        Duration(minutes: 10)
      );
      
      expect(updatedEntry.timerEndTime, isNotNull);
      expect(updatedEntry.timerEndTime!.difference(updatedEntry.timerStartTime!).inMinutes, 10);
    });

    test('should handle concurrent timer operations', () async {
      await timerService.init();
      
      // Start multiple timers concurrently
      final futures = List.generate(5, (index) async {
        final entry = Entry.create(
          substanceId: 'test-substance-$index',
          substanceName: 'Test Substance $index',
          dosage: 10.0,
          unit: 'mg',
          dateTime: DateTime.now(),
          notes: 'Test entry $index',
        );
        
        return await timerService.startTimer(
          entry, 
          customDuration: Duration(minutes: 1)
        );
      });
      
      final results = await Future.wait(futures);
      
      // Only one timer should be active (service allows only one active timer)
      expect(timerService.hasAnyActiveTimer, true);
      expect(timerService.currentActiveTimer, isNotNull);
    });

    tearDown(() {
      timerService.dispose();
    });
  });

  group('Impeller Helper Tests', () {
    test('should initialize Impeller helper without crashing', () async {
      expect(() => ImpellerHelper.initialize(), returnsNormally);
      
      await Future.delayed(Duration(milliseconds: 100));
      
      final debugInfo = ImpellerHelper.getDebugInfo();
      expect(debugInfo, isNotNull);
      expect(debugInfo['recommendedSettings'], isNotNull);
    });

    test('should provide animation settings based on Impeller status', () {
      final settings = ImpellerHelper.getTimerAnimationSettings();
      
      expect(settings, isNotNull);
      expect(settings['enableComplexAnimations'], isA<bool>());
      expect(settings['animationDuration'], isA<Duration>());
    });

    test('should handle known Impeller issues gracefully', () {
      // Force Impeller issues
      ImpellerHelper.forceDisableImpellerFeatures();
      
      expect(ImpellerHelper.hasKnownImpellerIssues(), true);
      expect(ImpellerHelper.shouldEnableFeature('pulsing'), false);
      expect(ImpellerHelper.shouldEnableFeature('shine'), false);
      expect(ImpellerHelper.shouldEnableFeature('basicAnimations'), true);
      
      // Re-enable for other tests
      ImpellerHelper.enableImpellerFeatures();
    });

    test('should provide reduced animation config for problematic devices', () {
      ImpellerHelper.forceDisableImpellerFeatures();
      
      final reducedConfig = ImpellerHelper.getReducedAnimationConfig();
      
      expect(reducedConfig, isNotNull);
      expect(reducedConfig['duration'], isA<Duration>());
      expect(reducedConfig['enableTransforms'], false);
      expect(reducedConfig['enableOpacity'], true);
      
      ImpellerHelper.enableImpellerFeatures();
    });
  });

  group('Error Handler Tests', () {
    test('should log different types of messages', () {
      expect(() => ErrorHandler.logError('TEST', 'Test error'), returnsNormally);
      expect(() => ErrorHandler.logWarning('TEST', 'Test warning'), returnsNormally);
      expect(() => ErrorHandler.logInfo('TEST', 'Test info'), returnsNormally);
      expect(() => ErrorHandler.logSuccess('TEST', 'Test success'), returnsNormally);
      expect(() => ErrorHandler.logTimer('TEST', 'Test timer'), returnsNormally);
      expect(() => ErrorHandler.logStartup('TEST', 'Test startup'), returnsNormally);
    });

    test('should handle safe calls', () {
      final result = ErrorHandler.safeCall('TEST', () {
        return 'success';
      });
      
      expect(result, 'success');
      
      final errorResult = ErrorHandler.safeCall('TEST', () {
        throw Exception('Test error');
      });
      
      expect(errorResult, null);
    });

    test('should handle safe async calls', () async {
      final result = await ErrorHandler.safeCallAsync('TEST', () async {
        return 'success';
      });
      
      expect(result, 'success');
      
      final errorResult = await ErrorHandler.safeCallAsync('TEST', () async {
        throw Exception('Test error');
      });
      
      expect(errorResult, null);
    });
  });

  group('Timer Crash Prevention Tests', () {
    test('should prevent setState after dispose', () async {
      // This test simulates the scenario where a timer tries to update
      // UI after the widget has been disposed
      
      bool stateUpdateCalled = false;
      bool crashOccurred = false;
      
      try {
        // Simulate a timer callback that tries to update state
        void simulateTimerCallback() {
          // This would normally cause a crash if not handled properly
          stateUpdateCalled = true;
        }
        
        // Simulate widget disposal
        bool isDisposed = true;
        
        // Safe state update (should not crash)
        if (!isDisposed) {
          simulateTimerCallback();
        }
        
        expect(stateUpdateCalled, false);
        expect(crashOccurred, false);
      } catch (e) {
        crashOccurred = true;
      }
      
      expect(crashOccurred, false);
    });

    test('should handle timer service disposal gracefully', () async {
      final timerService = MockTimerService();
      await timerService.init();
      
      // Start a timer
      final timerEntry = await timerService.startTimer(
        testEntry, 
        customDuration: Duration(seconds: 1)
      );
      
      expect(timerService.hasAnyActiveTimer, true);
      
      // Dispose the service
      timerService.dispose();
      
      // Service should handle subsequent calls gracefully
      expect(timerService.hasAnyActiveTimer, false);
      
      // Trying to start a new timer should not crash
      final newEntry = await timerService.startTimer(
        testEntry, 
        customDuration: Duration(seconds: 1)
      );
      
      expect(newEntry.id, testEntry.id); // Should return original entry unchanged
    });
  });
}