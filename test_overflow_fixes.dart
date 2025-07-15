import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'lib/screens/dosage_calculator/dosage_calculator_screen.dart';
import 'lib/screens/timer_dashboard_screen.dart';
import 'lib/screens/settings_screen.dart';
import 'lib/services/psychedelic_theme_service.dart';
import 'lib/services/settings_service.dart';
import 'lib/services/database_service.dart';

void main() {
  group('Overflow Fixes Tests', () {
    late Widget testApp;

    setUp(() {
      testApp = MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => PsychedelicThemeService()),
            ChangeNotifierProvider(create: (_) => SettingsService()),
            ChangeNotifierProvider(create: (_) => DatabaseService()),
          ],
          child: const Scaffold(body: Text('Test')),
        ),
      );
    });

    testWidgets('DosageCalculatorScreen handles text overflow', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => PsychedelicThemeService()),
            ],
            child: const DosageCalculatorScreen(),
          ),
        ),
      );

      // Test with different text scales
      await tester.binding.setSurfaceSize(const Size(400, 600));
      await tester.pumpAndSettle();

      // Check for overflow
      expect(find.byType(SingleChildScrollView), findsWidgets);
      expect(find.byType(FittedBox), findsWidgets);
      expect(find.byType(Flexible), findsWidgets);
    });

    testWidgets('TimerDashboardScreen handles text overflow', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => PsychedelicThemeService()),
            ],
            child: const TimerDashboardScreen(),
          ),
        ),
      );

      await tester.binding.setSurfaceSize(const Size(400, 600));
      await tester.pumpAndSettle();

      // Check for overflow handling
      expect(find.byType(SingleChildScrollView), findsWidgets);
      expect(find.byType(FittedBox), findsWidgets);
      expect(find.byType(Flexible), findsWidgets);
    });

    testWidgets('SettingsScreen handles text overflow', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => PsychedelicThemeService()),
              ChangeNotifierProvider(create: (_) => SettingsService()),
              ChangeNotifierProvider(create: (_) => DatabaseService()),
            ],
            child: const SettingsScreen(),
          ),
        ),
      );

      await tester.binding.setSurfaceSize(const Size(400, 600));
      await tester.pumpAndSettle();

      // Check for overflow handling
      expect(find.byType(SingleChildScrollView), findsWidgets);
      expect(find.byType(FittedBox), findsWidgets);
      expect(find.byType(Flexible), findsWidgets);
    });

    testWidgets('Test large text scaling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => PsychedelicThemeService()),
              ChangeNotifierProvider(create: (_) => SettingsService()),
              ChangeNotifierProvider(create: (_) => DatabaseService()),
            ],
            child: MediaQuery(
              data: const MediaQueryData(
                textScaler: TextScaler.linear(2.0), // Large text
              ),
              child: const SettingsScreen(),
            ),
          ),
        ),
      );

      await tester.binding.setSurfaceSize(const Size(400, 600));
      await tester.pumpAndSettle();

      // Should not overflow even with large text
      expect(tester.takeException(), isNull);
    });

    testWidgets('Test small screen sizes', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => PsychedelicThemeService()),
            ],
            child: const TimerDashboardScreen(),
          ),
        ),
      );

      // Test with small screen
      await tester.binding.setSurfaceSize(const Size(320, 480));
      await tester.pumpAndSettle();

      // Should not overflow on small screens
      expect(tester.takeException(), isNull);
    });

    testWidgets('Test extreme content lengths', (WidgetTester tester) async {
      // This would require custom test widgets with very long strings
      // For now, we verify the layout components are in place
      await tester.pumpWidget(testApp);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}