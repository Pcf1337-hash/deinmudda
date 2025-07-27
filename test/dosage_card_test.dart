import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import '../lib/widgets/dosage_card.dart';

void main() {
  group('DosageCard Widget Tests', () {
    testWidgets('DosageCard displays all required elements', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DosageCard(
              title: 'Test Substance',
              doseText: '100.0 mg',
              durationText: '2–4 Stunden',
              icon: Icons.science,
              gradientColors: [Colors.blue, Colors.blueAccent],
              isOral: true,
            ),
          ),
        ),
      );

      // Verify that the widget displays the title
      expect(find.text('Test Substance'), findsOneWidget);
      
      // Verify that the widget displays the dose
      expect(find.text('100.0 mg'), findsOneWidget);
      
      // Verify that the widget displays the duration
      expect(find.text('2–4 Stunden'), findsOneWidget);
      
      // Verify that the icon is displayed
      expect(find.byIcon(Icons.science), findsOneWidget);
      
      // Verify that the oral badge is displayed
      expect(find.text('Oral'), findsOneWidget);
    });

    testWidgets('DosageCard.mdma factory creates correct widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DosageCard.mdma(
              doseText: '125.0 mg',
              durationText: '4–6 Stunden',
            ),
          ),
        ),
      );

      // Verify MDMA-specific elements
      expect(find.text('MDMA'), findsOneWidget);
      expect(find.text('125.0 mg'), findsOneWidget);
      expect(find.text('4–6 Stunden'), findsOneWidget);
      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
      expect(find.text('Oral'), findsOneWidget);
    });

    testWidgets('DosageCard.ketamine factory creates correct widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DosageCard.ketamine(
              doseText: '75.0 mg',
              durationText: '1–2 Stunden',
            ),
          ),
        ),
      );

      // Verify Ketamine-specific elements
      expect(find.text('Ketamin'), findsOneWidget);
      expect(find.text('75.0 mg'), findsOneWidget);
      expect(find.text('1–2 Stunden'), findsOneWidget);
      expect(find.byIcon(Icons.medical_services_rounded), findsOneWidget);
      expect(find.text('Nasal'), findsOneWidget);
    });

    testWidgets('DosageCard responds to tap events', (WidgetTester tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DosageCard(
              title: 'Test',
              doseText: '100 mg',
              durationText: '2h',
              gradientColors: [Colors.blue, Colors.blueAccent],
              isOral: true,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      // Tap the widget
      await tester.tap(find.byType(DosageCard));
      await tester.pump();

      // Verify tap was registered
      expect(tapped, isTrue);
    });

    testWidgets('DosageCard adapts to theme changes', (WidgetTester tester) async {
      // Test light theme
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.light),
          home: Scaffold(
            body: DosageCard.lsd(
              doseText: '100 μg',
              durationText: '8–12h',
            ),
          ),
        ),
      );

      await tester.pump();

      // Test dark theme
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.dark),
          home: Scaffold(
            body: DosageCard.lsd(
              doseText: '100 μg',
              durationText: '8–12h',
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify widget rebuilds without errors
      expect(find.text('LSD'), findsOneWidget);
      expect(find.text('100 μg'), findsOneWidget);
    });

    testWidgets('DosageCard handles animation controller lifecycle', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DosageCard.cocaine(
              doseText: '60 mg',
              durationText: '30–60 Min',
            ),
          ),
        ),
      );

      // Simulate widget disposal
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      
      // Verify no animation controller leaks (implicit test - no errors thrown)
      expect(tester.takeException(), isNull);
    });
  });

  group('DosageCard Visual Elements', () {
    testWidgets('All factory methods create distinct visual elements', (WidgetTester tester) async {
      final cards = [
        DosageCard.mdma(doseText: '125 mg', durationText: '4–6h'),
        DosageCard.lsd(doseText: '100 μg', durationText: '8–12h'),
        DosageCard.ketamine(doseText: '75 mg', durationText: '1–2h'),
        DosageCard.cocaine(doseText: '60 mg', durationText: '30–60 Min'),
      ];

      for (final card in cards) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: card),
          ),
        );

        // Verify each card renders without error
        expect(find.byType(DosageCard), findsOneWidget);
        
        await tester.pump();
      }
    });
  });
}