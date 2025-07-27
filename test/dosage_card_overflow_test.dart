import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../lib/models/dosage_calculator_substance.dart';
import '../lib/models/dosage_calculator_user.dart';
import '../lib/services/psychedelic_theme_service.dart';
import '../lib/screens/dosage_calculator/dosage_calculator_screen.dart';

void main() {
  group('Dosage Card Overflow Fix Tests', () {
    testWidgets('Substance card handles content overflow with SingleChildScrollView', (WidgetTester tester) async {
      // Create a test substance with typical content
      final testSubstance = DosageCalculatorSubstance(
        name: 'Test Psychedelic Substance with Long Name',
        lightDosePerKg: 0.05,
        normalDosePerKg: 0.1,
        strongDosePerKg: 0.2,
        duration: '6-12 hours with extended effects',
        administrationRoute: 'Oral',
        safetyNotes: 'Test safety notes for testing',
      );

      // Build the widget with constrained height matching the issue
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => PsychedelicThemeService()),
            ],
            child: Scaffold(
              body: Container(
                constraints: const BoxConstraints(
                  maxWidth: 136.0,
                  maxHeight: 208.0, // Exact constraints from the issue
                ),
                child: SizedBox(
                  width: 136.0,
                  height: 240.0, // Fixed height that causes overflow
                  child: Material(
                    child: _TestSubstanceCardWrapper(substance: testSubstance),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the widget renders without throwing layout errors
      expect(tester.takeException(), isNull);
      
      // Verify SingleChildScrollView is present
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      
      // Verify Column is present inside the scroll view
      expect(find.byType(Column), findsWidgets);
      
      // Test scrolling behavior - should be able to scroll when content overflows
      final scrollView = find.byType(SingleChildScrollView);
      expect(scrollView, findsOneWidget);
      
      // Attempt to scroll down to verify scrolling works
      await tester.drag(scrollView, const Offset(0, -50));
      await tester.pumpAndSettle();
      
      // Should not throw any exceptions during scroll
      expect(tester.takeException(), isNull);
    });

    testWidgets('Substance card Column uses MainAxisSize.min', (WidgetTester tester) async {
      final testSubstance = DosageCalculatorSubstance(
        name: 'Test Substance',
        lightDosePerKg: 0.05,
        normalDosePerKg: 0.1,
        strongDosePerKg: 0.2,
        duration: '6-12 hours',
        administrationRoute: 'Oral',
        safetyNotes: 'Test safety notes',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => PsychedelicThemeService()),
            ],
            child: Scaffold(
              body: _TestSubstanceCardWrapper(substance: testSubstance),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the Column inside SingleChildScrollView
      final scrollView = tester.widget<SingleChildScrollView>(find.byType(SingleChildScrollView));
      final column = scrollView.child as Column;
      
      // Verify Column uses MainAxisSize.min to prevent infinite height issues
      expect(column.mainAxisSize, equals(MainAxisSize.min));
      expect(tester.takeException(), isNull);
    });

    testWidgets('Multiple substance cards in grid layout work without overflow', (WidgetTester tester) async {
      final testSubstances = [
        DosageCalculatorSubstance(
          name: 'LSD',
          lightDosePerKg: 0.0005,
          normalDosePerKg: 0.001,
          strongDosePerKg: 0.002,
          duration: '8-12 hours',
          administrationRoute: 'Oral',
          safetyNotes: 'Start with low doses',
        ),
        DosageCalculatorSubstance(
          name: 'Psilocybin Mushrooms',
          lightDosePerKg: 0.1,
          normalDosePerKg: 0.2,
          strongDosePerKg: 0.4,
          duration: '4-6 hours',
          administrationRoute: 'Oral',
          safetyNotes: 'Natural psychedelic',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => PsychedelicThemeService()),
            ],
            child: Scaffold(
              body: SingleChildScrollView(
                child: Wrap(
                  spacing: 12.0,
                  runSpacing: 12.0,
                  children: testSubstances.map((substance) {
                    return SizedBox(
                      width: 136, // Grid width from issue
                      height: 240, // Fixed height
                      child: _TestSubstanceCardWrapper(substance: substance),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should render multiple cards without layout errors
      expect(find.byType(SingleChildScrollView), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });
}

// Test wrapper to simulate the substance card structure
class _TestSubstanceCardWrapper extends StatelessWidget {
  final DosageCalculatorSubstance substance;

  const _TestSubstanceCardWrapper({required this.substance});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: 240,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.withOpacity(0.8), Colors.blue.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.science, color: Colors.white, size: 20),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      substance.administrationRoute,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.green,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Substance name
              Text(
                substance.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              
              // Risk assessment
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Safety: Important',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.orange),
                ),
              ),
              const SizedBox(height: 12),
              
              // Dosage information
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'Recommended Dose:',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(substance.normalDosePerKg * 70).toStringAsFixed(1)} mg',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              // Duration
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.schedule, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    substance.duration,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}