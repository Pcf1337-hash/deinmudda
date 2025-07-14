import 'package:flutter_test/flutter_test.dart';
import 'package:konsum_tracker_pro/services/database_service.dart';
import 'package:konsum_tracker_pro/models/entry.dart';
import 'package:konsum_tracker_pro/models/substance.dart';
import 'package:konsum_tracker_pro/models/quick_button_config.dart';

void main() {
  group('Database Service Tests', () {
    late DatabaseService databaseService;

    setUp(() async {
      databaseService = DatabaseService();
      await databaseService.deleteDatabase(); // Clean slate for each test
    });

    tearDown(() async {
      await databaseService.close();
    });

    test('Database initialization should succeed', () async {
      final db = await databaseService.database;
      expect(db.isOpen, true);
      
      // Check database health
      final isHealthy = await databaseService.isDatabaseHealthy();
      expect(isHealthy, true);
    });

    test('Database integrity should be maintained', () async {
      await databaseService.database; // Initialize database
      
      final isIntact = await databaseService.checkDatabaseIntegrity();
      expect(isIntact, true);
    });

    test('Database info should be retrievable', () async {
      await databaseService.database; // Initialize database
      
      final info = await databaseService.getDatabaseInfo();
      expect(info, isNotEmpty);
      expect(info.containsKey('version'), true);
      expect(info.containsKey('substancesCount'), true);
      expect(info['substancesCount'], greaterThan(0)); // Should have default substances
    });

    test('Default substances should be inserted correctly', () async {
      await databaseService.database; // Initialize database
      
      final info = await databaseService.getDatabaseInfo();
      expect(info['substancesCount'], greaterThan(7)); // Should have at least 8 default substances
    });

    test('Database vacuum should work', () async {
      await databaseService.database; // Initialize database
      
      // Should not throw any errors
      await databaseService.vacuumDatabase();
      
      // Database should still be healthy
      final isHealthy = await databaseService.isDatabaseHealthy();
      expect(isHealthy, true);
    });
  });
}