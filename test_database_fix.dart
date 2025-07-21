import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'lib/services/database_service.dart';
import 'lib/models/quick_button_config.dart';
import 'lib/models/entry.dart';

/// Simple test to verify database schema fixes work correctly
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🔍 Testing database schema fixes...');
  
  try {
    // Initialize database service
    final dbService = DatabaseService();
    
    // Delete existing database to test fresh creation
    await dbService.deleteDatabase();
    print('✅ Old database deleted');
    
    // Initialize fresh database
    final db = await dbService.database;
    print('✅ Fresh database created');
    
    // Test 1: Check if quick_buttons table has the expected columns
    print('\n📊 Testing quick_buttons table schema...');
    final quickButtonsInfo = await db.rawQuery('PRAGMA table_info(quick_buttons)');
    final quickButtonColumns = quickButtonsInfo.map((col) => col['name']).toSet();
    
    final expectedQuickButtonColumns = {
      'id', 'substanceId', 'substanceName', 'dosage', 'unit', 'cost', 
      'position', 'isActive', 'created_at', 'updated_at', 'iconCodePoint', 'colorValue'
    };
    
    print('Expected columns: $expectedQuickButtonColumns');
    print('Actual columns: $quickButtonColumns');
    
    if (expectedQuickButtonColumns.every((col) => quickButtonColumns.contains(col))) {
      print('✅ quick_buttons table has all required columns');
    } else {
      final missing = expectedQuickButtonColumns.difference(quickButtonColumns);
      print('❌ quick_buttons table missing columns: $missing');
      return;
    }
    
    // Test 2: Check if entries table has the expected columns
    print('\n📊 Testing entries table schema...');
    final entriesInfo = await db.rawQuery('PRAGMA table_info(entries)');
    final entriesColumns = entriesInfo.map((col) => col['name']).toSet();
    
    final expectedEntriesColumns = {
      'id', 'substanceId', 'substanceName', 'dosage', 'unit', 'dateTime', 'cost',
      'notes', 'created_at', 'updated_at', 'timerStartTime', 'timerEndTime',
      'timerCompleted', 'timerNotificationSent', 'iconCodePoint', 'colorValue'
    };
    
    print('Expected columns: $expectedEntriesColumns');
    print('Actual columns: $entriesColumns');
    
    if (expectedEntriesColumns.every((col) => entriesColumns.contains(col))) {
      print('✅ entries table has all required columns');
    } else {
      final missing = expectedEntriesColumns.difference(entriesColumns);
      print('❌ entries table missing columns: $missing');
      return;
    }
    
    // Test 3: Test creating a quick button with icon and color
    print('\n🔧 Testing QuickButtonConfig creation with icon and color...');
    
    final quickButton = QuickButtonConfig.create(
      substanceId: 'test_substance',
      substanceName: 'Test Substance',
      dosage: 100.0,
      unit: 'mg',
      cost: 5.0,
      position: 0,
      icon: Icons.local_cafe,
      color: Colors.blue,
    );
    
    // Insert into database
    await db.insert('quick_buttons', quickButton.toDatabase());
    print('✅ QuickButtonConfig with icon and color inserted successfully');
    
    // Retrieve from database
    final retrievedMaps = await db.query('quick_buttons', where: 'id = ?', whereArgs: [quickButton.id]);
    final retrieved = QuickButtonConfig.fromDatabase(retrievedMaps.first);
    
    print('Original icon codePoint: ${quickButton.iconCodePoint}');
    print('Retrieved icon codePoint: ${retrieved.iconCodePoint}');
    print('Original color value: ${quickButton.colorValue}');
    print('Retrieved color value: ${retrieved.colorValue}');
    
    if (retrieved.iconCodePoint == quickButton.iconCodePoint && 
        retrieved.colorValue == quickButton.colorValue) {
      print('✅ Icon and color data persisted correctly in quick_buttons');
    } else {
      print('❌ Icon and color data not persisted correctly in quick_buttons');
      return;
    }
    
    // Test 4: Test creating an entry with icon and color
    print('\n🔧 Testing Entry creation with icon and color...');
    
    final entry = Entry.create(
      substanceId: 'test_substance',
      substanceName: 'Test Substance',
      dosage: 50.0,
      unit: 'mg',
      dateTime: DateTime.now(),
      cost: 2.5,
      icon: Icons.medication,
      color: Colors.green,
    );
    
    // Insert into database
    await db.insert('entries', entry.toDatabase());
    print('✅ Entry with icon and color inserted successfully');
    
    // Retrieve from database
    final retrievedEntryMaps = await db.query('entries', where: 'id = ?', whereArgs: [entry.id]);
    final retrievedEntry = Entry.fromDatabase(retrievedEntryMaps.first);
    
    print('Original entry icon codePoint: ${entry.iconCodePoint}');
    print('Retrieved entry icon codePoint: ${retrievedEntry.iconCodePoint}');
    print('Original entry color value: ${entry.colorValue}');
    print('Retrieved entry color value: ${retrievedEntry.colorValue}');
    
    if (retrievedEntry.iconCodePoint == entry.iconCodePoint && 
        retrievedEntry.colorValue == entry.colorValue) {
      print('✅ Icon and color data persisted correctly in entries');
    } else {
      print('❌ Icon and color data not persisted correctly in entries');
      return;
    }
    
    print('\n🎉 All database schema tests passed successfully!');
    print('📝 Summary:');
    print('  - quick_buttons table has all required columns including iconCodePoint and colorValue');
    print('  - entries table has all required columns including iconCodePoint and colorValue');
    print('  - Quick button icon and color data persists correctly');
    print('  - Entry icon and color data persists correctly');
    
    // Clean up
    await dbService.close();
    
  } catch (e, stackTrace) {
    print('❌ Test failed with error: $e');
    print('Stack trace: $stackTrace');
    exit(1);
  }
}