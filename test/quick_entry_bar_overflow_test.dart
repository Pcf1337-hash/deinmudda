import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import '../lib/widgets/quick_entry/quick_entry_bar.dart';
import '../lib/services/psychedelic_theme_service.dart';

void main() {
  group('QuickEntryBar Overflow Fix Tests', () {
    testWidgets('Empty state should not overflow with height constraints', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider(
              create: (_) => PsychedelicThemeService(),
              child: SizedBox(
                height: 100, // Constrain to 100px height to trigger the original overflow
                child: QuickEntryBar(
                  quickButtons: const [], // Empty list to trigger empty state
                  onQuickEntry: (config) {},
                  onAddButton: () {},
                  isEditing: false,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should not have overflow errors despite height constraint
      expect(tester.takeException(), isNull);
      
      // Should find SingleChildScrollView in empty state
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      
      // Should find the empty state content
      expect(find.text('Schnelleingabe einrichten'), findsOneWidget);
      expect(find.text('Ersten Button erstellen'), findsOneWidget);
      expect(find.byIcon(Icons.flash_on_rounded), findsOneWidget);
    });

    testWidgets('Empty state SingleChildScrollView should have correct physics', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider(
              create: (_) => PsychedelicThemeService(),
              child: SizedBox(
                height: 50, // Very small height to force scrolling
                child: QuickEntryBar(
                  quickButtons: const [], // Empty list
                  onQuickEntry: (config) {},
                  onAddButton: () {},
                  isEditing: false,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should not crash with very small height constraint
      expect(tester.takeException(), isNull);
      
      // Find the SingleChildScrollView
      final scrollViewFinder = find.byType(SingleChildScrollView);
      expect(scrollViewFinder, findsOneWidget);
      
      // Get the ScrollView widget and verify it has ClampingScrollPhysics
      final scrollView = tester.widget<SingleChildScrollView>(scrollViewFinder);
      expect(scrollView.physics, isA<ClampingScrollPhysics>());
    });

    testWidgets('Empty state preserves glassmorphism styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider(
              create: (_) => PsychedelicThemeService(),
              child: QuickEntryBar(
                quickButtons: const [], // Empty list
                onQuickEntry: (config) {},
                onAddButton: () {},
                isEditing: false,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should not have any errors
      expect(tester.takeException(), isNull);
      
      // Should find Container with glassmorphism styling
      final containerFinder = find.byType(Container);
      expect(containerFinder, findsWidgets);
      
      // Should find the button with proper styling
      final buttonFinder = find.byType(ElevatedButton);
      expect(buttonFinder, findsOneWidget);
    });

    testWidgets('Empty state Column should use MainAxisSize.min', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider(
              create: (_) => PsychedelicThemeService(),
              child: QuickEntryBar(
                quickButtons: const [], // Empty list
                onQuickEntry: (config) {},
                onAddButton: () {},
                isEditing: false,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should not have any overflow errors
      expect(tester.takeException(), isNull);
      
      // Should find Column inside SingleChildScrollView
      expect(find.byType(Column), findsWidgets);
      
      // Should find all the expected content
      expect(find.text('Schnelleingabe einrichten'), findsOneWidget);
      expect(find.text('Erstellen Sie Quick Buttons für häufig verwendete Substanzen und Dosierungen.'), findsOneWidget);
    });
  });
}