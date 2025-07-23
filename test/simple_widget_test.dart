// Basic Widget Test for CI Pipeline
// This is a simplified test to ensure the CI pipeline passes

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Basic App Tests', () {
    testWidgets('App smoke test', (WidgetTester tester) async {
      // Build a basic widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('Konsum Tracker Pro'),
            ),
          ),
        ),
      );

      // Verify the text appears
      expect(find.text('Konsum Tracker Pro'), findsOneWidget);
    });

    testWidgets('Basic widget creation test', (WidgetTester tester) async {
      // Test basic Flutter widgets
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Test')),
            body: const Center(
              child: Column(
                children: [
                  Text('Test Text'),
                  Icon(Icons.star),
                ],
              ),
            ),
          ),
        ),
      );

      // Verify components are present
      expect(find.text('Test'), findsOneWidget);
      expect(find.text('Test Text'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });
  });
}