/// Entry Repository Interface and Implementation
/// 
/// Phase 3: Architecture Improvements - Repository Pattern
/// Separates data access logic from business logic
/// 
/// Author: Code Quality Improvement Agent
/// Date: Phase 3 - Architecture Improvements

import 'package:sqflite/sqflite.dart';
import '../models/entry.dart';

/// Abstract repository interface for entry data operations
abstract class IEntryRepository {
  Future<String> createEntry(Entry entry);
  Future<List<Entry>> getAllEntries();
  Future<List<Entry>> getEntriesByDateRange(DateTime start, DateTime end);
  Future<List<Entry>> getEntriesBySubstance(String substanceId);
  Future<Entry?> getEntryById(String id);
  Future<void> updateEntry(Entry entry);
  Future<void> deleteEntry(String id);
  Future<List<Entry>> getActiveTimerEntries();
  Future<void> updateEntryTimer(String id, DateTime? timerStartTime, Duration? duration);
  Future<Map<String, dynamic>> getStatistics();
  Future<Map<String, dynamic>> getCostStatistics();
  Future<List<Entry>> advancedSearch(Map<String, dynamic> searchParams);
}

/// Concrete implementation of entry repository
/// Wraps the existing database service with repository pattern
class EntryRepository implements IEntryRepository {
  final dynamic _databaseService;

  EntryRepository(this._databaseService);

  @override
  Future<String> createEntry(Entry entry) async {
    try {
      final db = await _databaseService.database;
      await db.insert(
        'entries',
        entry.toDatabase(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return entry.id;
    } catch (e) {
      throw Exception('Failed to create entry: $e');
    }
  }

  @override
  Future<List<Entry>> getAllEntries() async {
    try {
      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'entries',
        orderBy: 'dateTime DESC',
      );
      return maps.map((map) => Entry.fromDatabase(map)).toList();
    } catch (e) {
      throw Exception('Failed to get all entries: $e');
    }
  }

  @override
  Future<List<Entry>> getEntriesByDateRange(DateTime start, DateTime end) async {
    try {
      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'entries',
        where: 'dateTime >= ? AND dateTime <= ?',
        whereArgs: [start.toIso8601String(), end.toIso8601String()],
        orderBy: 'dateTime DESC',
      );
      return maps.map((map) => Entry.fromDatabase(map)).toList();
    } catch (e) {
      throw Exception('Failed to get entries by date range: $e');
    }
  }

