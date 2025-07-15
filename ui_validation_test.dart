import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'lib/services/psychedelic_theme_service.dart';
import 'lib/services/settings_service.dart';
import 'lib/services/database_service.dart';
import 'lib/services/entry_service.dart';
import 'lib/services/timer_service.dart';
import 'lib/services/substance_service.dart';
import 'lib/services/quick_button_service.dart';
import 'lib/theme/modern_theme.dart';
import 'lib/screens/home_screen.dart';
import 'lib/screens/settings_screen.dart';
import 'lib/screens/timer_dashboard_screen.dart';
import 'lib/screens/add_entry_screen.dart';
import 'lib/screens/quick_entry/quick_button_config_screen.dart';
import 'lib/screens/dosage_calculator/dosage_calculator_screen.dart';
import 'lib/widgets/header_bar.dart';
import 'lib/widgets/consistent_fab.dart';
import 'lib/widgets/active_timer_bar.dart';
import 'lib/widgets/trippy_fab.dart';
import 'lib/models/entry.dart';
import 'lib/models/substance.dart';

/// Comprehensive UI Testing and Validation Suite
/// Tests all screens for overflow issues, theme consistency, and animations
void main() {
  group('UI Validation Tests - Systematic QA Testing', () {
    
    late Widget testApp;
    
    setUpAll(() async {
      // Initialize services
      final databaseService = DatabaseService();
      await databaseService.database;
    });
    
    setUp(() {
      testApp = MaterialApp(
        theme: ModernTheme.lightTheme,
        darkTheme: ModernTheme.darkTheme,
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => PsychedelicThemeService()),
            ChangeNotifierProvider(create: (_) => SettingsService()),
            Provider<DatabaseService>(create: (_) => DatabaseService()),
            Provider<EntryService>(create: (_) => EntryService()),
            Provider<TimerService>(create: (_) => TimerService()),
            Provider<SubstanceService>(create: (_) => SubstanceService()),
            Provider<QuickButtonService>(create: (_) => QuickButtonService()),
          ],
          child: const Scaffold(body: Text('Test')),
        ),
      );
    });

    group('🧪 UI Tests & Overflow Checks', () {
      
      testWidgets('Home Screen - overflow and responsive behavior', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (_) => PsychedelicThemeService()),
                ChangeNotifierProvider(create: (_) => SettingsService()),
                Provider<DatabaseService>(create: (_) => DatabaseService()),
                Provider<EntryService>(create: (_) => EntryService()),
                Provider<TimerService>(create: (_) => TimerService()),
                Provider<SubstanceService>(create: (_) => SubstanceService()),
                Provider<QuickButtonService>(create: (_) => QuickButtonService()),
              ],
              child: const HomeScreen(),
            ),
          ),
        );

        // Test different screen sizes
        await _testScreenSizes(tester, 'HomeScreen');
        
        // Test text scaling
        await _testTextScaling(tester, 'HomeScreen');
        
        // Verify no overflow errors
        expect(tester.takeException(), isNull);
        
        // Check for proper scroll behavior
        expect(find.byType(SingleChildScrollView), findsWidgets);
        expect(find.byType(Flexible), findsWidgets);
      });

      testWidgets('Timer Dashboard Screen - overflow and responsive behavior', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (_) => PsychedelicThemeService()),
                ChangeNotifierProvider(create: (_) => SettingsService()),
                Provider<DatabaseService>(create: (_) => DatabaseService()),
                Provider<EntryService>(create: (_) => EntryService()),
                Provider<TimerService>(create: (_) => TimerService()),
              ],
              child: const TimerDashboardScreen(),
            ),
          ),
        );

        await _testScreenSizes(tester, 'TimerDashboardScreen');
        await _testTextScaling(tester, 'TimerDashboardScreen');
        expect(tester.takeException(), isNull);
      });

      testWidgets('Settings Screen - overflow and responsive behavior', (WidgetTester tester) async {
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

        await _testScreenSizes(tester, 'SettingsScreen');
        await _testTextScaling(tester, 'SettingsScreen');
        expect(tester.takeException(), isNull);
      });

      testWidgets('Dosage Calculator Screen - overflow and responsive behavior', (WidgetTester tester) async {
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

        await _testScreenSizes(tester, 'DosageCalculatorScreen');
        await _testTextScaling(tester, 'DosageCalculatorScreen');
        expect(tester.takeException(), isNull);
      });
    });

    group('🎨 Theme & Color Testing', () {
      
      testWidgets('Light Theme - color consistency', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ModernTheme.lightTheme,
            home: MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (_) => PsychedelicThemeService()),
                ChangeNotifierProvider(create: (_) => SettingsService()),
              ],
              child: const HomeScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();
        
        // Verify theme elements are present
        expect(find.byType(HeaderBar), findsOneWidget);
        expect(find.byType(ConsistentFAB), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('Dark Theme - color consistency', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ModernTheme.darkTheme,
            home: MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (_) => PsychedelicThemeService()),
                ChangeNotifierProvider(create: (_) => SettingsService()),
              ],
              child: const HomeScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });

      testWidgets('Trippy Mode - color consistency and effects', (WidgetTester tester) async {
        final psychedelicService = PsychedelicThemeService();
        await psychedelicService.init();
        await psychedelicService.setThemeMode(ThemeMode.trippy);
        
        await tester.pumpWidget(
          MaterialApp(
            theme: ModernTheme.darkTheme,
            home: ChangeNotifierProvider.value(
              value: psychedelicService,
              child: MultiProvider(
                providers: [
                  ChangeNotifierProvider(create: (_) => SettingsService()),
                ],
                child: const HomeScreen(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        
        // Verify trippy mode elements
        expect(find.byType(TrippyFAB), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });

    group('⚙️ Animation & Performance Testing', () {
      
      testWidgets('FAB Animation - smooth transitions', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (_) => PsychedelicThemeService()),
              ],
              child: const Scaffold(
                floatingActionButton: ConsistentFAB(
                  speedDialChildren: [],
                  mainIcon: Icons.add,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        
        // Test FAB tap animation
        await tester.tap(find.byType(ConsistentFAB));
        await tester.pumpAndSettle();
        
        expect(tester.takeException(), isNull);
      });

      testWidgets('TimerBar Animation - progress and pulsing', (WidgetTester tester) async {
        // Create a mock timer entry
        final mockEntry = Entry(
          id: 'test-id',
          substanceId: 'test-substance',
          substanceName: 'Test Substance',
          dosage: 10.0,
          unit: 'mg',
          price: 5.0,
          notes: 'Test notes',
          timestamp: DateTime.now(),
          timerStartTime: DateTime.now(),
          timerEndTime: DateTime.now().add(const Duration(hours: 4)),
          timerCompleted: false,
          timerNotificationSent: false,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (_) => PsychedelicThemeService()),
                Provider<TimerService>(create: (_) => TimerService()),
              ],
              child: Scaffold(
                body: ActiveTimerBar(timer: mockEntry),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        
        // Verify timer bar is rendered
        expect(find.byType(ActiveTimerBar), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });

    group('💡 UI Element Consistency', () {
      
      testWidgets('HeaderBar - consistent across screens', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (_) => PsychedelicThemeService()),
              ],
              child: const HeaderBar(
                title: 'Test Screen',
                subtitle: 'Test Subtitle',
                showLightningIcon: true,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        
        // Verify header elements
        expect(find.text('Test Screen'), findsOneWidget);
        expect(find.text('Test Subtitle'), findsOneWidget);
        expect(find.byIcon(Icons.flash_on_rounded), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('ConsistentFAB - unified design', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (_) => PsychedelicThemeService()),
              ],
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
        expect(tester.takeException(), isNull);
      });
    });
  });
}

/// Helper function to test different screen sizes
Future<void> _testScreenSizes(WidgetTester tester, String screenName) async {
  final sizes = [
    const Size(320, 568), // iPhone SE
    const Size(375, 667), // iPhone 8
    const Size(414, 896), // iPhone 11
    const Size(600, 800), // Tablet
  ];

  for (final size in sizes) {
    await tester.binding.setSurfaceSize(size);
    await tester.pumpAndSettle();
    
    // Verify no overflow errors at this size
    expect(tester.takeException(), isNull, 
        reason: '$screenName overflow at size ${size.width}x${size.height}');
  }
}

/// Helper function to test text scaling
Future<void> _testTextScaling(WidgetTester tester, String screenName) async {
  final textScales = [1.0, 1.5, 2.0, 3.0];

  for (final scale in textScales) {
    await tester.binding.window.textScaleFactorTestValue = scale;
    await tester.pumpAndSettle();
    
    // Verify no overflow errors at this text scale
    expect(tester.takeException(), isNull, 
        reason: '$screenName overflow at text scale $scale');
  }
  
  // Reset text scale
  await tester.binding.window.clearTextScaleFactorTestValue();
}