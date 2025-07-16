import 'package:sqflite/sqflite.dart';
import '../models/quick_button_config.dart';
import '../models/substance.dart';
import 'database_service.dart';
import 'substance_service.dart';

class QuickButtonService {
  final DatabaseService _databaseService = DatabaseService();
  final SubstanceService _substanceService = SubstanceService();

  // Create
  Future<String> createQuickButton(QuickButtonConfig config) async {
    try {
      final db = await _databaseService.database;
      await db.insert(
        'quick_buttons',
        config.toDatabase(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return config.id;
    } catch (e) {
      throw Exception('Failed to create quick button: $e');
    }
  }

  // Read - Get all quick buttons
  Future<List<QuickButtonConfig>> getAllQuickButtons() async {
    try {
      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'quick_buttons',
        where: 'isActive = ?',
        whereArgs: [1],
        orderBy: 'position ASC',
      );
      return maps.map((map) => QuickButtonConfig.fromDatabase(map)).toList();
    } catch (e) {
      throw Exception('Failed to get quick buttons: $e');
    }
  }

  // Read - Get quick button by ID
  Future<QuickButtonConfig?> getQuickButtonById(String id) async {
    try {
      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'quick_buttons',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      
      if (maps.isEmpty) return null;
      return QuickButtonConfig.fromDatabase(maps.first);
    } catch (e) {
      throw Exception('Failed to get quick button by ID: $e');
    }
  }

  // Read - Get quick buttons by substance
  Future<List<QuickButtonConfig>> getQuickButtonsBySubstance(String substanceId) async {
    try {
      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'quick_buttons',
        where: 'substanceId = ? AND isActive = ?',
        whereArgs: [substanceId, 1],
        orderBy: 'position ASC',
      );
      return maps.map((map) => QuickButtonConfig.fromDatabase(map)).toList();
    } catch (e) {
      throw Exception('Failed to get quick buttons by substance: $e');
    }
  }

  // Update
  Future<void> updateQuickButton(QuickButtonConfig config) async {
    try {
      final db = await _databaseService.database;
      final updatedConfig = config.copyWith(
        updatedAt: DateTime.now(),
      );
      
      await db.update(
        'quick_buttons',
        updatedConfig.toDatabase(),
        where: 'id = ?',
        whereArgs: [config.id],
      );
    } catch (e) {
      throw Exception('Failed to update quick button: $e');
    }
  }

