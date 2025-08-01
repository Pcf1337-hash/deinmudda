import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:konsum_tracker_pro/models/xtc_entry.dart';
import 'package:konsum_tracker_pro/models/quick_button_config.dart';
import 'package:konsum_tracker_pro/services/xtc_entry_service.dart';
import 'package:konsum_tracker_pro/services/quick_button_service.dart';
import 'package:konsum_tracker_pro/interfaces/service_interfaces.dart';
import 'package:konsum_tracker_pro/utils/service_locator.dart';
import 'package:konsum_tracker_pro/use_cases/entry_use_cases.dart';

/// Test to verify the compilation fixes are working correctly
void main() {
  group('Compilation Fixes Tests', () {
    test('XtcEntryService can be instantiated without compilation errors', () {
      // This test verifies that the XtcEntryService constructor
      // and method calls compile correctly after the fixes
      
      // Mock services for testing
      final mockEntryService = MockEntryService();
      final mockQuickButtonService = MockQuickButtonService();
      final mockCreateEntryUseCase = MockCreateEntryUseCase();
      final mockCreateEntryWithTimerUseCase = MockCreateEntryWithTimerUseCase();

      // This should not cause compilation errors
      final xtcEntryService = XtcEntryService(
        entryService: mockEntryService,
        quickButtonService: mockQuickButtonService,
        createEntryUseCase: mockCreateEntryUseCase,
        createEntryWithTimerUseCase: mockCreateEntryWithTimerUseCase,
      );

      expect(xtcEntryService, isNotNull);
    });

    test('QuickButtonService has saveQuickButton method', () {
      // This test verifies that the saveQuickButton method exists
      // and can be called without compilation errors
      
      final mockDatabase = MockDatabaseService();
      final mockSubstanceService = MockSubstanceService();
      final quickButtonService = QuickButtonService(mockDatabase, mockSubstanceService);
      
      // The saveQuickButton method should exist
      expect(quickButtonService.saveQuickButton, isNotNull);
    });

    test('ServiceLocator has static get method (not instance)', () {
      // This test verifies that ServiceLocator.get<T>() works
      // without needing .instance
      
      // The get method should be static and accessible
      expect(ServiceLocator.get, isNotNull);
    });

    test('XtcEntry model creates correctly', () {
      // Basic functionality test to ensure model still works
      final entry = XtcEntry.create(
        substanceName: 'Test Entry',
        form: XtcForm.rechteck,
        bruchrillienAnzahl: 2,
        content: XtcContent.mdma,
        size: XtcSize.full,
        dosageMg: 100.0,
        color: Colors.pink,
        dateTime: DateTime.now(),
      );

      expect(entry.substanceName, equals('Test Entry'));
      expect(entry.dosageMg, equals(100.0));
      expect(entry.bruchrillienAnzahl, equals(2));
    });
  });
}

// Mock classes for testing
class MockEntryService implements IEntryService {
  @override
  Future<String> createEntry(entry) async => 'mock-id';
  @override
  Future<String> addEntry(entry) async => 'mock-id';
  @override
  Future<createEntryWithTimer(entry, {customDuration, required timerService}) async => entry;
  @override
  Future<List> getAllEntries() async => [];
  @override
  Future<List> getEntriesByDateRange(start, end) async => [];
  @override
  Future<List> getEntriesBySubstance(substanceId) async => [];
  @override
  Future getEntryById(id) async => null;
  @override
  Future<void> updateEntry(entry) async {}
  @override
  Future<void> deleteEntry(id) async {}
  @override
  Future<List> getActiveTimerEntries() async => [];
  @override
  Future<void> updateEntryTimer(id, timerStartTime, duration) async {}
  @override
  Future<Map<String, dynamic>> getStatistics() async => {};
  @override
  Future<Map<String, dynamic>> getCostStatistics() async => {};
  @override
  Future<List> advancedSearch(searchParams) async => [];
  @override
  Future<int> importEntriesFromJson(jsonString) async => 0;
  @override
  void addListener(listener) {}
  @override
  void removeListener(listener) {}
  @override
  void dispose() {}
  @override
  bool get hasListeners => false;
  @override
  void notifyListeners() {}
}

class MockQuickButtonService implements IQuickButtonService {
  @override
  Future<String> createQuickButton(config) async => 'mock-id';
  @override
  Future<String> saveQuickButton(config) async => 'mock-id';
  @override
  Future<List<QuickButtonConfig>> getAllQuickButtons() async => [];
  @override
  Future<QuickButtonConfig?> getQuickButtonById(id) async => null;
  @override
  Future<void> updateQuickButton(config) async {}
  @override
  Future<void> deleteQuickButton(id) async {}
  @override
  Future<void> reorderQuickButtons(orderedIds) async {}
  @override
  Future executeQuickButton(quickButtonId) async => null;
  @override
  Future<void> toggleQuickButtonActive(id, isActive) async {}
  @override
  Future<List<QuickButtonConfig>> getActiveQuickButtons() async => [];
  @override
  Future<void> updateQuickButtonPosition(id, newPosition) async {}
  @override
  Future<int> getNextOrderIndex() async => 0;
}

class MockCreateEntryUseCase {
  Future<String> execute({
    required String substanceId,
    required double dosage,
    required String unit,
    DateTime? dateTime,
    String? notes,
    double cost = 0.0,
  }) async => 'mock-id';
}

class MockCreateEntryWithTimerUseCase {
  Future execute({
    required String substanceId,
    required double dosage,
    required String unit,
    DateTime? dateTime,
    String? notes,
    double cost = 0.0,
    Duration? customDuration,
  }) async => null;
}

class MockDatabaseService {
  Future get database async => null;
}

class MockSubstanceService implements ISubstanceService {
  @override
  Future<String> createSubstance(substance) async => 'mock-id';
  @override
  Future<List> getAllSubstances() async => [];
  @override
  Future getSubstanceById(id) async => null;
  @override
  Future getSubstanceByName(name) async => null;
  @override
  Future<void> updateSubstance(substance) async {}
  @override
  Future<void> deleteSubstance(id) async {}
  @override
  Future<List> searchSubstances(query) async => [];
  @override
  Future<List> getSubstancesByCategory(category) async => [];
  @override
  Future<List> getMostUsedSubstances({limit = 10}) async => [];
  @override
  Future<void> initializeDefaultSubstances() async {}
  @override
  Future<List<String>> getAllUsedUnits() async => [];
  @override
  Future<List<String>> getSuggestedUnits() async => [];
  @override
  Future<bool> unitExists(unit) async => false;
  @override
  Future<List> getSubstancesByUnit(unit) async => [];
  @override
  String? validateUnit(unit) => null;
  @override
  List<String> getRecommendedUnitsForCategory(category) => [];
  @override
  void addListener(listener) {}
  @override
  void removeListener(listener) {}
  @override
  void dispose() {}
  @override
  bool get hasListeners => false;
  @override
  void notifyListeners() {}
}