/// Substance Repository Interface and Implementation
/// 
/// Phase 3: Architecture Improvements - Repository Pattern
/// Separates data access logic from business logic
/// 
/// Author: Code Quality Improvement Agent
/// Date: Phase 3 - Architecture Improvements

import 'package:sqflite/sqflite.dart';
import '../models/substance.dart';

/// Abstract repository interface for substance data operations
abstract class ISubstanceRepository {
  Future<void> createSubstance(Substance substance);
  Future<List<Substance>> getAllSubstances();
  Future<Substance?> getSubstanceById(String id);
  Future<Substance?> getSubstanceByName(String name);
  Future<void> updateSubstance(Substance substance);
  Future<void> deleteSubstance(String id);
  Future<List<Substance>> searchSubstances(String query);
  Future<List<Substance>> getRecentSubstances(int limit);
  Future<List<Substance>> getSubstancesByCategory(SubstanceCategory category);
  Future<List<Substance>> getMostUsedSubstances({int limit = 10});
  Future<List<Substance>> getSubstancesByUnit(String unit);
}

/// Concrete implementation of substance repository
/// Wraps the existing database service with repository pattern
class SubstanceRepository implements ISubstanceRepository {
  final dynamic _databaseService;

  SubstanceRepository(this._databaseService);

  @override
  Future<void> createSubstance(Substance substance) async {
    try {
      final db = await _databaseService.database;
      await db.insert(
        'substances',
        substance.toDatabase(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Failed to create substance: $e');
    }
  }

  @override
  Future<List<Substance>> getAllSubstances() async {
    try {
      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'substances',
        orderBy: 'name ASC',
      );
      return maps.map((map) => Substance.fromDatabase(map)).toList();
    } catch (e) {
      throw Exception('Failed to get all substances: $e');
    }
  }

  @override
  Future<Substance?> getSubstanceById(String id) async {
    try {
      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'substances',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isEmpty) return null;
      return Substance.fromDatabase(maps.first);
    } catch (e) {
      throw Exception('Failed to get substance by id: $e');
    }
  }

  @override
  Future<Substance?> getSubstanceByName(String name) async {
    try {
      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'substances',
        where: 'name = ?',
        whereArgs: [name],
        limit: 1,
      );
      if (maps.isEmpty) return null;
      return Substance.fromDatabase(maps.first);
    } catch (e) {
      throw Exception('Failed to get substance by name: $e');
    }
  }

  @override
  Future<void> updateSubstance(Substance substance) async {
    try {
      final db = await _databaseService.database;
      await db.update(
        'substances',
        substance.toDatabase(),
        where: 'id = ?',
        whereArgs: [substance.id],
      );
    } catch (e) {
      throw Exception('Failed to update substance: $e');
    }
  }

  @override
  Future<void> deleteSubstance(String id) async {
    try {
      final db = await _databaseService.database;
      await db.delete(
        'substances',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to delete substance: $e');
    }
  }

  @override
  Future<List<Substance>> searchSubstances(String query) async {
    try {
      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'substances',
        where: 'name LIKE ? OR category LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'name ASC',
      );
      return maps.map((map) => Substance.fromDatabase(map)).toList();
    } catch (e) {
      throw Exception('Failed to search substances: $e');
    }
  }

  @override
  Future<List<Substance>> getRecentSubstances(int limit) async {
    try {
      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT DISTINCT s.* FROM substances s
        INNER JOIN entries e ON s.id = e.substanceId
        ORDER BY e.dateTime DESC
        LIMIT ?
      ''', [limit]);
      return maps.map((map) => Substance.fromDatabase(map)).toList();
    } catch (e) {
      throw Exception('Failed to get recent substances: $e');
    }
  }

  @override
  Future<List<Substance>> getSubstancesByCategory(SubstanceCategory category) async {
    try {
      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'substances',
        where: 'category = ?',
        whereArgs: [category.index],
        orderBy: 'name ASC',
      );
      return maps.map((map) => Substance.fromDatabase(map)).toList();
    } catch (e) {
      throw Exception('Failed to get substances by category: $e');
    }
  }

  @override
  Future<List<Substance>> getMostUsedSubstances({int limit = 10}) async {
    try {
      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT s.*, COUNT(e.id) as usage_count
        FROM substances s
        LEFT JOIN entries e ON s.id = e.substanceId
        GROUP BY s.id
        ORDER BY usage_count DESC, s.name ASC
        LIMIT ?
      ''', [limit]);
      
      return maps.map((map) => Substance.fromDatabase(map)).toList();
    } catch (e) {
      throw Exception('Failed to get most used substances: $e');
    }
  }

  @override
  Future<List<Substance>> getSubstancesByUnit(String unit) async {
    try {
      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'substances',
        where: 'defaultUnit = ?',
        whereArgs: [unit],
        orderBy: 'name ASC',
      );
      return maps.map((map) => Substance.fromDatabase(map)).toList();
    } catch (e) {
      throw Exception('Failed to get substances by unit: $e');
    }
  }
}