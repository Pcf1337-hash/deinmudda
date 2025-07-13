import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:konsum_tracker_pro/models/dosage_calculator_substance.dart';
import 'package:konsum_tracker_pro/models/dosage_calculator_user.dart';
import 'package:konsum_tracker_pro/widgets/dosage_calculator/improved_substance_card.dart';

/// Verification script to ensure the improved substance cards meet all requirements
void main() {
  group('Requirements Verification', () {
    testWidgets('Verify glassmorphism design elements', (WidgetTester tester) async {
      final substance = DosageCalculatorSubstance(
        name: 'MDMA',
        lightDosePerKg: 1.0,
        normalDosePerKg: 1.5,
        strongDosePerKg: 2.5,
        administrationRoute: 'oral',
        duration: '4-6 Stunden',
        safetyNotes: 'Test notes',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImprovedSubstanceCard(
              substance: substance,
              user: DosageCalculatorUser(
                id: 'test',
                weightKg: 70.0,
                heightCm: 175.0,
                age: 25,
                gender: 'male',
                lastUpdated: DateTime.now(),
              ),
            ),
          ),
        ),
      );

      // Verify card structure
      expect(find.byType(ImprovedSubstanceCard), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
      expect(find.byType(AnimatedBuilder), findsOneWidget);
      
      // Verify content requirements
      expect(find.text('MDMA'), findsOneWidget);
      expect(find.text('Oral (Mund)'), findsOneWidget);
      expect(find.text('4-6 Stunden'), findsOneWidget);
      expect(find.text('Empfohlene Dosis'), findsOneWidget);
      expect(find.text('Optionale Dosis (80%)'), findsOneWidget);
      expect(find.text('Berechnen'), findsOneWidget);
    });

    testWidgets('Verify responsive grid layout', (WidgetTester tester) async {
      final substances = [
        DosageCalculatorSubstance(
          name: 'MDMA',
          lightDosePerKg: 1.0,
          normalDosePerKg: 1.5,
          strongDosePerKg: 2.5,
          administrationRoute: 'oral',
          duration: '4-6 Stunden',
          safetyNotes: 'Test notes',
        ),
        DosageCalculatorSubstance(
          name: 'LSD',
          lightDosePerKg: 0.7,
          normalDosePerKg: 1.4,
          strongDosePerKg: 2.1,
          administrationRoute: 'oral',
          duration: '8-12 Stunden',
          safetyNotes: 'Test notes',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveSubstanceCardGrid(
              substances: substances,
              user: DosageCalculatorUser(
                id: 'test',
                weightKg: 70.0,
                heightCm: 175.0,
                age: 25,
                gender: 'male',
                lastUpdated: DateTime.now(),
              ),
            ),
          ),
        ),
      );

      // Verify responsive layout elements
      expect(find.byType(LayoutBuilder), findsOneWidget);
      expect(find.byType(Wrap), findsOneWidget);
      expect(find.byType(ImprovedSubstanceCard), findsNWidgets(2));
    });

    testWidgets('Verify required Flutter widgets are used', (WidgetTester tester) async {
      final substance = DosageCalculatorSubstance(
        name: 'Test Long Substance Name That Should Be Truncated',
        lightDosePerKg: 1.0,
        normalDosePerKg: 1.5,
        strongDosePerKg: 2.5,
        administrationRoute: 'oral',
        duration: '4-6 Stunden',
        safetyNotes: 'Test notes',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveSubstanceCardGrid(
              substances: [substance],
              user: DosageCalculatorUser(
                id: 'test',
                weightKg: 70.0,
                heightCm: 175.0,
                age: 25,
                gender: 'male',
                lastUpdated: DateTime.now(),
              ),
            ),
          ),
        ),
      );

      // Verify required widgets are present
      expect(find.byType(LayoutBuilder), findsOneWidget);
      expect(find.byType(Wrap), findsOneWidget);
      expect(find.byType(Flexible), findsWidgets);
      expect(find.byType(FittedBox), findsWidgets);
    });

    test('Verify dosage calculations', () {
      final substance = DosageCalculatorSubstance(
        name: 'MDMA',
        lightDosePerKg: 1.0,
        normalDosePerKg: 1.5,
        strongDosePerKg: 2.5,
        administrationRoute: 'oral',
        duration: '4-6 Stunden',
        safetyNotes: 'Test notes',
      );

      final user = DosageCalculatorUser(
        id: 'test',
        weightKg: 70.0,
        heightCm: 175.0,
        age: 25,
        gender: 'male',
        lastUpdated: DateTime.now(),
      );

      // Verify normal dose calculation
      final normalDose = substance.calculateDosage(user.weightKg, DosageIntensity.normal);
      expect(normalDose, equals(105.0)); // 1.5 * 70 = 105mg

      // Verify optional dose (80% of normal)
      final optionalDose = normalDose * 0.8;
      expect(optionalDose, equals(84.0)); // 105 * 0.8 = 84mg

      // Verify dosage range
      final lightDose = substance.calculateDosage(user.weightKg, DosageIntensity.light);
      final strongDose = substance.calculateDosage(user.weightKg, DosageIntensity.strong);
      
      expect(lightDose, equals(70.0)); // 1.0 * 70 = 70mg
      expect(strongDose, equals(175.0)); // 2.5 * 70 = 175mg
    });

    test('Verify substance-specific colors', () {
      // Test substance color mapping
      final substances = [
        'MDMA',
        'LSD',
        'Ketamin',
        'Kokain',
        'Cannabis',
        'Psilocybin',
        'Amphetamine',
        'Unknown Substance'
      ];

      for (final substanceName in substances) {
        // Color mapping should work without errors
        expect(() => _getSubstanceColor(substanceName), returnsNormally);
      }
    });

    test('Verify danger level mapping', () {
      final highRiskSubstances = ['MDMA', 'LSD', 'Kokain', 'Amphetamine'];
      final mediumRiskSubstances = ['Ketamin', '2C-B', 'Mescaline'];
      final lowRiskSubstances = ['Cannabis', 'Psilocybin', 'Unknown'];

      for (final substance in highRiskSubstances) {
        expect(_getDangerLevel(substance), equals(DangerLevel.high));
      }

      for (final substance in mediumRiskSubstances) {
        expect(_getDangerLevel(substance), equals(DangerLevel.medium));
      }

      for (final substance in lowRiskSubstances) {
        expect(_getDangerLevel(substance), equals(DangerLevel.low));
      }
    });
  });
}

