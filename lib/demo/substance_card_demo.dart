import 'package:flutter/material.dart';
import 'package:konsum_tracker_pro/models/dosage_calculator_substance.dart';
import 'package:konsum_tracker_pro/widgets/dosage_calculator/substance_quick_card.dart';

void main() {
  runApp(const SubstanceCardDemo());
}

class SubstanceCardDemo extends StatelessWidget {
  const SubstanceCardDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Substance Card Demo',
      theme: ThemeData.dark(),
      home: const SubstanceCardDemoScreen(),
    );
  }
}

class SubstanceCardDemoScreen extends StatelessWidget {
  const SubstanceCardDemoScreen({super.key});

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
        safetyNotes: 'Max. 1x/Monat, neurotoxisch bei Überdosierung.',
      ),
      DosageCalculatorSubstance(
        name: 'LSD',
        lightDosePerKg: 0.7,
        normalDosePerKg: 1.4,
        strongDosePerKg: 2.1,
        administrationRoute: 'oral',
        duration: '8–12 Stunden',
        safetyNotes: 'Nicht gewichtsbasiert, starke Psycheffekte.',
      ),
      DosageCalculatorSubstance(
        name: 'Ketamin',
        lightDosePerKg: 0.3,
        normalDosePerKg: 0.6,
        strongDosePerKg: 1.0,
        administrationRoute: 'nasal',
        duration: '45–90 Minuten',
        safetyNotes: 'Dissoziativ, Ohnmacht bei Überdosierung.',
      ),
      DosageCalculatorSubstance(
        name: 'Kokain',
        lightDosePerKg: 0.4,
        normalDosePerKg: 0.8,
        strongDosePerKg: 1.4,
        administrationRoute: 'nasal',
        duration: '30–60 Minuten',
        safetyNotes: 'Hoher Blutdruck, Herzinfarktrisiko.',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Substance Cards Demo'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Häufig verwendete Substanzen',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Fixed overflow issues with responsive design',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: substances.map((substance) {
                return SizedBox(
                  width: (MediaQuery.of(context).size.width - 48) / 2,
                  child: SubstanceQuickCard(
                    substance: substance,
                    userWeight: 70.0, // Example user weight
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Berechnung für ${substance.name}'),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            const Text(
              'Compact Cards',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: substances.map((substance) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SubstanceQuickCard(
                    substance: substance,
                    isCompact: true,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Berechnung für ${substance.name}'),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}