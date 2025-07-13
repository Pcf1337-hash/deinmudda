import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:konsum_tracker_pro/models/dosage_calculator_substance.dart';
import 'package:konsum_tracker_pro/widgets/dosage_calculator/substance_quick_card.dart';

void main() {
  group('SubstanceQuickCard', () {
    late DosageCalculatorSubstance testSubstance;

    setUp(() {
      testSubstance = DosageCalculatorSubstance(
        name: 'MDMA',
        lightDosePerKg: 1.0,
        normalDosePerKg: 1.5,
        strongDosePerKg: 2.0,
        administrationRoute: 'oral',
        duration: '4-6 hours',
        safetyNotes: 'Test safety notes',
      );
    });

    testWidgets('renders substance card without overflow', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              child: SubstanceQuickCard(
                substance: testSubstance,
                userWeight: 70.0,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('MDMA'), findsOneWidget);
      expect(find.text('Berechnen'), findsOneWidget);
      
      // Verify no overflow errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders compact card', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 100,
              child: SubstanceQuickCard(
                substance: testSubstance,
                isCompact: true,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('MDMA'), findsOneWidget);
      
      // Verify no overflow errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('displays dosage information when user weight provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              child: SubstanceQuickCard(
                substance: testSubstance,
                userWeight: 70.0,
                showDosagePreview: true,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Empfohlene Dosis'), findsOneWidget);
      
      // Verify no overflow errors
      expect(tester.takeException(), isNull);
    });
  });
}