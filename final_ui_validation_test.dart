import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'lib/services/psychedelic_theme_service.dart';
import 'lib/services/settings_service.dart';
import 'lib/services/database_service.dart';
import 'lib/screens/home_screen.dart';
import 'lib/screens/settings_screen.dart';
import 'lib/screens/substance_management_screen.dart';
import 'lib/screens/auth/security_settings_screen.dart';
import 'lib/widgets/header_bar.dart';
import 'lib/widgets/consistent_fab.dart';
import 'lib/theme/design_tokens.dart';

/// Final validation test to ensure UI consistency and proper implementation
void main() {
  group('Final UI Validation Tests', () {
    
    late Widget testApp;
    
    setUp(() {
      testApp = MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => PsychedelicThemeService()),
            ChangeNotifierProvider(create: (_) => SettingsService()),
            Provider<DatabaseService>(create: (_) => DatabaseService()),
          ],
          child: const Scaffold(body: Text('Test')),
        ),
      );
    });

    group('HeaderBar Consistency', () {
      testWidgets('HeaderBar displays lightning icon', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (_) => PsychedelicThemeService()),
              ],
              child: const Scaffold(
                body: HeaderBar(
                  title: 'Test Screen',
                  showLightningIcon: true,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        
        // Verify lightning icon is present
        expect(find.byIcon(DesignTokens.lightningIcon), findsOneWidget);
        expect(find.text('Test Screen'), findsOneWidget);
      });

      testWidgets('HeaderBar adapts to trippy mode', (WidgetTester tester) async {
        final psychedelicService = PsychedelicThemeService();
        await psychedelicService.init();
        await psychedelicService.setThemeMode(ThemeMode.trippy);
        
        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider.value(
              value: psychedelicService,
              child: const Scaffold(
                body: HeaderBar(
                  title: 'Trippy Mode Test',
                  showLightningIcon: true,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        
        // Verify trippy mode elements are present
        expect(find.text('Trippy Mode Test'), findsOneWidget);
        expect(find.byIcon(DesignTokens.lightningIcon), findsOneWidget);
      });
    });

    group('Screen Consistency', () {
      testWidgets('All screens use HeaderBar', (WidgetTester tester) async {
        // Test Settings Screen
        await tester.pumpWidget(
          MaterialApp(
            home: MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (_) => PsychedelicThemeService()),
                ChangeNotifierProvider(create: (_) => SettingsService()),
                Provider<DatabaseService>(create: (_) => DatabaseService()),
              ],
              child: const SettingsScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(HeaderBar), findsOneWidget);
        
        // Test Substance Management Screen
        await tester.pumpWidget(
          MaterialApp(
            home: MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (_) => PsychedelicThemeService()),
                ChangeNotifierProvider(create: (_) => SettingsService()),
                Provider<DatabaseService>(create: (_) => DatabaseService()),
              ],
              child: const SubstanceManagementScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(HeaderBar), findsOneWidget);
        
        // Test Security Settings Screen
        await tester.pumpWidget(
          MaterialApp(
            home: MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (_) => PsychedelicThemeService()),
                ChangeNotifierProvider(create: (_) => SettingsService()),
                Provider<DatabaseService>(create: (_) => DatabaseService()),
              ],
              child: const SecuritySettingsScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(HeaderBar), findsOneWidget);
      });
    });

    group('FAB Consistency', () {
      testWidgets('ConsistentFAB switches between normal and trippy mode', (WidgetTester tester) async {
        final psychedelicService = PsychedelicThemeService();
        await psychedelicService.init();
        
        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider.value(
              value: psychedelicService,
              child: const Scaffold(
                floatingActionButton: ConsistentFAB(
                  speedDialChildren: [],
                  mainIcon: Icons.add,
                  mainLabel: 'Test Action',
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(ConsistentFAB), findsOneWidget);
        
        // Switch to trippy mode
        await psychedelicService.setThemeMode(ThemeMode.trippy);
        await tester.pumpAndSettle();
        
        // Should still have ConsistentFAB but with trippy styling
        expect(find.byType(ConsistentFAB), findsOneWidget);
      });
    });

    group('Design Token Usage', () {
      testWidgets('Lightning icon uses DesignTokens.lightningIcon', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (_) => PsychedelicThemeService()),
              ],
              child: const Scaffold(
                body: HeaderBar(
                  title: 'Design Token Test',
                  showLightningIcon: true,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        
        // Verify the specific lightning icon from design tokens is used
        expect(find.byIcon(DesignTokens.lightningIcon), findsOneWidget);
      });
    });

    group('Responsive Design', () {
      testWidgets('HeaderBar adapts to different screen sizes', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (_) => PsychedelicThemeService()),
              ],
              child: const Scaffold(
                body: HeaderBar(
                  title: 'Responsive Test',
                  subtitle: 'This is a long subtitle that should handle overflow properly',
                  showLightningIcon: true,
                ),
              ),
            ),
          ),
        );

        // Test different screen sizes
        await tester.binding.setSurfaceSize(const Size(320, 568));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        
        await tester.binding.setSurfaceSize(const Size(800, 600));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    });
  });
}