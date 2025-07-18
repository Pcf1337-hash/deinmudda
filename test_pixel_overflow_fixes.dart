import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'lib/widgets/charts/pie_chart_widget.dart';
import 'lib/screens/main_navigation.dart';
import 'lib/widgets/layout_error_boundary.dart';

void main() {
  group('Pixel Overflow Fixes Tests', () {
    testWidgets('PieChartWidget legend handles text overflow', (WidgetTester tester) async {
      // Create test data with very long labels to trigger potential overflow
      final testData = [
        {'label': 'Very Long Substance Name That Could Cause Overflow', 'value': 45.5},
        {'label': 'Another Long Name Here', 'value': 30.2},
        {'label': 'Short', 'value': 24.3},
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300, // Constrained width to trigger overflow
              child: PieChartWidget(
                data: testData,
                title: 'Test Chart',
                size: 150,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should not have overflow errors
      expect(tester.takeException(), isNull);
      
      // Should find Flexible widgets for percentage text
      expect(find.byType(Flexible), findsWidgets);
      
      // Should find overflow handling
      expect(find.text('45.5%'), findsOneWidget);
    });

    testWidgets('MainNavigation handles narrow screen widths', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MainNavigation(),
        ),
      );

      // Test with very narrow screen
      await tester.binding.setSurfaceSize(const Size(320, 600));
      await tester.pumpAndSettle();

      // Should not have overflow errors
      expect(tester.takeException(), isNull);
      
      // Should find navigation items
      expect(find.byType(GestureDetector), findsWidgets);
      
      // Should find FittedBox for responsive text
      expect(find.byType(FittedBox), findsWidgets);
    });

    testWidgets('LayoutErrorBoundary handles errors gracefully', (WidgetTester tester) async {
      // Create a widget that will throw an error
      Widget errorWidget = LayoutErrorBoundary(
        debugLabel: 'Test Error',
        child: Builder(
          builder: (context) {
            throw FlutterError('Test layout error');
          },
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: errorWidget),
        ),
      );

      await tester.pumpAndSettle();

      // Should show error fallback instead of crashing
      expect(find.byIcon(Icons.warning_rounded), findsOneWidget);
      expect(find.text('Layout-Fehler aufgetreten'), findsOneWidget);
    });

    testWidgets('Legend Row handles very long percentage text', (WidgetTester tester) async {
      // Create extreme test case
      final testData = [
        {'label': 'Test', 'value': 99.999999},
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 100, // Very narrow to force overflow conditions
              child: PieChartWidget(
                data: testData,
                title: 'Narrow Test',
                size: 80,
                showLegend: true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should handle extremely narrow layout without overflow
      expect(tester.takeException(), isNull);
    });

    testWidgets('Navigation items handle long labels', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MainNavigation(),
        ),
      );

      // Test with narrow screen to force text scaling
      await tester.binding.setSurfaceSize(const Size(280, 600));
      await tester.pumpAndSettle();

      // Should handle narrow layout
      expect(tester.takeException(), isNull);
      
      // Navigation items should be present
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Dosisrechner'), findsOneWidget);
      expect(find.text('Statistiken'), findsOneWidget);
      expect(find.text('Menü'), findsOneWidget);
    });
  });
}