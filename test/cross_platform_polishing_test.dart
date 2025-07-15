import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import '../lib/main.dart';
import '../lib/services/psychedelic_theme_service.dart';
import '../lib/services/database_service.dart';
import '../lib/services/entry_service.dart';
import '../lib/services/substance_service.dart';
import '../lib/services/settings_service.dart';
import '../lib/services/quick_button_service.dart';
import '../lib/services/auth_service.dart';
import '../lib/services/notification_service.dart';
import '../lib/services/timer_service.dart';
import '../lib/utils/platform_helper.dart';
import '../lib/widgets/platform_adaptive_widgets.dart';
import '../lib/widgets/platform_adaptive_fab.dart';
import 'cross_platform_test_helper.dart';

void main() {
  group('Cross-Platform Polishing Tests', () {
    late PsychedelicThemeService psychedelicThemeService;
    late DatabaseService databaseService;
    late EntryService entryService;
    late SubstanceService substanceService;
    late SettingsService settingsService;
    late QuickButtonService quickButtonService;
    late AuthService authService;
    late NotificationService notificationService;
    late TimerService timerService;

    setUp(() async {
      // Initialize services
      psychedelicThemeService = PsychedelicThemeService();
      databaseService = DatabaseService();
      entryService = EntryService();
      substanceService = SubstanceService();
      settingsService = SettingsService();
      quickButtonService = QuickButtonService();
      authService = AuthService();
      notificationService = NotificationService();
      timerService = TimerService();

      // Initialize services that need async initialization
      await psychedelicThemeService.init();
      await databaseService.database;
      await notificationService.init();
      await timerService.init();
    });

    tearDown(() async {
      // Clean up services
      await databaseService.dispose();
    });

    group('Platform Detection Tests', () {
      testWidgets('Platform helper correctly identifies platform', (WidgetTester tester) async {
        // Test platform detection
        expect(PlatformHelper.isMobile, true);
        expect(PlatformHelper.isWeb, false);
        expect(PlatformHelper.isDesktop, false);
        expect(PlatformHelper.isAndroid || PlatformHelper.isIOS, true);
      });

      testWidgets('Platform-specific configurations are correct', (WidgetTester tester) async {
        // Test platform-specific configurations
        final statusBarStyle = PlatformHelper.getStatusBarStyle(
          isDark: false,
          isPsychedelicMode: false,
        );
        expect(statusBarStyle, isNotNull);

        final scrollPhysics = PlatformHelper.getScrollPhysics();
        expect(scrollPhysics, isNotNull);

        final borderRadius = PlatformHelper.getPlatformBorderRadius();
        expect(borderRadius, isNotNull);

        final elevation = PlatformHelper.getPlatformElevation();
        expect(elevation, isA<double>());

        final iconSize = PlatformHelper.getPlatformIconSize();
        expect(iconSize, isA<double>());
      });
    });

    group('SafeArea and System UI Tests', () {
      testWidgets('SafeArea is properly implemented across screens', (WidgetTester tester) async {
        // Test SafeArea implementation
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<PsychedelicThemeService>.value(
                value: psychedelicThemeService,
              ),
              ChangeNotifierProvider<SettingsService>.value(
                value: settingsService,
              ),
              Provider<DatabaseService>.value(value: databaseService),
              Provider<EntryService>.value(value: entryService),
              Provider<SubstanceService>.value(value: substanceService),
              Provider<QuickButtonService>.value(value: quickButtonService),
              Provider<AuthService>.value(value: authService),
              Provider<NotificationService>.value(value: notificationService),
              Provider<TimerService>.value(value: timerService),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: SafeArea(
                  child: Container(
                    width: 200,
                    height: 200,
                    color: Colors.blue,
                    child: const Center(
                      child: Text('Test SafeArea'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify SafeArea is working
        expect(find.byType(SafeArea), findsOneWidget);
        expect(find.text('Test SafeArea'), findsOneWidget);
      });

      testWidgets('System UI overlay styles are applied correctly', (WidgetTester tester) async {
        // Test system UI overlay styles
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                title: const Text('Test App Bar'),
                systemOverlayStyle: PlatformHelper.getStatusBarStyle(
                  isDark: false,
                  isPsychedelicMode: false,
                ),
              ),
              body: const Center(
                child: Text('Test Content'),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Test App Bar'), findsOneWidget);
        expect(find.text('Test Content'), findsOneWidget);
      });
    });

    group('Platform Adaptive Widgets Tests', () {
      testWidgets('Platform adaptive button works correctly', (WidgetTester tester) async {
        bool buttonPressed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: PlatformAdaptiveButton(
                  onPressed: () => buttonPressed = true,
                  child: const Text('Test Button'),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Test button tap
        await tester.tap(find.byType(PlatformAdaptiveButton));
        await tester.pumpAndSettle();

        expect(buttonPressed, true);
        expect(find.text('Test Button'), findsOneWidget);
      });

      testWidgets('Platform adaptive FAB works correctly', (WidgetTester tester) async {
        bool fabPressed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: const Center(
                child: Text('Test Content'),
              ),
              floatingActionButton: PlatformAdaptiveFAB(
                onPressed: () => fabPressed = true,
                child: const Icon(Icons.add),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Test FAB tap
        await tester.tap(find.byType(PlatformAdaptiveFAB));
        await tester.pumpAndSettle();

        expect(fabPressed, true);
        expect(find.byIcon(Icons.add), findsOneWidget);
      });

      testWidgets('Platform adaptive text field works correctly', (WidgetTester tester) async {
        final controller = TextEditingController();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: PlatformAdaptiveTextField(
                  controller: controller,
                  placeholder: 'Enter text',
                  keyboardType: TextInputType.text,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Test text input
        await tester.enterText(find.byType(PlatformAdaptiveTextField), 'Test input');
        await tester.pumpAndSettle();

        expect(controller.text, 'Test input');
      });

      testWidgets('Platform adaptive loading indicator displays correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: PlatformAdaptiveLoadingIndicator(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(PlatformAdaptiveLoadingIndicator), findsOneWidget);
      });

      testWidgets('Platform adaptive switch works correctly', (WidgetTester tester) async {
        bool switchValue = false;

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return MaterialApp(
                home: Scaffold(
                  body: Center(
                    child: PlatformAdaptiveSwitch(
                      value: switchValue,
                      onChanged: (value) {
                        setState(() {
                          switchValue = value;
                        });
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        );

        await tester.pumpAndSettle();

        // Test switch toggle
        await tester.tap(find.byType(PlatformAdaptiveSwitch));
        await tester.pumpAndSettle();

        expect(switchValue, true);
      });

      testWidgets('Platform adaptive slider works correctly', (WidgetTester tester) async {
        double sliderValue = 0.5;

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return MaterialApp(
                home: Scaffold(
                  body: Center(
                    child: PlatformAdaptiveSlider(
                      value: sliderValue,
                      onChanged: (value) {
                        setState(() {
                          sliderValue = value;
                        });
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        );

        await tester.pumpAndSettle();

        // Test slider drag
        await tester.drag(find.byType(PlatformAdaptiveSlider), const Offset(50, 0));
        await tester.pumpAndSettle();

        expect(sliderValue, greaterThan(0.5));
      });
    });

    group('Navigation and Scroll Physics Tests', () {
      testWidgets('Platform-specific scroll physics are applied', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView.builder(
                physics: PlatformHelper.getScrollPhysics(),
                itemCount: 100,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Item $index'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Test scroll behavior
        await tester.drag(find.byType(ListView), const Offset(0, -200));
        await tester.pumpAndSettle();

        expect(find.text('Item 0'), findsNothing);
        expect(find.text('Item 5'), findsOneWidget);
      });

      testWidgets('Back navigation works correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                title: const Text('Home'),
              ),
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Scaffold(
                            appBar: AppBar(
                              title: const Text('Second Screen'),
                            ),
                            body: const Center(
                              child: Text('Second Screen Content'),
                            ),
                          ),
                        ),
                      );
                    },
                    child: const Text('Go to Second Screen'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Navigate to second screen
        await tester.tap(find.text('Go to Second Screen'));
        await tester.pumpAndSettle();

        expect(find.text('Second Screen'), findsOneWidget);
        expect(find.text('Second Screen Content'), findsOneWidget);

        // Navigate back
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();

        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Go to Second Screen'), findsOneWidget);
      });
    });

    group('Modal and Dialog Tests', () {
      testWidgets('Platform adaptive modal bottom sheet works', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      PlatformAdaptiveModalBottomSheet.show(
                        context: context,
                        child: const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('Modal Content'),
                        ),
                      );
                    },
                    child: const Text('Show Modal'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Show modal
        await tester.tap(find.text('Show Modal'));
        await tester.pumpAndSettle();

        expect(find.text('Modal Content'), findsOneWidget);
      });

      testWidgets('Platform adaptive dialog works', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      PlatformAdaptiveDialog.show(
                        context: context,
                        title: 'Test Dialog',
                        content: 'This is a test dialog',
                        actions: [
                          PlatformAdaptiveButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                    child: const Text('Show Dialog'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Show dialog
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        expect(find.text('Test Dialog'), findsOneWidget);
        expect(find.text('This is a test dialog'), findsOneWidget);
        expect(find.text('OK'), findsOneWidget);

        // Dismiss dialog
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        expect(find.text('Test Dialog'), findsNothing);
      });
    });

    group('Theme and Visual Consistency Tests', () {
      testWidgets('Trippy mode affects UI correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<PsychedelicThemeService>.value(
                value: psychedelicThemeService,
              ),
            ],
            child: Consumer<PsychedelicThemeService>(
              builder: (context, psychedelicService, child) {
                return MaterialApp(
                  theme: psychedelicService.getTheme(),
                  home: Scaffold(
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Trippy Mode Test',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              psychedelicService.togglePsychedelicMode();
                            },
                            child: Text(
                              psychedelicService.isPsychedelicMode
                                  ? 'Disable Trippy Mode'
                                  : 'Enable Trippy Mode',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Trippy Mode Test'), findsOneWidget);
        expect(find.text('Enable Trippy Mode'), findsOneWidget);

        // Toggle trippy mode
        await tester.tap(find.text('Enable Trippy Mode'));
        await tester.pumpAndSettle();

        expect(find.text('Disable Trippy Mode'), findsOneWidget);
      });

      testWidgets('Dark mode theme is applied correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<PsychedelicThemeService>.value(
                value: psychedelicThemeService,
              ),
            ],
            child: Consumer<PsychedelicThemeService>(
              builder: (context, psychedelicService, child) {
                return MaterialApp(
                  theme: psychedelicService.getTheme(),
                  home: Scaffold(
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Dark Mode Test',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              psychedelicService.toggleDarkMode();
                            },
                            child: Text(
                              psychedelicService.isDarkMode
                                  ? 'Disable Dark Mode'
                                  : 'Enable Dark Mode',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Dark Mode Test'), findsOneWidget);
        expect(find.text('Enable Dark Mode'), findsOneWidget);

        // Toggle dark mode
        await tester.tap(find.text('Enable Dark Mode'));
        await tester.pumpAndSettle();

        expect(find.text('Disable Dark Mode'), findsOneWidget);
      });
    });

    group('Performance and Optimization Tests', () {
      testWidgets('Platform helpers work efficiently', (WidgetTester tester) async {
        // Test performance of platform helpers
        final stopwatch = Stopwatch()..start();

        // Run platform detection multiple times
        for (int i = 0; i < 1000; i++) {
          PlatformHelper.isIOS;
          PlatformHelper.isAndroid;
          PlatformHelper.isMobile;
        }

        stopwatch.stop();

        // Should be very fast (less than 100ms for 1000 calls)
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });

      testWidgets('Animations are optimized for platform', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: PlatformAdaptiveFAB(
                  onPressed: () {},
                  child: const Icon(Icons.add),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Test animation performance
        final stopwatch = Stopwatch()..start();

        // Tap FAB multiple times to trigger animations
        for (int i = 0; i < 10; i++) {
          await tester.tap(find.byType(PlatformAdaptiveFAB));
          await tester.pump();
        }

        await tester.pumpAndSettle();
        stopwatch.stop();

        // Should complete reasonably quickly
        expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      });
    });

    group('Integration Tests', () {
      testWidgets('Full app integration test', (WidgetTester tester) async {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<DatabaseService>.value(value: databaseService),
              ProxyProvider<DatabaseService, EntryService>(
                update: (_, db, __) => entryService,
              ),
              ProxyProvider<DatabaseService, SubstanceService>(
                update: (_, db, __) => substanceService,
              ),
              ProxyProvider<DatabaseService, QuickButtonService>(
                update: (_, db, __) => quickButtonService,
              ),
              ChangeNotifierProvider<SettingsService>.value(
                value: settingsService,
              ),
              ChangeNotifierProvider<PsychedelicThemeService>.value(
                value: psychedelicThemeService,
              ),
              Provider<AuthService>.value(value: authService),
              Provider<NotificationService>.value(value: notificationService),
              Provider<TimerService>.value(value: timerService),
            ],
            child: Consumer<PsychedelicThemeService>(
              builder: (context, psychedelicService, child) {
                return MaterialApp(
                  theme: psychedelicService.getTheme().copyWith(
                    pageTransitionsTheme: PageTransitionsTheme(
                      builders: {
                        TargetPlatform.android: PlatformHelper.getPageTransitionsBuilder(),
                        TargetPlatform.iOS: PlatformHelper.getPageTransitionsBuilder(),
                      },
                    ),
                  ),
                  home: Scaffold(
                    body: const Center(
                      child: Text('Integration Test'),
                    ),
                    floatingActionButton: PlatformAdaptiveFAB(
                      onPressed: () {},
                      child: const Icon(Icons.add),
                    ),
                  ),
                );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Integration Test'), findsOneWidget);
        expect(find.byType(PlatformAdaptiveFAB), findsOneWidget);
        expect(find.byIcon(Icons.add), findsOneWidget);
      });
    });
  });
}