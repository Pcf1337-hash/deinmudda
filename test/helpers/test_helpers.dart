/// Test Helpers and Utilities
/// 
/// Phase 6: Testing Implementation - Test Utilities
/// Provides utilities for setting up tests with ServiceLocator architecture
/// 
/// Author: Code Quality Improvement Agent
/// Date: Phase 6 - Testing Implementation

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/utils/service_locator.dart';
import '../../lib/models/entry.dart';
import '../../lib/models/substance.dart';
import '../mocks/service_mocks.dart';

/// Test setup utilities for ServiceLocator-based testing
class TestSetupHelper {
  static bool _isInitialized = false;

  /// Initialize test environment with mock services
  static Future<void> initializeTestEnvironment() async {
    if (_isInitialized) {
      await resetTestEnvironment();
      return;
    }

    // Register all mock services in ServiceLocator
    await ServiceLocator.initializeForTesting({
      'entryService': MockEntryService(),
      'substanceService': MockSubstanceService(),
      'timerService': MockTimerService(),
      'notificationService': MockNotificationService(),
      'settingsService': MockSettingsService(),
      'authService': MockAuthService(),
    });

    _isInitialized = true;
  }

  /// Reset all services to clean state for new test
  static Future<void> resetTestEnvironment() async {
    if (!_isInitialized) return;

    // Clear all mock services
    final entryService = ServiceLocator.get<MockEntryService>();
    final substanceService = ServiceLocator.get<MockSubstanceService>();
    final timerService = ServiceLocator.get<MockTimerService>();
    final notificationService = ServiceLocator.get<MockNotificationService>();
    final settingsService = ServiceLocator.get<MockSettingsService>();
    final authService = ServiceLocator.get<MockAuthService>();

    entryService.clearAllEntries();
    substanceService.clearAllSubstances();
    timerService.clearAllTimers();
    notificationService.clearNotifications();
    settingsService.clearAllSettings();
    authService.setMockAuthenticated(false);
    authService.setMockBiometricEnabled(false);

    // Re-initialize with default settings
    await settingsService.initialize();
  }

  /// Cleanup test environment
  static Future<void> cleanupTestEnvironment() async {
    if (_isInitialized) {
      await ServiceLocator.dispose();
      _isInitialized = false;
    }
  }
}

/// Factory for creating test data
class TestDataFactory {
  static int _entryCounter = 0;
  static int _substanceCounter = 0;

  /// Create a test substance with optional parameters
  static Substance createTestSubstance({
    String? name,
    SubstanceCategory? category,
    RiskLevel? riskLevel,
    double? pricePerUnit,
    String? defaultUnit,
    Duration? duration,
    String? notes,
  }) {
    _substanceCounter++;
    return Substance.create(
      name: name ?? 'Test Substance $_substanceCounter',
      category: category ?? SubstanceCategory.medication,
      defaultRiskLevel: riskLevel ?? RiskLevel.low,
      pricePerUnit: pricePerUnit ?? 10.0,
      defaultUnit: defaultUnit ?? 'mg',
      duration: duration,
      notes: notes ?? 'Test substance notes',
    );
  }

  /// Create a test entry with optional parameters
  static Entry createTestEntry({
    String? substanceId,
    String? substanceName,
    double? dosage,
    String? unit,
    DateTime? timestamp,
    DateTime? timerStartTime,
    Duration? duration,
    String? notes,
  }) {
    _entryCounter++;
    return Entry.create(
      substanceId: substanceId ?? 'test-substance-id-$_entryCounter',
      substanceName: substanceName ?? 'Test Substance $_entryCounter',
      dosage: dosage ?? 10.0,
      unit: unit ?? 'mg',
      timestamp: timestamp ?? DateTime.now(),
      timerStartTime: timerStartTime,
      duration: duration,
      notes: notes ?? 'Test entry notes',
    );
  }

