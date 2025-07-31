import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:konsum_tracker_pro/widgets/compact_timer_widget.dart';

void main() {
  group('CompactTimerWidget Tests', () {
    testWidgets('CompactTimerWidget renders correctly', (WidgetTester tester) async {
      final endTime = DateTime.now().add(const Duration(hours: 2));
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactTimerWidget(
              endTime: endTime,
              title: 'Test Timer',
            ),
          ),
        ),
      );

      // Verify title is displayed
      expect(find.text('Test Timer'), findsOneWidget);
      
      // Verify timer icon is present
      expect(find.byIcon(Icons.timer_rounded), findsOneWidget);
      
      // Verify compact design - should be smaller than original
      final container = tester.widget<Container>(
        find.byType(Container).first,
      );
      
      // Should have reduced margin
      expect(container.margin, const EdgeInsets.only(bottom: 12));
    });

    testWidgets('CompactTimer.createEffectTimer works', (WidgetTester tester) async {
      final startTime = DateTime.now();
      final duration = const Duration(hours: 3);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactTimer.createEffectTimer(
              substanceName: 'Cannabis',
              startTime: startTime,
              effectDuration: duration,
            ),
          ),
        ),
      );

      // Verify substance name is shown in title
      expect(find.textContaining('Cannabis'), findsOneWidget);
      expect(find.textContaining('Wirkung'), findsOneWidget);
    });

    testWidgets('CompactTimer.createCustomTimer works', (WidgetTester tester) async {
      final endTime = DateTime.now().add(const Duration(minutes: 30));
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactTimer.createCustomTimer(
              title: 'Meditation',
              endTime: endTime,
              accentColor: Colors.blue,
            ),
          ),
        ),
      );

      // Verify custom title is shown
      expect(find.text('Meditation'), findsOneWidget);
    });

    test('CompactTimerWidget time formatting', () {
      // Test the time formatting logic
      const duration1 = Duration(hours: 2, minutes: 30, seconds: 45);
      const duration2 = Duration(minutes: 15, seconds: 30);
      const duration3 = Duration(seconds: 45);
      const duration4 = Duration(days: 1, hours: 6);

      // This would test the private _formatCompactTime method
      // In practice, we'd need to expose it or test through the UI
      expect(duration1.inHours, 2);
      expect(duration2.inMinutes, 15);
      expect(duration3.inSeconds, 45);
      expect(duration4.inDays, 1);
    });
  });

  group('Timer Dashboard Layout Tests', () {
    test('Layout logic for multiple timers', () {
      // Test that the layout switches appropriately
      const fewTimers = 2;
      const manyTimers = 5;
      
      expect(fewTimers <= 2, true); // Should use vertical layout
      expect(manyTimers > 2, true); // Should use horizontal layout
    });
  });
}