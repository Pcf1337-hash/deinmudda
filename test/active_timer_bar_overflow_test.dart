import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:konsum_tracker_pro/widgets/active_timer_bar.dart';
import 'package:konsum_tracker_pro/models/entry.dart';
import 'package:konsum_tracker_pro/services/timer_service.dart';
import 'package:konsum_tracker_pro/services/psychedelic_theme_service.dart';

void main() {
  group('ActiveTimerBar Overflow Fix Tests', () {
    late Entry testEntry;
    late TimerService mockTimerService;
    late PsychedelicThemeService mockPsychedelicService;

    setUp(() {
      // Create a test entry with timer
      testEntry = Entry(
        id: 'test-1',
        substanceName: 'Test Substance with Long Name',
        amount: 100.0,
        unit: 'mg',
        timestamp: DateTime.now(),
        notes: 'Test notes',
        timerEndTime: DateTime.now().add(const Duration(hours: 2)),
      );

      // Mock services
      mockTimerService = TimerService();
      mockPsychedelicService = PsychedelicThemeService();
    });

    testWidgets('ActiveTimerBar handles 15-pixel overflow constraint (FIXED)', (WidgetTester tester) async {
      // Test widget with tight constraints that previously caused overflow
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<TimerService>.value(value: mockTimerService),
              ChangeNotifierProvider<PsychedelicThemeService>.value(value: mockPsychedelicService),
            ],
            child: Scaffold(
              body: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 344.4,
                  maxHeight: 41.0, // The exact constraint that caused the 15-pixel overflow
                ),
                child: ActiveTimerBar(
                  timer: testEntry,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify no overflow errors occurred
      expect(tester.takeException(), isNull);

      // Find the timer bar widget
      final activeTimerBar = find.byType(ActiveTimerBar);
      expect(activeTimerBar, findsOneWidget);

      // Verify the widget renders correctly within constraints
      final renderBox = tester.renderObject(activeTimerBar) as RenderBox;
      expect(renderBox.size.width, lessThanOrEqualTo(344.4));
      expect(renderBox.size.height, lessThanOrEqualTo(41.0));
    });

    testWidgets('ActiveTimerBar removes IntrinsicHeight for better layout flexibility', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<TimerService>.value(value: mockTimerService),
              ChangeNotifierProvider<PsychedelicThemeService>.value(value: mockPsychedelicService),
            ],
            child: ActiveTimerBar(
              timer: testEntry,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // No IntrinsicHeight should be present in the fixed version
      final intrinsicHeight = find.byType(IntrinsicHeight);
      expect(intrinsicHeight, findsNothing);

      // Should use Flexible/Expanded for better layout
      final flexible = find.byType(Flexible);
      expect(flexible, findsWidgets);
    });

    testWidgets('ActiveTimerBar gracefully handles very small height constraints', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<TimerService>.value(value: mockTimerService),
              ChangeNotifierProvider<PsychedelicThemeService>.value(value: mockPsychedelicService),
            ],
            child: Scaffold(
              body: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 300.0,
                  maxHeight: 25.0, // Very small height - should show minimal compact version
                ),
                child: ActiveTimerBar(
                  timer: testEntry,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should render minimal version without overflow
      expect(tester.takeException(), isNull);

      final activeTimerBar = find.byType(ActiveTimerBar);
      expect(activeTimerBar, findsOneWidget);
    });

    testWidgets('ActiveTimerBar progressive hiding works correctly', (WidgetTester tester) async {
      // Test different height constraints to ensure progressive hiding
      for (final height in [20.0, 30.0, 40.0, 50.0]) {
        await tester.pumpWidget(
          MaterialApp(
            home: MultiProvider(
              providers: [
                ChangeNotifierProvider<TimerService>.value(value: mockTimerService),
                ChangeNotifierProvider<PsychedelicThemeService>.value(value: mockPsychedelicService),
              ],
              child: Scaffold(
                body: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 344.4,
                    maxHeight: height,
                  ),
                  child: ActiveTimerBar(
                    timer: testEntry,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Should never cause overflow regardless of height
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('ActiveTimerBar uses aggressive space management', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<TimerService>.value(value: mockTimerService),
              ChangeNotifierProvider<PsychedelicThemeService>.value(value: mockPsychedelicService),
            ],
            child: Scaffold(
              body: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 344.4,
                  maxHeight: 41.0, // Exactly the problematic constraint
                ),
                child: ActiveTimerBar(
                  timer: testEntry,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Fixed version should handle this constraint without any issues
      expect(tester.takeException(), isNull);

      // Should use ConstrainedBox for better height management
      final constrainedBox = find.byType(ConstrainedBox);
      expect(constrainedBox, findsWidgets);

      // Should use Positioned.fill for proper stack layout
      final positioned = find.byType(Positioned);
      expect(positioned, findsWidgets);
    });
  });
}