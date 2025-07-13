import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../services/database_service.dart';
import '../models/entry.dart';
import '../models/substance.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  final DatabaseService _databaseService = DatabaseService();

  // Backup database to JSON
  Future<Map<String, dynamic>> backupDatabase() async {
    try {
      final db = await _databaseService.database;
      
      // Get all entries
      final entriesResult = await db.query('entries', orderBy: 'dateTime DESC');
      final entries = entriesResult.map((map) => Entry.fromDatabase(map).toJson()).toList();
      
      // Get all substances
      final substancesResult = await db.query('substances', orderBy: 'name ASC');
      final substances = substancesResult.map((map) => Substance.fromDatabase(map).toJson()).toList();
      
      // Get all quick buttons
      final quickButtonsResult = await db.query('quick_buttons', orderBy: 'position ASC');
      
      // Get all dosage calculator users
      final usersResult = await db.query('dosage_calculator_users');
      
      // Get all dosage calculator substances
      final dosageSubstancesResult = await db.query('dosage_calculator_substances', orderBy: 'name ASC');
      
      return {
        'version': '1.0.0',
        'exportDate': DateTime.now().toIso8601String(),
        'entries': entries,
        'substances': substances,
        'quickButtons': quickButtonsResult,
        'users': usersResult,
        'dosageSubstances': dosageSubstancesResult,
      };
    } catch (e) {
      throw Exception('Failed to backup database: $e');
    }
  }

  // Restore database from JSON
  Future<void> restoreDatabase(Map<String, dynamic> backup) async {
    try {
      final db = await _databaseService.database;
      
      await db.transaction((txn) async {
        // Clear existing data
        await txn.delete('entries');
        await txn.delete('substances');
        await txn.delete('quick_buttons');
        await txn.delete('dosage_calculator_users');
        await txn.delete('dosage_calculator_substances');
        
        // Restore substances first (due to foreign key constraints)
        if (backup['substances'] != null) {
          for (final substanceData in backup['substances']) {
            final substance = Substance.fromJson(substanceData);
            await txn.insert('substances', substance.toDatabase());
          }
        }
        
        // Restore entries
        if (backup['entries'] != null) {
          for (final entryData in backup['entries']) {
            final entry = Entry.fromJson(entryData);
            await txn.insert('entries', entry.toDatabase());
          }
        }
        
        // Restore quick buttons
        if (backup['quickButtons'] != null) {
          for (final buttonData in backup['quickButtons']) {
            await txn.insert('quick_buttons', buttonData);
          }
        }
        
        // Restore users
        if (backup['users'] != null) {
          for (final userData in backup['users']) {
            await txn.insert('dosage_calculator_users', userData);
          }
        }
        
        // Restore dosage substances
        if (backup['dosageSubstances'] != null) {
          for (final dosageData in backup['dosageSubstances']) {
            await txn.insert('dosage_calculator_substances', dosageData);
          }
        }
      });
    } catch (e) {
      throw Exception('Failed to restore database: $e');
    }
  }

  // Export database to JSON file
  Future<String> exportToFile() async {
    try {
      final backup = await backupDatabase();
      final jsonString = const JsonEncoder.withIndent('  ').convert(backup);
      
      // Get documents directory
      final directory = Directory('/storage/emulated/0/Download'); // Android Downloads
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      
      final fileName = 'konsum_tracker_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File(join(directory.path, fileName));
      
      await file.writeAsString(jsonString);
      return file.path;
    } catch (e) {
      throw Exception('Failed to export to file: $e');
    }
  }

  // Import database from JSON file
  Future<void> importFromFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist: $filePath');
      }
      
      final jsonString = await file.readAsString();
      final backup = jsonDecode(jsonString) as Map<String, dynamic>;
      
      await restoreDatabase(backup);
    } catch (e) {
      throw Exception('Failed to import from file: $e');
    }
  }

  // Validate backup data
  Future<bool> validateBackup(Map<String, dynamic> backup) async {
    try {
      // Check required fields
      if (!backup.containsKey('version') || 
          !backup.containsKey('exportDate') ||
          !backup.containsKey('entries') ||
          !backup.containsKey('substances')) {
        return false;
      }
      
      // Validate entries
      if (backup['entries'] is List) {
        for (final entryData in backup['entries']) {
          try {
            Entry.fromJson(entryData);
          } catch (e) {
            return false;
          }
        }
      }
      
      // Validate substances
      if (backup['substances'] is List) {
        for (final substanceData in backup['substances']) {
          try {
            Substance.fromJson(substanceData);
          } catch (e) {
            return false;
          }
        }
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get database statistics
  Future<Map<String, dynamic>> getDatabaseStatistics() async {
    try {
      final db = await _databaseService.database;
      
      // Count entries
      final entriesCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM entries')
      ) ?? 0;
      
      // Count substances
      final substancesCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM substances')
      ) ?? 0;
      
      // Count quick buttons
      final quickButtonsCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM quick_buttons')
      ) ?? 0;
      
      // Count users
      final usersCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM dosage_calculator_users')
      ) ?? 0;
      
      // Count dosage substances
      final dosageSubstancesCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM dosage_calculator_substances')
      ) ?? 0;
      
      // Get database size
      final dbPath = db.path;
      final dbFile = File(dbPath);
      final dbSize = await dbFile.length();
      
      // Get oldest and newest entry dates
      final oldestEntryResult = await db.rawQuery(
        'SELECT MIN(dateTime) as oldest FROM entries'
      );
      final newestEntryResult = await db.rawQuery(
        'SELECT MAX(dateTime) as newest FROM entries'
      );
      
      final oldestEntry = oldestEntryResult.first['oldest'] as String?;
      final newestEntry = newestEntryResult.first['newest'] as String?;
      
      return {
        'entriesCount': entriesCount,
        'substancesCount': substancesCount,
        'quickButtonsCount': quickButtonsCount,
        'usersCount': usersCount,
        'dosageSubstancesCount': dosageSubstancesCount,
        'databaseSize': dbSize,
        'databasePath': dbPath,
        'oldestEntry': oldestEntry,
        'newestEntry': newestEntry,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to get database statistics: $e');
    }
  }

  // Optimize database
  Future<void> optimizeDatabase() async {
    try {
      final db = await _databaseService.database;
      
      // Run VACUUM to reclaim space
      await db.execute('VACUUM');
      
      // Analyze tables for query optimization
      await db.execute('ANALYZE');
      
      // Update table statistics
      await db.execute('PRAGMA optimize');
    } catch (e) {
      throw Exception('Failed to optimize database: $e');
    }
  }

  // Check database integrity
  Future<bool> checkDatabaseIntegrity() async {
    try {
      final db = await _databaseService.database;
      
      // Run integrity check
      final result = await db.rawQuery('PRAGMA integrity_check');
      
      // Check if result contains 'ok'
      return result.isNotEmpty && 
             result.first.values.any((value) => value.toString().toLowerCase() == 'ok');
    } catch (e) {
      return false;
    }
  }

  // Repair database (if possible)
  Future<bool> repairDatabase() async {
    try {
      final db = await _databaseService.database;
      
      // Try to repair using REINDEX
      await db.execute('REINDEX');
      
      // Check integrity after repair
      return await checkDatabaseIntegrity();
    } catch (e) {
      return false;
    }
  }

  // Clean old data based on retention policy
  Future<int> cleanOldData({int retentionDays = 365}) async {
    try {
      final db = await _databaseService.database;
      final cutoffDate = DateTime.now().subtract(Duration(days: retentionDays));
      
      // Delete old entries
      final deletedCount = await db.delete(
        'entries',
        where: 'dateTime < ?',
        whereArgs: [cutoffDate.toIso8601String()],
      );
      
      return deletedCount;
    } catch (e) {
      throw Exception('Failed to clean old data: $e');
    }
  }

  // Get database schema version
  Future<int> getDatabaseVersion() async {
    try {
      final db = await _databaseService.database;
      return await db.getVersion();
    } catch (e) {
      throw Exception('Failed to get database version: $e');
    }
  }

  // Create database backup with compression
  Future<String> createCompressedBackup() async {
    try {
      final backup = await backupDatabase();
      final jsonString = jsonEncode(backup);
      
      // In a real implementation, you would compress the JSON string here
      // For now, we'll just return the regular backup
      return jsonString;
    } catch (e) {
      throw Exception('Failed to create compressed backup: $e');
    }
  }
}