  // Delete
  Future<void> deleteQuickButton(String id) async {
    try {
      final db = await _databaseService.database;
      await db.delete(
        'quick_buttons',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      // Reorder remaining buttons to ensure no gaps in position
      await _reorderAfterDelete();
    } catch (e) {
      throw Exception('Failed to delete quick button: $e');
    }
  }

  // Reorder quick buttons
  Future<void> reorderQuickButtons(List<QuickButtonConfig> reorderedButtons) async {
    try {
      final db = await _databaseService.database;
      
      await _databaseService.transaction((txn) async {
        for (int i = 0; i < reorderedButtons.length; i++) {
          final button = reorderedButtons[i].copyWith(position: i);
          await txn.update(
            'quick_buttons',
            button.toDatabase(),
            where: 'id = ?',
            whereArgs: [button.id],
          );
        }
      });
    } catch (e) {
      throw Exception('Failed to reorder quick buttons: $e');
    }
  }

  // Get next order index
  Future<int> getNextOrderIndex() async {
    try {
      final db = await _databaseService.database;
      final result = await db.rawQuery('SELECT MAX(position) as maxPosition FROM quick_buttons');
      final maxPosition = result.first['maxPosition'] as int?;
      return (maxPosition ?? -1) + 1;
    } catch (e) {
      throw Exception('Failed to get next order index: $e');
    }
  }

  // Move quick button to position
  Future<void> moveQuickButtonToPosition(String buttonId, int newPosition) async {
    try {
      final allButtons = await getAllQuickButtons();
      final buttonToMove = allButtons.firstWhere((b) => b.id == buttonId);
      final otherButtons = allButtons.where((b) => b.id != buttonId).toList();
      
      // Insert at new position
      otherButtons.insert(newPosition, buttonToMove);
      
      // Update order indices
      final updatedButtons = otherButtons.asMap().entries.map((entry) {
        final index = entry.key;
        final button = entry.value;
        return button.copyWith(position: index);
      }).toList();
      
      // Save updated order
      await reorderQuickButtons(updatedButtons);
    } catch (e) {
      throw Exception('Failed to move quick button to position: $e');
    }
  }

  // Reorder after delete to ensure no gaps in position
  Future<void> _reorderAfterDelete() async {
    try {
      final buttons = await getAllQuickButtons();
      
      // Update positions to be sequential
      final updatedButtons = buttons.asMap().entries.map((entry) {
        final index = entry.key;
        final button = entry.value;
        return button.copyWith(position: index);
      }).toList();
      
      await reorderQuickButtons(updatedButtons);
    } catch (e) {
      throw Exception('Failed to reorder after delete: $e');
    }
  }

  // Create quick buttons for most used substances
  Future<List<String>> createQuickButtonsForMostUsedSubstances({int limit = 5}) async {
    try {
      final substances = await _substanceService.getMostUsedSubstances(limit: limit);
      final List<String> createdIds = [];
      
      if (substances.isEmpty) return createdIds;
      
      // Get next position index
      int position = await getNextOrderIndex();
      
      for (final substance in substances) {
        // Check if a quick button already exists for this substance
        final existingButtons = await getQuickButtonsBySubstance(substance.id);
        if (existingButtons.isNotEmpty) continue;
        
        // Create new quick button
        final config = QuickButtonConfig.create(
          substanceId: substance.id,
          substanceName: substance.name,
          dosage: 1.0, // Default dosage
          unit: substance.defaultUnit,
          position: position++,
        );
        
        final id = await createQuickButton(config);
        createdIds.add(id);
      }
      
      return createdIds;
    } catch (e) {
      throw Exception('Failed to create quick buttons for most used substances: $e');
    }
  }

  // Create quick buttons for favorite substances
  Future<List<String>> createQuickButtonsForFavorites(List<Substance> favorites) async {
    try {
      final List<String> createdIds = [];
      
      if (favorites.isEmpty) return createdIds;
      
      // Get next position index
      int position = await getNextOrderIndex();
      
      for (final substance in favorites) {
        // Check if a quick button already exists for this substance
        final existingButtons = await getQuickButtonsBySubstance(substance.id);
        if (existingButtons.isNotEmpty) continue;
        
        // Create new quick button
        final config = QuickButtonConfig.create(
          substanceId: substance.id,
          substanceName: substance.name,
          dosage: 1.0, // Default dosage
          unit: substance.defaultUnit,
          position: position++,
        );
        
        final id = await createQuickButton(config);
        createdIds.add(id);
      }
      
      return createdIds;
    } catch (e) {
      throw Exception('Failed to create quick buttons for favorites: $e');
    }
  }

  // Get quick button statistics
  Future<Map<String, dynamic>> getQuickButtonStats() async {
    try {
      final db = await _databaseService.database;
      
      // Total quick buttons
      final totalButtons = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM quick_buttons WHERE isActive = 1')
      ) ?? 0;
      
      // Most used substance in quick buttons
      final mostUsedResult = await db.rawQuery('''
        SELECT 
          substanceName,
          COUNT(*) as count
        FROM quick_buttons
        WHERE isActive = 1
        GROUP BY substanceName
        ORDER BY count DESC
        LIMIT 1
      ''');
      
      final mostUsedSubstance = mostUsedResult.isNotEmpty 
          ? mostUsedResult.first['substanceName'] as String
          : null;
      
      return {
        'totalButtons': totalButtons,
        'mostUsedSubstance': mostUsedSubstance,
      };
    } catch (e) {
      throw Exception('Failed to get quick button stats: $e');
    }
  }

  // Create entry from quick button with price calculation
  Future<Entry> createEntryFromQuickButton(QuickButtonConfig config) async {
    try {
      // Get substance details for price calculation
      final substance = await _substanceService.getSubstanceById(config.substanceId);
      
      // Create the entry
      final entry = Entry.create(
        substanceId: config.substanceId,
        substanceName: config.substanceName,
        dosage: config.dosage,
        unit: config.unit,
        dateTime: DateTime.now(),
        notes: 'Erstellt über Quick Button',
      );
      
      // Calculate price if both dosage and substance price are available
      double calculatedPrice = 0.0;
      if (config.dosage != null && substance?.pricePerUnit != null) {
        calculatedPrice = config.dosage * substance!.pricePerUnit;
      }
      
      // Create final entry with calculated price
      final entryWithPrice = entry.copyWith(cost: calculatedPrice);
      
      return entryWithPrice;
    } catch (e) {
      throw Exception('Failed to create entry from quick button: $e');
    }
  }

  // Toggle quick button active state
  Future<void> toggleQuickButtonActive(String id, bool isActive) async {
    try {
      final button = await getQuickButtonById(id);
      if (button != null) {
        final updatedButton = button.copyWith(isActive: isActive);
        await updateQuickButton(updatedButton);
      }
    } catch (e) {
      throw Exception('Failed to toggle quick button active state: $e');
    }
  }
}