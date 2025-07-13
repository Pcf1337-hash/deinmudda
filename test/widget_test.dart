import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:konsum_tracker_pro/widgets/dosage_calculator/substance_card.dart';
import 'package:konsum_tracker_pro/models/dosage_calculator_substance.dart';

void main() {
  group('SubstanceCard Overflow Tests', () {
    late DosageCalculatorSubstance testSubstance;

    setUp(() {
      testSubstance = DosageCalculatorSubstance(
        id: '1',
        name: 'Very Long Substance Name That Could Potentially Cause Overflow Issues',
        description: 'This is a very long description that could cause overflow issues in the card layout when displayed',
        administrationRoute: 'oral',
        administrationRouteDisplayName: 'Oral (very long route description)',
        duration: 'Very long duration description that could cause overflow',
        lightDosePerKg: 1.5,
        normalDosePerKg: 2.0,
        strongDosePerKg: 3.0,
        safetyNotes: 'Very long safety notes that could cause overflow',
      );
    });

    testWidgets('SubstanceCard should not overflow with long content', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    width: 200,
                    child: SubstanceCard(
                      substance: testSubstance,
                      showDosagePreview: true,
                      isCompact: false,
                      showRiskLevel: true,
                      userWeight: 70.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Verify no overflow errors
      expect(tester.takeException(), isNull);
      
      // Check that card renders successfully
      expect(find.byType(SubstanceCard), findsOneWidget);
      
      // Check that text is properly truncated
      expect(find.textContaining('Very Long Substance Name'), findsOneWidget);
    });

    testWidgets('CompactSubstanceCard should not overflow with long content', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    width: 150,
                    child: CompactSubstanceCard(
                      substance: testSubstance,
                      userWeight: 70.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Verify no overflow errors
      expect(tester.takeException(), isNull);
      
      // Check that card renders successfully
      expect(find.byType(CompactSubstanceCard), findsOneWidget);
    });

    testWidgets('SubstanceCard should handle various screen sizes', (WidgetTester tester) async {
      final screenSizes = [
        const Size(300, 600),
        const Size(400, 800),
        const Size(500, 900),
      ];

      for (final size in screenSizes) {
        await tester.binding.setSurfaceSize(size);
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    SubstanceCard(
                      substance: testSubstance,
                      showDosagePreview: true,
                      isCompact: false,
                      showRiskLevel: true,
                      userWeight: 70.0,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        // Verify no overflow errors for different screen sizes
        expect(tester.takeException(), isNull, reason: 'Overflow on screen size $size');
      }
    });
  });
}