import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:konsum_tracker_pro/widgets/dosage_calculator/enhanced_substance_card.dart';
import 'package:konsum_tracker_pro/models/dosage_calculator_substance.dart';

void main() {
  group('Enhanced Substance Card Tests', () {
    final testSubstance = DosageCalculatorSubstance(
      name: 'MDMA',
      lightDosePerKg: 1.0,
      normalDosePerKg: 1.5,
      strongDosePerKg: 2.5,
      administrationRoute: 'oral',
      duration: '4–6 Stunden',
      safetyNotes: 'Test safety notes',
    );

    testWidgets('Enhanced substance card displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedSubstanceCard(
              substance: testSubstance,
              userWeight: 70.0,
              onTap: () {},
            ),
          ),
        ),
      );

      // Check if substance name is displayed
      expect(find.text('MDMA'), findsOneWidget);
      
      // Check if administration route is displayed
      expect(find.text('Oral (Mund)'), findsOneWidget);
      
      // Check if duration is displayed
      expect(find.text('4–6 Stunden'), findsOneWidget);
      
      // Check if calculate button is displayed
      expect(find.text('Berechnen'), findsOneWidget);
      
      // Check if recommended dose is calculated and displayed
      expect(find.text('105.0 mg'), findsOneWidget); // 70kg * 1.5
      
      // Check if optional dose (80%) is calculated and displayed
      expect(find.text('84.0 mg'), findsOneWidget); // 105.0 * 0.8
    });

    testWidgets('Responsive grid layout works', (WidgetTester tester) async {
      final substances = [testSubstance, testSubstance, testSubstance, testSubstance];
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveSubstanceGrid(
              substances: substances,
              userWeight: 70.0,
              onCardTap: (substance) {},
            ),
          ),
        ),
      );

      // Check if multiple cards are displayed
      expect(find.text('MDMA'), findsNWidgets(4));
      expect(find.text('Berechnen'), findsNWidgets(4));
    });

    testWidgets('Card tap animation works', (WidgetTester tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedSubstanceCard(
              substance: testSubstance,
              userWeight: 70.0,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      // Tap the card
      await tester.tap(find.text('Berechnen'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('Optional dose calculation is correct', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedSubstanceCard(
              substance: testSubstance,
              userWeight: 80.0, // Different weight
              onTap: () {},
            ),
          ),
        ),
      );

      // Check if recommended dose is correct for 80kg user
      expect(find.text('120.0 mg'), findsOneWidget); // 80kg * 1.5
      
      // Check if optional dose (80%) is correct
      expect(find.text('96.0 mg'), findsOneWidget); // 120.0 * 0.8
    });
  });
}