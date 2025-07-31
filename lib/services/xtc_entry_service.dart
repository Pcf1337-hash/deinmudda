import '../models/xtc_entry.dart';
import '../interfaces/service_interfaces.dart';
import '../models/entry.dart';
import '../models/quick_button_config.dart';
import '../use_cases/entry_use_cases.dart';
import 'package:flutter/material.dart';

/// Service for managing XTC entries
class XtcEntryService {
  final IEntryService _entryService;
  final IQuickButtonService _quickButtonService;
  final CreateEntryUseCase _createEntryUseCase;
  final CreateEntryWithTimerUseCase _createEntryWithTimerUseCase;

  XtcEntryService({
    required IEntryService entryService,
    required IQuickButtonService quickButtonService,
    required CreateEntryUseCase createEntryUseCase,
    required CreateEntryWithTimerUseCase createEntryWithTimerUseCase,
  }) : _entryService = entryService,
       _quickButtonService = quickButtonService,
       _createEntryUseCase = createEntryUseCase,
       _createEntryWithTimerUseCase = createEntryWithTimerUseCase;

  /// Creates a regular Entry from an XtcEntry for storage in the main database
  Entry _convertToRegularEntry(XtcEntry xtcEntry) {
    // Create a virtual substance ID for XTC entries
    final virtualSubstanceId = 'xtc_virtual_${xtcEntry.id}';
    
    return Entry.create(
      substanceId: virtualSubstanceId,
      substanceName: xtcEntry.substanceName,
      dosage: xtcEntry.dosageMg ?? 0.0,
      unit: 'mg',
      dateTime: xtcEntry.dateTime,
      cost: 0.0, // XTC entries don't track cost
      notes: _buildXtcNotesString(xtcEntry),
      icon: Icons.medication_rounded,
      color: xtcEntry.color,
    );
  }

  /// Builds a notes string containing XTC-specific information
  String _buildXtcNotesString(XtcEntry xtcEntry) {
    final buffer = StringBuffer();
    buffer.writeln('XTC-Eintrag:');
    buffer.writeln('Form: ${xtcEntry.form.displayName}');
    buffer.writeln('Bruchrillen: ${xtcEntry.hasBruchrillen ? "Ja" : "Nein"}');
    buffer.writeln('Inhalt: ${xtcEntry.content.displayName}');
    buffer.writeln('Größe: ${xtcEntry.size.displaySymbol}');
    if (xtcEntry.dosageMg != null) {
      buffer.writeln('Dosierung: ${xtcEntry.formattedDosage}');
    } else {
      buffer.writeln('Dosierung: Unbekannt');
    }
    buffer.writeln('Farbe: #${xtcEntry.color.value.toRadixString(16).padLeft(8, '0')}');
    if (xtcEntry.weightGrams != null) {
      buffer.writeln('Gewicht: ${xtcEntry.formattedWeight}');
    }
    if (xtcEntry.notes != null && xtcEntry.notes!.isNotEmpty) {
      buffer.writeln('Notizen: ${xtcEntry.notes}');
    }
    return buffer.toString();
  }

  /// Saves an XTC entry by converting it to a regular entry
  Future<void> saveXtcEntry(XtcEntry xtcEntry, {bool startTimer = false}) async {
    final virtualSubstanceId = 'xtc_virtual_${xtcEntry.id}';
    
    if (startTimer) {
      // XTC typically lasts 3-6 hours, default to 4 hours
      const duration = Duration(hours: 4);
      await _createEntryWithTimerUseCase.execute(
        substanceId: virtualSubstanceId,
        dosage: xtcEntry.dosageMg ?? 0.0,
        unit: 'mg',
        dateTime: xtcEntry.dateTime,
        notes: _buildXtcNotesString(xtcEntry),
        customDuration: duration,
      );
    } else {
      await _createEntryUseCase.execute(
        substanceId: virtualSubstanceId,
        dosage: xtcEntry.dosageMg ?? 0.0,
        unit: 'mg',
        dateTime: xtcEntry.dateTime,
        notes: _buildXtcNotesString(xtcEntry),
      );
    }
  }

