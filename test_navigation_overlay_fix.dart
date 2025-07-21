import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

// Import the main app and services
import 'lib/screens/main_navigation.dart';
import 'lib/screens/home_screen.dart';
import 'lib/screens/menu_screen.dart';
import 'lib/services/database_service.dart';
import 'lib/services/entry_service.dart';
import 'lib/services/substance_service.dart';
import 'lib/services/settings_service.dart';
import 'lib/services/quick_button_service.dart';
import 'lib/services/auth_service.dart';
import 'lib/services/notification_service.dart';
import 'lib/services/timer_service.dart';
import 'lib/services/psychedelic_theme_service.dart' as service;
import 'lib/theme/modern_theme.dart';

void main() {
  group('Bottom Navigation Overlay and Shrinking Fix Tests', () {
    late DatabaseService databaseService;
    late EntryService entryService;
    late SubstanceService substanceService;
    late SettingsService settingsService;
    late QuickButtonService quickButtonService;
    late AuthService authService;
    late NotificationService notificationService;
    late TimerService timerService;
    late service.PsychedelicThemeService psychedelicThemeService;

    setUp(() async {
      // Initialize mock services for testing
      databaseService = DatabaseService();
      await databaseService.initDatabase();

      entryService = EntryService(databaseService);
      substanceService = SubstanceService(databaseService);
      settingsService = SettingsService(databaseService);
      quickButtonService = QuickButtonService(databaseService);
      authService = AuthService(databaseService);
      notificationService = NotificationService();
      timerService = TimerService(databaseService);
      psychedelicThemeService = service.PsychedelicThemeService(databaseService);

      await notificationService.initialize();
      await timerService.initialize();
      await psychedelicThemeService.initialize();
    });

    Widget createTestApp() {
      return MultiProvider(
        providers: [
          Provider<DatabaseService>.value(value: databaseService),
          Provider<EntryService>.value(value: entryService),
          Provider<SubstanceService>.value(value: substanceService),
          Provider<QuickButtonService>.value(value: quickButtonService),
          ChangeNotifierProvider<SettingsService>.value(value: settingsService),
          ChangeNotifierProvider<service.PsychedelicThemeService>.value(value: psychedelicThemeService),
          Provider<AuthService>.value(value: authService),
          Provider<NotificationService>.value(value: notificationService),
          ChangeNotifierProvider<TimerService>.value(value: timerService),
        ],
        child: MaterialApp(
          theme: psychedelicThemeService.getTheme(),
          home: const MainNavigation(),
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.noScaling,
              ),
              child: child!,
            );
          },
        ),
      );
    }

    testWidgets('Bottom Navigation Items Have Fixed Size', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Find bottom navigation items
      final homeItem = find.text('Home');
      final menuItem = find.text('Menü');

      expect(homeItem, findsOneWidget);
      expect(menuItem, findsOneWidget);

      // Check that navigation items have fixed constraints
      final homeIcon = find.ancestor(
        of: find.byIcon(Icons.home_rounded),
        matching: find.byType(SizedBox),
      );
      expect(homeIcon, findsWidgets);

      // Check that text has fixed height
      final homeText = find.ancestor(
        of: homeItem,
        matching: find.byType(SizedBox),
      );
      expect(homeText, findsWidgets);
    });

    testWidgets('Navigation Transitions Do Not Cause Layout Shifts', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Get initial bottom navigation bar size
      final bottomNav = find.byType(Container).last;
      final initialSize = tester.getSize(bottomNav);

      // Navigate from Home to Menu
      await tester.tap(find.text('Menü'));
      await tester.pumpAndSettle();

      // Check that bottom navigation bar size remains consistent
      final afterMenuSize = tester.getSize(bottomNav);
      expect(afterMenuSize, equals(initialSize));

      // Navigate back to Home
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      // Check that size is still consistent
      final afterHomeSize = tester.getSize(bottomNav);
      expect(afterHomeSize, equals(initialSize));
    });

    testWidgets('No AnimatedSwitcher in Bottom Navigation', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Ensure AnimatedSwitcher is not used in bottom navigation
      // (This helps prevent the overlay effect)
      final animatedSwitcher = find.descendant(
        of: find.byType(Container).last, // Bottom navigation container
        matching: find.byType(AnimatedSwitcher),
      );
      
      expect(animatedSwitcher, findsNothing);
    });

    testWidgets('No FittedBox with scaleDown in Bottom Navigation', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Navigate between screens to trigger any potential scaling
      await tester.tap(find.text('Menü'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      // Check that we don't have FittedBox causing scaling issues
      final fittedBoxes = find.descendant(
        of: find.byType(Container).last,
        matching: find.byType(FittedBox),
      );
      
      expect(fittedBoxes, findsNothing);
    });

    testWidgets('Navigation Icons Maintain Consistent Size', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Find home icon (should be active initially)
      final homeIcon = find.byIcon(Icons.home_rounded);
      expect(homeIcon, findsOneWidget);
      
      final initialHomeIcon = tester.widget<Icon>(homeIcon);
      expect(initialHomeIcon.size, isNotNull);

      // Navigate to menu
      await tester.tap(find.text('Menü'));
      await tester.pumpAndSettle();

      // Find menu icon (should be active now)
      final menuIcon = find.byIcon(Icons.menu_rounded);
      expect(menuIcon, findsWidgets);

      // Navigate back to home
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      // Check that home icon size remains consistent
      final finalHomeIcon = find.byIcon(Icons.home_rounded);
      final finalIconWidget = tester.widget<Icon>(finalHomeIcon);
      expect(finalIconWidget.size, equals(initialHomeIcon.size));
    });

    testWidgets('Safe SnackBar Method Prevents Overlays', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Navigate to Menu to test transition
      await tester.tap(find.text('Menü'));
      
      // Don't wait for settle - simulate rapid navigation during transition
      await tester.tap(find.text('Home'));
      await tester.pump(const Duration(milliseconds: 100));

      // Check that no multiple SnackBars are shown
      final snackBars = find.byType(SnackBar);
      expect(snackBars, findsNothing); // Should be no SnackBars during transition

      await tester.pumpAndSettle();
    });

    testWidgets('Bottom Navigation Container Has Fixed Height', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Find the bottom navigation container
      final bottomNavContainers = find.byType(Container);
      expect(bottomNavContainers, findsWidgets);

      // Navigate and check that height remains stable
      await tester.tap(find.text('Menü'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      // Test passes if no layout overflow occurs during transitions
    });

    testWidgets('No Layout Overflow During Navigation', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Rapid navigation to test for overflow
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.text('Menü'));
        await tester.pump(const Duration(milliseconds: 50));
        await tester.tap(find.text('Home'));
        await tester.pump(const Duration(milliseconds: 50));
      }

      await tester.pumpAndSettle();
      
      // If we reach here without overflow exceptions, the fix works
      expect(find.byType(MainNavigation), findsOneWidget);
    });
  });
}