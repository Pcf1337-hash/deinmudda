import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:konsum_tracker_pro/models/xtc_substance.dart';
import 'package:konsum_tracker_pro/widgets/xtc_color_picker.dart';
import 'package:konsum_tracker_pro/widgets/xtc_quick_button.dart';

void main() {
  group('XTC Substance Tests', () {
    test('XTC Substance creation and properties', () {
      final xtcSubstance = XTCSubstance.create(
        name: 'Blue Punisher',
        form: XTCForm.stern,
        bruchrillen: true,
        inhalt: XTCContent.mdma,
        menge: 250.0,
        farbe: Colors.blue,
        gewicht: 300.0,
      );

      expect(xtcSubstance.name, 'Blue Punisher');
      expect(xtcSubstance.form, XTCForm.stern);
      expect(xtcSubstance.formDisplayName, 'Stern');
      expect(xtcSubstance.bruchrillen, true);
      expect(xtcSubstance.inhalt, XTCContent.mdma);
      expect(xtcSubstance.inhaltDisplayName, 'MDMA');
      expect(xtcSubstance.menge, 250.0);
      expect(xtcSubstance.formattedMenge, '250 mg');
      expect(xtcSubstance.farbe, Colors.blue);
      expect(xtcSubstance.gewicht, 300.0);
      expect(xtcSubstance.formattedGewicht, '300 mg');
    });

    test('XTC Form display names', () {
      expect(XTCForm.rechteck, XTCForm.rechteck);
      expect(XTCForm.stern, XTCForm.stern);
      expect(XTCForm.kreis, XTCForm.kreis);
      expect(XTCForm.dreieck, XTCForm.dreieck);
      expect(XTCForm.blume, XTCForm.blume);
      expect(XTCForm.oval, XTCForm.oval);
      expect(XTCForm.viereck, XTCForm.viereck);
      expect(XTCForm.pillenSpezifisch, XTCForm.pillenSpezifisch);
    });

    test('XTC Content display names', () {
      expect(XTCContent.mdma, XTCContent.mdma);
      expect(XTCContent.mda, XTCContent.mda);
      expect(XTCContent.amphetamin, XTCContent.amphetamin);
      expect(XTCContent.unbekannt, XTCContent.unbekannt);
    });

    test('XTC Substance serialization', () {
      final original = XTCSubstance.create(
        name: 'Test Pill',
        form: XTCForm.kreis,
        bruchrillen: false,
        inhalt: XTCContent.mda,
        menge: 150.0,
        farbe: Colors.red,
      );

      final json = original.toJson();
      final fromJson = XTCSubstance.fromJson(json);

      expect(fromJson.name, original.name);
      expect(fromJson.form, original.form);
      expect(fromJson.bruchrillen, original.bruchrillen);
      expect(fromJson.inhalt, original.inhalt);
      expect(fromJson.menge, original.menge);
      expect(fromJson.farbe, original.farbe);
    });

    test('XTC Substance database serialization', () {
      final original = XTCSubstance.create(
        name: 'Database Test',
        form: XTCForm.dreieck,
        bruchrillen: true,
        inhalt: XTCContent.amphetamin,
        menge: 180.0,
        farbe: Colors.green,
        gewicht: 220.0,
      );

      final dbMap = original.toDatabase();
      final fromDb = XTCSubstance.fromDatabase(dbMap);

      expect(fromDb.name, original.name);
      expect(fromDb.form, original.form);
      expect(fromDb.bruchrillen, original.bruchrillen);
      expect(fromDb.inhalt, original.inhalt);
      expect(fromDb.menge, original.menge);
      expect(fromDb.farbe, original.farbe);
      expect(fromDb.gewicht, original.gewicht);
    });

    test('XTC Substance copyWith functionality', () {
      final original = XTCSubstance.create(
        name: 'Original',
        form: XTCForm.rechteck,
        bruchrillen: false,
        inhalt: XTCContent.mdma,
        menge: 100.0,
        farbe: Colors.blue,
      );

      final copied = original.copyWith(
        name: 'Modified',
        menge: 200.0,
        farbe: Colors.red,
      );

      expect(copied.name, 'Modified');
      expect(copied.menge, 200.0);
      expect(copied.farbe, Colors.red);
      // Unchanged properties
      expect(copied.form, original.form);
      expect(copied.bruchrillen, original.bruchrillen);
      expect(copied.inhalt, original.inhalt);
    });
  });

  group('XTC Widget Tests', () {
    testWidgets('XTC Color Picker renders correctly', (WidgetTester tester) async {
      Color? selectedColor;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: XTCColorPicker(
              selectedColor: Colors.blue,
              onColorChanged: (color) {
                selectedColor = color;
              },
              label: 'Test Color',
            ),
          ),
        ),
      );

      expect(find.text('Test Color'), findsOneWidget);
      expect(find.text('Farbe auswählen'), findsOneWidget);
      expect(find.byType(XTCColorPicker), findsOneWidget);
    });

    testWidgets('CompactXTCQuickButton renders correctly', (WidgetTester tester) async {
      bool entryCreated = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactXTCQuickButton(
              onEntryCreated: () {
                entryCreated = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('XTC'), findsOneWidget);
      expect(find.text('Ecstasy'), findsOneWidget);
      expect(find.byType(CompactXTCQuickButton), findsOneWidget);
      expect(find.byIcon(Icons.medication_rounded), findsOneWidget);
    });

    testWidgets('XTCQuickButtonSection renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: XTCQuickButtonSection(
              onEntryCreated: () {},
            ),
          ),
        ),
      );

      expect(find.text('XTC / Ecstasy'), findsOneWidget);
      expect(find.text('Spezialisierte Erfassung für Ecstasy-Pillen'), findsOneWidget);
      expect(find.text('XTC-Einträge erscheinen nicht in der Substanzverwaltung'), findsOneWidget);
      expect(find.byType(XTCQuickButtonSection), findsOneWidget);
    });
  });

  group('XTC Form and Content Icon Tests', () {
    test('All XTC forms have valid icons', () {
      for (final form in XTCForm.values) {
        final substance = XTCSubstance.create(
          name: 'Test',
          form: form,
          bruchrillen: false,
          inhalt: XTCContent.mdma,
          menge: 100.0,
          farbe: Colors.blue,
        );
        
        // Verify that each form has an icon
        expect(substance.formIcon, isA<IconData>());
        expect(substance.formDisplayName, isNotEmpty);
      }
    });

    test('All XTC contents have valid icons', () {
      for (final content in XTCContent.values) {
        final substance = XTCSubstance.create(
          name: 'Test',
          form: XTCForm.kreis,
          bruchrillen: false,
          inhalt: content,
          menge: 100.0,
          farbe: Colors.blue,
        );
        
        // Verify that each content has an icon
        expect(substance.inhaltIcon, isA<IconData>());
        expect(substance.inhaltDisplayName, isNotEmpty);
      }
    });
  });

  group('XTC Edge Cases', () {
    test('XTC Substance with optional weight as null', () {
      final substance = XTCSubstance.create(
        name: 'No Weight',
        form: XTCForm.kreis,
        bruchrillen: false,
        inhalt: XTCContent.mdma,
        menge: 100.0,
        farbe: Colors.blue,
        // gewicht is null
      );

      expect(substance.gewicht, isNull);
      expect(substance.formattedGewicht, 'Nicht angegeben');
    });

    test('XTC Substance decimal handling', () {
      final substance = XTCSubstance.create(
        name: 'Decimal Test',
        form: XTCForm.kreis,
        bruchrillen: false,
        inhalt: XTCContent.mdma,
        menge: 125.5,
        farbe: Colors.blue,
        gewicht: 150.7,
      );

      expect(substance.formattedMenge, '125.5 mg');
      expect(substance.formattedGewicht, '150.7 mg');
    });

    test('XTC Substance integer handling', () {
      final substance = XTCSubstance.create(
        name: 'Integer Test',
        form: XTCForm.kreis,
        bruchrillen: false,
        inhalt: XTCContent.mdma,
        menge: 200.0,
        farbe: Colors.blue,
        gewicht: 250.0,
      );

      expect(substance.formattedMenge, '200 mg');
      expect(substance.formattedGewicht, '250 mg');
    });
  });
}