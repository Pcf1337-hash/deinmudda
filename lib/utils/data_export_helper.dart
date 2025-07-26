import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../services/entry_service.dart';
import '../services/substance_service.dart';
import '../services/quick_button_service.dart';
import '../services/database_service.dart';
import '../interfaces/service_interfaces.dart';
import '../utils/service_locator.dart';
// Import with prefix to avoid conflicts
import '../models/substance.dart' as substance_model;
import '../models/quick_button_config.dart';
import '../models/entry.dart';

class DataExportHelper {
  late final IEntryService _entryService;
  late final ISubstanceService _substanceService;
  late final IQuickButtonService _quickButtonService;
  late final DatabaseService _databaseService;

  DataExportHelper() {
    _entryService = ServiceLocator.get<IEntryService>();
    _substanceService = ServiceLocator.get<ISubstanceService>();
    _quickButtonService = ServiceLocator.get<IQuickButtonService>();
    _databaseService = ServiceLocator.get<DatabaseService>();
  }

  // Export all data to JSON file
  Future<String> exportAllData() async {
    try {
      // Get all data
      final entries = await _entryService.getAllEntries();
      final substances = await _substanceService.getAllSubstances();
      final quickButtons = await _quickButtonService.getAllQuickButtons();
      
      // Create export object
      final exportData = {
        'version': '1.0.0',
        'exportDate': DateTime.now().toIso8601String(),
        'entries': entries.map((e) => e.toJson()).toList(),
        'substances': substances.map((s) => s.toDatabase()).toList(),
        'quickButtons': quickButtons.map((b) => b.toJson()).toList(),
      };
      
      // Convert to JSON
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
      
      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final dateFormat = DateFormat('yyyyMMdd_HHmmss');
      final fileName = 'konsum_tracker_export_${dateFormat.format(DateTime.now())}.json';
      final file = File('${directory.path}/$fileName');
      
      await file.writeAsString(jsonString);
      
      return file.path;
    } catch (e) {
      throw Exception('Failed to export data: $e');
    }
  }

