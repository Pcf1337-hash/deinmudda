/// Substance Management Use Cases
/// 
/// Phase 3: Architecture Improvements - Use Case Layer
/// Contains business logic for substance operations
/// 
/// Author: Code Quality Improvement Agent
/// Date: Phase 3 - Architecture Improvements

import 'package:uuid/uuid.dart';
import '../models/substance.dart';
import '../repositories/substance_repository.dart';
import '../repositories/entry_repository.dart';

/// Use case for creating new substances
class CreateSubstanceUseCase {
  final ISubstanceRepository _substanceRepository;

  CreateSubstanceUseCase(this._substanceRepository);

  /// Create a new substance with validation
  Future<void> execute({
    required String name,
    required SubstanceCategory category,
    required RiskLevel defaultRiskLevel,
    required double pricePerUnit,
    required String defaultUnit,
    String? notes,
    String? iconName,
    Duration? duration,
  }) async {
    // Validate name
    if (name.trim().isEmpty) {
      throw ArgumentError('Substance name cannot be empty');
    }

    // Check if substance with same name already exists
    final existingSubstance = await _substanceRepository.getSubstanceByName(name.trim());
    if (existingSubstance != null) {
      throw ArgumentError('Substance with name "$name" already exists');
    }

    // Validate default unit
    if (defaultUnit.trim().isEmpty) {
      throw ArgumentError('Default unit cannot be empty');
    }

    // Validate price
    if (pricePerUnit < 0) {
      throw ArgumentError('Price per unit cannot be negative');
    }

    // Create substance
    final substance = Substance.create(
      name: name.trim(),
      category: category,
      defaultRiskLevel: defaultRiskLevel,
      pricePerUnit: pricePerUnit,
      defaultUnit: defaultUnit.trim(),
      notes: notes,
      iconName: iconName,
      duration: duration,
    );

    await _substanceRepository.createSubstance(substance);
  }
}

/// Use case for updating substances
class UpdateSubstanceUseCase {
  final ISubstanceRepository _substanceRepository;

  UpdateSubstanceUseCase(this._substanceRepository);

  /// Update an existing substance with validation
  Future<void> execute(Substance updatedSubstance) async {
    // Validate substance exists
    final existingSubstance = await _substanceRepository.getSubstanceById(updatedSubstance.id);
    if (existingSubstance == null) {
      throw ArgumentError('Substance with id ${updatedSubstance.id} not found');
    }

    // Validate name
    if (updatedSubstance.name.trim().isEmpty) {
      throw ArgumentError('Substance name cannot be empty');
    }

    // Check if another substance with same name exists (excluding current one)
    final substanceWithSameName = await _substanceRepository.getSubstanceByName(updatedSubstance.name.trim());
    if (substanceWithSameName != null && substanceWithSameName.id != updatedSubstance.id) {
      throw ArgumentError('Another substance with name "${updatedSubstance.name}" already exists');
    }

    // Validate category (assuming category is now an enum)
    // No validation needed for enum types

    await _substanceRepository.updateSubstance(updatedSubstance);
  }
}

/// Use case for deleting substances
class DeleteSubstanceUseCase {
  final ISubstanceRepository _substanceRepository;
  final IEntryRepository _entryRepository;

  DeleteSubstanceUseCase(this._substanceRepository, this._entryRepository);

  /// Delete a substance with safety checks
  Future<void> execute(String substanceId, {bool force = false}) async {
    // Validate substance exists
    final substance = await _substanceRepository.getSubstanceById(substanceId);
    if (substance == null) {
      throw ArgumentError('Substance with id $substanceId not found');
    }

    // Check if substance has associated entries
    final entriesWithSubstance = await _entryRepository.getEntriesBySubstance(substanceId);
    if (entriesWithSubstance.isNotEmpty && !force) {
      throw ArgumentError(
        'Cannot delete substance "${substance.name}" as it has ${entriesWithSubstance.length} associated entries. '
        'Use force=true to delete anyway.'
      );
    }

    await _substanceRepository.deleteSubstance(substanceId);
  }
}

/// Use case for getting substances with filters
class GetSubstancesUseCase {
  final ISubstanceRepository _substanceRepository;

  GetSubstancesUseCase(this._substanceRepository);

  /// Get all substances
  Future<List<Substance>> getAllSubstances() async {
    return await _substanceRepository.getAllSubstances();
  }

  /// Search substances by query
  Future<List<Substance>> searchSubstances(String query) async {
    if (query.trim().isEmpty) {
      return await getAllSubstances();
    }
    return await _substanceRepository.searchSubstances(query.trim());
  }

  /// Get recently used substances
  Future<List<Substance>> getRecentSubstances(int limit) async {
    if (limit <= 0) {
      throw ArgumentError('Limit must be greater than 0');
    }
    return await _substanceRepository.getRecentSubstances(limit);
  }

  /// Get substances by category
  Future<List<Substance>> getSubstancesByCategory(SubstanceCategory category) async {
    final allSubstances = await getAllSubstances();
    return allSubstances.where((substance) => 
      substance.category == category
    ).toList();
  }

  /// Get distinct categories
  Future<List<String>> getCategories() async {
    final allSubstances = await getAllSubstances();
    final categories = allSubstances.map((s) => s.categoryDisplayName).toSet().toList();
    categories.sort();
    return categories;
  }
}

/// Use case for substance statistics
class SubstanceStatisticsUseCase {
  final ISubstanceRepository _substanceRepository;
  final IEntryRepository _entryRepository;

  SubstanceStatisticsUseCase(this._substanceRepository, this._entryRepository);

  /// Get usage statistics for a substance
  Future<SubstanceUsageStats> getUsageStats(String substanceId) async {
    final substance = await _substanceRepository.getSubstanceById(substanceId);
    if (substance == null) {
      throw ArgumentError('Substance with id $substanceId not found');
    }

    final entries = await _entryRepository.getEntriesBySubstance(substanceId);
    
    if (entries.isEmpty) {
      return SubstanceUsageStats(
        substanceId: substanceId,
        substanceName: substance.name,
        totalEntries: 0,
        totalDosage: 0,
        averageDosage: 0,
        firstUse: null,
        lastUse: null,
        mostCommonUnit: '',
      );
    }

    final totalDosage = entries.fold<double>(0, (sum, entry) => sum + entry.dosage);
    final averageDosage = totalDosage / entries.length;
    
    // Find most common unit
    final unitCounts = <String, int>{};
    for (final entry in entries) {
      unitCounts[entry.unit] = (unitCounts[entry.unit] ?? 0) + 1;
    }
    final mostCommonUnit = unitCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    entries.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    return SubstanceUsageStats(
      substanceId: substanceId,
      substanceName: substance.name,
      totalEntries: entries.length,
      totalDosage: totalDosage,
      averageDosage: averageDosage,
      firstUse: entries.first.dateTime,
      lastUse: entries.last.dateTime,
      mostCommonUnit: mostCommonUnit,
    );
  }
}

/// Data class for substance usage statistics
class SubstanceUsageStats {
  final String substanceId;
  final String substanceName;
  final int totalEntries;
  final double totalDosage;
  final double averageDosage;
  final DateTime? firstUse;
  final DateTime? lastUse;
  final String mostCommonUnit;

  SubstanceUsageStats({
    required this.substanceId,
    required this.substanceName,
    required this.totalEntries,
    required this.totalDosage,
    required this.averageDosage,
    required this.firstUse,
    required this.lastUse,
    required this.mostCommonUnit,
  });
}