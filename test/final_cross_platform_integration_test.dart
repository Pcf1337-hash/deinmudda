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

void main() {
  group('Final Cross-Platform Integration Tests', () {
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

    testWidgets('Platform detection works correctly', (WidgetTester tester) async {
      // Test that platform detection is working
      expect(PlatformHelper.isMobile, isTrue);
      expect(PlatformHelper.isWeb, isFalse);
      expect(PlatformHelper.isDesktop, isFalse);
      
      // Test that only one platform is detected
      final platformCount = [
        PlatformHelper.isIOS,
        PlatformHelper.isAndroid,
        PlatformHelper.isWeb,
        PlatformHelper.isDesktop,
      ].where((platform) => platform).length;
      
      expect(platformCount, equals(1));
    });

    testWidgets('Platform-specific configurations are consistent', (WidgetTester tester) async {
      // Test that platform-specific configurations are reasonable
      final iconSize = PlatformHelper.getPlatformIconSize();
      expect(iconSize, greaterThan(16.0));
      expect(iconSize, lessThan(32.0));
      
      final elevation = PlatformHelper.getPlatformElevation();
      expect(elevation, greaterThanOrEqualTo(0.0));
      expect(elevation, lessThanOrEqualTo(16.0));
      
      final borderRadius = PlatformHelper.getPlatformBorderRadius();
      expect(borderRadius, isNotNull);
      expect(borderRadius.topLeft.x, greaterThan(0.0));
      
      final scrollPhysics = PlatformHelper.getScrollPhysics();
      expect(scrollPhysics, isNotNull);
      
      final pageTransitionsBuilder = PlatformHelper.getPageTransitionsBuilder();
      expect(pageTransitionsBuilder, isNotNull);
    });

    testWidgets('System UI overlay styles are properly configured', (WidgetTester tester) async {
      // Test system UI overlay styles
      final lightStyle = PlatformHelper.getStatusBarStyle(
        isDark: false,
        isPsychedelicMode: false,
      );
      expect(lightStyle, isNotNull);
      expect(lightStyle.statusBarColor, equals(Colors.transparent));
      
      final darkStyle = PlatformHelper.getStatusBarStyle(
        isDark: true,
        isPsychedelicMode: false,
      );
      expect(darkStyle, isNotNull);
      expect(darkStyle.statusBarColor, equals(Colors.transparent));
      
      final psychedelicStyle = PlatformHelper.getStatusBarStyle(
        isDark: false,
        isPsychedelicMode: true,
      );
      expect(psychedelicStyle, isNotNull);
      expect(psychedelicStyle.statusBarColor, equals(Colors.transparent));
    });

    testWidgets('Haptic feedback methods work without errors', (WidgetTester tester) async {
      // Test that haptic feedback methods can be called without errors
      expect(() {
        PlatformHelper.performHapticFeedback(HapticFeedbackType.lightImpact);
      }, returnsNormally);
      
      expect(() {
        PlatformHelper.performHapticFeedback(HapticFeedbackType.mediumImpact);
      }, returnsNormally);
      
      expect(() {
        PlatformHelper.performHapticFeedback(HapticFeedbackType.heavyImpact);
      }, returnsNormally);
      
      expect(() {
        PlatformHelper.performHapticFeedback(HapticFeedbackType.selectionClick);
      }, returnsNormally);
      
      expect(() {
        PlatformHelper.performHapticFeedback(HapticFeedbackType.vibrate);
      }, returnsNormally);
    });

    testWidgets('Platform-specific keyboard types are valid', (WidgetTester tester) async {
      // Test keyboard type generation
      final numberKeyboard = PlatformHelper.getPlatformKeyboardType('number');
      expect(numberKeyboard, isNotNull);
      
      final emailKeyboard = PlatformHelper.getPlatformKeyboardType('email');
      expect(emailKeyboard, equals(TextInputType.emailAddress));
      
      final phoneKeyboard = PlatformHelper.getPlatformKeyboardType('phone');
      expect(phoneKeyboard, equals(TextInputType.phone));
      
      final urlKeyboard = PlatformHelper.getPlatformKeyboardType('url');
      expect(urlKeyboard, equals(TextInputType.url));
      
      final textKeyboard = PlatformHelper.getPlatformKeyboardType('text');
      expect(textKeyboard, equals(TextInputType.text));
    });

    testWidgets('Platform helper navigation methods work correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        expect(PlatformHelper.shouldShowBackButton(context), isFalse);
                      },
                      child: const Text('Test Back Button'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Scaffold(
                              appBar: AppBar(title: const Text('Second')),
                              body: const Text('Second Screen'),
                            ),
                          ),
                        );
                      },
                      child: const Text('Navigate'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Test navigation
      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      expect(find.text('Second Screen'), findsOneWidget);

      // Test back navigation
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.text('Test Back Button'), findsOneWidget);
    });

    testWidgets('Platform font and text scaling work correctly', (WidgetTester tester) async {
      // Test platform font family
      final fontFamily = PlatformHelper.getPlatformFontFamily();
      expect(fontFamily, isNotNull);
      
      // Test text scale factor
      final textScaleFactor = PlatformHelper.getPlatformTextScaleFactor();
      expect(textScaleFactor, equals(1.0));
      
      // Test text input action
      final textInputAction = PlatformHelper.getPlatformTextInputAction();
      expect(textInputAction, isNotNull);
    });

    testWidgets('Platform-specific safe area handling works', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final mediaQuery = MediaQuery.of(context);
                final safeAreaPadding = PlatformHelper.getSafeAreaPadding(mediaQuery);
                
                expect(safeAreaPadding, isNotNull);
                expect(safeAreaPadding.top, greaterThanOrEqualTo(0.0));
                expect(safeAreaPadding.bottom, greaterThanOrEqualTo(0.0));
                
                return Container(
                  padding: safeAreaPadding,
                  child: const Text('Safe Area Test'),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Safe Area Test'), findsOneWidget);
    });

    testWidgets('Theme integration with platform features works', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<PsychedelicThemeService>.value(
              value: psychedelicThemeService,
            ),
            ChangeNotifierProvider<SettingsService>.value(
              value: settingsService,
            ),
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
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Theme Integration Test',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            psychedelicService.toggleDarkMode();
                          },
                          child: const Text('Toggle Dark Mode'),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            psychedelicService.togglePsychedelicMode();
                          },
                          child: const Text('Toggle Trippy Mode'),
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

      expect(find.text('Theme Integration Test'), findsOneWidget);
      expect(find.text('Toggle Dark Mode'), findsOneWidget);
      expect(find.text('Toggle Trippy Mode'), findsOneWidget);

      // Test theme toggling
      await tester.tap(find.text('Toggle Dark Mode'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Toggle Trippy Mode'));
      await tester.pumpAndSettle();

      // Verify buttons are still present after theme changes
      expect(find.text('Toggle Dark Mode'), findsOneWidget);
      expect(find.text('Toggle Trippy Mode'), findsOneWidget);
    });

    testWidgets('Platform modal and dialog methods work', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        PlatformHelper.showPlatformModal(
                          context: context,
                          child: const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('Modal Content'),
                          ),
                        );
                      },
                      child: const Text('Show Modal'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        PlatformHelper.showPlatformDialog(
                          context: context,
                          child: AlertDialog(
                            title: const Text('Dialog Title'),
                            content: const Text('Dialog Content'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text('Show Dialog'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Test modal
      await tester.tap(find.text('Show Modal'));
      await tester.pumpAndSettle();

      expect(find.text('Modal Content'), findsOneWidget);

      // Dismiss modal (tap outside)
      await tester.tapAt(const Offset(50, 50));
      await tester.pumpAndSettle();

      // Test dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Dialog Title'), findsOneWidget);
      expect(find.text('Dialog Content'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);

      // Dismiss dialog
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.text('Dialog Title'), findsNothing);
    });

    testWidgets('All platform components work together seamlessly', (WidgetTester tester) async {
      // Final integration test to ensure all components work together
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
                  body: SafeArea(
                    child: SingleChildScrollView(
                      physics: PlatformHelper.getScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cross-Platform Integration Test',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Platform: ${PlatformHelper.isIOS ? 'iOS' : 'Android'}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                PlatformHelper.performHapticFeedback(
                                  HapticFeedbackType.lightImpact,
                                );
                              },
                              child: const Text('Test Haptic Feedback'),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              height: 200,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: PlatformHelper.getPlatformBorderRadius(),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8.0,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text('Platform-styled container'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify all components are working
      expect(find.text('Cross-Platform Integration Test'), findsOneWidget);
      expect(find.text('Platform: ${PlatformHelper.isIOS ? 'iOS' : 'Android'}'), findsOneWidget);
      expect(find.text('Test Haptic Feedback'), findsOneWidget);
      expect(find.text('Platform-styled container'), findsOneWidget);

      // Test interaction
      await tester.tap(find.text('Test Haptic Feedback'));
      await tester.pumpAndSettle();

      // Test scrolling
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -50));
      await tester.pumpAndSettle();

      // Verify everything still works after interactions
      expect(find.text('Cross-Platform Integration Test'), findsOneWidget);
    });
  });
}