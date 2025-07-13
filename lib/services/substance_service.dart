import 'package:sqflite/sqflite.dart';
import '../models/substance.dart';
import '../utils/unit_manager.dart';
import 'database_service.dart';

class SubstanceService {
  final DatabaseService _databaseService = DatabaseService();

  // Create
  Future<String> createSubstance(Substance substance) async {
    try {
      final db = await _databaseService.database;
      
      // Sicherstellen, dass die Daten korrekt formatiert sind
      final substanceData = substance.toDatabase();
      
      // Prüfen, ob alle erforderlichen Felder vorhanden sind
      if (substanceData['name'] == null || substanceData['id'] == null) {
        throw Exception('Ungültige Substanzdaten: Fehlende Pflichtfelder');
      }
      
      await db.insert(
        'substances',
        substanceData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return substance.id;
    } catch (e) {
      throw Exception('Failed to create substance: $e');
    }
  }

  // Read - Get all substances
  Future<List<Substance>> getAllSubstances() async {
    try {
      try {
        final db = await _databaseService.database;
        final List<Map<String, dynamic>> maps = await db.query(
          'substances',
          orderBy: 'name ASC',
        );
        
        if (maps.isEmpty) {
          // If no substances found, initialize default substances
          await initializeDefaultSubstances();
          
          // Try again after initialization
          final updatedMaps = await db.query(
            'substances',
            orderBy: 'name ASC',
          );
          
          return updatedMaps.map((map) => Substance.fromDatabase(map)).toList();
        }
        
        return maps.map((map) => Substance.fromDatabase(map)).toList();
      } catch (e) {
        // If there's an error with the database query, return default substances
        print('Error querying substances: $e');
        return Substance.getDefaultSubstances();
      }
    } catch (e) {
      print('Critical error in getAllSubstances: $e');
      // Return default substances as fallback
      return Substance.getDefaultSubstances();
    }
  }

  // Read - Get substance by ID
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
      throw Exception('Failed to get substance by ID: $e');
    }
  }

  // Read - Get substance by name
  Future<Substance?> getSubstanceByName(String name) async {
    try {
      if (name.isEmpty) {
        return null;
      }
      
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

  // Read - Search substances
  Future<List<Substance>> searchSubstances(String query) async {
    try {
      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'substances',
        where: 'name LIKE ? OR notes LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'name ASC',
      );
      return maps.map((map) => Substance.fromDatabase(map)).toList();
    } catch (e) {
      throw Exception('Failed to search substances: $e');
    }
  }

  // Update
  Future<void> updateSubstance(Substance substance) async {
    try {
      final db = await _databaseService.database;
      final updatedSubstance = substance.copyWith(
        // updatedAt will be handled in the model
      );
      
      await db.update(
        'substances',
        updatedSubstance.toDatabase(),
        where: 'id = ?',
        whereArgs: [substance.id],
      );
    } catch (e) {
      throw Exception('Failed to update substance: $e');
    }
  }

  // Delete
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

  // Get substances by category
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

  // Get most used substances
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

  // Initialize default substances if database is empty
  Future<void> initializeDefaultSubstances() async {
    try {
      final existingSubstances = await getAllSubstances();
      if (existingSubstances.isEmpty) {
        final defaultSubstances = Substance.getDefaultSubstances();
        for (final substance in defaultSubstances) {
          await createSubstance(substance);
        }
      }
    } catch (e) {
      throw Exception('Failed to initialize default substances: $e');
    }
  }

  // Get all unique units used in substances
  Future<List<String>> getAllUsedUnits() async {
    try {
      final substances = await getAllSubstances();
      return await UnitManager.getUsedUnits(substances);
    } catch (e) {
      throw Exception('Failed to get used units: $e');
    }
  }

  // Get suggested units for unit dropdown
  Future<List<String>> getSuggestedUnits() async {
    try {
      final substances = await getAllSubstances();
      return await UnitManager.getSuggestedUnits(substances);
    } catch (e) {
      throw Exception('Failed to get suggested units: $e');
    }
  }

  // Check if a unit exists in the database
  Future<bool> unitExists(String unit) async {
    try {
      final substances = await getAllSubstances();
      return await UnitManager.unitExists(unit, substances);
    } catch (e) {
      throw Exception('Failed to check unit existence: $e');
    }
  }

  // Get substances by unit
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

  // Validate unit before creating/updating substance
  String? validateUnit(String? unit) {
    return UnitManager.validateUnit(unit);
  }

  // Get recommended units for a substance category
  List<String> getRecommendedUnitsForCategory(SubstanceCategory category) {
    return UnitManager.getRecommendedUnitsForCategory(category);
  }
}
