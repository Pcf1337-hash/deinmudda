import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:konsum_tracker_pro/models/xtc_entry.dart';
import 'package:konsum_tracker_pro/widgets/xtc_color_picker.dart';
import 'package:konsum_tracker_pro/widgets/xtc_size_selector.dart';

void main() {
  group('XTC Entry Tests', () {
    test('XtcEntry can be created with all fields', () {
      final entry = XtcEntry.create(
        substanceName: 'Test Pill',
        form: XtcForm.rechteck,
        hasBruchrillen: true,
        content: XtcContent.mdma,
        size: XtcSize.full,
        dosageMg: 120.0,
        color: Colors.pink,
        weightGrams: 0.3,
        dateTime: DateTime.now(),
        notes: 'Test notes',
      );

      expect(entry.substanceName, equals('Test Pill'));
      expect(entry.form, equals(XtcForm.rechteck));
      expect(entry.hasBruchrillen, isTrue);
      expect(entry.content, equals(XtcContent.mdma));
      expect(entry.size, equals(XtcSize.full));
      expect(entry.dosageMg, equals(120.0));
      expect(entry.color, equals(Colors.pink));
      expect(entry.weightGrams, equals(0.3));
      expect(entry.notes, equals('Test notes'));
    });

    test('XtcEntry can be serialized to JSON and back', () {
      final original = XtcEntry.create(
        substanceName: 'Blue Tesla',
        form: XtcForm.stern,
        hasBruchrillen: false,
        content: XtcContent.mdma,
        size: XtcSize.half,
        dosageMg: 80.0,
        color: Colors.blue,
        dateTime: DateTime(2023, 12, 25, 14, 30),
      );

      final json = original.toJson();
      final restored = XtcEntry.fromJson(json);

      expect(restored.substanceName, equals(original.substanceName));
      expect(restored.form, equals(original.form));
      expect(restored.hasBruchrillen, equals(original.hasBruchrillen));
      expect(restored.content, equals(original.content));
      expect(restored.size, equals(original.size));
      expect(restored.dosageMg, equals(original.dosageMg));
      expect(restored.colorValue, equals(original.colorValue));
      expect(restored.dateTime, equals(original.dateTime));
    });

    test('XtcEntry handles unknown dosage correctly', () {
      final entry = XtcEntry.create(
        substanceName: 'Unknown Dose',
        form: XtcForm.kreis,
        hasBruchrillen: true,
        content: XtcContent.mda,
        size: XtcSize.quarter,
        dosageMg: null, // Unknown dosage
        color: Colors.green,
        dateTime: DateTime.now(),
      );

      expect(entry.dosageMg, isNull);
      expect(entry.formattedDosage, equals('Unbekannt'));
    });

    test('XtcForm enum has correct display names', () {
      expect(XtcForm.rechteck.displayName, equals('Rechteck'));
      expect(XtcForm.stern.displayName, equals('Stern'));
      expect(XtcForm.kreis.displayName, equals('Kreis'));
      expect(XtcForm.dreieck.displayName, equals('Dreieck'));
      expect(XtcForm.blume.displayName, equals('Blume'));
      expect(XtcForm.oval.displayName, equals('Oval'));
      expect(XtcForm.viereck.displayName, equals('Viereck'));
      expect(XtcForm.pillenSpezifisch.displayName, equals('PillenSpezifisch'));
    });

    test('XtcContent enum has correct display names', () {
      expect(XtcContent.mdma.displayName, equals('MDMA'));
      expect(XtcContent.mda.displayName, equals('MDA'));
      expect(XtcContent.amph.displayName, equals('Amph.'));
    });

    test('XtcSize enum has correct display values', () {
      expect(XtcSize.full.value, equals('1'));
      expect(XtcSize.full.displaySymbol, equals('1'));
      
      expect(XtcSize.half.value, equals('1/2'));
      expect(XtcSize.half.displaySymbol, equals('½'));
      
      expect(XtcSize.quarter.value, equals('1/4'));
      expect(XtcSize.quarter.displaySymbol, equals('¼'));
      
      expect(XtcSize.eighth.value, equals('1/8'));
      expect(XtcSize.eighth.displaySymbol, equals('⅛'));
    });
  });

  group('XTC Widget Tests', () {
    testWidgets('XtcColorPicker shows initial color', (WidgetTester tester) async {
      Color selectedColor = Colors.red;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: XtcColorPicker(
              initialColor: Colors.red,
              onColorChanged: (color) {
                selectedColor = color;
              },
            ),
          ),
        ),
      );

      expect(find.byType(XtcColorPicker), findsOneWidget);
      expect(find.byIcon(Icons.palette), findsOneWidget);
    });

    testWidgets('XtcSizeSelector shows all size options', (WidgetTester tester) async {
      XtcSize selectedSize = XtcSize.full;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: XtcSizeSelector(
              selectedSize: XtcSize.full,
              onSizeChanged: (size) {
                selectedSize = size;
              },
            ),
          ),
        ),
      );

      expect(find.byType(XtcSizeSelector), findsOneWidget);
      expect(find.text('Größe'), findsOneWidget);
      
      // Should show all size options
      expect(find.text('1'), findsOneWidget);
      expect(find.text('½'), findsOneWidget);
      expect(find.text('¼'), findsOneWidget);
      expect(find.text('⅛'), findsOneWidget);
    });
  });
}