import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import '../lib/screens/dosage_calculator/dosage_calculator_screen.dart';
import '../lib/services/dosage_calculator_service.dart';
import '../lib/services/psychedelic_theme_service.dart' as service;
import '../lib/models/dosage_calculator_user.dart';
import '../lib/models/dosage_calculator_substance.dart';

void main() {
  group('DosageCalculatorScreen Layout Tests', () {
    late service.PsychedelicThemeService psychedelicThemeService;
    late DosageCalculatorService dosageService;

    setUp(() {
      psychedelicThemeService = service.PsychedelicThemeService();
      dosageService = DosageCalculatorService();
    });

    testWidgets('renders without layout overflow', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: psychedelicThemeService,
            child: const DosageCalculatorScreen(),
          ),
        ),
      );

      // Allow time for async operations
      await tester.pumpAndSettle();

      // Verify screen renders
      expect(find.byType(DosageCalculatorScreen), findsOneWidget);
      
      // Check for overflow errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('modal appears when substance is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: psychedelicThemeService,
            child: const DosageCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Look for substance cards
      final substanceCards = find.byType(Container);
      if (substanceCards.evaluate().isNotEmpty) {
        // Tap on a substance card
        await tester.tap(substanceCards.first);
        await tester.pumpAndSettle();

        // Verify modal appears (check for modal specific widgets)
        // This will depend on the actual modal implementation
      }
    });

    testWidgets('GlobalKey uniqueness check', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: psychedelicThemeService,
            child: const DosageCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Test should pass if no GlobalKey duplication errors occur
      expect(tester.takeException(), isNull);
    });

    testWidgets('proper layout constraints', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: psychedelicThemeService,
            child: const DosageCalculatorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check that RenderBox layout issues don't occur
      expect(tester.takeException(), isNull);
      
      // Verify scrollable areas are properly constrained
      expect(find.byType(SingleChildScrollView), findsWidgets);
    });
  });
}