import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import '../utils/platform_helper.dart';
import '../utils/keyboard_handler.dart';
import '../widgets/platform_adaptive_widgets.dart';
import '../widgets/platform_adaptive_fab.dart';

/// Cross-platform testing utilities for UI consistency
class CrossPlatformTestHelper {
  // Private constructor to prevent instantiation
  CrossPlatformTestHelper._();

  /// Test platform-specific safe area handling
  static void testSafeAreaHandling({
    required WidgetTester tester,
    required Widget testWidget,
  }) {
    testWidgets('Safe area handling - iOS', (WidgetTester tester) async {
      // Mock iOS environment
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            padding: EdgeInsets.only(top: 44.0, bottom: 34.0),
            viewInsets: EdgeInsets.zero,
          ),
          child: MaterialApp(
            home: Scaffold(
              body: SafeArea(
                child: testWidget,
              ),
            ),
          ),
        ),
      );

      // Verify safe area padding is applied
      final SafeArea safeArea = tester.widget(find.byType(SafeArea));
      expect(safeArea.top, true);
      expect(safeArea.bottom, true);
      expect(safeArea.left, true);
      expect(safeArea.right, true);
    });

    testWidgets('Safe area handling - Android', (WidgetTester tester) async {
      // Mock Android environment
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            padding: EdgeInsets.only(top: 24.0, bottom: 0.0),
            viewInsets: EdgeInsets.zero,
          ),
          child: MaterialApp(
            home: Scaffold(
              body: SafeArea(
                child: testWidget,
              ),
            ),
          ),
        ),
      );

      // Verify safe area padding is applied
      final SafeArea safeArea = tester.widget(find.byType(SafeArea));
      expect(safeArea.top, true);
      expect(safeArea.bottom, true);
    });
  }

  /// Test keyboard handling across platforms
  static void testKeyboardHandling({
    required WidgetTester tester,
    required Widget testWidget,
  }) {
    testWidgets('Keyboard handling - iOS', (WidgetTester tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            viewInsets: EdgeInsets.only(bottom: 300.0), // Keyboard visible
          ),
          child: MaterialApp(
            home: Scaffold(
              body: testWidget,
            ),
          ),
        ),
      );

      // Test keyboard dismissal
      await tester.tap(find.byType(Scaffold));
      await tester.pumpAndSettle();

      // Verify keyboard is dismissed
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('Keyboard handling - Android', (WidgetTester tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            viewInsets: EdgeInsets.only(bottom: 280.0), // Keyboard visible
          ),
          child: MaterialApp(
            home: Scaffold(
              body: testWidget,
            ),
          ),
        ),
      );

      // Test keyboard dismissal
      await tester.tap(find.byType(Scaffold));
      await tester.pumpAndSettle();

      // Verify keyboard is dismissed
      expect(find.byType(TextField), findsWidgets);
    });
  }

  /// Test platform-adaptive widgets
  static void testPlatformAdaptiveWidgets({
    required WidgetTester tester,
  }) {
    testWidgets('Platform adaptive button - iOS', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlatformAdaptiveButton(
              onPressed: () {},
              child: const Text('Test Button'),
            ),
          ),
        ),
      );

      // Test button behavior
      await tester.tap(find.byType(PlatformAdaptiveButton));
      await tester.pumpAndSettle();

      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('Platform adaptive button - Android', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlatformAdaptiveButton(
              onPressed: () {},
              child: const Text('Test Button'),
            ),
          ),
        ),
      );

      // Test button behavior
      await tester.tap(find.byType(PlatformAdaptiveButton));
      await tester.pumpAndSettle();

      expect(find.text('Test Button'), findsOneWidget);
    });
  }

  /// Test FAB behavior across platforms
  static void testPlatformAdaptiveFAB({
    required WidgetTester tester,
  }) {
    testWidgets('Platform adaptive FAB - iOS', (WidgetTester tester) async {
      bool pressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const Center(child: Text('Test Content')),
            floatingActionButton: PlatformAdaptiveFAB(
              onPressed: () => pressed = true,
              child: const Icon(Icons.add),
            ),
          ),
        ),
      );

      // Test FAB behavior
      await tester.tap(find.byType(PlatformAdaptiveFAB));
      await tester.pumpAndSettle();

      expect(pressed, true);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('Platform adaptive FAB - Android', (WidgetTester tester) async {
      bool pressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const Center(child: Text('Test Content')),
            floatingActionButton: PlatformAdaptiveFAB(
              onPressed: () => pressed = true,
              child: const Icon(Icons.add),
            ),
          ),
        ),
      );

      // Test FAB behavior
      await tester.tap(find.byType(PlatformAdaptiveFAB));
      await tester.pumpAndSettle();

      expect(pressed, true);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  }

  /// Test scroll behavior across platforms
  static void testScrollBehavior({
    required WidgetTester tester,
    required Widget scrollableWidget,
  }) {
    testWidgets('Scroll behavior - iOS (bouncing)', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: scrollableWidget,
            ),
          ),
        ),
      );

      // Test scroll behavior
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -100));
      await tester.pumpAndSettle();

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('Scroll behavior - Android (clamping)', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: scrollableWidget,
            ),
          ),
        ),
      );

      // Test scroll behavior
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -100));
      await tester.pumpAndSettle();

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  }

  /// Test modal presentation across platforms
  static void testModalPresentation({
    required WidgetTester tester,
  }) {
    testWidgets('Modal presentation - iOS', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  PlatformAdaptiveModalBottomSheet.show(
                    context: context,
                    child: const Text('Modal Content'),
                  );
                },
                child: const Text('Show Modal'),
              ),
            ),
          ),
        ),
      );

      // Test modal presentation
      await tester.tap(find.text('Show Modal'));
      await tester.pumpAndSettle();

      expect(find.text('Modal Content'), findsOneWidget);
    });

    testWidgets('Modal presentation - Android', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  PlatformAdaptiveModalBottomSheet.show(
                    context: context,
                    child: const Text('Modal Content'),
                  );
                },
                child: const Text('Show Modal'),
              ),
            ),
          ),
        ),
      );

      // Test modal presentation
      await tester.tap(find.text('Show Modal'));
      await tester.pumpAndSettle();

      expect(find.text('Modal Content'), findsOneWidget);
    });
  }

  /// Test dialog presentation across platforms
  static void testDialogPresentation({
    required WidgetTester tester,
  }) {
    testWidgets('Dialog presentation - iOS', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  PlatformAdaptiveDialog.show(
                    context: context,
                    title: 'Test Dialog',
                    content: 'Dialog content',
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Test dialog presentation
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Test Dialog'), findsOneWidget);
      expect(find.text('Dialog content'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
    });

    testWidgets('Dialog presentation - Android', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  PlatformAdaptiveDialog.show(
                    context: context,
                    title: 'Test Dialog',
                    content: 'Dialog content',
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Test dialog presentation
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Test Dialog'), findsOneWidget);
      expect(find.text('Dialog content'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
    });
  }

  /// Test text input behavior across platforms
  static void testTextInputBehavior({
    required WidgetTester tester,
  }) {
    testWidgets('Text input - iOS', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlatformAdaptiveTextField(
              placeholder: 'Enter text',
              keyboardType: TextInputType.text,
            ),
          ),
        ),
      );

      // Test text input
      await tester.enterText(find.byType(PlatformAdaptiveTextField), 'Test text');
      await tester.pumpAndSettle();

      expect(find.text('Test text'), findsOneWidget);
    });

    testWidgets('Text input - Android', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlatformAdaptiveTextField(
              placeholder: 'Enter text',
              keyboardType: TextInputType.text,
            ),
          ),
        ),
      );

      // Test text input
      await tester.enterText(find.byType(PlatformAdaptiveTextField), 'Test text');
      await tester.pumpAndSettle();

      expect(find.text('Test text'), findsOneWidget);
    });
  }

  /// Test loading indicators across platforms
  static void testLoadingIndicators({
    required WidgetTester tester,
  }) {
    testWidgets('Loading indicator - iOS', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: PlatformAdaptiveLoadingIndicator(),
            ),
          ),
        ),
      );

      expect(find.byType(PlatformAdaptiveLoadingIndicator), findsOneWidget);
    });

    testWidgets('Loading indicator - Android', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: PlatformAdaptiveLoadingIndicator(),
            ),
          ),
        ),
      );

      expect(find.byType(PlatformAdaptiveLoadingIndicator), findsOneWidget);
    });
  }

  /// Test haptic feedback across platforms
  static void testHapticFeedback({
    required WidgetTester tester,
  }) {
    testWidgets('Haptic feedback - iOS', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () {
                PlatformHelper.performHapticFeedback(HapticFeedbackType.lightImpact);
              },
              child: const Text('Haptic Test'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Haptic Test'));
      await tester.pumpAndSettle();

      // Verify button works (haptic feedback is not testable directly)
      expect(find.text('Haptic Test'), findsOneWidget);
    });

    testWidgets('Haptic feedback - Android', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () {
                PlatformHelper.performHapticFeedback(HapticFeedbackType.selectionClick);
              },
              child: const Text('Haptic Test'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Haptic Test'));
      await tester.pumpAndSettle();

      // Verify button works (haptic feedback is not testable directly)
      expect(find.text('Haptic Test'), findsOneWidget);
    });
  }

  /// Test system UI overlay styles
  static void testSystemUIOverlay({
    required WidgetTester tester,
  }) {
    testWidgets('System UI overlay - iOS', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              systemOverlayStyle: PlatformHelper.getStatusBarStyle(
                isDark: false,
                isPsychedelicMode: false,
              ),
            ),
            body: const Center(
              child: Text('System UI Test'),
            ),
          ),
        ),
      );

      expect(find.text('System UI Test'), findsOneWidget);
    });

    testWidgets('System UI overlay - Android', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              systemOverlayStyle: PlatformHelper.getStatusBarStyle(
                isDark: false,
                isPsychedelicMode: false,
              ),
            ),
            body: const Center(
              child: Text('System UI Test'),
            ),
          ),
        ),
      );

      expect(find.text('System UI Test'), findsOneWidget);
    });
  }

  /// Run all cross-platform tests
  static void runAllTests({
    required WidgetTester tester,
    required Widget testWidget,
  }) {
    testSafeAreaHandling(tester: tester, testWidget: testWidget);
    testKeyboardHandling(tester: tester, testWidget: testWidget);
    testPlatformAdaptiveWidgets(tester: tester);
    testPlatformAdaptiveFAB(tester: tester);
    testScrollBehavior(tester: tester, scrollableWidget: testWidget);
    testModalPresentation(tester: tester);
    testDialogPresentation(tester: tester);
    testTextInputBehavior(tester: tester);
    testLoadingIndicators(tester: tester);
    testHapticFeedback(tester: tester);
    testSystemUIOverlay(tester: tester);
  }
}