import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'lib/screens/main_navigation.dart';
import 'lib/services/psychedelic_theme_service.dart';

void main() {
  group('Navigation Overflow Tests', () {
    testWidgets('Navigation switching does not cause overflow', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => PsychedelicThemeService(),
            child: const MainNavigation(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Test clicking through each navigation item
      final navigationTabs = find.byType(GestureDetector);
      expect(navigationTabs, findsWidgets);

      // Start with narrow screen to trigger potential overflow
      await tester.binding.setSurfaceSize(const Size(320, 600));
      await tester.pumpAndSettle();

      // No overflow initially
      expect(tester.takeException(), isNull);

      // Test switching to each tab
      for (int i = 0; i < 4; i++) {
        await tester.tap(navigationTabs.at(i));
        await tester.pumpAndSettle();
        
        // Should not cause overflow when switching
        expect(tester.takeException(), isNull, 
               reason: 'Overflow occurred when switching to tab $i');
      }
    });

    testWidgets('Very narrow screen navigation', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => PsychedelicThemeService(),
            child: const MainNavigation(),
          ),
        ),
      );

      // Test with extremely narrow screen
      await tester.binding.setSurfaceSize(const Size(280, 600));
      await tester.pumpAndSettle();

      // Should handle extreme narrow layout
      expect(tester.takeException(), isNull);

      // Test switching on narrow screen
      final navigationTabs = find.byType(GestureDetector);
      if (navigationTabs.found) {
        await tester.tap(navigationTabs.first);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('Navigation with large text scaling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => PsychedelicThemeService(),
            child: MediaQuery(
              data: const MediaQueryData(
                textScaler: TextScaler.linear(2.0),
              ),
              child: const MainNavigation(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should handle large text without overflow
      expect(tester.takeException(), isNull);

      // Find navigation labels with large text
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Dosisrechner'), findsOneWidget);
      expect(find.text('Statistiken'), findsOneWidget);
      expect(find.text('Menü'), findsOneWidget);
    });

    testWidgets('Rapid navigation switching', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => PsychedelicThemeService(),
            child: const MainNavigation(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final navigationTabs = find.byType(GestureDetector);
      
      // Rapidly switch between tabs
      for (int cycle = 0; cycle < 3; cycle++) {
        for (int i = 0; i < 4; i++) {
          await tester.tap(navigationTabs.at(i));
          await tester.pump(const Duration(milliseconds: 50));
          expect(tester.takeException(), isNull);
        }
      }
      
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}