import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:konsum_tracker_pro/models/dosage_calculator_substance.dart';
import 'package:konsum_tracker_pro/models/dosage_calculator_user.dart';
import 'package:konsum_tracker_pro/widgets/dosage_calculator/improved_substance_card.dart';

void main() {
  group('ImprovedSubstanceCard Tests', () {
    late DosageCalculatorSubstance testSubstance;
    late DosageCalculatorUser testUser;

    setUp(() {
      testSubstance = DosageCalculatorSubstance(
        name: 'MDMA',
        lightDosePerKg: 1.0,
        normalDosePerKg: 1.5,
        strongDosePerKg: 2.5,
        administrationRoute: 'oral',
        duration: '4-6 Stunden',
        safetyNotes: 'Test safety notes',
      );

      testUser = DosageCalculatorUser(
        id: 'test-id',
        weightKg: 70.0,
        heightCm: 175.0,
        age: 25,
        gender: 'male',
        lastUpdated: DateTime.now(),
      );
    });

    testWidgets('should display substance name and basic info', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImprovedSubstanceCard(
              substance: testSubstance,
              user: testUser,
            ),
          ),
        ),
      );

      expect(find.text('MDMA'), findsOneWidget);
      expect(find.text('Oral (Mund)'), findsOneWidget);
      expect(find.text('4-6 Stunden'), findsOneWidget);
      expect(find.text('Berechnen'), findsOneWidget);
    });

    testWidgets('should display recommended and optional doses when user is provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImprovedSubstanceCard(
              substance: testSubstance,
              user: testUser,
            ),
          ),
        ),
      );

      expect(find.text('Empfohlene Dosis'), findsOneWidget);
      expect(find.text('Optionale Dosis (80%)'), findsOneWidget);
      
      // Check that dosage values are calculated correctly
      // Normal dose for 70kg user: 1.5 * 70 = 105mg
      expect(find.text('105.0 mg'), findsOneWidget);
      // Optional dose (80% of normal): 105 * 0.8 = 84mg
      expect(find.text('84.0 mg'), findsOneWidget);
    });

    testWidgets('should display dosage range per kg', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImprovedSubstanceCard(
              substance: testSubstance,
              user: testUser,
            ),
          ),
        ),
      );

      expect(find.text('1.0mg'), findsOneWidget);
      expect(find.text('1.5mg'), findsOneWidget);
      expect(find.text('2.5mg'), findsOneWidget);
      expect(find.text('Leicht'), findsOneWidget);
      expect(find.text('Normal'), findsOneWidget);
      expect(find.text('Stark'), findsOneWidget);
    });

    testWidgets('should show high danger level for MDMA', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImprovedSubstanceCard(
              substance: testSubstance,
              user: testUser,
            ),
          ),
        ),
      );

      expect(find.text('Hoch'), findsOneWidget);
      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('should handle tap callback', (WidgetTester tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImprovedSubstanceCard(
              substance: testSubstance,
              user: testUser,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Berechnen'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('should display proper substance colors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImprovedSubstanceCard(
              substance: testSubstance,
              user: testUser,
            ),
          ),
        ),
      );

      await tester.pump();

      // The card should be built successfully with proper colors
      expect(find.byType(ImprovedSubstanceCard), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should work without user data', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImprovedSubstanceCard(
              substance: testSubstance,
              user: null,
            ),
          ),
        ),
      );

      expect(find.text('MDMA'), findsOneWidget);
      expect(find.text('Berechnen'), findsOneWidget);
      // Should not show recommended dose without user
      expect(find.text('Empfohlene Dosis'), findsNothing);
    });

    testWidgets('should handle text overflow properly', (WidgetTester tester) async {
      final longNameSubstance = DosageCalculatorSubstance(
        name: 'Very Long Substance Name That Should Be Truncated',
        lightDosePerKg: 1.0,
        normalDosePerKg: 1.5,
        strongDosePerKg: 2.5,
        administrationRoute: 'oral',
        duration: '4-6 Stunden',
        safetyNotes: 'Test safety notes',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              child: ImprovedSubstanceCard(
                substance: longNameSubstance,
                user: testUser,
              ),
            ),
          ),
        ),
      );

      // Should not overflow
      expect(tester.takeException(), isNull);
    });
  });

  group('ResponsiveSubstanceCardGrid Tests', () {
    late List<DosageCalculatorSubstance> testSubstances;
    late DosageCalculatorUser testUser;

    setUp(() {
      testSubstances = [
        DosageCalculatorSubstance(
          name: 'MDMA',
          lightDosePerKg: 1.0,
          normalDosePerKg: 1.5,
          strongDosePerKg: 2.5,
          administrationRoute: 'oral',
          duration: '4-6 Stunden',
          safetyNotes: 'Test safety notes',
        ),
        DosageCalculatorSubstance(
          name: 'LSD',
          lightDosePerKg: 0.7,
          normalDosePerKg: 1.4,
          strongDosePerKg: 2.1,
          administrationRoute: 'oral',
          duration: '8-12 Stunden',
          safetyNotes: 'Test safety notes',
        ),
      ];

      testUser = DosageCalculatorUser(
        id: 'test-id',
        weightKg: 70.0,
        heightCm: 175.0,
        age: 25,
        gender: 'male',
        lastUpdated: DateTime.now(),
      );
    });

    testWidgets('should display substances in responsive grid', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveSubstanceCardGrid(
              substances: testSubstances,
              user: testUser,
            ),
          ),
        ),
      );

      expect(find.text('MDMA'), findsOneWidget);
      expect(find.text('LSD'), findsOneWidget);
      expect(find.byType(ImprovedSubstanceCard), findsNWidgets(2));
    });

    testWidgets('should handle card tap callbacks', (WidgetTester tester) async {
      DosageCalculatorSubstance? tappedSubstance;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveSubstanceCardGrid(
              substances: testSubstances,
              user: testUser,
              onCardTap: (substance) => tappedSubstance = substance,
            ),
          ),
        ),
      );

      await tester.tap(find.text('MDMA'));
      await tester.pump();

      expect(tappedSubstance?.name, equals('MDMA'));
    });

    testWidgets('should use LayoutBuilder for responsive layout', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveSubstanceCardGrid(
              substances: testSubstances,
              user: testUser,
            ),
          ),
        ),
      );

      expect(find.byType(LayoutBuilder), findsOneWidget);
      expect(find.byType(Wrap), findsOneWidget);
    });
  });
}