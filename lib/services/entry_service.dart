// removed unused import: dart:convert // cleaned by BereinigungsAgent
// removed unused import: package:sqflite/sqflite.dart // cleaned by BereinigungsAgent
import 'package:flutter/foundation.dart';
import '../models/entry.dart';
// Import with prefix to avoid conflicts
import '../models/substance.dart' as substance_model;
import '../interfaces/service_interfaces.dart';
import '../repositories/entry_repository.dart';
import '../utils/performance_helper.dart';

class EntryService extends ChangeNotifier implements IEntryService {
  final IEntryRepository _entryRepository;

  EntryService(this._entryRepository);

  // Factory constructor for backward compatibility - delegates to ServiceLocator
  factory EntryService.create() {
    // This should never be called if ServiceLocator is properly initialized
    throw UnimplementedError('Use ServiceLocator.get<IEntryService>() instead of creating services directly');
  }

  // Create
  @override
  Future<String> createEntry(Entry entry) async {
    try {
      final result = await _entryRepository.createEntry(entry);
      notifyListeners(); // Notify listeners of changes
      return result;
    } catch (e) {
      throw Exception('Failed to create entry: $e');
    }
  }

  // Add entry (alias for createEntry)
  @override
  Future<String> addEntry(Entry entry) async {
    return await createEntry(entry);
  }

  // Create entry with timer
  @override
  Future<Entry> createEntryWithTimer(Entry entry, {Duration? customDuration, required dynamic timerService}) async {
    try {
      // First create the entry
      await createEntry(entry);
      
      // Then start the timer
      return await timerService.startTimer(entry, customDuration: customDuration);
    } catch (e) {
      throw Exception('Failed to create entry with timer: $e');
    }
  }

  // Read - Get all entries
  @override
  Future<List<Entry>> getAllEntries() async {
    try {
      // Use performance helper to measure execution time in debug mode
      return await PerformanceHelper.measureExecutionTime(() async {
        return await _entryRepository.getAllEntries();
      }, tag: 'Get All Entries');
    } catch (e) {
      throw Exception('Failed to get entries: $e');
    }
  }

  // Read - Get entry by ID
  @override
  Future<Entry?> getEntryById(String id) async {
    try {
      return await _entryRepository.getEntryById(id);
    } catch (e) {
      throw Exception('Failed to get entry by ID: $e');
    }
  }

  // Get entries by date range  
  @override
  Future<List<Entry>> getEntriesByDateRange(DateTime start, DateTime end) async {
    try {
      return await _entryRepository.getEntriesByDateRange(start, end);
    } catch (e) {
      throw Exception('Failed to get entries by date range: $e');
    }
  }

  // Get entries by substance
  @override
  Future<List<Entry>> getEntriesBySubstance(String substanceId) async {
    try {
      return await _entryRepository.getEntriesBySubstance(substanceId);
    } catch (e) {
      throw Exception('Failed to get entries by substance: $e');
    }
  }

  // Update entry
  @override
  Future<void> updateEntry(Entry entry) async {
    try {
      await _entryRepository.updateEntry(entry);
      notifyListeners(); // Notify listeners of changes
    } catch (e) {
      throw Exception('Failed to update entry: $e');
    }
  }

  // Delete entry
  @override
  Future<void> deleteEntry(String id) async {
    try {
      await _entryRepository.deleteEntry(id);
      notifyListeners(); // Notify listeners of changes
    } catch (e) {
      throw Exception('Failed to delete entry: $e');
    }
  }

  // Get active timer entries
  @override
  Future<List<Entry>> getActiveTimerEntries() async {
    try {
      return await _entryRepository.getActiveTimerEntries();
    } catch (e) {
      throw Exception('Failed to get active timer entries: $e');
    }
  }

  // Update entry timer
  @override
  Future<void> updateEntryTimer(String id, DateTime? timerStartTime, Duration? duration) async {
    try {
      await _entryRepository.updateEntryTimer(id, timerStartTime, duration);
      notifyListeners(); // Notify listeners of changes
    } catch (e) {
      throw Exception('Failed to update entry timer: $e');
    }
  }

  // Add missing interface methods
  @override
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      return await _entryRepository.getStatistics();
    } catch (e) {
      throw Exception('Failed to get statistics: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getCostStatistics() async {
    try {
      return await _entryRepository.getCostStatistics();
    } catch (e) {
      throw Exception('Failed to get cost statistics: $e');
    }
  }

  @override
  Future<List<Entry>> advancedSearch(Map<String, dynamic> searchParams) async {
    try {
      return await _entryRepository.advancedSearch(searchParams);
    } catch (e) {
      throw Exception('Failed to perform advanced search: $e');
    }
  }

  @override
  Future<int> importEntriesFromJson(String jsonString) async {
    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      int importedCount = 0;
      
      for (final item in jsonList) {
        try {
          final entry = Entry.fromJson(item);
          await _entryRepository.createEntry(entry);
          importedCount++;
        } catch (e) {
          // Skip invalid entries
          print('Skipping invalid entry: $e');
        }
      }
      
      notifyListeners();
      return importedCount;
    } catch (e) {
      throw Exception('Failed to import entries from JSON: $e');
    }
  }
}