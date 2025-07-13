import 'package:flutter/material.dart';
import 'package:konsum_tracker_pro/widgets/dosage_calculator/substance_card.dart';
import 'package:konsum_tracker_pro/models/dosage_calculator_substance.dart';

void main() {
  runApp(const OverflowTestApp());
}

class OverflowTestApp extends StatelessWidget {
  const OverflowTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Overflow Test',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: const OverflowTestScreen(),
    );
  }
}

class OverflowTestScreen extends StatelessWidget {
  const OverflowTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Create test substances with varying content lengths
    final testSubstances = [
      DosageCalculatorSubstance(
        id: '1',
        name: 'Short Name',
        description: 'Short description',
        administrationRoute: 'oral',
        administrationRouteDisplayName: 'Oral',
        duration: '4-6 hours',
        lightDosePerKg: 1.5,
        normalDosePerKg: 2.0,
        strongDosePerKg: 3.0,
        safetyNotes: 'Basic safety notes',
      ),
      DosageCalculatorSubstance(
        id: '2',
        name: 'Very Long Substance Name That Could Potentially Cause Overflow Issues',
        description: 'This is a very long description that could cause overflow issues in the card layout when displayed on smaller screens',
        administrationRoute: 'oral',
        administrationRouteDisplayName: 'Oral (sublingual administration with detailed instructions)',
        duration: 'Very long duration description that could cause overflow - 6-12 hours with extended effects',
        lightDosePerKg: 1.5,
        normalDosePerKg: 2.0,
        strongDosePerKg: 3.0,
        safetyNotes: 'Very long safety notes that could cause overflow if not handled properly',
      ),
      DosageCalculatorSubstance(
        id: '3',
        name: 'Medium Length Substance Name',
        description: 'Medium length description that should fit well',
        administrationRoute: 'nasal',
        administrationRouteDisplayName: 'Nasal insufflation',
        duration: '2-4 hours',
        lightDosePerKg: 0.5,
        normalDosePerKg: 1.0,
        strongDosePerKg: 1.5,
        safetyNotes: 'Medium length safety notes for testing',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Substance Card Overflow Test'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Full Cards with User Weight (70kg)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...testSubstances.map((substance) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SubstanceCard(
                substance: substance,
                showDosagePreview: true,
                isCompact: false,
                showRiskLevel: true,
                userWeight: 70.0,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Tapped on ${substance.name}'),
                    ),
                  );
                },
              ),
            )),
            const SizedBox(height: 32),
            const Text(
              'Compact Cards',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...testSubstances.map((substance) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: CompactSubstanceCard(
                substance: substance,
                userWeight: 70.0,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Tapped on ${substance.name}'),
                    ),
                  );
                },
              ),
            )),
            const SizedBox(height: 32),
            const Text(
              'Small Width Test (200px)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...testSubstances.map((substance) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SizedBox(
                width: 200,
                child: SubstanceCard(
                  substance: substance,
                  showDosagePreview: true,
                  isCompact: false,
                  showRiskLevel: true,
                  userWeight: 70.0,
                ),
              ),
            )),
            const SizedBox(height: 32),
            const Text(
              'Very Small Width Test (150px)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...testSubstances.map((substance) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SizedBox(
                width: 150,
                child: CompactSubstanceCard(
                  substance: substance,
                  userWeight: 70.0,
                ),
              ),
            )),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}