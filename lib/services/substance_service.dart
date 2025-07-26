import 'package:flutter/foundation.dart';
// removed unused import: package:sqflite/sqflite.dart // cleaned by BereinigungsAgent
import '../models/substance.dart';
import '../utils/unit_manager.dart';
import '../interfaces/service_interfaces.dart';
import '../repositories/substance_repository.dart';

class SubstanceService extends ChangeNotifier implements ISubstanceService {
  final ISubstanceRepository _substanceRepository;

  SubstanceService(this._substanceRepository);

  // Create
  @override
  Future<String> createSubstance(Substance substance) async {
    try {
      await _substanceRepository.createSubstance(substance);
      notifyListeners();
      return substance.id;
    } catch (e) {
      throw Exception('Failed to create substance: $e');
    }
  }

  // Read - Get all substances
  @override
  Future<List<Substance>> getAllSubstances() async {
    try {
      final substances = await _substanceRepository.getAllSubstances();
      if (substances.isEmpty) {
        // If no substances found, initialize default substances
        await initializeDefaultSubstances();
        return await _substanceRepository.getAllSubstances();
      }
      return substances;
    } catch (e) {
      print('Error in getAllSubstances: $e');
      // Return default substances as fallback
      return Substance.getDefaultSubstances();
    }
  }

  // Read - Get substance by ID
  @override
  Future<Substance?> getSubstanceById(String id) async {
    try {
      return await _substanceRepository.getSubstanceById(id);
    } catch (e) {
      throw Exception('Failed to get substance by ID: $e');
    }
  }

  // Read - Get substance by name
  @override
  Future<Substance?> getSubstanceByName(String name) async {
    try {
      if (name.isEmpty) {
        return null;
      }
      return await _substanceRepository.getSubstanceByName(name);
    } catch (e) {
      throw Exception('Failed to get substance by name: $e');
    }
  }

  // Read - Search substances
  @override
  Future<List<Substance>> searchSubstances(String query) async {
    try {
      return await _substanceRepository.searchSubstances(query);
    } catch (e) {
      throw Exception('Failed to search substances: $e');
    }
  }

  // Update
  @override
  Future<void> updateSubstance(Substance substance) async {
    try {
      await _substanceRepository.updateSubstance(substance);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to update substance: $e');
    }
  }

  // Delete
  @override
  Future<void> deleteSubstance(String id) async {
    try {
      await _substanceRepository.deleteSubstance(id);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to delete substance: $e');
    }
  }

  // Get substances by category
  @override
  Future<List<Substance>> getSubstancesByCategory(SubstanceCategory category) async {
    try {
      return await _substanceRepository.getSubstancesByCategory(category);
    } catch (e) {
      throw Exception('Failed to get substances by category: $e');
    }
  }

  // Get most used substances
  @override
  Future<List<Substance>> getMostUsedSubstances({int limit = 10}) async {
    try {
      return await _substanceRepository.getMostUsedSubstances(limit: limit);
    } catch (e) {
      throw Exception('Failed to get most used substances: $e');
    }
  }

  // Initialize default substances if database is empty
  @override
  Future<void> initializeDefaultSubstances() async {
    try {
      final existingSubstances = await _substanceRepository.getAllSubstances();
      if (existingSubstances.isEmpty) {
        final defaultSubstances = Substance.getDefaultSubstances();
        for (final substance in defaultSubstances) {
          await _substanceRepository.createSubstance(substance);
        }
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Failed to initialize default substances: $e');
    }
  }

  // Get all unique units used in substances
  @override
  Future<List<String>> getAllUsedUnits() async {
    try {
      final substances = await getAllSubstances();
      return await UnitManager.getUsedUnits(substances);
    } catch (e) {
      throw Exception('Failed to get used units: $e');
    }
  }

  // Get suggested units for unit dropdown
  @override
  Future<List<String>> getSuggestedUnits() async {
    try {
      final substances = await getAllSubstances();
      return await UnitManager.getSuggestedUnits(substances);
    } catch (e) {
      throw Exception('Failed to get suggested units: $e');
    }
  }

  // Check if a unit exists in the database
  @override
  Future<bool> unitExists(String unit) async {
    try {
      final substances = await getAllSubstances();
      return await UnitManager.unitExists(unit, substances);
    } catch (e) {
      throw Exception('Failed to check unit existence: $e');
    }
  }

  // Get substances by unit
  @override
  Future<List<Substance>> getSubstancesByUnit(String unit) async {
    try {
      return await _substanceRepository.getSubstancesByUnit(unit);
    } catch (e) {
      throw Exception('Failed to get substances by unit: $e');
    }
  }

  // Validate unit before creating/updating substance
  @override
  String? validateUnit(String? unit) {
    return UnitManager.validateUnit(unit);
  }

  // Get recommended units for a substance category
  @override
  List<String> getRecommendedUnitsForCategory(SubstanceCategory category) {
    return UnitManager.getRecommendedUnitsForCategory(category);
  }
}