  // Share exported data
  Future<void> shareExportedData(String filePath) async {
    try {
      final result = await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Konsum Tracker Pro - Datenexport',
      );
      
      if (result.status != ShareResultStatus.success) {
        throw Exception('Failed to share data');
      }
    } catch (e) {
      throw Exception('Failed to share data: $e');
    }
  }

  // Export entries as CSV
  Future<String> exportEntriesAsCsv() async {
    try {
      final entries = await _entryService.getAllEntries();
      
      // Create CSV header
      final csvData = StringBuffer();
      csvData.writeln('ID,Substanz,Dosierung,Einheit,Datum,Uhrzeit,Kosten,Notizen');
      
      // Add entries
      for (final entry in entries) {
        final dateFormat = DateFormat('dd.MM.yyyy');
        final timeFormat = DateFormat('HH:mm');
        final date = dateFormat.format(entry.dateTime);
        final time = timeFormat.format(entry.dateTime);
        
        // Escape notes to handle commas and quotes
        final notes = entry.notes != null 
            ? '"${entry.notes!.replaceAll('"', '""')}"' 
            : '';
        
        csvData.writeln(
          '${entry.id},${entry.substanceName},${entry.dosage},${entry.unit},$date,$time,${entry.cost},$notes'
        );
      }
      
      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final dateFormat = DateFormat('yyyyMMdd_HHmmss');
      final fileName = 'konsum_tracker_entries_${dateFormat.format(DateTime.now())}.csv';
      final file = File('${directory.path}/$fileName');
      
      await file.writeAsString(csvData.toString());
      
      return file.path;
    } catch (e) {
      throw Exception('Failed to export entries as CSV: $e');
    }
  }

  // Import data from JSON file
  Future<Map<String, int>> importDataFromJson(String jsonString) async {
    try {
      final importData = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // Validate import data
      if (!importData.containsKey('version') || 
          !importData.containsKey('entries') || 
          !importData.containsKey('substances')) {
        throw Exception('Invalid import data format');
      }
      
      // Import substances first (due to foreign key constraints)
      int substancesCount = 0;
      if (importData.containsKey('substances')) {
        final substancesJson = importData['substances'] as List<dynamic>;
        for (final substanceJson in substancesJson) {
          try {
            final substanceMap = substanceJson as Map<String, dynamic>;
            final substance = substance_model.Substance(
              id: substanceMap['id'] as String,
              name: substanceMap['name'] as String,
              category: substance_model.SubstanceCategory.values[substanceMap['category'] as int],
              defaultRiskLevel: substance_model.RiskLevel.values[substanceMap['defaultRiskLevel'] as int],
              pricePerUnit: (substanceMap['pricePerUnit'] as num).toDouble(),
              defaultUnit: substanceMap['defaultUnit'] as String,
              notes: substanceMap['notes'] as String?,
              iconName: substanceMap['iconName'] as String?,
              createdAt: DateTime.parse(substanceMap['created_at'] as String),
              updatedAt: DateTime.parse(substanceMap['updated_at'] as String),
            );
            await _substanceService.createSubstance(substance);
            substancesCount++;
          } catch (e) {
            print('Error importing substance: $e');
            // Continue with next substance
          }
        }
      }
      
      // Import entries
      int entriesCount = 0;
      if (importData.containsKey('entries')) {
        final entriesJson = importData['entries'] as List<dynamic>;
        entriesCount = await _entryService.importEntriesFromJson(
          entriesJson.cast<Map<String, dynamic>>()
        );
      }
      
      // Import quick buttons
      int quickButtonsCount = 0;
      if (importData.containsKey('quickButtons')) {
        final quickButtonsJson = importData['quickButtons'] as List<dynamic>;
        for (final buttonJson in quickButtonsJson) {
          try {
            final buttonMap = buttonJson as Map<String, dynamic>;
            final button = QuickButtonConfig(
              id: buttonMap['id'] as String,
              substanceId: buttonMap['substanceId'] as String,
              substanceName: buttonMap['substanceName'] as String,
              dosage: (buttonMap['dosage'] as num).toDouble(),
              unit: buttonMap['unit'] as String,
              position: buttonMap['position'] as int,
              isActive: buttonMap['isActive'] as bool,
              createdAt: DateTime.parse(buttonMap['createdAt'] as String),
              updatedAt: DateTime.parse(buttonMap['updatedAt'] as String),
            );
            await _quickButtonService.createQuickButton(button);
            quickButtonsCount++;
          } catch (e) {
            print('Error importing quick button: $e');
            // Continue with next button
          }
        }
      }
      
      return {
        'substances': substancesCount,
        'entries': entriesCount,
        'quickButtons': quickButtonsCount,
      };
    } catch (e) {
      throw Exception('Failed to import data: $e');
    }
  }

  // Import data from file
  Future<Map<String, int>> importDataFromFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist');
      }
      
      final jsonString = await file.readAsString();
      return await importDataFromJson(jsonString);
    } catch (e) {
      throw Exception('Failed to import data from file: $e');
    }
  }

  // Create database backup
  Future<String> createDatabaseBackup() async {
    try {
      final dbPath = (await _databaseService.database).path;
      final dbFile = File(dbPath);
      
      // Create backup directory
      final directory = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${directory.path}/backups');
      if (!await backupDir.exists()) {
        await backupDir.create();
      }
      
      // Create backup file
      final dateFormat = DateFormat('yyyyMMdd_HHmmss');
      final backupFileName = 'konsum_tracker_backup_${dateFormat.format(DateTime.now())}.db';
      final backupFile = File('${backupDir.path}/$backupFileName');
      
      // Copy database file
      await dbFile.copy(backupFile.path);
      
      return backupFile.path;
    } catch (e) {
      throw Exception('Failed to create database backup: $e');
    }
  }

  // Restore database from backup
  Future<bool> restoreDatabaseFromBackup(String backupPath) async {
    try {
      final backupFile = File(backupPath);
      if (!await backupFile.exists()) {
        throw Exception('Backup file does not exist');
      }
      
      // Close current database
      await _databaseService.close();
      
      // Get path to current database
      final dbPath = (await _databaseService.database).path;
      final dbFile = File(dbPath);
      
      // Delete current database
      if (await dbFile.exists()) {
        await dbFile.delete();
      }
      
      // Copy backup to database location
      await backupFile.copy(dbPath);
      
      return true;
    } catch (e) {
      throw Exception('Failed to restore database from backup: $e');
    }
  }

  // Get list of available backups
  Future<List<Map<String, dynamic>>> getAvailableBackups() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${directory.path}/backups');
      
      if (!await backupDir.exists()) {
        return [];
      }
      
      final backupFiles = await backupDir.list().toList();
      final backups = <Map<String, dynamic>>[];
      
      for (final file in backupFiles) {
        if (file is File && file.path.endsWith('.db')) {
          final fileName = file.path.split('/').last;
          final fileStat = await file.stat();
          
          backups.add({
            'path': file.path,
            'name': fileName,
            'size': fileStat.size,
            'modified': fileStat.modified,
          });
        }
      }
      
      // Sort by modified date (newest first)
      backups.sort((a, b) => (b['modified'] as DateTime).compareTo(a['modified'] as DateTime));
      
      return backups;
    } catch (e) {
      throw Exception('Failed to get available backups: $e');
    }
  }
}