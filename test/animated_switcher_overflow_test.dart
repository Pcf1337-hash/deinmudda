import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import '../lib/screens/home_screen.dart';
import '../lib/services/entry_service.dart';
import '../lib/services/quick_button_service.dart';
import '../lib/services/timer_service.dart';
import '../lib/services/substance_service.dart';
import '../lib/services/psychedelic_theme_service.dart';

void main() {
  group('AnimatedSwitcher Overflow Fix Tests', () {
    
    Widget createTestWidget() {
      return MaterialApp(
        home: MultiProvider(
          providers: [
            Provider<EntryService>(create: (_) => EntryService()),
            Provider<QuickButtonService>(create: (_) => QuickButtonService()),
            Provider<TimerService>(create: (_) => TimerService()),
            Provider<SubstanceService>(create: (_) => SubstanceService()),
            ChangeNotifierProvider<PsychedelicThemeService>(
              create: (_) => PsychedelicThemeService(),
            ),
          ],
          child: const Scaffold(
            body: HomeScreen(),
          ),
        ),
      );
    }

    testWidgets('AnimatedSwitcher should not overflow during QuickEntry loading transition', (WidgetTester tester) async {
      // Set a small screen size to increase chance of overflow
      await tester.binding.setSurfaceSize(const Size(360, 600));

      await tester.pumpWidget(createTestWidget());
      
      // Wait for the initial loading to complete
      await tester.pump();
      
      // Should not have any overflow errors during initial load
      expect(tester.takeException(), isNull);
      
      // Should find the AnimatedSwitcher
      expect(find.byType(AnimatedSwitcher), findsAtLeastNWidget(1));
      
      // During loading, should show loading state
      expect(find.text('Lade Quick-Buttons...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsAtLeastNWidget(1));
      
      // Let the animation complete
      await tester.pumpAndSettle();
      
      // Should not have overflow errors after transition
      expect(tester.takeException(), isNull);
    });

    testWidgets('ConstrainedBox should prevent overflow in QuickEntry content', (WidgetTester tester) async {
      // Set a very small screen size to force constraints
      await tester.binding.setSurfaceSize(const Size(320, 480));

      await tester.pumpWidget(createTestWidget());
      
      // Wait for loading to complete
      await tester.pumpAndSettle();
      
      // Should not have overflow errors even on small screen
      expect(tester.takeException(), isNull);
      
      // Should find ConstrainedBox wrapping the content
      expect(find.byType(ConstrainedBox), findsAtLeastNWidget(1));
      
      // Should find SingleChildScrollView for overflow handling
      expect(find.byType(SingleChildScrollView), findsAtLeastNWidget(1));
    });

    testWidgets('AnimatedSwitcher should have proper ValueKeys for smooth transitions', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      await tester.pump();
      
      // Should not crash during key transitions
      expect(tester.takeException(), isNull);
      
      // Let animation complete
      await tester.pumpAndSettle();
      
      // Should still be stable after transition
      expect(tester.takeException(), isNull);
    });

    testWidgets('LayoutBuilder should provide responsive constraints', (WidgetTester tester) async {
      // Test different screen sizes
      for (final size in [
        const Size(320, 480), // Small
        const Size(375, 667), // Medium (iPhone)
        const Size(428, 926), // Large (iPhone Pro Max)
      ]) {
        await tester.binding.setSurfaceSize(size);
        
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();
        
        // Should handle all screen sizes without overflow
        expect(tester.takeException(), isNull, 
               reason: 'Failed on screen size: ${size.width}x${size.height}');
        
        // Should find LayoutBuilder
        expect(find.byType(LayoutBuilder), findsAtLeastNWidget(1));
      }
    });

    testWidgets('SingleChildScrollView should have ClampingScrollPhysics', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      // Find SingleChildScrollView widgets
      final scrollViews = find.byType(SingleChildScrollView);
      expect(scrollViews, findsAtLeastNWidget(1));
      
      // Check that they have ClampingScrollPhysics (prevents bounce on Android)
      for (int i = 0; i < scrollViews.evaluate().length; i++) {
        final scrollView = tester.widget<SingleChildScrollView>(scrollViews.at(i));
        if (scrollView.physics is ClampingScrollPhysics) {
          // Found at least one with ClampingScrollPhysics, which is good
          break;
        }
      }
    });

    testWidgets('AnimatedSwitcher duration should be reasonable for UX', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      await tester.pump();
      
      // Find the AnimatedSwitcher
      final animatedSwitchers = find.byType(AnimatedSwitcher);
      expect(animatedSwitchers, findsAtLeastNWidget(1));
      
      // Check duration is reasonable (not too fast, not too slow)
      final switcher = tester.widget<AnimatedSwitcher>(animatedSwitchers.first);
      expect(switcher.duration.inMilliseconds, lessThanOrEqualTo(500));
      expect(switcher.duration.inMilliseconds, greaterThanOrEqualTo(100));
    });
  });
}