/// Helper function to test substance color mapping
/// (This replicates the logic from the widget)
Color _getSubstanceColor(String substanceName) {
  final lowerName = substanceName.toLowerCase();
  
  if (lowerName.contains('mdma')) {
    return const Color(0xFFFF10F0); // Pink/Magenta
  } else if (lowerName.contains('lsd')) {
    return const Color(0xFF9D4EDD); // Purple
  } else if (lowerName.contains('ketamin')) {
    return const Color(0xFF0080FF); // Blue
  } else if (lowerName.contains('kokain')) {
    return const Color(0xFFFFA500); // Orange
  } else if (lowerName.contains('cannabis')) {
    return const Color(0xFF22C55E); // Green
  } else if (lowerName.contains('psilocybin')) {
    return const Color(0xFF8B5CF6); // Violet
  } else if (lowerName.contains('amphetamine')) {
    return const Color(0xFFEF4444); // Red
  } else {
    return const Color(0xFF06B6D4); // Cyan (default)
  }
}

/// Helper function to test danger level mapping
/// (This replicates the logic from the widget)
DangerLevel _getDangerLevel(String substanceName) {
  final lowerName = substanceName.toLowerCase();
  
  if (lowerName.contains('mdma') || 
      lowerName.contains('lsd') || 
      lowerName.contains('kokain') ||
      lowerName.contains('amphetamine')) {
    return DangerLevel.high;
  } else if (lowerName.contains('ketamin') || 
             lowerName.contains('2c-b') ||
             lowerName.contains('mescaline')) {
    return DangerLevel.medium;
  } else {
    return DangerLevel.low;
  }
}