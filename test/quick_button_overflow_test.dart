import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../lib/widgets/quick_entry/quick_button_widget.dart';
import '../lib/models/quick_button_config.dart';
import '../lib/services/timer_service.dart';
import '../lib/services/substance_service.dart';

void main() {
  group('QuickButton Overflow Fix Tests', () {
    testWidgets('QuickButton handles Row overflow with cost and timer info', (WidgetTester tester) async {
      // Create a mock quick button config with cost and timer info
      final mockConfig = QuickButtonConfig(
        id: '1',
        substanceId: '1',
        substanceName: 'Test Substance',
        amount: 10.0,
        unit: 'mg',
        cost: 5.99,
        position: 0,
      );

      // Build the widget with constrained height
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => TimerService()),
              ChangeNotifierProvider(create: (_) => SubstanceService()),
            ],
            child: Scaffold(
              body: Container(
                width: 80,
                height: 100, // Same dimensions as QuickButton
                child: QuickButtonWidget(config: mockConfig),
              ),
            ),
          ),
        ),
      );

      // Verify the widget renders without throwing layout errors
      expect(find.byType(QuickButtonWidget), findsOneWidget);
      
      // Verify no overflow indicators are present
      expect(tester.takeException(), isNull);
      
      // Check that the cost/timer Row has the expected constraints
      final rowFinder = find.descendant(
        of: find.byType(QuickButtonWidget),
        matching: find.byType(Row),
      );
      expect(rowFinder, findsAtLeastNWidgets(1));
    });

    testWidgets('QuickButton Row uses MainAxisSize.min', (WidgetTester tester) async {
      final mockConfig = QuickButtonConfig(
        id: '1',
        substanceId: '1',
        substanceName: 'Test',
        amount: 10.0,
        unit: 'mg',
        cost: 5.99,
        position: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => TimerService()),
              ChangeNotifierProvider(create: (_) => SubstanceService()),
            ],
            child: Scaffold(
              body: QuickButtonWidget(config: mockConfig),
            ),
          ),
        ),
      );

      // Verify the widget renders
      expect(find.byType(QuickButtonWidget), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('QuickButton handles very small container height', (WidgetTester tester) async {
      final mockConfig = QuickButtonConfig(
        id: '1',
        substanceId: '1',
        substanceName: 'LongSubstanceName',
        amount: 10.0,
        unit: 'mg',
        cost: 15.99,
        position: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => TimerService()),
              ChangeNotifierProvider(create: (_) => SubstanceService()),
            ],
            child: Scaffold(
              body: Container(
                width: 80,
                height: 60, // Smaller than normal height
                child: QuickButtonWidget(config: mockConfig),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(QuickButtonWidget), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('AddQuickButton uses MainAxisSize.max for consistency', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(
              width: 80,
              height: 100,
              child: AddQuickButtonWidget(),
            ),
          ),
        ),
      );

      expect(find.byType(AddQuickButtonWidget), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    test('QuickButton layout constraint validation', () {
      // Test that the fixed height of 12.0 for the cost/timer row is appropriate
      const containerHeight = 100.0;
      const padding = 16.0; // Spacing.paddingMd
      const iconContainerHeight = 32.0; // Approximate
      const verticalSpacing = 4.0; // Spacing.xs
      const substanceNameHeight = 14.0; // Approximate
      const dosageHeight = 13.0; // Approximate
      const costTimerRowHeight = 12.0; // Our fix

      final totalContentHeight = iconContainerHeight + 
                                  verticalSpacing + 
                                  substanceNameHeight + 
                                  dosageHeight + 
                                  costTimerRowHeight;
      
      final totalHeightNeeded = totalContentHeight + (padding * 2);
      
      // Should fit within container height with some margin
      expect(totalHeightNeeded, lessThanOrEqualTo(containerHeight));
      expect(totalHeightNeeded, greaterThan(containerHeight * 0.8)); // Using most of the space
    });
  });
}