  @override
  Future<List<Entry>> getEntriesBySubstance(String substanceId) async {
    try {
      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'entries',
        where: 'substanceId = ?',
        whereArgs: [substanceId],
        orderBy: 'dateTime DESC',
      );
      return maps.map((map) => Entry.fromDatabase(map)).toList();
    } catch (e) {
      throw Exception('Failed to get entries by substance: $e');
    }
  }

  @override
  Future<Entry?> getEntryById(String id) async {
    try {
      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'entries',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isEmpty) return null;
      return Entry.fromDatabase(maps.first);
    } catch (e) {
      throw Exception('Failed to get entry by id: $e');
    }
  }

  @override
  Future<void> updateEntry(Entry entry) async {
    try {
      final db = await _databaseService.database;
      await db.update(
        'entries',
        entry.toDatabase(),
        where: 'id = ?',
        whereArgs: [entry.id],
      );
    } catch (e) {
      throw Exception('Failed to update entry: $e');
    }
  }

  @override
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

  @override
  Future<List<Entry>> getActiveTimerEntries() async {
    try {
      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'entries',
        where: 'timerStartTime IS NOT NULL',
        orderBy: 'dateTime DESC',
      );
      return maps.map((map) => Entry.fromDatabase(map)).toList();
    } catch (e) {
      throw Exception('Failed to get active timer entries: $e');
    }
  }

  @override
  Future<void> updateEntryTimer(String id, DateTime? timerStartTime, Duration? duration) async {
    try {
      final db = await _databaseService.database;
      await db.update(
        'entries',
        {
          'timerStartTime': timerStartTime?.toIso8601String(),
          'duration': duration?.inMinutes,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to update entry timer: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final db = await _databaseService.database;
      
      // Get total entries count
      final totalResult = await db.rawQuery('SELECT COUNT(*) as count FROM entries');
      final totalEntries = totalResult.first['count'] as int;
      
      // Get entries this week
      final weekStart = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
      final weekStartString = weekStart.toIso8601String();
      final weekResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM entries WHERE dateTime >= ?',
        [weekStartString]
      );
      final weekEntries = weekResult.first['count'] as int;
      
      // Get entries this month
      final monthStart = DateTime(DateTime.now().year, DateTime.now().month, 1);
      final monthStartString = monthStart.toIso8601String();
      final monthResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM entries WHERE dateTime >= ?',
        [monthStartString]
      );
      final monthEntries = monthResult.first['count'] as int;
      
      // Get TODAY's statistics (fix for _buildTodayStatsSection showing only 0)
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      final todayEnd = todayStart.add(const Duration(days: 1));
      final todayStartString = todayStart.toIso8601String();
      final todayEndString = todayEnd.toIso8601String();
      
      // Today's entries count
      final todayEntriesResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM entries WHERE dateTime >= ? AND dateTime < ?',
        [todayStartString, todayEndString]
      );
      final todayEntries = todayEntriesResult.first['count'] as int;
      
      // Today's total cost
      final todayCostResult = await db.rawQuery(
        'SELECT SUM(cost) as total FROM entries WHERE dateTime >= ? AND dateTime < ? AND cost IS NOT NULL',
        [todayStartString, todayEndString]
      );
      final todayCost = (todayCostResult.first['total'] as num?)?.toDouble() ?? 0.0;
      
      // Today's unique substances count
      final todaySubstancesResult = await db.rawQuery(
        'SELECT COUNT(DISTINCT substanceId) as count FROM entries WHERE dateTime >= ? AND dateTime < ? AND substanceId IS NOT NULL',
        [todayStartString, todayEndString]
      );
      final todaySubstances = todaySubstancesResult.first['count'] as int;
      
      // Additional statistics that might be useful
      final mostUsedSubstanceResult = await db.rawQuery(
        'SELECT substanceName, COUNT(*) as count FROM entries WHERE substanceName IS NOT NULL GROUP BY substanceName ORDER BY count DESC LIMIT 1'
      );
      final mostUsedSubstance = mostUsedSubstanceResult.isNotEmpty 
          ? mostUsedSubstanceResult.first['substanceName'] as String
          : 'Keine Daten';
      
      final averageDailyCostResult = await db.rawQuery(
        'SELECT AVG(daily_cost) as avg FROM (SELECT DATE(dateTime) as day, SUM(cost) as daily_cost FROM entries WHERE cost IS NOT NULL GROUP BY DATE(dateTime))'
      );
      final averageDailyCost = (averageDailyCostResult.first['avg'] as num?)?.toDouble() ?? 0.0;
      
      return {
        'totalEntries': totalEntries,
        'weekEntries': weekEntries,
        'monthEntries': monthEntries,
        // Today's statistics for HomeScreen _buildTodayStatsSection
        'todayEntries': todayEntries,
        'todayCost': todayCost,
        'todaySubstances': todaySubstances,
        // Additional statistics for insights
        'mostUsedSubstance': mostUsedSubstance,
        'averageDailyCost': averageDailyCost,
      };
    } catch (e) {
      throw Exception('Failed to get statistics: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getCostStatistics() async {
    try {
      final db = await _databaseService.database;
      
      // Calculate total cost
      final totalResult = await db.rawQuery(
        'SELECT SUM(cost) as total FROM entries WHERE cost IS NOT NULL'
      );
      final totalCost = (totalResult.first['total'] as num?)?.toDouble() ?? 0.0;
      
      // Calculate monthly cost
      final monthStart = DateTime(DateTime.now().year, DateTime.now().month, 1);
      final monthStartString = monthStart.toIso8601String();
      final monthResult = await db.rawQuery(
        'SELECT SUM(cost) as total FROM entries WHERE cost IS NOT NULL AND dateTime >= ?',
        [monthStartString]
      );
      final monthlyCost = (monthResult.first['total'] as num?)?.toDouble() ?? 0.0;
      
      return {
        'totalCost': totalCost,
        'monthlyCost': monthlyCost,
      };
    } catch (e) {
      throw Exception('Failed to get cost statistics: $e');
    }
  }

  @override
  Future<List<Entry>> advancedSearch(Map<String, dynamic> searchParams) async {
    try {
      final db = await _databaseService.database;
      
      // Build query based on search parameters
      String whereClause = '1=1';
      List<dynamic> whereArgs = [];
      
      if (searchParams['substanceId'] != null) {
        whereClause += ' AND substance_id = ?';
        whereArgs.add(searchParams['substanceId']);
      }
      
      if (searchParams['startDate'] != null) {
        whereClause += ' AND dateTime >= ?';
        whereArgs.add((searchParams['startDate'] as DateTime).toIso8601String());
      }
      
      if (searchParams['endDate'] != null) {
        whereClause += ' AND dateTime <= ?';
        whereArgs.add((searchParams['endDate'] as DateTime).toIso8601String());
      }
      
      if (searchParams['minAmount'] != null) {
        whereClause += ' AND amount >= ?';
        whereArgs.add(searchParams['minAmount']);
      }
      
      if (searchParams['maxAmount'] != null) {
        whereClause += ' AND amount <= ?';
        whereArgs.add(searchParams['maxAmount']);
      }
      
      final List<Map<String, dynamic>> maps = await db.query(
        'entries',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'dateTime DESC',
      );
      
      return List.generate(maps.length, (i) {
        return Entry.fromDatabase(maps[i]);
      });
    } catch (e) {
      throw Exception('Failed to perform advanced search: $e');
    }
  }
}