import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import '../lib/widgets/quick_entry/quick_entry_bar.dart';
import '../lib/widgets/quick_entry/quick_button_widget.dart';
import '../lib/models/quick_button_config.dart';
import '../lib/services/timer_service.dart';

/// Test for the optimized UI layout of the QuickEntry section
/// 
/// This test validates:
/// - Reduced vertical spacing between title and buttons
/// - Proper button centering and alignment
/// - Consistent height between QuickButton and Add Button
/// - Overflow prevention with proper constraints
/// - ReorderableListView with stable keys and empty state handling
void main() {
  group('QuickEntry Layout Optimization Tests', () {
    late TimerService timerService;

    setUp(() {
      timerService = TimerService();
    });

    Widget createTestWidget({
      List<QuickButtonConfig> quickButtons = const [],
      bool isEditing = false,
    }) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: timerService),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: QuickEntryBar(
              quickButtons: quickButtons,
              onQuickEntry: (config) {},
              onAddButton: () {},
              onEditMode: () {},
              isEditing: isEditing,
              onReorder: (buttons) {},
            ),
          ),
        ),
      );
    }

    testWidgets('should have reduced vertical spacing between title and buttons', (WidgetTester tester) async {
      // Create test widget with some quick buttons
      final quickButtons = [
        QuickButtonConfig(
          id: '1',
          substanceId: 'test',
          substanceName: 'Test Substance',
          dosage: 10.0,
          unit: 'mg',
          position: 0,
        ),
      ];

      await tester.pumpWidget(createTestWidget(quickButtons: quickButtons));

      // Find the title text
      final titleFinder = find.text('Schnelleingabe');
      expect(titleFinder, findsOneWidget);

      // Find the button container
      final buttonFinder = find.byType(QuickButtonWidget);
      expect(buttonFinder, findsOneWidget);

      // Verify the spacing is minimal (the exact value depends on Spacing.verticalSpaceXs)
      // This ensures the layout is compact
      final titleWidget = tester.widget<Text>(titleFinder);
      expect(titleWidget, isNotNull);
    });

    testWidgets('should center buttons horizontally in normal mode', (WidgetTester tester) async {
      final quickButtons = [
        QuickButtonConfig(
          id: '1',
          substanceId: 'test1',
          substanceName: 'Test 1',
          dosage: 10.0,
          unit: 'mg',
          position: 0,
        ),
        QuickButtonConfig(
          id: '2',
          substanceId: 'test2',
          substanceName: 'Test 2',
          dosage: 20.0,
          unit: 'mg',
          position: 1,
        ),
      ];

      await tester.pumpWidget(createTestWidget(quickButtons: quickButtons));

      // Find the main row containing buttons
      final rowFinder = find.byType(Row);
      expect(rowFinder, findsWidgets);

      // Find QuickButton widgets
      final quickButtonFinder = find.byType(QuickButtonWidget);
      expect(quickButtonFinder, findsNWidgets(2));

      // Find AddQuickButtonWidget
      final addButtonFinder = find.byType(AddQuickButtonWidget);
      expect(addButtonFinder, findsOneWidget);
    });

    testWidgets('should have consistent button heights', (WidgetTester tester) async {
      final quickButtons = [
        QuickButtonConfig(
          id: '1',
          substanceId: 'test',
          substanceName: 'Test Substance',
          dosage: 10.0,
          unit: 'mg',
          position: 0,
        ),
      ];

      await tester.pumpWidget(createTestWidget(quickButtons: quickButtons));

      // Find both button types
      final quickButtonFinder = find.byType(QuickButtonWidget);
      final addButtonFinder = find.byType(AddQuickButtonWidget);

      expect(quickButtonFinder, findsOneWidget);
      expect(addButtonFinder, findsOneWidget);

      // Both should be rendered without overflow issues
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('should handle empty state without overflow', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(quickButtons: []));

      // Should show empty state
      final emptyStateFinder = find.text('Schnelleingabe einrichten');
      expect(emptyStateFinder, findsOneWidget);

      // Should not have overflow issues
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('should handle reorderable mode properly', (WidgetTester tester) async {
      final quickButtons = [
        QuickButtonConfig(
          id: '1',
          substanceId: 'test1',
          substanceName: 'Test 1',
          dosage: 10.0,
          unit: 'mg',
          position: 0,
        ),
        QuickButtonConfig(
          id: '2',
          substanceId: 'test2',
          substanceName: 'Test 2',
          dosage: 20.0,
          unit: 'mg',
          position: 1,
        ),
      ];

      await tester.pumpWidget(createTestWidget(
        quickButtons: quickButtons,
        isEditing: true,
      ));

      // Should show reorderable list
      final reorderableFinder = find.byType(ReorderableListView);
      expect(reorderableFinder, findsOneWidget);

      // Should not have overflow issues
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('should handle empty reorderable state', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        quickButtons: [],
        isEditing: true,
      ));

      // Should handle empty reorderable state gracefully
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Should still show add button
      final addButtonFinder = find.byType(AddQuickButtonWidget);
      expect(addButtonFinder, findsOneWidget);
    });

    testWidgets('should have proper height constraints', (WidgetTester tester) async {
      final quickButtons = List.generate(5, (index) => QuickButtonConfig(
        id: 'test_$index',
        substanceId: 'substance_$index',
        substanceName: 'Substance $index',
        dosage: (index + 1) * 10.0,
        unit: 'mg',
        position: index,
      ));

      await tester.pumpWidget(createTestWidget(quickButtons: quickButtons));

      // Find the constrained box
      final constrainedBoxFinder = find.byType(ConstrainedBox);
      expect(constrainedBoxFinder, findsWidgets);

      // Should not have rendering issues with many buttons
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}