import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import '../lib/screens/main_navigation.dart';
import '../lib/services/psychedelic_theme_service.dart';

void main() {
  group('Navigation Duplicate Key Tests', () {
    testWidgets('Navigation items should have unique keys in AnimatedSwitcher', (WidgetTester tester) async {
      // Setup the app with MainNavigation
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => PsychedelicThemeService(),
            child: const MainNavigation(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find all AnimatedSwitcher widgets in the navigation
      final animatedSwitchers = find.byType(AnimatedSwitcher);
      expect(animatedSwitchers, findsWidgets);

      // Navigate from home (index 0) to menu (index 3) to reproduce the issue
      final navigationTabs = find.byType(GestureDetector);
      expect(navigationTabs, findsWidgets);

      // Should start at home
      expect(tester.takeException(), isNull, reason: 'Initial state should not have exceptions');

      // Navigate to menu (this should NOT trigger the duplicate key issue after fix)
      await tester.tap(navigationTabs.at(3)); // Menu tab
      await tester.pump(); // Start the animation

      // Check if there's a duplicate key exception
      final exception = tester.takeException();
      expect(exception, isNull, reason: 'Should NOT have duplicate key issues after fix');

      await tester.pumpAndSettle();
    });

    testWidgets('Rapid navigation switching should not cause duplicate key issues', (WidgetTester tester) async {
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
      
      // Rapidly switch between tabs to stress test the key uniqueness
      // Start at home (0), go to menu (3), then back to home (0)
      await tester.tap(navigationTabs.at(0)); // Home
      await tester.pump(const Duration(milliseconds: 50));
      
      await tester.tap(navigationTabs.at(3)); // Menu
      await tester.pump(const Duration(milliseconds: 50));
      
      await tester.tap(navigationTabs.at(0)); // Home
      await tester.pump(const Duration(milliseconds: 50));
      
      // Should not have any duplicate key exceptions
      expect(tester.takeException(), isNull, 
             reason: 'Rapid navigation should not cause duplicate key issues');
      
      await tester.pumpAndSettle();
    });

    testWidgets('All navigation items should maintain unique identities', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => PsychedelicThemeService(),
            child: const MainNavigation(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find all Icons within AnimatedSwitchers
      final animatedSwitchers = find.byType(AnimatedSwitcher);
      
      // Each AnimatedSwitcher should contain exactly one Icon
      for (int i = 0; i < animatedSwitchers.evaluate().length; i++) {
        final switcher = animatedSwitchers.at(i);
        final iconsInSwitcher = find.descendant(
          of: switcher,
          matching: find.byType(Icon),
        );
        
        // Should find exactly one icon per switcher
        expect(iconsInSwitcher, findsOneWidget,
               reason: 'Each AnimatedSwitcher should contain exactly one Icon');
      }

      // Navigate through all tabs and ensure no duplicate key issues
      final navigationTabs = find.byType(GestureDetector);
      for (int i = 0; i < 4; i++) {
        await tester.tap(navigationTabs.at(i));
        await tester.pump();
        expect(tester.takeException(), isNull, 
               reason: 'Navigation to tab $i should not cause duplicate key issues');
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Specific home to menu navigation bug fix', (WidgetTester tester) async {
      // This test specifically targets the bug mentioned in the issue:
      // "wenn ich von home zu menü wechsel ist irgendwie nen overflow fehler drinne"
      
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => PsychedelicThemeService(),
            child: const MainNavigation(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Start at home (should be default)
      expect(tester.takeException(), isNull, reason: 'Should start without errors');

      // Find navigation tabs
      final navigationTabs = find.byType(GestureDetector);
      expect(navigationTabs, hasLength(4), reason: 'Should have 4 navigation tabs');

      // Navigate specifically from home to menu as mentioned in the issue
      await tester.tap(navigationTabs.at(3)); // Menu tab (index 3)
      await tester.pump(); // Trigger the animation that was causing the issue
      
      // This should not cause the duplicate key exception
      expect(tester.takeException(), isNull, 
             reason: 'Home to Menu navigation should not cause duplicate key issues');

      await tester.pumpAndSettle();
      
      // Verify we can continue using the app after the problematic navigation
      await tester.tap(navigationTabs.at(0)); // Back to home
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, 
             reason: 'Should be able to navigate back without issues');
    });
  });
}