import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/entry.dart';
import '../models/substance.dart';
import '../models/quick_button_config.dart';
import '../models/dosage_calculator_user.dart';
import '../models/dosage_calculator_substance.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;
  static const String _databaseName = 'konsum_tracker.db';
  static const int _databaseVersion = 1;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }
  
  // Original openDatabase call (replaced with the above)
  Future<Database> _initDatabaseOriginal() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();

    // Create entries table
    batch.execute('''
      CREATE TABLE entries (
        id TEXT PRIMARY KEY,
        substanceId TEXT NOT NULL,
        substanceName TEXT NOT NULL,
        dosage REAL NOT NULL,
        unit TEXT NOT NULL,
        dateTime TEXT NOT NULL,
        cost REAL NOT NULL DEFAULT 0.0,
        notes TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Create substances table
    batch.execute('''
      CREATE TABLE substances (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL UNIQUE,
        category INTEGER NOT NULL,
        defaultRiskLevel INTEGER NOT NULL,
        pricePerUnit REAL NOT NULL DEFAULT 0.0,
        defaultUnit TEXT NOT NULL,
        notes TEXT,
        iconName TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create quick_buttons table
    batch.execute('''
      CREATE TABLE quick_buttons (
        id TEXT PRIMARY KEY,
        substanceId TEXT NOT NULL,
        substanceName TEXT NOT NULL,
        dosage REAL NOT NULL,
        unit TEXT NOT NULL,
        position INTEGER NOT NULL,
        isActive INTEGER NOT NULL DEFAULT 1,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (substanceId) REFERENCES substances (id) ON DELETE CASCADE
      )
    ''');

    // Create dosage_calculator_users table
    batch.execute('''
      CREATE TABLE dosage_calculator_users (
        id TEXT PRIMARY KEY,
        gender INTEGER NOT NULL,
        weightKg REAL NOT NULL,
        heightCm REAL NOT NULL,
        ageYears INTEGER NOT NULL,
        lastUpdated TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Create dosage_calculator_substances table
    batch.execute('''
      CREATE TABLE dosage_calculator_substances (
        name TEXT PRIMARY KEY,
        lightDosePerKg REAL NOT NULL,
        normalDosePerKg REAL NOT NULL,
        strongDosePerKg REAL NOT NULL,
        administrationRoute TEXT NOT NULL,
        duration TEXT NOT NULL,
        safetyNotes TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create indexes for better performance
    batch.execute('CREATE INDEX idx_entries_datetime ON entries (dateTime)');
    batch.execute('CREATE INDEX idx_entries_substance ON entries (substanceName)');
    batch.execute('CREATE INDEX idx_substances_name ON substances (name)');
    batch.execute('CREATE INDEX idx_quick_buttons_position ON quick_buttons (position)');
    batch.execute('CREATE INDEX idx_dosage_substances_name ON dosage_calculator_substances (name)');

    await batch.commit(noResult: true);

    // Insert default data
    await _insertDefaultData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
    if (oldVersion < newVersion) {
      // Add migration logic for future versions
    }
  }

  Future<void> _insertDefaultData(Database db) async {
    try {
      // Insert default substances
      final defaultSubstances = [
        {
          'id': 'default_caffeine',
          'name': 'Koffein',
          'category': 1, // stimulant
          'defaultRiskLevel': 0, // low
          'pricePerUnit': 0.05,
          'defaultUnit': 'mg',
          'notes': 'Häufig in Kaffee, Tee und Energy-Drinks enthalten',
          'iconName': 'coffee',
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
        {
          'id': 'default_cannabis',
          'name': 'Cannabis',
          'category': 4, // recreational
          'defaultRiskLevel': 1, // medium
          'pricePerUnit': 10.0,
          'defaultUnit': 'g',
          'notes': 'THC-haltige Cannabisprodukte',
          'iconName': 'leaf',
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
        {
          'id': 'default_alcohol',
          'name': 'Alkohol',
          'category': 2, // depressant
          'defaultRiskLevel': 1, // medium
          'pricePerUnit': 2.5,
          'defaultUnit': 'ml',
          'notes': 'Ethanol in alkoholischen Getränken',
          'iconName': 'wine',
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
        {
          'id': 'default_vitamin_d',
          'name': 'Vitamin D',
          'category': 3, // supplement
          'defaultRiskLevel': 0, // low
          'pricePerUnit': 0.1,
          'defaultUnit': 'IE',
          'notes': 'Wichtig für Knochengesundheit und Immunsystem',
          'iconName': 'sun',
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
        {
          'id': 'default_ibuprofen',
          'name': 'Ibuprofen',
          'category': 0, // medication
          'defaultRiskLevel': 0, // low
          'pricePerUnit': 0.02,
          'defaultUnit': 'mg',
          'notes': 'Nichtsteroidales Antirheumatikum (NSAR)',
          'iconName': 'pill',
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
      ];

      for (final substance in defaultSubstances) {
        await db.insert('substances', substance);
      }

      // Load and insert dosage calculator substances from JSON
      await _loadDosageCalculatorSubstances(db);
    } catch (e) {
      print('Error inserting default data: $e');
    }
  }

  Future<void> _loadDosageCalculatorSubstances(Database db) async {
    try {
      // Load JSON data from assets
      final jsonString =
          await rootBundle.loadString('assets/data/dosage_calculator_substances_enhanced.json');
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;

      for (final item in jsonList) {
        try {
          final substance = DosageCalculatorSubstance(
            name: item['name'] as String,
            lightDosePerKg: (item['lightDosePerKg'] as num).toDouble(),
            normalDosePerKg: (item['normalDosePerKg'] as num).toDouble(),
            strongDosePerKg: (item['strongDosePerKg'] as num).toDouble(),
            administrationRoute: item['administrationRoute'] as String,
            duration: item['duration'] as String,
            safetyNotes: item['safetyNotes'] as String,
          );

          await db.insert(
            'dosage_calculator_substances',
            substance.toDatabase(),
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        } catch (e) {
          print('Failed to parse dosage substance: $e');
        }
      }
    } catch (e) {
      print('Error loading dosage calculator substances: $e');
    }
  }

  // Transaction support
  Future<void> transaction(Future<void> Function(Transaction txn) action) async {
    final db = await database;
    await db.transaction(action);
  }

  // Close database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  // Delete database (for testing/reset)
  Future<void> deleteDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    await close();

    if (await File(path).exists()) {
      await File(path).delete();
    }
  }

  // Database health check
  Future<bool> isDatabaseHealthy() async {
    try {
      final db = await database;
      final result = await db.rawQuery('SELECT 1');
      return result.isNotEmpty;
    } catch (e) {
      print('Database health check failed: $e');
      return false;
    }
  }

  // Get database info
  Future<Map<String, dynamic>> getDatabaseInfo() async {
    try {
      final db = await database;
      final version = await db.getVersion();
      final path = db.path;

      // Get table counts
      final entriesCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM entries')
      ) ?? 0;

      final substancesCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM substances')
      ) ?? 0;

      final quickButtonsCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM quick_buttons')
      ) ?? 0;

      final usersCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM dosage_calculator_users')
      ) ?? 0;

      final dosageSubstancesCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM dosage_calculator_substances')
      ) ?? 0;

      return {
        'version': version,
        'path': path,
        'entriesCount': entriesCount,
        'substancesCount': substancesCount,
        'quickButtonsCount': quickButtonsCount,
        'usersCount': usersCount,
        'dosageSubstancesCount': dosageSubstancesCount,
      };
    } catch (e) {
      print('Error getting database info: $e');
      return {};
    }
  }
  
  // Vacuum database to reclaim space and optimize performance
  Future<void> vacuumDatabase() async {
    try {
      final db = await database;
      await db.execute('VACUUM');
    } catch (e) {
      print('Error vacuuming database: $e');
    }
  }
  
  // Check database integrity
  Future<bool> checkDatabaseIntegrity() async {
    try {
      final db = await database;
      final result = await db.rawQuery('PRAGMA integrity_check');
      return result.isNotEmpty && result.first.values.first == 'ok';
    } catch (e) {
      print('Error checking database integrity: $e');
      return false;
    }
  }
}