  /// Create a test entry with timer
  static Entry createTestEntryWithTimer({
    String? substanceId,
    String? substanceName,
    double? dosage,
    String? unit,
    DateTime? timestamp,
    Duration? duration,
    String? notes,
  }) {
    return createTestEntry(
      substanceId: substanceId,
      substanceName: substanceName,
      dosage: dosage,
      unit: unit,
      timestamp: timestamp,
      timerStartTime: DateTime.now(),
      duration: duration ?? const Duration(hours: 2),
      notes: notes,
    );
  }

  /// Create multiple test substances
  static List<Substance> createTestSubstances(int count) {
    return List.generate(count, (index) => createTestSubstance(
      name: 'Test Substance ${index + 1}',
      category: SubstanceCategory.values[index % SubstanceCategory.values.length],
    ));
  }

  /// Create multiple test entries
  static List<Entry> createTestEntries(int count, {List<String>? substanceIds}) {
    return List.generate(count, (index) => createTestEntry(
      substanceId: substanceIds?[index % substanceIds.length] ?? 'substance-$index',
      substanceName: 'Substance ${index + 1}',
      dosage: (index + 1) * 5.0,
    ));
  }

  /// Reset counters for consistent test data
  static void resetCounters() {
    _entryCounter = 0;
    _substanceCounter = 0;
  }
}

/// Widget test utilities
class WidgetTestHelper {
  /// Create a test app wrapper with providers
  static Widget createTestApp({
    required Widget child,
    bool useRealRouter = false,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
      // Add theme data if needed
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
    );
  }

  /// Pump widget with proper setup
  static Future<void> pumpTestWidget(
    WidgetTester tester,
    Widget widget, {
    Duration? duration,
  }) async {
    await tester.pumpWidget(createTestApp(child: widget));
    if (duration != null) {
      await tester.pump(duration);
    }
  }

  /// Common expectations for no overflow
  static void expectNoOverflow(WidgetTester tester) {
    expect(tester.takeException(), isNull, reason: 'Widget should not have overflow errors');
  }

  /// Simulate time passing for timer tests
  static Future<void> simulateTimeElapsed(WidgetTester tester, Duration duration) async {
    await tester.binding.delayed(duration);
    await tester.pump();
  }
}

/// Mock data presets for common test scenarios
class TestDataPresets {
  /// Create a typical substance library
  static List<Substance> createTypicalSubstanceLibrary() {
    return [
      TestDataFactory.createTestSubstance(
        name: 'Caffeine',
        category: SubstanceCategory.stimulant,
        defaultUnit: 'mg',
        duration: const Duration(hours: 6),
      ),
      TestDataFactory.createTestSubstance(
        name: 'Melatonin',
        category: SubstanceCategory.supplement,
        defaultUnit: 'mg',
        duration: const Duration(hours: 8),
      ),
      TestDataFactory.createTestSubstance(
        name: 'Ibuprofen',
        category: SubstanceCategory.medication,
        defaultUnit: 'mg',
        duration: const Duration(hours: 6),
      ),
      TestDataFactory.createTestSubstance(
        name: 'Alcohol',
        category: SubstanceCategory.depressant,
        defaultUnit: 'ml',
        duration: const Duration(hours: 4),
      ),
    ];
  }

  /// Create recent entries for testing
  static List<Entry> createRecentEntries() {
    final now = DateTime.now();
    final substances = createTypicalSubstanceLibrary();
    
    return [
      TestDataFactory.createTestEntry(
        substanceId: substances[0].id,
        substanceName: substances[0].name,
        dosage: 200.0,
        unit: 'mg',
        timestamp: now.subtract(const Duration(hours: 2)),
      ),
      TestDataFactory.createTestEntry(
        substanceId: substances[1].id,
        substanceName: substances[1].name,
        dosage: 3.0,
        unit: 'mg',
        timestamp: now.subtract(const Duration(hours: 8)),
      ),
      TestDataFactory.createTestEntry(
        substanceId: substances[2].id,
        substanceName: substances[2].name,
        dosage: 400.0,
        unit: 'mg',
        timestamp: now.subtract(const Duration(hours: 4)),
      ),
    ];
  }

