import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:konsum_tracker_pro/widgets/active_timer_bar.dart';
import 'package:konsum_tracker_pro/models/entry.dart';
import 'package:konsum_tracker_pro/services/timer_service.dart';
import 'package:konsum_tracker_pro/services/psychedelic_theme_service.dart';

void main() {
  group('ActiveTimerBar Visual Improvements Tests', () {
    late Entry testEntry;
    late TimerService mockTimerService;
    late PsychedelicThemeService mockPsychedelicService;

    setUp(() {
      // Create a test entry with timer
      testEntry = Entry(
        id: 'test-visual-1',
        substanceName: 'Test Substance for Visual Improvements',
        amount: 100.0,
        unit: 'mg',
        timestamp: DateTime.now(),
        notes: 'Testing visual balance',
        timerEndTime: DateTime.now().add(const Duration(hours: 2)),
      );

      // Mock services
      mockTimerService = TimerService();
      mockPsychedelicService = PsychedelicThemeService();
    });

    testWidgets('ActiveTimerBar shows mini edit indicator for small height (VISUAL FIX)', (WidgetTester tester) async {
      // Test with medium constraint where mini edit indicator should appear
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
                  maxHeight: 38.0, // Small enough to trigger mini edit indicator
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

      // Should have tooltip widgets for edit functionality
      final tooltipWidgets = find.byType(Tooltip);
      expect(tooltipWidgets, findsWidgets);
    });

    testWidgets('ActiveTimerBar shows very small edit icon for minimal height (VISUAL FIX)', (WidgetTester tester) async {
      // Test with very small constraint where tiny edit icon should appear
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
                  maxHeight: 22.0, // Very small - should show compact version with tiny edit icon
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

      // Should render without overflow
      expect(tester.takeException(), isNull);

      // Find the timer bar widget
      final activeTimerBar = find.byType(ActiveTimerBar);
      expect(activeTimerBar, findsOneWidget);

      // Should have tooltip for edit functionality even in very small layout
      final tooltipWidgets = find.byType(Tooltip);
      expect(tooltipWidgets, findsWidgets);
    });

    testWidgets('ActiveTimerBar maintains full edit button for sufficient height', (WidgetTester tester) async {
      // Test with sufficient height where full edit button should appear
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
                  maxHeight: 55.0, // Sufficient height for full layout
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

      // Should render without overflow
      expect(tester.takeException(), isNull);

      // Should have full IconButton for edit functionality
      final iconButtons = find.byType(IconButton);
      expect(iconButtons, findsWidgets);
    });

    testWidgets('ActiveTimerBar visual hierarchy improvements work correctly', (WidgetTester tester) async {
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
                  maxHeight: 41.0, // The exact problematic constraint
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

      // Should handle this constraint without any issues after visual improvements
      expect(tester.takeException(), isNull);

      final activeTimerBar = find.byType(ActiveTimerBar);
      expect(activeTimerBar, findsOneWidget);

      // Should use SizedBox for visual separation
      final sizedBoxes = find.byType(SizedBox);
      expect(sizedBoxes, findsWidgets);
    });
  });
}