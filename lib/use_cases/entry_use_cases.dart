/// Entry Management Use Cases
/// 
/// Phase 3: Architecture Improvements - Use Case Layer
/// Contains business logic for entry operations
/// 
/// Author: Code Quality Improvement Agent
/// Date: Phase 3 - Architecture Improvements

import 'package:uuid/uuid.dart';
import '../models/entry.dart';
import '../models/substance.dart';
import '../repositories/entry_repository.dart';
import '../repositories/substance_repository.dart';
import '../interfaces/service_interfaces.dart';

/// Use case for creating new entries
class CreateEntryUseCase {
  final IEntryRepository _entryRepository;
  final ISubstanceRepository _substanceRepository;

  CreateEntryUseCase(this._entryRepository, this._substanceRepository);

  /// Create a new entry with validation
  Future<String> execute({
    required String substanceId,
    required double dosage,
    required String unit,
    DateTime? dateTime,
    String? notes,
  }) async {
    // Validate substance exists
    final substance = await _substanceRepository.getSubstanceById(substanceId);
    if (substance == null) {
      throw ArgumentError('Substance with id $substanceId not found');
    }

    // Validate dosage
    if (dosage <= 0) {
      throw ArgumentError('Dosage must be greater than 0');
    }

    // Validate unit
    if (unit.trim().isEmpty) {
      throw ArgumentError('Unit cannot be empty');
    }

    // Create entry
    final entry = Entry(
      id: const Uuid().v4(),
      substanceId: substanceId,
      substanceName: substance.name,
      dosage: dosage,
      unit: unit,
      dateTime: dateTime ?? DateTime.now(),
      cost: 0.0, // Default cost
      notes: notes,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return await _entryRepository.createEntry(entry);
  }
}

/// Use case for creating an entry with timer
class CreateEntryWithTimerUseCase {
  final IEntryRepository _entryRepository;
  final ISubstanceRepository _substanceRepository;
  final ITimerService _timerService;

  CreateEntryWithTimerUseCase(
    this._entryRepository,
    this._substanceRepository,
    this._timerService,
  );

  /// Create a new entry and start a timer
  Future<Entry> execute({
    required String substanceId,
    required double dosage,
    required String unit,
    DateTime? dateTime,
    String? notes,
    Duration? customDuration,
  }) async {
    // Validate substance exists
    final substance = await _substanceRepository.getSubstanceById(substanceId);
    if (substance == null) {
      throw ArgumentError('Substance with id $substanceId not found');
    }

    // Validate dosage
    if (dosage <= 0) {
      throw ArgumentError('Dosage must be greater than 0');
    }

    // Create entry
    final entry = Entry(
      id: const Uuid().v4(),
      substanceId: substanceId,
      substanceName: substance.name,
      dosage: dosage,
      unit: unit,
      dateTime: dateTime ?? DateTime.now(),
      cost: 0.0, // Default cost
      notes: notes,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Create entry in database
    await _entryRepository.createEntry(entry);

    // Start timer
    return await _timerService.startTimer(entry, customDuration: customDuration);
  }
}

/// Use case for updating entries
class UpdateEntryUseCase {
  final IEntryRepository _entryRepository;
  final ISubstanceRepository _substanceRepository;

  UpdateEntryUseCase(this._entryRepository, this._substanceRepository);

  /// Update an existing entry with validation
  Future<void> execute(Entry updatedEntry) async {
    // Validate entry exists
    final existingEntry = await _entryRepository.getEntryById(updatedEntry.id);
    if (existingEntry == null) {
      throw ArgumentError('Entry with id ${updatedEntry.id} not found');
    }

    // Validate substance exists
    final substance = await _substanceRepository.getSubstanceById(updatedEntry.substanceId);
    if (substance == null) {
      throw ArgumentError('Substance with id ${updatedEntry.substanceId} not found');
    }

    // Validate dosage
    if (updatedEntry.dosage <= 0) {
      throw ArgumentError('Dosage must be greater than 0');
    }

    // Validate unit
    if (updatedEntry.unit.trim().isEmpty) {
      throw ArgumentError('Unit cannot be empty');
    }

    // Update substance name if it changed
    final entryWithUpdatedName = updatedEntry.copyWith(
      substanceName: substance.name,
    );

    await _entryRepository.updateEntry(entryWithUpdatedName);
  }
}

/// Use case for deleting entries
class DeleteEntryUseCase {
  final IEntryRepository _entryRepository;
  final ITimerService _timerService;

  DeleteEntryUseCase(this._entryRepository, this._timerService);

  /// Delete an entry and stop its timer if active
  Future<void> execute(String entryId) async {
    // Validate entry exists
    final entry = await _entryRepository.getEntryById(entryId);
    if (entry == null) {
      throw ArgumentError('Entry with id $entryId not found');
    }

    // Stop timer if active
    if (_timerService.isTimerActive(entryId)) {
      await _timerService.stopTimer(entryId);
    }

    // Delete entry
    await _entryRepository.deleteEntry(entryId);
  }
}

/// Use case for getting entries with filters
class GetEntriesUseCase {
  final IEntryRepository _entryRepository;

  GetEntriesUseCase(this._entryRepository);

  /// Get all entries
  Future<List<Entry>> getAllEntries() async {
    return await _entryRepository.getAllEntries();
  }

  /// Get entries by date range
  Future<List<Entry>> getEntriesByDateRange(DateTime start, DateTime end) async {
    if (start.isAfter(end)) {
      throw ArgumentError('Start date must be before end date');
    }
    return await _entryRepository.getEntriesByDateRange(start, end);
  }

  /// Get entries by substance
  Future<List<Entry>> getEntriesBySubstance(String substanceId) async {
    if (substanceId.trim().isEmpty) {
      throw ArgumentError('Substance ID cannot be empty');
    }
    return await _entryRepository.getEntriesBySubstance(substanceId);
  }

  /// Get active timer entries
  Future<List<Entry>> getActiveTimerEntries() async {
    return await _entryRepository.getActiveTimerEntries();
  }
}