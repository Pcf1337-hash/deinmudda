/// Widget Tests with ServiceLocator Integration
/// 
/// Phase 6: Testing Implementation - Widget Tests
/// Tests UI components with dependency injection
/// 
/// Author: Code Quality Improvement Agent
/// Date: Phase 6 - Testing Implementation

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../mocks/service_mocks.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('Widget Tests with ServiceLocator Integration', () {
    late MockEntryService mockEntryService;
    late MockSubstanceService mockSubstanceService;
    late MockTimerService mockTimerService;

    setUp(() async {
      await TestSetupHelper.initializeTestEnvironment();
      
      mockEntryService = MockEntryService();
      mockSubstanceService = MockSubstanceService();
      mockTimerService = MockTimerService();
    });

    tearDown(() async {
      await TestSetupHelper.cleanupTestEnvironment();
    });

    group('Entry List Widget Tests', () {
      testWidgets('should display entries from service', (WidgetTester tester) async {
        // Arrange
        final testEntries = TestDataPresets.createRecentEntries();
        for (final entry in testEntries) {
          mockEntryService.addMockEntry(entry);
        }

        // Create a simple widget that displays entries
        final widget = MaterialApp(
          home: Scaffold(
            body: FutureBuilder(
              future: mockEntryService.getAllEntries(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                
                final entries = snapshot.data as List;
                return ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return ListTile(
                      title: Text(entry.substanceName),
                      subtitle: Text('${entry.dosage} ${entry.unit}'),
                      key: Key('entry_${entry.id}'),
                    );
                  },
                );
              },
            ),
          ),
        );

        // Act
        await tester.pumpWidget(widget);
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(ListTile), findsNWidgets(3));
        expect(find.text('Caffeine'), findsOneWidget);
        expect(find.text('200.0 mg'), findsOneWidget);
        
        WidgetTestHelper.expectNoOverflow(tester);
      });

      testWidgets('should handle empty entry list', (WidgetTester tester) async {
        // Arrange - Empty entry service
        final widget = MaterialApp(
          home: Scaffold(
            body: FutureBuilder(
              future: mockEntryService.getAllEntries(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                
                final entries = snapshot.data as List;
                if (entries.isEmpty) {
                  return const Center(
                    child: Text('No entries found'),
                  );
                }
                
                return ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return ListTile(
                      title: Text(entry.substanceName),
                    );
                  },
                );
              },
            ),
          ),
        );

        // Act
        await tester.pumpWidget(widget);
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('No entries found'), findsOneWidget);
        expect(find.byType(ListTile), findsNothing);
        
        WidgetTestHelper.expectNoOverflow(tester);
      });
    });

    group('Substance Selection Widget Tests', () {
      testWidgets('should display substances from service', (WidgetTester tester) async {
        // Arrange
        final testSubstances = TestDataPresets.createTypicalSubstanceLibrary();
        for (final substance in testSubstances) {
          mockSubstanceService.addMockSubstance(substance);
        }

        final widget = MaterialApp(
          home: Scaffold(
            body: FutureBuilder(
              future: mockSubstanceService.getAllSubstances(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                
                final substances = snapshot.data as List;
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: substances.length,
                  itemBuilder: (context, index) {
                    final substance = substances[index];
                    return Card(
                      key: Key('substance_${substance.id}'),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              substance.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              substance.category.toString().split('.').last,
                              style: const TextStyle(fontSize: 12),
                            ),
                            const Spacer(),
                            Text(
                              '${substance.defaultUnit}',
                              style: const TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );

        // Act
        await tester.pumpWidget(widget);
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(Card), findsNWidgets(4));
        expect(find.text('Caffeine'), findsOneWidget);
        expect(find.text('Melatonin'), findsOneWidget);
        expect(find.text('Ibuprofen'), findsOneWidget);
        expect(find.text('Alcohol'), findsOneWidget);
        
        WidgetTestHelper.expectNoOverflow(tester);
      });

      testWidgets('should handle substance selection', (WidgetTester tester) async {
        // Arrange
        String? selectedSubstanceId;
        final testSubstances = TestDataPresets.createTypicalSubstanceLibrary();
        for (final substance in testSubstances) {
          mockSubstanceService.addMockSubstance(substance);
        }

        final widget = MaterialApp(
          home: Scaffold(
            body: FutureBuilder(
              future: mockSubstanceService.getAllSubstances(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                
                final substances = snapshot.data as List;
                return Column(
                  children: [
                    if (selectedSubstanceId != null)
                      Text('Selected: $selectedSubstanceId'),
                    Expanded(
                      child: ListView.builder(
                        itemCount: substances.length,
                        itemBuilder: (context, index) {
                          final substance = substances[index];
                          return ListTile(
                            key: Key('substance_${substance.id}'),
                            title: Text(substance.name),
                            onTap: () {
                              selectedSubstanceId = substance.id;
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );

        // Act
        await tester.pumpWidget(widget);
        await tester.pumpAndSettle();

        // Tap on Caffeine
        await tester.tap(find.text('Caffeine'));
        await tester.pumpAndSettle();

        // Assert
        final caffeineSubstance = testSubstances.firstWhere((s) => s.name == 'Caffeine');
        expect(selectedSubstanceId, equals(caffeineSubstance.id));
        
        WidgetTestHelper.expectNoOverflow(tester);
      });
    });

    group('Timer Display Widget Tests', () {
      testWidgets('should display active timers', (WidgetTester tester) async {
        // Arrange
        final entriesWithTimers = TestDataPresets.createActiveTimerEntries();
        for (final entry in entriesWithTimers) {
          mockTimerService.addMockTimer(entry.id, entry, entry.duration!);
        }

        final widget = MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text('Active Timers: ${mockTimerService.getActiveTimers().length}'),
                Expanded(
                  child: ListView.builder(
                    itemCount: mockTimerService.getActiveTimers().length,
                    itemBuilder: (context, index) {
                      final timers = mockTimerService.getActiveTimers();
                      final entryId = timers.keys.elementAt(index);
                      final entry = timers[entryId]!;
                      final progress = mockTimerService.getTimerProgress(entryId);
                      final remainingTime = mockTimerService.getRemainingTime(entryId);
                      
                      return Card(
                        key: Key('timer_$entryId'),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.substanceName,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(value: progress),
                              const SizedBox(height: 8),
                              Text('Remaining: ${remainingTime?.inMinutes ?? 0} minutes'),
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () => mockTimerService.pauseTimer(entryId),
                                    child: Text(mockTimerService.isTimerPaused(entryId) ? 'Resume' : 'Pause'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () => mockTimerService.stopTimer(entryId),
                                    child: const Text('Stop'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );

        // Act
        await tester.pumpWidget(widget);
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Active Timers: 2'), findsOneWidget);
        expect(find.byType(Card), findsNWidgets(2));
        expect(find.byType(LinearProgressIndicator), findsNWidgets(2));
        expect(find.text('Pause'), findsNWidgets(2));
        expect(find.text('Stop'), findsNWidgets(2));
        
        WidgetTestHelper.expectNoOverflow(tester);
      });

      testWidgets('should handle timer controls', (WidgetTester tester) async {
        // Arrange
        final entry = TestDataFactory.createTestEntryWithTimer();
        mockTimerService.addMockTimer(entry.id, entry, entry.duration!);

        final widget = StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    Text('Timer Status: ${mockTimerService.isTimerPaused(entry.id) ? 'Paused' : 'Running'}'),
                    ElevatedButton(
                      key: const Key('pause_button'),
                      onPressed: () {
                        mockTimerService.pauseTimer(entry.id);
                        setState(() {});
                      },
                      child: Text(mockTimerService.isTimerPaused(entry.id) ? 'Resume' : 'Pause'),
                    ),
                    ElevatedButton(
                      key: const Key('stop_button'),
                      onPressed: () {
                        mockTimerService.stopTimer(entry.id);
                        setState(() {});
                      },
                      child: const Text('Stop'),
                    ),
                  ],
                ),
              ),
            );
          },
        );

        // Act & Assert
        await tester.pumpWidget(widget);
        await tester.pumpAndSettle();

        // Initially running
        expect(find.text('Timer Status: Running'), findsOneWidget);
        expect(find.text('Pause'), findsOneWidget);

        // Pause timer
        await tester.tap(find.byKey(const Key('pause_button')));
        await tester.pumpAndSettle();

        expect(find.text('Timer Status: Paused'), findsOneWidget);
        expect(find.text('Resume'), findsOneWidget);

        // Stop timer
        await tester.tap(find.byKey(const Key('stop_button')));
        await tester.pumpAndSettle();

        expect(mockTimerService.hasActiveTimer(entry.id), isFalse);
        
        WidgetTestHelper.expectNoOverflow(tester);
      });
    });

    group('Form Widget Tests', () {
      testWidgets('should validate entry form inputs', (WidgetTester tester) async {
        // Arrange
        final formKey = GlobalKey<FormState>();
        String? substanceName;
        double? dosage;

        final widget = MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    key: const Key('substance_name_field'),
                    decoration: const InputDecoration(labelText: 'Substance Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter substance name';
                      }
                      return null;
                    },
                    onSaved: (value) => substanceName = value,
                  ),
                  TextFormField(
                    key: const Key('dosage_field'),
                    decoration: const InputDecoration(labelText: 'Dosage'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter dosage';
                      }
                      final parsedValue = double.tryParse(value);
                      if (parsedValue == null || parsedValue <= 0) {
                        return 'Please enter valid dosage';
                      }
                      return null;
                    },
                    onSaved: (value) => dosage = double.tryParse(value ?? ''),
                  ),
                  ElevatedButton(
                    key: const Key('submit_button'),
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save();
                      }
                    },
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
          ),
        );

        // Act & Assert
        await tester.pumpWidget(widget);
        await tester.pumpAndSettle();

        // Test empty form validation
        await tester.tap(find.byKey(const Key('submit_button')));
        await tester.pumpAndSettle();

        expect(find.text('Please enter substance name'), findsOneWidget);
        expect(find.text('Please enter dosage'), findsOneWidget);

        // Test invalid dosage
        await tester.enterText(find.byKey(const Key('substance_name_field')), 'Caffeine');
        await tester.enterText(find.byKey(const Key('dosage_field')), '-10');
        await tester.tap(find.byKey(const Key('submit_button')));
        await tester.pumpAndSettle();

        expect(find.text('Please enter valid dosage'), findsOneWidget);

        // Test valid form
        await tester.enterText(find.byKey(const Key('dosage_field')), '200');
        await tester.tap(find.byKey(const Key('submit_button')));
        await tester.pumpAndSettle();

        expect(find.text('Please enter substance name'), findsNothing);
        expect(find.text('Please enter dosage'), findsNothing);
        expect(find.text('Please enter valid dosage'), findsNothing);
        
        WidgetTestHelper.expectNoOverflow(tester);
      });
    });

    group('Responsive Design Tests', () {
      testWidgets('should adapt to different screen sizes', (WidgetTester tester) async {
        // Arrange
        final testSubstances = TestDataPresets.createTypicalSubstanceLibrary();
        for (final substance in testSubstances) {
          mockSubstanceService.addMockSubstance(substance);
        }

        final widget = MaterialApp(
          home: Scaffold(
            body: FutureBuilder(
              future: mockSubstanceService.getAllSubstances(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                
                final substances = snapshot.data as List;
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
                    
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: 1.5,
                      ),
                      itemCount: substances.length,
                      itemBuilder: (context, index) {
                        final substance = substances[index];
                        return Card(
                          child: Center(
                            child: Text(
                              substance.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        );

        // Test different screen sizes
        final screenSizes = [
          const Size(400, 800),  // Phone
          const Size(800, 600),  // Tablet
          const Size(1200, 800), // Desktop
        ];

        for (final size in screenSizes) {
          await tester.binding.setSurfaceSize(size);
          await tester.pumpWidget(widget);
          await tester.pumpAndSettle();

          // Should not overflow regardless of screen size
          WidgetTestHelper.expectNoOverflow(tester);
          
          // Should show appropriate number of columns
          expect(find.byType(Card), findsNWidgets(4));
        }

        // Reset surface size
        await tester.binding.setSurfaceSize(null);
      });
    });

    group('Accessibility Tests', () {
      testWidgets('should provide proper semantics', (WidgetTester tester) async {
        // Arrange
        final widget = MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Entries'),
            ),
            body: Column(
              children: [
                Semantics(
                  label: 'Entry count',
                  child: const Text('3 entries'),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      Semantics(
                        label: 'Entry for Caffeine, 200 milligrams',
                        button: true,
                        child: ListTile(
                          title: const Text('Caffeine'),
                          subtitle: const Text('200 mg'),
                          onTap: () {},
                        ),
                      ),
                      Semantics(
                        label: 'Entry for Melatonin, 3 milligrams',
                        button: true,
                        child: ListTile(
                          title: const Text('Melatonin'),
                          subtitle: const Text('3 mg'),
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            floatingActionButton: Semantics(
              label: 'Add new entry',
              button: true,
              child: FloatingActionButton(
                onPressed: () {},
                child: const Icon(Icons.add),
              ),
            ),
          ),
        );

        // Act
        await tester.pumpWidget(widget);
        await tester.pumpAndSettle();

        // Assert - Check semantic elements exist
        expect(find.bySemanticsLabel('Entry count'), findsOneWidget);
        expect(find.bySemanticsLabel('Entry for Caffeine, 200 milligrams'), findsOneWidget);
        expect(find.bySemanticsLabel('Entry for Melatonin, 3 milligrams'), findsOneWidget);
        expect(find.bySemanticsLabel('Add new entry'), findsOneWidget);
        
        WidgetTestHelper.expectNoOverflow(tester);
      });
    });
  });
}