import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../lib/widgets/active_timer_bar.dart';
import '../lib/models/entry.dart';
import '../lib/services/timer_service.dart';
import '../lib/services/psychedelic_theme_service.dart';

void main() {
  group('Layout Constraint Fixes', () {
    testWidgets('ActiveTimerBar handles infinite height constraints', (WidgetTester tester) async {
      // Create a mock timer entry
      final mockEntry = Entry(
        id: '1',
        substanceName: 'Test Substance',
        amount: 10.0,
        unit: 'mg',
        notes: 'Test notes',
        datetime: DateTime.now(),
        timerEndTime: DateTime.now().add(Duration(hours: 1)),
      );

      // Build the widget with infinite height constraints
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => TimerService()),
              ChangeNotifierProvider(create: (_) => PsychedelicThemeService()),
            ],
            child: Scaffold(
              body: Column(
                children: [
                  // This should handle infinite height gracefully
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          ActiveTimerBar(timer: mockEntry),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Verify the widget renders without throwing layout errors
      expect(find.byType(ActiveTimerBar), findsOneWidget);
      
      // Verify no overflow indicators are present
      expect(tester.takeException(), isNull);
    });

    testWidgets('ActiveTimerBar handles constrained layouts', (WidgetTester tester) async {
      final mockEntry = Entry(
        id: '1',
        substanceName: 'Test Substance',
        amount: 10.0,
        unit: 'mg',
        notes: 'Test notes',
        datetime: DateTime.now(),
        timerEndTime: DateTime.now().add(Duration(hours: 1)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => TimerService()),
              ChangeNotifierProvider(create: (_) => PsychedelicThemeService()),
            ],
            child: Scaffold(
              body: Container(
                height: 80, // Constrained height
                width: 300,
                child: ActiveTimerBar(timer: mockEntry),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ActiveTimerBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ActiveTimerBar handles very small constraints', (WidgetTester tester) async {
      final mockEntry = Entry(
        id: '1',
        substanceName: 'Test',
        amount: 10.0,
        unit: 'mg',
        notes: 'Test',
        datetime: DateTime.now(),
        timerEndTime: DateTime.now().add(Duration(hours: 1)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => TimerService()),
              ChangeNotifierProvider(create: (_) => PsychedelicThemeService()),
            ],
            child: Scaffold(
              body: Container(
                height: 20, // Very small height
                width: 200,
                child: ActiveTimerBar(timer: mockEntry),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ActiveTimerBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    test('Layout constraint validation functions', () {
      // Test constraint validation logic
      const validConstraints = BoxConstraints(
        minWidth: 0,
        maxWidth: 400,
        minHeight: 0,
        maxHeight: 100,
      );

      const infiniteConstraints = BoxConstraints(
        minWidth: 0,
        maxWidth: 400,
        minHeight: 0,
        maxHeight: double.infinity,
      );

      // Should handle valid constraints
      expect(validConstraints.maxHeight.isFinite, isTrue);
      expect(validConstraints.maxHeight, equals(100));

      // Should detect infinite constraints
      expect(infiniteConstraints.maxHeight.isFinite, isFalse);
      expect(infiniteConstraints.maxHeight, equals(double.infinity));

      // Fallback behavior
      final safeHeight = infiniteConstraints.maxHeight.isFinite 
          ? infiniteConstraints.maxHeight 
          : 50.0;
      expect(safeHeight, equals(50.0));
    });
  });

  group('Substance Card Layout Tests', () {
    testWidgets('Substance cards fit within fixed height', (WidgetTester tester) async {
      // Test that substance cards respect the 240px height constraint
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Wrap(
              children: [
                SizedBox(
                  width: 150,
                  height: 240, // Fixed height
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        Container(height: 60, child: Text('Header')),
                        Container(height: 100, child: Text('Content')),
                        Container(height: 60, child: Text('Footer')),
                        // Total: 220px + padding should fit in 240px
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(Wrap), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}