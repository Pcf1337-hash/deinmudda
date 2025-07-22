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
}