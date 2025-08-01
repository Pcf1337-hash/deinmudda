import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:konsum_tracker_pro/models/quick_button_config.dart';
import 'package:konsum_tracker_pro/utils/service_locator.dart';
import 'package:konsum_tracker_pro/services/xtc_entry_service.dart';
import 'package:konsum_tracker_pro/interfaces/service_interfaces.dart';
import 'package:konsum_tracker_pro/use_cases/entry_use_cases.dart';

/// Test to verify the XTC ServiceLocator fix is working correctly
void main() {
  group('XTC ServiceLocator Fix Tests', () {
    
    test('ServiceLocator can register XtcEntryService correctly', () async {
      // Mock services needed for XtcEntryService initialization
      final mockServices = {
        'entryService': MockEntryService(),
        'quickButtonService': MockQuickButtonService(),
      };
      
      // Initialize ServiceLocator for testing
      await ServiceLocator.initializeForTesting(mockServices);
      
      // Manually register the use cases that XtcEntryService needs
      ServiceLocator.register<CreateEntryUseCase>(MockCreateEntryUseCase());
      ServiceLocator.register<CreateEntryWithTimerUseCase>(MockCreateEntryWithTimerUseCase());
      
      // Manually register XtcEntryService like in the real initialization
      final xtcEntryService = XtcEntryService(
        entryService: mockServices['entryService'] as IEntryService,
        quickButtonService: mockServices['quickButtonService'] as IQuickButtonService,
        createEntryUseCase: ServiceLocator.get<CreateEntryUseCase>(),
        createEntryWithTimerUseCase: ServiceLocator.get<CreateEntryWithTimerUseCase>(),
      );
      ServiceLocator.register<XtcEntryService>(xtcEntryService);
      
      // Test that XtcEntryService can be retrieved from ServiceLocator
      expect(() => ServiceLocator.get<XtcEntryService>(), returnsNormally);
      
      final retrievedService = ServiceLocator.get<XtcEntryService>();
      expect(retrievedService, isNotNull);
      expect(retrievedService, isA<XtcEntryService>());
      
      await ServiceLocator.dispose();
    });
    
    test('ServiceLocator provides helpful error when service is missing', () {
      // Reset ServiceLocator
      ServiceLocator.dispose();
      
      // Try to get XtcEntryService when ServiceLocator is not initialized
      expect(
        () => ServiceLocator.get<XtcEntryService>(),
        throwsA(isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('ServiceLocator not initialized'),
        )),
      );
    });
    
    test('ServiceLocator provides helpful error with debug info when service not found', () async {
      // Initialize with limited mock services
      final mockServices = {
        'entryService': MockEntryService(),
      };
      
      await ServiceLocator.initializeForTesting(mockServices);
      
      // Try to get XtcEntryService when it's not registered
      expect(
        () => ServiceLocator.get<XtcEntryService>(),
        throwsA(isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('Service of type XtcEntryService not found'),
        )),
      );
      
      await ServiceLocator.dispose();
    });
    
    test('Quick button config can identify XTC entries correctly', () {
      // Test XTC virtual substance ID pattern recognition
      final xtcQuickButton = QuickButtonConfig.create(
        substanceId: 'xtc_virtual_test-id-123',
        substanceName: 'Pink Superman',
        dosage: 120.0,
        unit: 'mg',
        position: 0,
        icon: Icons.medication_rounded,
        color: Colors.pink,
      );
      
      // Test that we can identify XTC quick buttons by their virtual substance ID
      expect(xtcQuickButton.substanceId.startsWith('xtc_virtual_'), isTrue);
      
      final regularQuickButton = QuickButtonConfig.create(
        substanceId: 'regular-substance-id',
        substanceName: 'LSD',
        dosage: 150.0,
        unit: 'μg',
        position: 1,
      );
      
      // Test that regular quick buttons don't match the XTC pattern
      expect(regularQuickButton.substanceId.startsWith('xtc_virtual_'), isFalse);
    });
    
    test('ServiceLocator registration info provides debugging data', () async {
      final mockServices = {
        'entryService': MockEntryService(),
        'quickButtonService': MockQuickButtonService(),
      };
      
      await ServiceLocator.initializeForTesting(mockServices);
      
      final info = ServiceLocator.getRegistrationInfo();
      expect(info, contains('ServiceLocator Status:'));
      expect(info, contains('Initialized: true'));
      expect(info, contains('Services count:'));
      expect(info, contains('Registered services:'));
      
      await ServiceLocator.dispose();
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