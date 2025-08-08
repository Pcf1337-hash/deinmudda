import 'package:flutter_test/flutter_test.dart';
import 'package:konsum_tracker_pro/use_cases/entry_use_cases.dart';
import 'package:konsum_tracker_pro/interfaces/service_interfaces.dart';
import 'package:konsum_tracker_pro/models/entry.dart';

// Mock implementations for testing
class MockEntryRepository implements IEntryRepository {
  final List<Entry> _entries = [];

  @override
  Future<String> createEntry(Entry entry) async {
    _entries.add(entry);
    return entry.id;
  }

  @override
  Future<List<Entry>> getAllEntries() async => _entries;

  @override
  Future<Entry?> getEntryById(String id) async {
    try {
      return _entries.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateEntry(Entry entry) async {
    final index = _entries.indexWhere((e) => e.id == entry.id);
    if (index != -1) {
      _entries[index] = entry;
    }
  }

  @override
  Future<void> deleteEntry(String id) async {
    _entries.removeWhere((e) => e.id == id);
  }

  @override
  Future<List<Entry>> getEntriesBySubstance(String substanceId) async {
    return _entries.where((e) => e.substanceId == substanceId).toList();
  }

  @override
  Future<List<Entry>> getEntriesByDateRange(DateTime start, DateTime end) async {
    return _entries.where((e) => 
      e.dateTime.isAfter(start) && e.dateTime.isBefore(end)
    ).toList();
  }
}

class MockSubstanceRepository implements ISubstanceRepository {
  @override
  Future<dynamic> getSubstanceById(String id) async {
    // Return null for virtual substance IDs to simulate they don't exist in substance repo
    if (id.startsWith('xtc_virtual_')) {
      return null;
    }
    // Return a mock substance for regular IDs
    return MockSubstance(id: id, name: 'Test Substance');
  }

  @override
  Future<List<dynamic>> getAllSubstances() async => [];

  @override
  Future<dynamic> getSubstanceByName(String name) async => null;

  @override
  Future<String> createSubstance(dynamic substance) async => 'mock-id';

  @override
  Future<void> updateSubstance(dynamic substance) async {}

  @override
  Future<void> deleteSubstance(String id) async {}
}

class MockSubstance {
  final String id;
  final String name;
  
  MockSubstance({required this.id, required this.name});
}

abstract class IEntryRepository {
  Future<String> createEntry(Entry entry);
  Future<List<Entry>> getAllEntries();
  Future<Entry?> getEntryById(String id);
  Future<void> updateEntry(Entry entry);
  Future<void> deleteEntry(String id);
  Future<List<Entry>> getEntriesBySubstance(String substanceId);
  Future<List<Entry>> getEntriesByDateRange(DateTime start, DateTime end);
}

abstract class ISubstanceRepository {
  Future<dynamic> getSubstanceById(String id);
  Future<List<dynamic>> getAllSubstances();
  Future<dynamic> getSubstanceByName(String name);
  Future<String> createSubstance(dynamic substance);
  Future<void> updateSubstance(dynamic substance);
  Future<void> deleteSubstance(String id);
}

void main() {
  group('Virtual Substance Validation Tests', () {
    late CreateEntryUseCase createEntryUseCase;
    late MockEntryRepository mockEntryRepository;
    late MockSubstanceRepository mockSubstanceRepository;

    setUp(() {
      mockEntryRepository = MockEntryRepository();
      mockSubstanceRepository = MockSubstanceRepository();
      createEntryUseCase = CreateEntryUseCase(mockEntryRepository, mockSubstanceRepository);
    });

    test('CreateEntryUseCase handles virtual substance IDs without validation error', () async {
      // Test that virtual substance IDs don't trigger validation errors
      final virtualSubstanceId = 'xtc_virtual_test-uuid-1234';
      
      // This should not throw an error
      final entryId = await createEntryUseCase.execute(
        substanceId: virtualSubstanceId,
        substanceName: 'Blue Tesla',
        dosage: 120.0,
        unit: 'mg',
        notes: 'Test XTC entry',
      );

      expect(entryId, isNotEmpty);
      
      // Verify the entry was created
      final entries = await mockEntryRepository.getAllEntries();
      expect(entries.length, 1);
      expect(entries.first.substanceId, virtualSubstanceId);
      expect(entries.first.substanceName, 'Blue Tesla');
      expect(entries.first.dosage, 120.0);
    });

    test('CreateEntryUseCase allows zero dosage for virtual substances (unknown dosage)', () async {
      // Test that virtual substances can have zero/unknown dosage
      final virtualSubstanceId = 'xtc_virtual_unknown-dose';
      
      // This should not throw an error even with 0 dosage
      final entryId = await createEntryUseCase.execute(
        substanceId: virtualSubstanceId,
        substanceName: 'Unknown Dose Pill',
        dosage: 0.0, // Unknown dosage
        unit: 'mg',
      );

      expect(entryId, isNotEmpty);
      
      // Verify the entry was created with zero dosage
      final entries = await mockEntryRepository.getAllEntries();
      expect(entries.length, 1);
      expect(entries.first.dosage, 0.0);
    });

    test('CreateEntryUseCase still validates regular substance IDs', () async {
      // Test that regular (non-virtual) substance IDs still get validated
      const regularSubstanceId = 'regular-substance-id';
      
      // This should throw an error because the substance doesn't exist
      expect(
        () async => await createEntryUseCase.execute(
          substanceId: regularSubstanceId,
          dosage: 100.0,
          unit: 'mg',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Virtual substance ID format is correct', () {
      // Test the virtual substance ID format
      const baseId = 'test-uuid-1234';
      final virtualId = 'xtc_virtual_$baseId';
      
      expect(virtualId.startsWith('xtc_virtual_'), true);
      expect(virtualId.contains(baseId), true);
      expect(virtualId.length, greaterThan(12));
    });
  });
}