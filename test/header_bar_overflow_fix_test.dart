import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'lib/widgets/header_bar.dart';
import 'lib/services/psychedelic_theme_service.dart';

void main() {
  group('HeaderBar Overflow Fix Tests', () {
    testWidgets('HeaderBar should handle constrained height without overflow', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider(
              create: (_) => PsychedelicThemeService(),
              child: SizedBox(
                height: 55.6, // The exact height constraint from the error
                width: 241.0, // The exact width constraint from the error
                child: const HeaderBar(
                  title: 'Very Long Title That Could Cause Overflow Issues',
                  subtitle: 'This is a subtitle that might also cause problems',
                  showBackButton: true,
                  showLightningIcon: true,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should not have overflow errors despite height constraint
      expect(tester.takeException(), isNull);
      
      // Should find the header content
      expect(find.text('Very Long Title That Could Cause Overflow Issues'), findsOneWidget);
    });

    testWidgets('HeaderBar should use Flexible instead of Expanded in constrained spaces', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider(
              create: (_) => PsychedelicThemeService(),
              child: Container(
                constraints: const BoxConstraints(
                  maxHeight: 60, // Very constrained height
                  maxWidth: 200, // Constrained width
                ),
                child: const HeaderBar(
                  title: 'Test Title',
                  subtitle: 'Test Subtitle', 
                  showBackButton: true,
                  showLightningIcon: true,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should not crash or have overflow errors
      expect(tester.takeException(), isNull);
      
      // Should find Flexible widget in the widget tree
      expect(find.byType(Flexible), findsWidgets);
      
      // Should find the title (might be truncated)
      expect(find.text('Test Title'), findsOneWidget);
    });

    testWidgets('HeaderBar should handle no subtitle without issues', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider(
              create: (_) => PsychedelicThemeService(),
              child: Container(
                constraints: const BoxConstraints(
                  maxHeight: 55.6,
                  maxWidth: 241.0,
                ),
                child: const HeaderBar(
                  title: 'Simple Title',
                  showBackButton: true,
                  showLightningIcon: true,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should not have any errors
      expect(tester.takeException(), isNull);
      
      // Should find the title
      expect(find.text('Simple Title'), findsOneWidget);
    });
  });
}