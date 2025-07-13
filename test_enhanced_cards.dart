import 'package:flutter/material.dart';
import 'package:konsum_tracker_pro/widgets/dosage_calculator/enhanced_substance_card.dart';
import 'package:konsum_tracker_pro/models/dosage_calculator_substance.dart';
import 'package:konsum_tracker_pro/theme/modern_theme.dart';

void main() {
  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Enhanced Substance Cards Demo',
      theme: ModernTheme.darkTheme,
      home: const TestScreen(),
    );
  }
}

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final substances = [
      DosageCalculatorSubstance(
        name: 'MDMA',
        lightDosePerKg: 1.0,
        normalDosePerKg: 1.5,
        strongDosePerKg: 2.5,
        administrationRoute: 'oral',
        duration: '4–6 Stunden',
        safetyNotes: 'Max. 1x/Monat, neurotoxisch bei Überdosierung. Ausreichend trinken, aber nicht übertreiben.',
      ),
      DosageCalculatorSubstance(
        name: 'LSD',
        lightDosePerKg: 0.7,
        normalDosePerKg: 1.4,
        strongDosePerKg: 2.1,
        administrationRoute: 'oral',
        duration: '8–12 Stunden',
        safetyNotes: 'Nicht gewichtsbasiert, starke Psycheffekte. Set & Setting beachten, Tripsitter empfohlen.',
      ),
      DosageCalculatorSubstance(
        name: 'Ketamin',
        lightDosePerKg: 0.3,
        normalDosePerKg: 0.6,
        strongDosePerKg: 1.0,
        administrationRoute: 'nasal',
        duration: '45–90 Minuten',
        safetyNotes: 'Dissoziativ, Ohnmacht bei Überdosierung. Nicht im Stehen konsumieren, K-Hole Gefahr.',
      ),
      DosageCalculatorSubstance(
        name: 'Kokain',
        lightDosePerKg: 0.4,
        normalDosePerKg: 0.8,
        strongDosePerKg: 1.4,
        administrationRoute: 'nasal',
        duration: '30–60 Minuten',
        safetyNotes: 'Hoher Blutdruck, Herzinfarktrisiko. Hohes Suchtpotential, nicht mit Alkohol kombinieren.',
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('Enhanced Substance Cards'),
        backgroundColor: const Color(0xFF1A1A1A),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dosisrechner-Karten: Glasmorphismus & Responsive Layout',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Responsive layout: 2 cards side by side on wide screens, 1 per row on mobile',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 24),
              ResponsiveSubstanceGrid(
                substances: substances,
                userWeight: 70.0,
                onCardTap: (substance) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Tapped: ${substance.name}'),
                      backgroundColor: Colors.purple,
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Features implemented:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '✅ Glasmorphismus background with BoxDecoration\n'
                '✅ Substance-specific neon glows and colored borders\n'
                '✅ Responsive layout (LayoutBuilder)\n'
                '✅ Substance name, icon, route, duration display\n'
                '✅ Recommended dose calculation\n'
                '✅ Optional dose (80% of normal) calculation\n'
                '✅ Ripple effects and tap animations\n'
                '✅ Overflow prevention with maxLines: 2, ellipsis\n'
                '✅ SafeArea and ScrollView for proper layout\n'
                '✅ Responsive text sizing with FittedBox',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}