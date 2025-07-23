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
  static const int _databaseVersion = 4;
  
  // CRITICAL FIX: Add mutex to prevent race condition during database initialization
  static bool _isInitializing = false;

  Future<Database> get database async {
    // If database is already initialized, return it
    if (_database != null) {
      return _database!;
    }
    
    // RACE CONDITION FIX: Prevent multiple simultaneous initialization attempts
    if (_isInitializing) {
      // Wait for the current initialization to complete
      while (_isInitializing) {
        await Future.delayed(const Duration(milliseconds: 10));
      }
      // After waiting, return the database (should be initialized now)
      if (_database != null) {
        return _database!;
      }
    }
    
    // Mark as initializing and proceed
    _isInitializing = true;
    try {
      _database ??= await _initDatabase();
      return _database!;
    } finally {
      _isInitializing = false;
    }
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
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        timerStartTime TEXT,
        timerEndTime TEXT,
        timerCompleted INTEGER NOT NULL DEFAULT 0,
        timerNotificationSent INTEGER NOT NULL DEFAULT 0,
        iconCodePoint INTEGER,
        colorValue INTEGER
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
        duration INTEGER,
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
        cost REAL NOT NULL DEFAULT 0.0,
        position INTEGER NOT NULL,
        isActive INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        iconCodePoint INTEGER,
        colorValue INTEGER,
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
        dosageStrategy INTEGER NOT NULL DEFAULT 1,
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
    if (oldVersion < 2) {
      // Add timer fields to entries table
      await _addColumnIfNotExists(db, 'entries', 'timerStartTime', 'TEXT');
      await _addColumnIfNotExists(db, 'entries', 'timerEndTime', 'TEXT');
      await _addColumnIfNotExists(db, 'entries', 'timerCompleted', 'INTEGER NOT NULL DEFAULT 0');
      await _addColumnIfNotExists(db, 'entries', 'timerNotificationSent', 'INTEGER NOT NULL DEFAULT 0');
      
      // Add duration field to substances table
      await _addColumnIfNotExists(db, 'substances', 'duration', 'INTEGER');
      
      // Update existing substances with default durations
      await db.execute('''
        UPDATE substances 
        SET duration = 240 
        WHERE name = 'Koffein';
      '''); // 4 hours
      
      await db.execute('''
        UPDATE substances 
        SET duration = 120 
        WHERE name = 'Cannabis';
      '''); // 2 hours
      
      await db.execute('''
        UPDATE substances 
        SET duration = 120 
        WHERE name = 'Alkohol';
      '''); // 2 hours
      
      await db.execute('''
        UPDATE substances 
        SET duration = 1440 
        WHERE name = 'Vitamin D';
      '''); // 24 hours
      
      await db.execute('''
        UPDATE substances 
        SET duration = 360 
        WHERE name = 'Ibuprofen';
      '''); // 6 hours
      
      await db.execute('''
        UPDATE substances 
        SET duration = 30 
        WHERE name = 'Nikotin';
      '''); // 30 minutes
      
      await db.execute('''
        UPDATE substances 
        SET duration = 480 
        WHERE name = 'Melatonin';
      '''); // 8 hours
      
      await db.execute('''
        UPDATE substances 
        SET duration = 240 
        WHERE name = 'Paracetamol';
      '''); // 4 hours
    }
    
    if (oldVersion < 3) {
      // Add icon and color fields to entries table
      await _addColumnIfNotExists(db, 'entries', 'iconCodePoint', 'INTEGER');
      await _addColumnIfNotExists(db, 'entries', 'colorValue', 'INTEGER');
      
      // Add icon and color fields to quick_buttons table
      await _addColumnIfNotExists(db, 'quick_buttons', 'iconCodePoint', 'INTEGER');
      await _addColumnIfNotExists(db, 'quick_buttons', 'colorValue', 'INTEGER');
    }
    
    if (oldVersion < 4) {
      // Add dosage strategy field to dosage_calculator_users table
      await _addColumnIfNotExists(db, 'dosage_calculator_users', 'dosageStrategy', 'INTEGER NOT NULL DEFAULT 1');
    }
    
    // Migration for any version that doesn't have created_at/updated_at columns
    await _ensureTimestampColumns(db);
  }

  /// Safely add a column if it doesn't exist
  /// CRITICAL SAFETY FIX: Added backup and recovery mechanisms
  Future<void> _addColumnIfNotExists(Database db, String tableName, String columnName, String columnType) async {
    try {
      // First check if column already exists
      final result = await db.rawQuery('PRAGMA table_info($tableName)');
      final columnExists = result.any((column) => column['name'] == columnName);
      
      if (!columnExists) {
        // SAFETY ENHANCEMENT: Create backup table before schema modification
        final backupTableName = '${tableName}_backup_${DateTime.now().millisecondsSinceEpoch}';
        
        try {
          // Create backup table with existing data
          await db.execute('CREATE TABLE $backupTableName AS SELECT * FROM $tableName');
          print('Created backup table: $backupTableName');
          
          // Perform the schema change
          await db.execute('ALTER TABLE $tableName ADD COLUMN $columnName $columnType');
          print('✅ Successfully added column $columnName to table $tableName');
          
          // Verify the column was added correctly
          final verifyResult = await db.rawQuery('PRAGMA table_info($tableName)');
          final columnAdded = verifyResult.any((column) => column['name'] == columnName);
          
          if (columnAdded) {
            // SUCCESS: Column added successfully, clean up backup
            await db.execute('DROP TABLE $backupTableName');
            print('✅ Migration completed successfully, backup cleaned up');
          } else {
            // FAILURE: Column not added, restore from backup
            throw Exception('Column verification failed after ALTER TABLE');
          }
          
        } catch (migrationError) {
          print('🚨 MIGRATION ERROR: $migrationError');
          
          // RECOVERY: Attempt to restore from backup if it exists
          try {
            final backupExists = await _tableExists(db, backupTableName);
            if (backupExists) {
              // Drop the potentially corrupted table
              await db.execute('DROP TABLE IF EXISTS $tableName');
              // Restore from backup
              await db.execute('ALTER TABLE $backupTableName RENAME TO $tableName');
              print('🔄 Successfully restored table $tableName from backup');
            }
          } catch (recoveryError) {
            print('💥 CRITICAL: Failed to recover from backup: $recoveryError');
            // This is a critical error - the migration failed and recovery failed
            rethrow;
          }
          
          // Re-throw the original migration error
          rethrow;
        }
      }
    } catch (e) {
      print('🚨 CRITICAL ERROR in _addColumnIfNotExists for $tableName.$columnName: $e');
      // Log to error handler for proper tracking
      print('Stack trace: ${StackTrace.current}');
      rethrow; // Re-throw to let caller handle the critical error
    }
  }
  
  /// Helper method to check if a table exists
  Future<bool> _tableExists(Database db, String tableName) async {
    try {
      final result = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
        [tableName]
      );
      return result.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Ensure created_at and updated_at columns exist in all tables
  Future<void> _ensureTimestampColumns(Database db) async {
    final now = DateTime.now().toIso8601String();
    
    // Check and add created_at/updated_at to entries table
    await _addColumnIfNotExists(db, 'entries', 'created_at', 'TEXT NOT NULL DEFAULT \'$now\'');
    await _addColumnIfNotExists(db, 'entries', 'updated_at', 'TEXT NOT NULL DEFAULT \'$now\'');
    
    // Check and add created_at/updated_at to substances table
    await _addColumnIfNotExists(db, 'substances', 'created_at', 'TEXT NOT NULL DEFAULT \'$now\'');
    await _addColumnIfNotExists(db, 'substances', 'updated_at', 'TEXT NOT NULL DEFAULT \'$now\'');
    
    // Check and add created_at/updated_at to quick_buttons table
    await _addColumnIfNotExists(db, 'quick_buttons', 'created_at', 'TEXT NOT NULL DEFAULT \'$now\'');
    await _addColumnIfNotExists(db, 'quick_buttons', 'updated_at', 'TEXT NOT NULL DEFAULT \'$now\'');
    
    // Check and add cost column to quick_buttons table
    await _addColumnIfNotExists(db, 'quick_buttons', 'cost', 'REAL NOT NULL DEFAULT 0.0');
    
    // Check and add created_at to dosage_calculator_users table
    await _addColumnIfNotExists(db, 'dosage_calculator_users', 'created_at', 'TEXT NOT NULL DEFAULT \'$now\'');
    
    // Check and add created_at/updated_at to dosage_calculator_substances table
    await _addColumnIfNotExists(db, 'dosage_calculator_substances', 'created_at', 'TEXT NOT NULL DEFAULT \'$now\'');
    await _addColumnIfNotExists(db, 'dosage_calculator_substances', 'updated_at', 'TEXT NOT NULL DEFAULT \'$now\'');
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
          'duration': 240, // 4 hours
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
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
          'duration': 120, // 2 hours
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
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
          'duration': 120, // 2 hours
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
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
          'duration': 1440, // 24 hours
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
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
          'duration': 360, // 6 hours
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        {
          'id': 'default_nicotine',
          'name': 'Nikotin',
          'category': 1, // stimulant
          'defaultRiskLevel': 2, // high
          'pricePerUnit': 0.5,
          'defaultUnit': 'mg',
          'notes': 'Hauptwirkstoff in Tabakprodukten',
          'iconName': 'cigarette',
          'duration': 30, // 30 minutes
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        {
          'id': 'default_melatonin',
          'name': 'Melatonin',
          'category': 3, // supplement
          'defaultRiskLevel': 0, // low
          'pricePerUnit': 0.3,
          'defaultUnit': 'mg',
          'notes': 'Natürliches Schlafhormon',
          'iconName': 'moon',
          'duration': 480, // 8 hours
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        {
          'id': 'default_paracetamol',
          'name': 'Paracetamol',
          'category': 0, // medication
          'defaultRiskLevel': 0, // low
          'pricePerUnit': 0.01,
          'defaultUnit': 'mg',
          'notes': 'Schmerzmittel und Fiebersenkend',
          'iconName': 'pill',
          'duration': 240, // 4 hours
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        {
          'id': 'default_multivitamin',
          'name': 'Multivitamin',
          'category': 3, // supplement
          'defaultRiskLevel': 0, // low
          'pricePerUnit': 0.25,
          'defaultUnit': 'Stück',
          'notes': 'Tägliche Vitamin- und Mineralstoffergänzung',
          'iconName': 'pill',
          'duration': 1440, // 24 hours
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
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

  // Safe query methods with parameter binding to prevent SQL injection
  
  /// Execute a safe SELECT query with parameter binding
  Future<List<Map<String, dynamic>>> safeQuery(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    try {
      final db = await database;
      return await db.query(
        table,
        distinct: distinct,
        columns: columns,
        where: where,
        whereArgs: whereArgs,
        groupBy: groupBy,
        having: having,
        orderBy: orderBy,
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      print('Error in safe query: $e');
      return [];
    }
  }

  /// Execute a safe INSERT with parameter binding
  Future<int> safeInsert(
    String table,
    Map<String, dynamic> values, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    try {
      final db = await database;
      return await db.insert(
        table,
        values,
        nullColumnHack: nullColumnHack,
        conflictAlgorithm: conflictAlgorithm,
      );
    } catch (e) {
      print('Error in safe insert: $e');
      return -1;
    }
  }

  /// Execute a safe UPDATE with parameter binding
  Future<int> safeUpdate(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<dynamic>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    try {
      final db = await database;
      return await db.update(
        table,
        values,
        where: where,
        whereArgs: whereArgs,
        conflictAlgorithm: conflictAlgorithm,
      );
    } catch (e) {
      print('Error in safe update: $e');
      return 0;
    }
  }

  /// Execute a safe DELETE with parameter binding
  Future<int> safeDelete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    try {
      final db = await database;
      return await db.delete(
        table,
        where: where,
        whereArgs: whereArgs,
      );
    } catch (e) {
      print('Error in safe delete: $e');
      return 0;
    }
  }

  /// Execute a safe raw query with parameter binding
  Future<List<Map<String, dynamic>>> safeRawQuery(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    try {
      final db = await database;
      
      // Validate SQL to prevent obvious injection attempts
      if (_containsSqlInjectionAttempt(sql)) {
        throw ArgumentError('Potentially unsafe SQL detected');
      }
      
      return await db.rawQuery(sql, arguments);
    } catch (e) {
      print('Error in safe raw query: $e');
      return [];
    }
  }

  /// Validate SQL string for obvious injection attempts
  bool _containsSqlInjectionAttempt(String sql) {
    final lowerSql = sql.toLowerCase();
    
    // Check for common SQL injection patterns
    final suspiciousPatterns = [
      ';',  // Multiple statements
      '--', // Comments
      '/*', // Block comments
      'union',
      'drop',
      'delete',
      'insert',
      'update',
      'create',
      'alter',
      'exec',
      'execute',
      'sp_',
      'xp_',
    ];
    
    // Only allow specific safe operations
    final allowedOperations = [
      'select',
      'pragma',
      'count',
      'max',
      'min',
      'avg',
      'sum',
    ];
    
    // Check if the query starts with an allowed operation
    bool startsWithAllowed = false;
    for (final op in allowedOperations) {
      if (lowerSql.trimLeft().startsWith(op)) {
        startsWithAllowed = true;
        break;
      }
    }
    
    if (!startsWithAllowed) {
      return true; // Suspicious - doesn't start with allowed operation
    }
    
    // Check for suspicious patterns
    for (final pattern in suspiciousPatterns) {
      if (lowerSql.contains(pattern)) {
        return true; // Suspicious pattern found
      }
    }
    
    return false; // Looks safe
  }

  /// Get table statistics safely
  Future<Map<String, int>> getTableStatistics() async {
    try {
      final stats = <String, int>{};
      
      // Use safe parameterized queries for table counts
      final tables = ['entries', 'substances', 'quick_buttons', 'dosage_calculator_users', 'dosage_calculator_substances'];
      
      for (final table in tables) {
        final result = await safeRawQuery('SELECT COUNT(*) as count FROM $table');
        stats[table] = (result.isNotEmpty ? result.first['count'] as int? : null) ?? 0;
      }
      
      return stats;
    } catch (e) {
      print('Error getting table statistics: $e');
      return {};
    }
  }
}
