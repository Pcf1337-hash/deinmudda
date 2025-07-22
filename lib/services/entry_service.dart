import 'package:sqflite/sqflite.dart';
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
      
      if (maps.isEmpty) return null;
      return Entry.fromDatabase(maps.first);
    } catch (e) {
      throw Exception('Failed to get entry by ID: $e');
    }
  }

  // Read - Get entries by date range
  Future<List<Entry>> getEntriesByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'entries',
        where: 'dateTime BETWEEN ? AND ?',
        whereArgs: [
          startDate.toIso8601String(),
          endDate.toIso8601String(),
        ],
        orderBy: 'dateTime DESC',
      );
      return maps.map((map) => Entry.fromDatabase(map)).toList();
    } catch (e) {
      throw Exception('Failed to get entries by date range: $e');
    }
  }

  // Read - Get today's entries
  Future<List<Entry>> getTodaysEntries() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);
    return await getEntriesByDateRange(startOfDay, endOfDay);
  }

  // Read - Get this week's entries
  Future<List<Entry>> getThisWeeksEntries() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return await getEntriesByDateRange(startOfWeek, endOfWeek);
  }

  // Read - Get entries by substance
  Future<List<Entry>> getEntriesBySubstance(String substanceName) async {
    try {
      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'entries',
        where: 'substanceName = ?',
        whereArgs: [substanceName],
        orderBy: 'dateTime DESC',
      );
      return maps.map((map) => Entry.fromDatabase(map)).toList();
    } catch (e) {
      throw Exception('Failed to get entries by substance: $e');
    }
  }

  // Read - Get entries by category
  Future<List<Entry>> getEntriesByCategory(substance_model.SubstanceCategory category) async {
    try {
      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'entries',
        where: 'category = ?',
        whereArgs: [category.index],
        orderBy: 'dateTime DESC',
      );
      return maps.map((map) => Entry.fromDatabase(map)).toList();
    } catch (e) {
      throw Exception('Failed to get entries by category: $e');
    }
  }

  // Read - Search entries
  Future<List<Entry>> searchEntries(String query) async {
    try {
      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'entries',
        where: 'substanceName LIKE ? OR notes LIKE ? OR unit LIKE ?',
        whereArgs: ['%$query%', '%$query%', '%$query%'],
        orderBy: 'dateTime DESC',
      );
      return maps.map((map) => Entry.fromDatabase(map)).toList();
    } catch (e) {
      throw Exception('Failed to search entries: $e');
    }
  }

  // NEW: Advanced search with multiple filters
  Future<List<Entry>> advancedSearch(Map<String, dynamic> searchParams) async {
    try {
      // Use performance helper to measure execution time in debug mode
      return await PerformanceHelper.measureExecutionTime(() async {
        final db = await _databaseService.database;
        
        final List<String> whereConditions = [];
        final List<dynamic> whereArgs = [];
        
        // Text search
        final searchQuery = searchParams['query'] as String?;
        if (searchQuery != null && searchQuery.isNotEmpty) {
          whereConditions.add('(substanceName LIKE ? OR notes LIKE ?)');
          whereArgs.add('%$searchQuery%');
          whereArgs.add('%$searchQuery%');
        }
        
        // Date range
        final startDate = searchParams['startDate'] as DateTime?;
        final endDate = searchParams['endDate'] as DateTime?;
        
        if (startDate != null && endDate != null) {
          whereConditions.add('dateTime BETWEEN ? AND ?');
          whereArgs.add(startDate.toIso8601String());
          whereArgs.add(endDate.toIso8601String());
        } else if (startDate != null) {
          whereConditions.add('dateTime >= ?');
          whereArgs.add(startDate.toIso8601String());
        } else if (endDate != null) {
          whereConditions.add('dateTime <= ?');
          whereArgs.add(endDate.toIso8601String());
        }
        
        // Substance IDs
        final substanceIds = searchParams['substanceIds'] as List<String>?;
        if (substanceIds != null && substanceIds.isNotEmpty) {
          final placeholders = List.filled(substanceIds.length, '?').join(', ');
          whereConditions.add('substanceId IN ($placeholders)');
          whereArgs.addAll(substanceIds);
        }
        
        // Categories
        final categories = searchParams['categories'] as List<substance_model.SubstanceCategory>?;
        if (categories != null && categories.isNotEmpty) {
          // Join with substances table to filter by category
          final placeholders = List.filled(categories.length, '?').join(', ');
          whereConditions.add('e.substanceId IN (SELECT id FROM substances WHERE category IN ($placeholders))');
          whereArgs.addAll(categories.map((c) => c.index));
        }
        
        // Cost range
        final minCost = searchParams['minCost'] as double?;
        final maxCost = searchParams['maxCost'] as double?;
        
        if (minCost != null && maxCost != null) {
          whereConditions.add('cost BETWEEN ? AND ?');
          whereArgs.add(minCost);
          whereArgs.add(maxCost);
        } else if (minCost != null) {
          whereConditions.add('cost >= ?');
          whereArgs.add(minCost);
        } else if (maxCost != null) {
          whereConditions.add('cost <= ?');
          whereArgs.add(maxCost);
        }
        
        // Only with notes
        final onlyWithNotes = searchParams['onlyWithNotes'] as bool?;
        if (onlyWithNotes == true) {
          whereConditions.add('notes IS NOT NULL AND notes != ""');
        }
        
        // Build query
        String queryString;
        if (categories != null && categories.isNotEmpty) {
          // Need to join with substances table
          queryString = '''
            SELECT e.* FROM entries e
            LEFT JOIN substances s ON e.substanceId = s.id
          ''';
          
          if (whereConditions.isNotEmpty) {
            queryString += ' WHERE ${whereConditions.join(' AND ')}';
          }
          
          queryString += ' ORDER BY e.dateTime DESC';
        } else {
          // Simple query without join
          queryString = 'SELECT * FROM entries';
          
          if (whereConditions.isNotEmpty) {
            queryString += ' WHERE ${whereConditions.join(' AND ')}';
          }
          
          queryString += ' ORDER BY dateTime DESC';
        }
        
        // Add limit for performance on low-end devices
        if (kReleaseMode && PerformanceHelper.isLowEndDevice()) {
          queryString += ' LIMIT 100';
        }
        
        final List<Map<String, dynamic>> maps = await db.rawQuery(queryString, whereArgs);
        return maps.map((map) => Entry.fromDatabase(map)).toList();
      }, tag: 'Advanced Search');
    } catch (e) {
      throw Exception('Failed to perform advanced search: $e');
    }
  }

  // Update
  Future<void> updateEntry(Entry entry) async {
    try {
      final db = await _databaseService.database;
      final updatedEntry = entry.copyWith(
        updatedAt: DateTime.now(),
      );
      
      await db.update(
        'entries',
        updatedEntry.toDatabase(),
        where: 'id = ?',
        whereArgs: [entry.id],
      );
    } catch (e) {
      throw Exception('Failed to update entry: $e');
    }
  }

  // Delete
  Future<void> deleteEntry(String id) async {
    try {
      final db = await _databaseService.database;
      await db.delete(
        'entries',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to delete entry: $e');
    }
  }

  // Delete multiple entries
  Future<void> deleteEntries(List<String> ids) async {
    try {
      final db = await _databaseService.database;
      await _databaseService.transaction((txn) async {
        for (final id in ids) {
          await txn.delete(
            'entries',
            where: 'id = ?',
            whereArgs: [id],
          );
        }
      });
    } catch (e) {
      throw Exception('Failed to delete entries: $e');
    }
  }

  // Statistics
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      // Use performance helper to measure execution time in debug mode
      return await PerformanceHelper.measureExecutionTime(() async {
        final db = await _databaseService.database;
        
        // Total entries
        final totalEntries = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM entries')
        ) ?? 0;
        
        // Today's entries
        final today = DateTime.now();
        final startOfDay = DateTime(today.year, today.month, today.day);
        final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);
        
        final todayEntries = Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM entries WHERE dateTime BETWEEN ? AND ?',
            [startOfDay.toIso8601String(), endOfDay.toIso8601String()]
          )
        ) ?? 0;
        
        // Today's cost
        final todayCostResult = await db.rawQuery(
          'SELECT SUM(cost) as total FROM entries WHERE dateTime BETWEEN ? AND ?',
          [startOfDay.toIso8601String(), endOfDay.toIso8601String()]
        );
        final todayCost = (todayCostResult.first['total'] as num?)?.toDouble() ?? 0.0;
        
        // Today's unique substances
        final todaySubstances = Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(DISTINCT substanceName) FROM entries WHERE dateTime BETWEEN ? AND ?',
            [startOfDay.toIso8601String(), endOfDay.toIso8601String()]
          )
        ) ?? 0;
        
        // This week's entries
        final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
        final weekEntries = Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM entries WHERE dateTime >= ?',
            [startOfWeek.toIso8601String()]
          )
        ) ?? 0;
        
        // Unique substances
        final uniqueSubstances = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(DISTINCT substanceName) FROM entries')
        ) ?? 0;
        
        // Total cost
        final totalCostResult = await db.rawQuery('SELECT SUM(cost) as total FROM entries');
        final totalCost = (totalCostResult.first['total'] as num?)?.toDouble() ?? 0.0;
        
        // Average entries per day (last 30 days)
        final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
        final recentEntries = Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM entries WHERE dateTime >= ?',
            [thirtyDaysAgo.toIso8601String()]
          )
        ) ?? 0;
        
        // Calculate days difference for average
        final daysDiff = 30; // Fixed to 30 days for this calculation
        final avgPerDay = daysDiff > 0 ? recentEntries / daysDiff : 0.0;
        
        // Average daily cost
        final avgDailyCost = totalEntries > 0 ? totalCost / totalEntries : 0.0;
        
        // Most used substance
        final mostUsedResult = await db.rawQuery('''
          SELECT substanceName, COUNT(*) as count 
          FROM entries 
          GROUP BY substanceName 
          ORDER BY count DESC 
          LIMIT 1
        ''');
        final mostUsedSubstance = mostUsedResult.isNotEmpty 
            ? mostUsedResult.first['substanceName'] as String
            : 'Keine Daten';
        
        return {
          'totalEntries': totalEntries,
          'todayEntries': todayEntries,
          'todayCost': todayCost,
          'todaySubstances': todaySubstances,
          'weekEntries': weekEntries,
          'uniqueSubstances': uniqueSubstances,
          'totalCost': totalCost,
          'avgEntriesPerDay': avgPerDay,
          'averageDailyCost': avgDailyCost,
          'mostUsedSubstance': mostUsedSubstance,
        };
      }, tag: 'Get Statistics');
    } catch (e) {
      throw Exception('Failed to get statistics: $e');
    }
  }

  // Get entries grouped by date
  Future<Map<String, List<Entry>>> getEntriesGroupedByDate() async {
    try {
      final entries = await getAllEntries();
      final Map<String, List<Entry>> groupedEntries = {};
      
      for (final entry in entries) {
        final dateKey = entry.dateTime.toIso8601String().split('T')[0];
        if (groupedEntries[dateKey] == null) {
          groupedEntries[dateKey] = [];
        }
        groupedEntries[dateKey]!.add(entry);
      }
      
      return groupedEntries;
    } catch (e) {
      throw Exception('Failed to get entries grouped by date: $e');
    }
  }

  // Get cost statistics
  Future<Map<String, dynamic>> getCostStatistics() async {
    try {
      final db = await _databaseService.database;
      
      // Total cost
      final totalCostResult = await db.rawQuery('SELECT SUM(cost) as total FROM entries');
      final totalCost = (totalCostResult.first['total'] as num?)?.toDouble() ?? 0.0;
      
      // This week's cost
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final weekCostResult = await db.rawQuery(
        'SELECT SUM(cost) as total FROM entries WHERE dateTime >= ?',
        [startOfWeek.toIso8601String()]
      );
      final weekCost = (weekCostResult.first['total'] as num?)?.toDouble() ?? 0.0;
      
      // Average cost per entry
      final avgCostResult = await db.rawQuery('SELECT AVG(cost) as avg FROM entries');
      final avgCost = (avgCostResult.first['avg'] as num?)?.toDouble() ?? 0.0;
      
      // Highest single cost
      final maxCostResult = await db.rawQuery('SELECT MAX(cost) as max FROM entries');
      final maxCost = (maxCostResult.first['max'] as num?)?.toDouble() ?? 0.0;
      
      return {
        'totalCost': totalCost,
        'weekCost': weekCost,
        'avgCost': avgCost,
        'maxCost': maxCost,
      };
    } catch (e) {
      throw Exception('Failed to get cost statistics: $e');
    }
  }

  // Export entries to JSON
  Future<List<Map<String, dynamic>>> exportEntriesToJson() async {
    try {
      final entries = await getAllEntries();
      return entries.map((entry) => entry.toJson()).toList();
    } catch (e) {
      throw Exception('Failed to export entries to JSON: $e');
    }
  }

  // Import entries from JSON
  Future<int> importEntriesFromJson(List<Map<String, dynamic>> entriesJson) async {
    try {
      final db = await _databaseService.database;
      int importedCount = 0;
      
      await _databaseService.transaction((txn) async {
        for (final entryJson in entriesJson) {
          try {
            final entry = Entry.fromJson(entryJson);
            await txn.insert(
              'entries',
              entry.toDatabase(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
            importedCount++;
          } catch (e) {
            print('Error importing entry: $e');
            // Continue with next entry
          }
        }
      });
      
      return importedCount;
    } catch (e) {
      throw Exception('Failed to import entries from JSON: $e');
    }
  }
}