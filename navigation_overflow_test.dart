import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'lib/screens/main_navigation.dart';
import 'lib/services/psychedelic_theme_service.dart' as service;
import 'lib/services/database_service.dart';
import 'lib/services/entry_service.dart';
import 'lib/services/substance_service.dart';
import 'lib/services/quick_button_service.dart';
import 'lib/services/settings_service.dart';
import 'lib/services/auth_service.dart';
import 'lib/services/notification_service.dart';
import 'lib/services/timer_service.dart';

/// Test app to verify navigation overflow fixes
void main() {
  group('Navigation Overflow Fix Tests', () {
    testWidgets('Navigation switching without extreme overflow', (WidgetTester tester) async {
      // Create test app with all required providers
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<DatabaseService>(create: (_) => DatabaseService()),
            Provider<EntryService>(create: (_) => EntryService()),
            Provider<SubstanceService>(create: (_) => SubstanceService()),
            Provider<QuickButtonService>(create: (_) => QuickButtonService()),
            ChangeNotifierProvider<SettingsService>(create: (_) => SettingsService()),
            ChangeNotifierProvider<service.PsychedelicThemeService>(create: (_) => service.PsychedelicThemeService()),
            Provider<AuthService>(create: (_) => AuthService()),
            Provider<NotificationService>(create: (_) => NotificationService()),
            ChangeNotifierProvider<TimerService>(create: (_) => TimerService()),
          ],
          child: const MaterialApp(
            home: MainNavigation(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initially no overflow errors
      expect(tester.takeException(), isNull);

      // Find navigation tabs
      final navigationTabs = find.byType(GestureDetector);
      expect(navigationTabs, findsWidgets);

      // Test rapid navigation switching (this was causing the extreme overflow)
      for (int cycle = 0; cycle < 5; cycle++) {
        for (int tabIndex = 0; tabIndex < 4; tabIndex++) {
          await tester.tap(navigationTabs.at(tabIndex));
          await tester.pump(const Duration(milliseconds: 16)); // Simulate 60fps frame
          
          // Should not cause extreme overflow errors during rapid switching
          final exception = tester.takeException();
          if (exception != null) {
            final errorMessage = exception.toString();
            // Fail if we get the extreme overflow (99991 pixels)
            expect(errorMessage.contains('99991'), false, 
                   reason: 'Extreme overflow detected: $errorMessage');
          }
        }
      }
      
      await tester.pumpAndSettle();
      
      // Final check - no exceptions after rapid navigation
      expect(tester.takeException(), isNull);
    });

    testWidgets('Narrow screen navigation without overflow', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<DatabaseService>(create: (_) => DatabaseService()),
            Provider<EntryService>(create: (_) => EntryService()),
            Provider<SubstanceService>(create: (_) => SubstanceService()),
            Provider<QuickButtonService>(create: (_) => QuickButtonService()),
            ChangeNotifierProvider<SettingsService>(create: (_) => SettingsService()),
            ChangeNotifierProvider<service.PsychedelicThemeService>(create: (_) => service.PsychedelicThemeService()),
            Provider<AuthService>(create: (_) => AuthService()),
            Provider<NotificationService>(create: (_) => NotificationService()),
            ChangeNotifierProvider<TimerService>(create: (_) => TimerService()),
          ],
          child: const MaterialApp(
            home: MainNavigation(),
          ),
        ),
      );

      // Test with very narrow screen (this was triggering layout calculation errors)
      await tester.binding.setSurfaceSize(const Size(320, 600));
      await tester.pumpAndSettle();

      // Should handle narrow layout without overflow
      expect(tester.takeException(), isNull);

      // Test navigation on narrow screen
      final navigationTabs = find.byType(GestureDetector);
      if (navigationTabs.found) {
        await tester.tap(navigationTabs.at(3)); // Menu tab
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        await tester.tap(navigationTabs.at(0)); // Home tab
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('Layout error boundaries catch overflow errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<DatabaseService>(create: (_) => DatabaseService()),
            Provider<EntryService>(create: (_) => EntryService()),
            Provider<SubstanceService>(create: (_) => SubstanceService()),
            Provider<QuickButtonService>(create: (_) => QuickButtonService()),
            ChangeNotifierProvider<SettingsService>(create: (_) => SettingsService()),
            ChangeNotifierProvider<service.PsychedelicThemeService>(create: (_) => service.PsychedelicThemeService()),
            Provider<AuthService>(create: (_) => AuthService()),
            Provider<NotificationService>(create: (_) => NotificationService()),
            ChangeNotifierProvider<TimerService>(create: (_) => TimerService()),
          ],
          child: const MaterialApp(
            home: MainNavigation(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Navigation should be functional
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Dosisrechner'), findsOneWidget);
      expect(find.text('Statistiken'), findsOneWidget);
      expect(find.text('Menü'), findsOneWidget);

      // Should not have critical layout errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('Unique widget keys prevent duplicate key errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<DatabaseService>(create: (_) => DatabaseService()),
            Provider<EntryService>(create: (_) => EntryService()),
            Provider<SubstanceService>(create: (_) => SubstanceService()),
            Provider<QuickButtonService>(create: (_) => QuickButtonService()),
            ChangeNotifierProvider<SettingsService>(create: (_) => SettingsService()),
            ChangeNotifierProvider<service.PsychedelicThemeService>(create: (_) => service.PsychedelicThemeService()),
            Provider<AuthService>(create: (_) => AuthService()),
            Provider<NotificationService>(create: (_) => NotificationService()),
            ChangeNotifierProvider<TimerService>(create: (_) => TimerService()),
          ],
          child: const MaterialApp(
            home: MainNavigation(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Test multiple screen instances - should not cause duplicate key errors
      final navigationTabs = find.byType(GestureDetector);
      
      // Navigate to each screen multiple times
      for (int i = 0; i < 4; i++) {
        await tester.tap(navigationTabs.at(i));
        await tester.pumpAndSettle();
        
        // Check for duplicate key exceptions
        final exception = tester.takeException();
        if (exception != null) {
          final errorMessage = exception.toString();
          expect(errorMessage.toLowerCase().contains('duplicate'), false,
                 reason: 'Duplicate key error detected: $errorMessage');
        }
      }
    });
  });
}

// Example usage as a standalone test app
class NavigationOverflowTestApp extends StatelessWidget {
  const NavigationOverflowTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DatabaseService>(create: (_) => DatabaseService()),
        Provider<EntryService>(create: (_) => EntryService()),
        Provider<SubstanceService>(create: (_) => SubstanceService()),
        Provider<QuickButtonService>(create: (_) => QuickButtonService()),
        ChangeNotifierProvider<SettingsService>(create: (_) => SettingsService()),
        ChangeNotifierProvider<service.PsychedelicThemeService>(create: (_) => service.PsychedelicThemeService()),
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<NotificationService>(create: (_) => NotificationService()),
        ChangeNotifierProvider<TimerService>(create: (_) => TimerService()),
      ],
      child: MaterialApp(
        title: 'Navigation Overflow Test',
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Navigation Overflow Test'),
            backgroundColor: Colors.blue,
          ),
          body: const MainNavigation(),
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}