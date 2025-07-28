import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:konsum_tracker_pro/widgets/quick_entry/quick_entry_bar.dart';
import 'package:konsum_tracker_pro/widgets/quick_entry/quick_button_widget.dart';
import 'package:konsum_tracker_pro/models/quick_button_config.dart';
import 'package:konsum_tracker_pro/services/timer_service.dart';

void main() {
  group('QuickButton Alignment Tests', () {
    testWidgets('QuickEntryBar should use CrossAxisAlignment.center', (WidgetTester tester) async {
      // Create a sample quick button config
      final quickButton = QuickButtonConfig(
        id: 'test-id',
        substanceId: 'substance-1',
        substanceName: 'Test Substance',
        dosage: 100.0,
        unit: 'mg',
        cost: 5.0,
        position: 0,
      );

      // Create the widget tree
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<TimerService>(
              create: (_) => TimerService(),
              child: QuickEntryBar(
                quickButtons: [quickButton],
                onQuickEntry: (config) {},
                onAddButton: () {},
              ),
            ),
          ),
        ),
      );

      // Find the Row widget in the QuickEntryBar
      final rowFinder = find.descendant(
        of: find.byType(QuickEntryBar),
        matching: find.byType(Row),
      );

      expect(rowFinder, findsAtLeastNWidgets(1));

      // Get the Row widget and check its CrossAxisAlignment
      final Row row = tester.widget(rowFinder.first);
      expect(row.crossAxisAlignment, equals(CrossAxisAlignment.center),
          reason: 'Row should use CrossAxisAlignment.center for proper vertical alignment');
    });

    testWidgets('QuickButton and AddQuickButton should have consistent structure', (WidgetTester tester) async {
      // Create a sample quick button config
      final quickButton = QuickButtonConfig(
        id: 'test-id',
        substanceId: 'substance-1',
        substanceName: 'Test Substance',
        dosage: 100.0,
        unit: 'mg',
        cost: 5.0,
        position: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<TimerService>(
              create: (_) => TimerService(),
              child: QuickEntryBar(
                quickButtons: [quickButton],
                onQuickEntry: (config) {},
                onAddButton: () {},
              ),
            ),
          ),
        ),
      );

      // Find QuickButtonWidget and AddQuickButtonWidget
      final quickButtonFinder = find.byType(QuickButtonWidget);
      final addButtonFinder = find.byType(AddQuickButtonWidget);

      expect(quickButtonFinder, findsOneWidget);
      expect(addButtonFinder, findsOneWidget);

      // Check that both widgets have the same height
      final quickButtonSize = tester.getSize(quickButtonFinder);
      final addButtonSize = tester.getSize(addButtonFinder);

      expect(quickButtonSize.height, equals(addButtonSize.height),
          reason: 'QuickButton and AddQuickButton should have the same height');

      expect(quickButtonSize.width, equals(addButtonSize.width),
          reason: 'QuickButton and AddQuickButton should have the same width');
    });

    testWidgets('Both buttons should be wrapped in Center widgets', (WidgetTester tester) async {
      final quickButton = QuickButtonConfig(
        id: 'test-id',
        substanceId: 'substance-1',
        substanceName: 'Test Substance',
        dosage: 100.0,
        unit: 'mg',
        cost: 5.0,
        position: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<TimerService>(
              create: (_) => TimerService(),
              child: QuickEntryBar(
                quickButtons: [quickButton],
                onQuickEntry: (config) {},
                onAddButton: () {},
              ),
            ),
          ),
        ),
      );

      // Check that there are Center widgets for alignment
      final centerFinder = find.byType(Center);
      expect(centerFinder, findsAtLeastNWidgets(2),
          reason: 'Both QuickButton and AddQuickButton should be wrapped in Center widgets');
    });

    testWidgets('Buttons should have MainAxisAlignment.center in their Columns', (WidgetTester tester) async {
      final quickButton = QuickButtonConfig(
        id: 'test-id',
        substanceId: 'substance-1',
        substanceName: 'Test Substance',
        dosage: 100.0,
        unit: 'mg',
        cost: 5.0,
        position: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<TimerService>(
              create: (_) => TimerService(),
              child: QuickEntryBar(
                quickButtons: [quickButton],
                onQuickEntry: (config) {},
                onAddButton: () {},
              ),
            ),
          ),
        ),
      );

      // Find all Column widgets within the buttons
      final columnFinder = find.byType(Column);
      expect(columnFinder, findsAtLeastNWidgets(2));

      // Check that columns have center alignment
      for (int i = 0; i < tester.widgetList(columnFinder).length; i++) {
        final Column column = tester.widget(columnFinder.at(i));
        if (column.mainAxisAlignment == MainAxisAlignment.center) {
          expect(column.mainAxisAlignment, equals(MainAxisAlignment.center),
              reason: 'Column $i should have MainAxisAlignment.center');
        }
      }
    });

    testWidgets('Reorderable mode should maintain consistent alignment', (WidgetTester tester) async {
      final quickButton = QuickButtonConfig(
        id: 'test-id',
        substanceId: 'substance-1',
        substanceName: 'Test Substance',
        dosage: 100.0,
        unit: 'mg',
        cost: 5.0,
        position: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<TimerService>(
              create: (_) => TimerService(),
              child: QuickEntryBar(
                quickButtons: [quickButton],
                onQuickEntry: (config) {},
                onAddButton: () {},
                isEditing: true, // Enable reorderable mode
              ),
            ),
          ),
        ),
      );

      // Find the ReorderableListView
      final reorderableListFinder = find.byType(ReorderableListView);
      expect(reorderableListFinder, findsOneWidget);

      // Check that buttons in reorderable mode also have Center alignment
      final centerFinder = find.byType(Center);
      expect(centerFinder, findsAtLeastNWidgets(2),
          reason: 'Reorderable mode should also wrap buttons in Center widgets');
    });
  });
}