  /// Create entries with active timers
  static List<Entry> createActiveTimerEntries() {
    final now = DateTime.now();
    final substances = createTypicalSubstanceLibrary();
    
    return [
      TestDataFactory.createTestEntryWithTimer(
        substanceId: substances[0].id,
        substanceName: substances[0].name,
        dosage: 200.0,
        unit: 'mg',
        timestamp: now.subtract(const Duration(minutes: 30)),
        duration: const Duration(hours: 6),
      ),
      TestDataFactory.createTestEntryWithTimer(
        substanceId: substances[3].id,
        substanceName: substances[3].name,
        dosage: 100.0,
        unit: 'ml',
        timestamp: now.subtract(const Duration(minutes: 45)),
        duration: const Duration(hours: 4),
      ),
    ];
  }
}

/// Assertion helpers for common test scenarios
class TestAssertions {
  /// Assert that a substance has expected properties
  static void assertSubstanceProperties(
    Substance substance,
    String expectedName,
    SubstanceCategory expectedCategory,
  ) {
    expect(substance.name, equals(expectedName));
    expect(substance.category, equals(expectedCategory));
    expect(substance.id, isNotEmpty);
    expect(substance.createdAt, isNotNull);
  }

  /// Assert that an entry has expected properties
  static void assertEntryProperties(
    Entry entry,
    String expectedSubstanceId,
    double expectedDosage,
  ) {
    expect(entry.substanceId, equals(expectedSubstanceId));
    expect(entry.dosage, equals(expectedDosage));
    expect(entry.id, isNotEmpty);
    expect(entry.timestamp, isNotNull);
  }

  /// Assert that timer is active
  static void assertTimerActive(Entry entry) {
    expect(entry.timerStartTime, isNotNull);
    expect(entry.duration, isNotNull);
    expect(entry.isTimerActive, isTrue);
  }

  /// Assert that timer is not active
  static void assertTimerInactive(Entry entry) {
    expect(entry.isTimerActive, isFalse);
  }

  /// Assert notification was sent
  static void assertNotificationSent(
    MockNotificationService notificationService,
    String expectedEntryId,
  ) {
    expect(
      notificationService.hasNotificationForEntry(expectedEntryId),
      isTrue,
      reason: 'Notification should be sent for entry $expectedEntryId',
    );
  }

  /// Assert settings value
  static Future<void> assertSettingValue<T>(
    MockSettingsService settingsService,
    String key,
    T expectedValue,
  ) async {
    final actualValue = await settingsService.get<T>(key);
    expect(actualValue, equals(expectedValue));
  }
}

/// Performance testing utilities
class PerformanceTestHelper {
  /// Measure execution time of an operation
  static Future<Duration> measureExecutionTime(Future<void> Function() operation) async {
    final stopwatch = Stopwatch()..start();
    await operation();
    stopwatch.stop();
    return stopwatch.elapsed;
  }

  /// Assert operation completes within time limit
  static Future<void> assertCompletesWithinTime(
    Future<void> Function() operation,
    Duration maxDuration,
  ) async {
    final executionTime = await measureExecutionTime(operation);
    expect(
      executionTime.inMilliseconds,
      lessThan(maxDuration.inMilliseconds),
      reason: 'Operation took ${executionTime.inMilliseconds}ms, expected < ${maxDuration.inMilliseconds}ms',
    );
  }

  /// Stress test with multiple operations
  static Future<void> stressTest(
    Future<void> Function() operation,
    int iterations,
  ) async {
    for (int i = 0; i < iterations; i++) {
      await operation();
    }
  }
}

/// Error testing utilities
class ErrorTestHelper {
  /// Expect operation to throw specific error
  static Future<void> expectThrows<T extends Exception>(
    Future<void> Function() operation,
  ) async {
    try {
      await operation();
      fail('Expected operation to throw $T');
    } catch (e) {
      expect(e, isA<T>());
    }
  }

  /// Expect operation to handle error gracefully
  static Future<void> expectHandlesErrorGracefully(
    Future<void> Function() operation,
  ) async {
    try {
      await operation();
      // Should not throw
    } catch (e) {
      fail('Operation should handle errors gracefully, but threw: $e');
    }
  }
}