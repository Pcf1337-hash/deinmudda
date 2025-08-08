// Test for XtcColorPicker widget to verify selectedColor parameter functionality

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:konsum_tracker_pro/widgets/xtc_color_picker.dart';

void main() {
  group('XtcColorPicker Tests', () {
    testWidgets('XtcColorPicker can be created with initialColor only (uncontrolled mode)', (WidgetTester tester) async {
      Color? callbackColor;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: XtcColorPicker(
              initialColor: Colors.red,
              onColorChanged: (color) => callbackColor = color,
            ),
          ),
        ),
      );

      // Verify the widget builds without error
      expect(find.byType(XtcColorPicker), findsOneWidget);
    });

    testWidgets('XtcColorPicker can be created with selectedColor parameter (controlled mode)', (WidgetTester tester) async {
      Color? callbackColor;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: XtcColorPicker(
              initialColor: Colors.red,
              selectedColor: Colors.blue,
              onColorChanged: (color) => callbackColor = color,
            ),
          ),
        ),
      );

      // Verify the widget builds without error  
      expect(find.byType(XtcColorPicker), findsOneWidget);
    });

    testWidgets('XtcColorPicker with custom size parameter', (WidgetTester tester) async {
      const customSize = 80.0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: XtcColorPicker(
              initialColor: Colors.green,
              onColorChanged: (_) {},
              size: customSize,
            ),
          ),
        ),
      );

      // Verify the widget builds without error
      expect(find.byType(XtcColorPicker), findsOneWidget);
    });

    testWidgets('XtcColorPicker opens color selection dialog', (WidgetTester tester) async {
      Color? callbackColor;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: XtcColorPicker(
              initialColor: Colors.red,
              onColorChanged: (color) => callbackColor = color,
            ),
          ),
        ),
      );

      // Tap to open color picker dialog
      await tester.tap(find.byType(XtcColorPicker));
      await tester.pumpAndSettle();

      // Verify color picker dialog opened
      expect(find.byType(Dialog), findsOneWidget);
      expect(find.text('Farbe wählen'), findsOneWidget);
    });

    // Test demonstrating the fix for the selectedColor parameter issue
    testWidgets('XtcColorPicker supports selectedColor parameter - resolves compilation error', (WidgetTester tester) async {
      final testColor = Colors.purple;
      Color? callbackColor;
      
      // This usage pattern should now work without compilation errors
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: XtcColorPicker(
              initialColor: Colors.red,
              selectedColor: testColor,  // This parameter now exists and should work
              onColorChanged: (color) => callbackColor = color,
            ),
          ),
        ),
      );

      // Verify the widget builds successfully
      expect(find.byType(XtcColorPicker), findsOneWidget);
      
      // The widget should use the selectedColor when provided
      // (In controlled mode, selectedColor takes precedence over initialColor)
    });
  });
}