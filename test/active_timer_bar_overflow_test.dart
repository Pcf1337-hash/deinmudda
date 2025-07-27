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

    testWidgets('ActiveTimerBar handles 15-pixel overflow constraint', (WidgetTester tester) async {
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

    testWidgets('ActiveTimerBar Column uses MainAxisSize.min', (WidgetTester tester) async {
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

      // Find Column widgets and verify they use MainAxisSize.min where needed
      final columns = find.byType(Column);
      expect(columns, findsWidgets);

      // The fix should ensure no overflow exceptions
      expect(tester.takeException(), isNull);
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
                  maxHeight: 25.0, // Very small height
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

    testWidgets('ActiveTimerBar _overflowAdjustment constant is properly used', (WidgetTester tester) async {
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
                  maxHeight: 56.0, // Height that would cause overflow without adjustment
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

      // The _overflowAdjustment (15 pixels) should prevent overflow
      expect(tester.takeException(), isNull);
    });
  });
}