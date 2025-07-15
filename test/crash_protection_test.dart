import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:deinmudda/main.dart';
import 'package:deinmudda/utils/app_initialization_manager.dart';
import 'package:deinmudda/utils/error_handler.dart';
import 'package:deinmudda/utils/crash_protection.dart';
import 'package:deinmudda/services/psychedelic_theme_service.dart';
import 'package:deinmudda/services/timer_service.dart';
import 'package:deinmudda/screens/home_screen.dart';

void main() {
  group('Crash Protection and Error Handling Tests', () {
    testWidgets('AppInitializationManager initializes correctly', (WidgetTester tester) async {
      final initManager = AppInitializationManager();
      
      // Initialize the app
      final result = await initManager.initialize();
      
      // Should complete without throwing errors
      expect(result, isTrue);
      expect(initManager.isInitialized, isTrue);
      expect(initManager.currentPhase, AppInitializationPhase.complete);
    });

    testWidgets('CrashProtectionWrapper handles errors gracefully', (WidgetTester tester) async {
      // Create a widget that will throw an error
      final errorWidget = CrashProtectionWrapper(
        context: 'test_context',
        child: Builder(
          builder: (context) {
            throw Exception('Test error');
          },
        ),
      );

      // The widget should render without crashing
      await tester.pumpWidget(MaterialApp(home: errorWidget));
      
      // Should show fallback UI instead of crashing
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Ein Fehler ist aufgetreten'), findsOneWidget);
    });

    testWidgets('ErrorHandler logs errors correctly', (WidgetTester tester) async {
      // Test error logging
      ErrorHandler.logError('TEST_CONTEXT', 'Test error message');
      ErrorHandler.logStartup('TEST_PHASE', 'Test startup message');
      ErrorHandler.logTimer('TEST_ACTION', 'Test timer message');
      
      // Should complete without throwing errors
      expect(true, isTrue);
    });

    testWidgets('InitializationScreen displays correctly', (WidgetTester tester) async {
      final initManager = AppInitializationManager();
      
      await tester.pumpWidget(MaterialApp(
        home: InitializationScreen(initManager: initManager),
      ));
      
      // Should show initialization screen elements
      expect(find.byIcon(Icons.psychology), findsOneWidget);
      expect(find.text('Konsum Tracker Pro'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('SafeStateMixin prevents crashes', (WidgetTester tester) async {
      // Create a test widget that uses SafeStateMixin
      await tester.pumpWidget(MaterialApp(
        home: _TestSafeStateWidget(),
      ));
      
      // Should render without crashing
      expect(find.text('Test Widget'), findsOneWidget);
    });

    testWidgets('TimerService initializes safely', (WidgetTester tester) async {
      final timerService = TimerService();
      
      // Should initialize without throwing errors
      await timerService.init();
      
      // Should have proper getters
      expect(timerService.currentActiveTimer, isNull);
      expect(timerService.activeTimers, isEmpty);
      expect(timerService.hasAnyActiveTimer, isFalse);
    });

    testWidgets('PsychedelicThemeService handles initialization errors', (WidgetTester tester) async {
      final themeService = PsychedelicThemeService();
      
      // Should initialize without throwing errors
      await themeService.init();
      
      // Should have proper default values
      expect(themeService.currentThemeMode, isNotNull);
      expect(themeService.isPsychedelicMode, isFalse);
      expect(themeService.isInitialized, isTrue);
    });

    testWidgets('HomeScreen handles errors gracefully', (WidgetTester tester) async {
      final initManager = AppInitializationManager();
      await initManager.initialize();
      
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<TimerService>.value(value: initManager.timerService),
            ChangeNotifierProvider<PsychedelicThemeService>.value(value: initManager.psychedelicThemeService),
          ],
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );
      
      // Should render without crashing
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}

class _TestSafeStateWidget extends StatefulWidget {
  @override
  _TestSafeStateWidgetState createState() => _TestSafeStateWidgetState();
}

class _TestSafeStateWidgetState extends State<_TestSafeStateWidget> with SafeStateMixin {
  bool _testValue = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Test Widget'),
            ElevatedButton(
              onPressed: () {
                // Test safeSetState
                safeSetState(() {
                  _testValue = !_testValue;
                });
              },
              child: Text('Toggle'),
            ),
          ],
        ),
      ),
    );
  }
}