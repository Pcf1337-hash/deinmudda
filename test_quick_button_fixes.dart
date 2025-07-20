import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'lib/widgets/quick_entry/quick_entry_bar.dart';
import 'lib/widgets/quick_entry/quick_button_widget.dart';
import 'lib/models/quick_button_config.dart';
import 'lib/services/psychedelic_theme_service.dart';

void main() {
  group('Quick Button Fixes Tests', () {
    testWidgets('QuickEntryBar Add button is always visible', (WidgetTester tester) async {
      // Create many quick buttons to test horizontal scroll
      final quickButtons = List.generate(10, (index) {
        return QuickButtonConfig.create(
          substanceId: 'test_$index',
          substanceName: 'Test Substance $index with Very Long Name',
          dosage: 100.0 + index,
          unit: 'mg',
          position: index,
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider(
              create: (_) => PsychedelicThemeService(),
              child: QuickEntryBar(
                quickButtons: quickButtons,
                onQuickEntry: (config) {},
                onAddButton: () {},
                isEditing: false,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should not have overflow errors
      expect(tester.takeException(), isNull);
      
      // Add button should be present
      expect(find.byType(AddQuickButtonWidget), findsOneWidget);
      
      // Should find Row layout (new layout structure)
      expect(find.byType(Row), findsWidgets);
      
      // Should find Expanded widget (for scrollable content)
      expect(find.byType(Expanded), findsWidgets);
    });

    testWidgets('QuickButtonWidget text handles overflow properly', (WidgetTester tester) async {
      final config = QuickButtonConfig.create(
        substanceId: 'test',
        substanceName: 'Very Long Substance Name That Should Trigger Overflow Handling',
        dosage: 999.999,
        unit: 'mg',
        position: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 100, // Constrained width to test overflow
              child: QuickButtonWidget(
                config: config,
                onTap: () {},
                isEditing: false,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should not have overflow errors
      expect(tester.takeException(), isNull);
      
      // Should find FittedBox widgets for responsive text scaling
      expect(find.byType(FittedBox), findsWidgets);
      
      // Should find Flexible widgets for proper layout
      expect(find.byType(Flexible), findsWidgets);
    });

    testWidgets('AddQuickButtonWidget text scales properly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 60, // Very narrow to test text scaling
              child: AddQuickButtonWidget(
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should not have overflow errors
      expect(tester.takeException(), isNull);
      
      // Should find the add button text
      expect(find.text('Hinzufügen'), findsOneWidget);
      
      // Should find FittedBox for text scaling
      expect(find.byType(FittedBox), findsWidgets);
    });

    testWidgets('QuickEntryBar edit mode layout works correctly', (WidgetTester tester) async {
      final quickButtons = List.generate(5, (index) {
        return QuickButtonConfig.create(
          substanceId: 'test_$index',
          substanceName: 'Test $index',
          dosage: 100.0,
          unit: 'mg',
          position: index,
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider(
              create: (_) => PsychedelicThemeService(),
              child: QuickEntryBar(
                quickButtons: quickButtons,
                onQuickEntry: (config) {},
                onAddButton: () {},
                isEditing: true, // Test edit mode
                onReorder: (buttons) {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should not have overflow errors in edit mode
      expect(tester.takeException(), isNull);
      
      // Add button should still be visible in edit mode
      expect(find.byType(AddQuickButtonWidget), findsOneWidget);
      
      // Should find ReorderableListView in edit mode
      expect(find.byType(ReorderableListView), findsOneWidget);
    });

    testWidgets('Layout handles narrow screen widths', (WidgetTester tester) async {
      final quickButtons = List.generate(3, (index) {
        return QuickButtonConfig.create(
          substanceId: 'test_$index',
          substanceName: 'Test $index',
          dosage: 100.0,
          unit: 'mg',
          position: index,
        );
      });

      // Set narrow screen size
      await tester.binding.setSurfaceSize(const Size(320, 600));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider(
              create: (_) => PsychedelicThemeService(),
              child: QuickEntryBar(
                quickButtons: quickButtons,
                onQuickEntry: (config) {},
                onAddButton: () {},
                isEditing: false,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should handle narrow screen without overflow
      expect(tester.takeException(), isNull);
      
      // All elements should still be present
      expect(find.byType(AddQuickButtonWidget), findsOneWidget);
      expect(find.byType(QuickButtonWidget), findsWidgets);
    });
  });
}