import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:konsum_tracker_pro/widgets/dosage_card.dart';

void main() {
  group('DosageCard Widget Tests', () {
    testWidgets('should render DosageCard with provided parameters', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DosageCard(
              title: 'MDMA',
              doseText: '85.0 mg',
              durationText: '4–6 Stunden',
              icon: Icons.favorite,
              gradientColors: const [
                Color(0xFFFF10F0),
                Color(0xFFE91E63),
              ],
              isOral: true,
            ),
          ),
        ),
      );

      // Verify that the title is displayed
      expect(find.text('MDMA'), findsOneWidget);
      
      // Verify that the dose text is displayed
      expect(find.text('85.0 mg'), findsOneWidget);
      
      // Verify that the duration text is displayed
      expect(find.text('4–6 Stunden'), findsOneWidget);
      
      // Verify that the administration route is displayed
      expect(find.text('Oral'), findsOneWidget);
      
      // Verify that the icon is displayed
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('should show "Nasal" for nasal administration', (WidgetTester tester) async {
      // Build the widget with nasal administration
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DosageCard(
              title: 'Ketamin',
              doseText: '50.0 mg',
              durationText: '45–90 Min',
              icon: Icons.cloud,
              gradientColors: const [
                Color(0xFF0080FF),
                Color(0xFF0056B3),
              ],
              isOral: false,
            ),
          ),
        ),
      );

      // Verify that nasal administration is displayed
      expect(find.text('Nasal'), findsOneWidget);
    });

    testWidgets('should handle tap gestures', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DosageCard(
              title: 'LSD',
              doseText: '150 µg',
              durationText: '8–12 Stunden',
              icon: Icons.psychology,
              gradientColors: const [
                Color(0xFF9D4EDD),
                Color(0xFF6A4C93),
              ],
              isOral: true,
            ),
          ),
        ),
      );

      // Find the GestureDetector widget
      final gestureDetector = find.byType(GestureDetector);
      expect(gestureDetector, findsOneWidget);
      
      // Tap the card
      await tester.tap(gestureDetector);
      await tester.pump();
      
      // Verify that the widget still exists after tap
      expect(find.text('LSD'), findsOneWidget);
    });
  });
}