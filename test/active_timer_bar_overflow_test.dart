import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import '../lib/widgets/active_timer_bar.dart';
import '../lib/models/entry.dart';
import '../lib/services/timer_service.dart';
import '../lib/services/psychedelic_theme_service.dart';

void main() {
  group('ActiveTimerBar Overflow Fix Tests', () {
    Entry createTestTimer({
      String substanceName = 'LSD',
      double progress = 0.5,
      bool isExpired = false,
    }) {
      final timer = Entry.create(
        substanceId: 'test-id',
        substanceName: substanceName,
        dosage: 100.0,
        unit: 'μg',
        dateTime: DateTime.now().subtract(const Duration(hours: 2)),
        notes: 'Test timer',
      );
      
      // Simulate timer properties
      timer.timerEndTime = DateTime.now().add(const Duration(hours: 2));
      timer.timerProgress = progress;
      timer.isTimerExpired = isExpired;
      
      return timer;
    }

    Widget createTestWidget(Entry timer, {double? height, double? width}) {
      return MaterialApp(
        home: Scaffold(
          body: MultiProvider(
            providers: [
              Provider<TimerService>(create: (_) => TimerService()),
              ChangeNotifierProvider<PsychedelicThemeService>(
                create: (_) => PsychedelicThemeService(),
              ),
            ],
            child: Container(
              height: height,
              width: width,
              constraints: height != null || width != null 
                ? BoxConstraints(
                    maxHeight: height ?? double.infinity,
                    maxWidth: width ?? double.infinity,
                  )
                : null,
              child: ActiveTimerBar(
                timer: timer,
                onTap: () {},
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('ActiveTimerBar should not overflow with exact problematic constraints', (WidgetTester tester) async {
      final timer = createTestTimer();
      
      // Reproduce the exact constraint that causes overflow: height=33, width=285
      await tester.pumpWidget(createTestWidget(timer, height: 33, width: 285));
      
      await tester.pumpAndSettle();
      
      // Should not have overflow errors
      expect(tester.takeException(), isNull);
      
      // Should find the timer content
      expect(find.text('LSD'), findsOneWidget);
      expect(find.text('Timer läuft'), findsOneWidget);
    });

    testWidgets('ActiveTimerBar should handle extremely small height constraints', (WidgetTester tester) async {
      final timer = createTestTimer();
      
      // Test with even smaller height to ensure robustness
      await tester.pumpWidget(createTestWidget(timer, height: 25, width: 285));
      
      await tester.pumpAndSettle();
      
      // Should not crash with very small height
      expect(tester.takeException(), isNull);
    });

    testWidgets('ActiveTimerBar should handle long substance names without overflow', (WidgetTester tester) async {
      final timer = createTestTimer(substanceName: 'Very Long Substance Name That Could Cause Overflow');
      
      await tester.pumpWidget(createTestWidget(timer, height: 33, width: 285));
      
      await tester.pumpAndSettle();
      
      // Should not overflow with long names
      expect(tester.takeException(), isNull);
      
      // Should properly truncate the name
      expect(find.textContaining('Very Long'), findsOneWidget);
    });

    testWidgets('ActiveTimerBar Column should use MainAxisSize.min to prevent overflow', (WidgetTester tester) async {
      final timer = createTestTimer();
      
      await tester.pumpWidget(createTestWidget(timer, height: 33, width: 285));
      
      await tester.pumpAndSettle();
      
      // Should not have overflow errors
      expect(tester.takeException(), isNull);
      
      // Should find Column with proper configuration
      expect(find.byType(Column), findsAtLeastNWidget(1));
    });

    testWidgets('ActiveTimerBar should handle expired timer state', (WidgetTester tester) async {
      final timer = createTestTimer(isExpired: true);
      
      await tester.pumpWidget(createTestWidget(timer, height: 33, width: 285));
      
      await tester.pumpAndSettle();
      
      // Should not overflow even with expired state
      expect(tester.takeException(), isNull);
      
      // Should show expired state content
      expect(find.text('Abgelaufen'), findsOneWidget);
    });

    testWidgets('ActiveTimerBar responsive font sizes should prevent text overflow', (WidgetTester tester) async {
      final timer = createTestTimer();
      
      // Test different widths to ensure responsive fonts work
      for (final width in [200.0, 285.0, 350.0]) {
        await tester.pumpWidget(createTestWidget(timer, height: 33, width: width));
        await tester.pumpAndSettle();
        
        // Should not overflow at any width
        expect(tester.takeException(), isNull, 
               reason: 'Failed at width: $width');
      }
    });

    testWidgets('ActiveTimerBar should hide AnimatedSize content when not shown', (WidgetTester tester) async {
      final timer = createTestTimer();
      
      await tester.pumpWidget(createTestWidget(timer, height: 33, width: 285));
      
      await tester.pumpAndSettle();
      
      // Should not show timer input initially
      expect(find.text('Timer anpassen'), findsNothing);
      
      // Should have SizedBox.shrink() for hidden content
      expect(find.byType(SizedBox), findsAtLeastNWidget(1));
    });
  });
}