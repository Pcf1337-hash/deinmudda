/// Example of refactored screen using new architecture
/// 
/// Phase 3: Architecture Improvements - Demo Implementation
/// Shows how to use ServiceLocator with Use Cases instead of direct service calls
/// 
/// Author: Code Quality Improvement Agent
/// Date: Phase 3 - Architecture Improvements

import 'package:flutter/material.dart';
import '../utils/service_locator.dart';
import '../use_cases/entry_use_cases.dart';
import '../use_cases/substance_use_cases.dart';
import '../models/entry.dart';
import '../models/substance.dart';

/// Example screen showing how to use the new architecture
/// This demonstrates the pattern that other screens should follow
class ExampleRefactoredScreen extends StatefulWidget {
  const ExampleRefactoredScreen({super.key});

  @override
  State<ExampleRefactoredScreen> createState() => _ExampleRefactoredScreenState();
}

class _ExampleRefactoredScreenState extends State<ExampleRefactoredScreen> {
  // Use cases (injected via ServiceLocator)
  late final CreateEntryUseCase _createEntryUseCase;
  late final GetEntriesUseCase _getEntriesUseCase;
  late final GetSubstancesUseCase _getSubstancesUseCase;
  
  // State
  List<Entry> _entries = [];
  List<Substance> _substances = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeUseCases();
    _loadData();
  }

  /// Initialize use cases from ServiceLocator
  /// This is the new pattern - inject dependencies instead of creating them
  void _initializeUseCases() {
    _createEntryUseCase = ServiceLocator.get<CreateEntryUseCase>();
    _getEntriesUseCase = ServiceLocator.get<GetEntriesUseCase>();
    _getSubstancesUseCase = ServiceLocator.get<GetSubstancesUseCase>();
  }

  /// Load data using use cases
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Use cases handle all business logic and validation
      final entries = await _getEntriesUseCase.getAllEntries();
      final substances = await _getSubstancesUseCase.getAllSubstances();
      
      setState(() {
        _entries = entries;
        _substances = substances;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Example of creating an entry using the use case
  Future<void> _createSampleEntry() async {
    if (_substances.isEmpty) return;

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Use case handles all validation and business logic
      await _createEntryUseCase.execute(
        substanceId: _substances.first.id,
        dosage: 10.0,
        unit: 'mg',
        notes: 'Sample entry created via new architecture',
      );

      // Reload data to show the new entry
      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entry created successfully!')),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to create entry: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Architecture Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Architecture Info Card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'New Architecture Pattern',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '• Uses ServiceLocator for dependency injection\n'
                                '• Business logic in Use Cases\n'
                                '• Data access through Repositories\n'
                                '• Services implement interfaces for testability',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Substances Section
                      Text(
                        'Substances (${_substances.length})',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      if (_substances.isEmpty)
                        const Text('No substances found')
                      else
                        Column(
                          children: _substances.take(3).map((substance) {
                            return ListTile(
                              title: Text(substance.name),
                              subtitle: Text(substance.category),
                              leading: CircleAvatar(
                                backgroundColor: Color(
                                  int.parse(substance.color.substring(1), radix: 16) + 0xFF000000,
                                ),
                                child: Text(
                                  substance.name.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: 16),

                      // Entries Section
                      Text(
                        'Recent Entries (${_entries.length})',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      if (_entries.isEmpty)
                        const Text('No entries found')
                      else
                        Column(
                          children: _entries.take(3).map((entry) {
                            return ListTile(
                              title: Text(entry.substanceName),
                              subtitle: Text('${entry.dosage} ${entry.unit}'),
                              trailing: Text(
                                '${entry.dateTime.hour}:${entry.dateTime.minute.toString().padLeft(2, '0')}',
                              ),
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: 16),

                      // Action Button
                      if (_substances.isNotEmpty)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _createSampleEntry,
                            child: const Text('Create Sample Entry'),
                          ),
                        ),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadData,
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  @override
  void dispose() {
    // Note: Use cases are managed by ServiceLocator, no need to dispose
    super.dispose();
  }
}