  /// Creates a quick button from an XTC entry
  Future<QuickButtonConfig> createQuickButtonFromXtcEntry(
    XtcEntry xtcEntry, 
    int position,
  ) async {
    final virtualSubstanceId = 'xtc_virtual_${xtcEntry.id}';
    
    final quickButton = QuickButtonConfig.create(
      substanceId: virtualSubstanceId,
      substanceName: xtcEntry.substanceName, // Use substance name, not "XTC"
      dosage: xtcEntry.dosageMg ?? 0.0,
      unit: 'mg',
      cost: 0.0,
      position: position,
      icon: Icons.medication_rounded,
      color: xtcEntry.color,
    );

    await _quickButtonService.saveQuickButton(quickButton);
    return quickButton;
  }

  /// Checks if an entry is an XTC entry based on its notes
  bool isXtcEntry(Entry entry) {
    return entry.notes?.startsWith('XTC-Eintrag:') == true;
  }

  /// Attempts to parse an XTC entry from a regular entry's notes
  XtcEntry? parseXtcEntryFromNotes(Entry entry) {
    if (!isXtcEntry(entry)) return null;

    try {
      final lines = entry.notes!.split('\n');
      String? formStr, contentStr, sizeStr, dosageStr, colorStr, weightStr;
      bool hasBruchrillen = false;
      
      for (final line in lines) {
        if (line.startsWith('Form: ')) {
          formStr = line.substring(6);
        } else if (line.startsWith('Bruchrillen: ')) {
          hasBruchrillen = line.substring(13) == 'Ja';
        } else if (line.startsWith('Inhalt: ')) {
          contentStr = line.substring(8);
        } else if (line.startsWith('Größe: ')) {
          sizeStr = line.substring(7);
        } else if (line.startsWith('Dosierung: ')) {
          dosageStr = line.substring(11);
        } else if (line.startsWith('Farbe: ')) {
          colorStr = line.substring(7);
        } else if (line.startsWith('Gewicht: ')) {
          weightStr = line.substring(9);
        }
      }

      // Parse form
      final form = XtcForm.values.firstWhere(
        (f) => f.displayName == formStr,
        orElse: () => XtcForm.rechteck,
      );

      // Parse content
      final content = XtcContent.values.firstWhere(
        (c) => c.displayName == contentStr,
        orElse: () => XtcContent.mdma,
      );

      // Parse size
      final size = XtcSize.values.firstWhere(
        (s) => s.displaySymbol == sizeStr,
        orElse: () => XtcSize.full,
      );

      // Parse dosage
      double? dosageMg;
      if (dosageStr != null && dosageStr != 'Unbekannt') {
        final match = RegExp(r'(\d+(?:\.\d+)?)\s*mg').firstMatch(dosageStr);
        if (match != null) {
          dosageMg = double.tryParse(match.group(1)!);
        }
      }

      // Parse color
      Color color = Colors.pink; // default
      if (colorStr != null && colorStr.startsWith('#')) {
        try {
          final colorValue = int.parse(colorStr.substring(1), radix: 16);
          color = Color(colorValue);
        } catch (e) {
          // Use default color if parsing fails
        }
      }

      // Parse weight
      double? weightGrams;
      if (weightStr != null && weightStr != 'Nicht angegeben') {
        final match = RegExp(r'(\d+(?:\.\d+)?)\s*g').firstMatch(weightStr);
        if (match != null) {
          weightGrams = double.tryParse(match.group(1)!);
        }
      }

      return XtcEntry.create(
        substanceName: entry.substanceName,
        form: form,
        hasBruchrillen: hasBruchrillen,
        content: content,
        size: size,
        dosageMg: dosageMg,
        color: color,
        weightGrams: weightGrams,
        dateTime: entry.dateTime,
        notes: null, // Clear XTC metadata from notes
      );
    } catch (e) {
      // Return null if parsing fails
      return null;
    }
  }
}