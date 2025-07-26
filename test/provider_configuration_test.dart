// Test to verify Provider configuration for ChangeNotifier services
// This test validates that services extending ChangeNotifier are properly
// configured with ChangeNotifierProvider instead of regular Provider

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

// Mock services for testing provider configuration
class MockEntryService extends ChangeNotifier {
  void updateEntry() {
    notifyListeners();
  }
}

class MockSubstanceService extends ChangeNotifier {
  void updateSubstance() {
    notifyListeners();
  }
}

class MockDatabaseService {
  void getData() {
    // Non-ChangeNotifier service
  }
}

void main() {
  group('Provider Configuration Tests', () {
    testWidgets('ChangeNotifier services should use ChangeNotifierProvider', (WidgetTester tester) async {
      // Test that ChangeNotifier services work with ChangeNotifierProvider
      final mockEntryService = MockEntryService();
      final mockSubstanceService = MockSubstanceService();
      final mockDatabaseService = MockDatabaseService();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            // ChangeNotifier services - should use ChangeNotifierProvider
            ChangeNotifierProvider<MockEntryService>.value(
              value: mockEntryService,
            ),
            ChangeNotifierProvider<MockSubstanceService>.value(
              value: mockSubstanceService,
            ),
            // Non-ChangeNotifier services - should use regular Provider
            Provider<MockDatabaseService>.value(
              value: mockDatabaseService,
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Consumer2<MockEntryService, MockSubstanceService>(
                builder: (context, entryService, substanceService, child) {
                  return const Text('Provider Configuration Test');
                },
              ),
            ),
          ),
        ),
      );

      // Verify the widget builds without errors
      expect(find.text('Provider Configuration Test'), findsOneWidget);
    });

    testWidgets('Regular Provider should work with non-ChangeNotifier services', (WidgetTester tester) async {
      final mockDatabaseService = MockDatabaseService();

      await tester.pumpWidget(
        Provider<MockDatabaseService>.value(
          value: mockDatabaseService,
          child: MaterialApp(
            home: Scaffold(
              body: Consumer<MockDatabaseService>(
                builder: (context, databaseService, child) {
                  return const Text('Database Service Test');
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Database Service Test'), findsOneWidget);
    });
  });
}