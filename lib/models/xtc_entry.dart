import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// Enumeration for XTC pill forms/shapes
enum XtcForm {
  rechteck('Rechteck'),
  stern('Stern'),
  kreis('Kreis'),
  dreieck('Dreieck'),
  blume('Blume'),
  oval('Oval'),
  viereck('Viereck'),
  pillenSpezifisch('PillenSpezifisch');

  const XtcForm(this.displayName);
  final String displayName;
}

/// Enumeration for XTC content types
enum XtcContent {
  mdma('MDMA'),
  mda('MDA'),
  amph('Amph.');

  const XtcContent(this.displayName);
  final String displayName;
}

/// Enumeration for XTC pill sizes
enum XtcSize {
  full('1', '1'),
  half('1/2', '½'),
  quarter('1/4', '¼'),
  eighth('1/8', '⅛');

  const XtcSize(this.value, this.displaySymbol);
  final String value;
  final String displaySymbol;
}

/// Represents an XTC (Ecstasy) substance entry with specific fields
/// for pill characteristics like form, content, size, and color.
class XtcEntry {
  final String id;
  final String substanceName; // The actual substance name, not "XTC"
  final String? logo;
  final XtcForm form;
  final int bruchrillienAnzahl; // Number of break lines/scoring (0-4)
  final XtcContent content;
  final XtcSize size;
  final double? dosageMg; // Dosage in mg, can be null for "Unbekannt"
  final int colorValue; // Color as int value for serialization
  final double? weightGrams; // Optional weight in grams
  final DateTime dateTime;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Timer fields (inherited from regular entries)
  final DateTime? timerStartTime;
  final DateTime? timerEndTime;
  final bool timerCompleted;
  final bool timerNotificationSent;

  /// Creates an XTC entry with all required and optional parameters.
  const XtcEntry({
    required this.id,
    required this.substanceName,
    this.logo,
    required this.form,
    required this.bruchrillienAnzahl,
    required this.content,
    required this.size,
    this.dosageMg,
    required this.colorValue,
    this.weightGrams,
    required this.dateTime,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.timerStartTime,
    this.timerEndTime,
    this.timerCompleted = false,
    this.timerNotificationSent = false,
  });

  /// Factory constructor for creating new XTC entries with automatic ID generation.
  factory XtcEntry.create({
    required String substanceName,
    String? logo,
    required XtcForm form,
    required int bruchrillienAnzahl,
    required XtcContent content,
    required XtcSize size,
    double? dosageMg,
    required Color color,
    double? weightGrams,
    required DateTime dateTime,
    String? notes,
    DateTime? timerStartTime,
    DateTime? timerEndTime,
    bool timerCompleted = false,
    bool timerNotificationSent = false,
  }) {
    final now = DateTime.now();
    return XtcEntry(
      id: const Uuid().v4(),
      substanceName: substanceName,
      logo: logo,
      form: form,
      bruchrillienAnzahl: bruchrillienAnzahl,
      content: content,
      size: size,
      dosageMg: dosageMg,
      colorValue: color.value,
      weightGrams: weightGrams,
      dateTime: dateTime,
      notes: notes,
      createdAt: now,
      updatedAt: now,
      timerStartTime: timerStartTime,
      timerEndTime: timerEndTime,
      timerCompleted: timerCompleted,
      timerNotificationSent: timerNotificationSent,
    );
  }

  // Helper getters
  
  /// Gets the Color representation of the stored color value.
  Color get color => Color(colorValue);

  /// Returns formatted dosage string.
  String get formattedDosage {
    if (dosageMg == null) return 'Unbekannt';
    return '${dosageMg!.toStringAsFixed(dosageMg! == dosageMg!.roundToDouble() ? 0 : 1)} mg';
  }

  /// Returns formatted weight string.
  String get formattedWeight {
    if (weightGrams == null) return 'Nicht angegeben';
    return '${weightGrams!.toStringAsFixed(weightGrams! == weightGrams!.roundToDouble() ? 0 : 1)} g';
  }

  /// Returns a display summary of the XTC entry.
  String get displaySummary {
    final bruchrillienText = bruchrillienAnzahl > 0 ? '$bruchrillienAnzahl Bruchrillen' : 'Keine Bruchrillen';
    return '$substanceName (${size.displaySymbol} ${form.displayName}, ${content.displayName}, $bruchrillienText)';
  }

  /// Returns whether this entry has timer data.
  bool get hasTimer => timerStartTime != null && timerEndTime != null;
  
  /// Returns whether the timer is currently active.
  bool get isTimerActive => hasTimer && !timerCompleted && DateTime.now().isBefore(timerEndTime!);
  
  /// Returns whether the timer has expired.
  bool get isTimerExpired => hasTimer && DateTime.now().isAfter(timerEndTime!) && !timerCompleted;

  /// Converts XTC entry to JSON map for serialization.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'substanceName': substanceName,
      'logo': logo,
      'form': form.index,
      'bruchrillienAnzahl': bruchrillienAnzahl,
      'content': content.index,
      'size': size.index,
      'dosageMg': dosageMg,
      'colorValue': colorValue,
      'weightGrams': weightGrams,
      'dateTime': dateTime.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'timerStartTime': timerStartTime?.toIso8601String(),
      'timerEndTime': timerEndTime?.toIso8601String(),
      'timerCompleted': timerCompleted,
      'timerNotificationSent': timerNotificationSent,
    };
  }

  /// Creates XtcEntry from JSON map.
  factory XtcEntry.fromJson(Map<String, dynamic> json) {
    return XtcEntry(
      id: json['id'] as String,
      substanceName: json['substanceName'] as String,
      logo: json['logo'] as String?,
      form: XtcForm.values[json['form'] as int],
      bruchrillienAnzahl: json['bruchrillienAnzahl'] as int? ?? ((json['hasBruchrillen'] as bool?) == true ? 1 : 0), // Migration fallback
      content: XtcContent.values[json['content'] as int],
      size: XtcSize.values[json['size'] as int],
      dosageMg: (json['dosageMg'] as num?)?.toDouble(),
      colorValue: json['colorValue'] as int,
      weightGrams: (json['weightGrams'] as num?)?.toDouble(),
      dateTime: DateTime.parse(json['dateTime'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      timerStartTime: json['timerStartTime'] != null ? DateTime.parse(json['timerStartTime'] as String) : null,
      timerEndTime: json['timerEndTime'] != null ? DateTime.parse(json['timerEndTime'] as String) : null,
      timerCompleted: json['timerCompleted'] as bool? ?? false,
      timerNotificationSent: json['timerNotificationSent'] as bool? ?? false,
    );
  }

  /// Converts XTC entry to database map for storage.
  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'substanceName': substanceName,
      'logo': logo,
      'form': form.index,
      'bruchrillienAnzahl': bruchrillienAnzahl,
      'content': content.index,
      'size': size.index,
      'dosageMg': dosageMg,
      'colorValue': colorValue,
      'weightGrams': weightGrams,
      'dateTime': dateTime.toIso8601String(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'timerStartTime': timerStartTime?.toIso8601String(),
      'timerEndTime': timerEndTime?.toIso8601String(),
      'timerCompleted': timerCompleted ? 1 : 0,
      'timerNotificationSent': timerNotificationSent ? 1 : 0,
    };
  }

  /// Creates XtcEntry from database map.
  factory XtcEntry.fromDatabase(Map<String, dynamic> map) {
    return XtcEntry(
      id: map['id'] as String,
      substanceName: map['substanceName'] as String,
      logo: map['logo'] as String?,
      form: XtcForm.values[map['form'] as int],
      bruchrillienAnzahl: map['bruchrillienAnzahl'] as int? ?? ((map['hasBruchrillen'] as int?) == 1 ? 1 : 0), // Migration fallback
      content: XtcContent.values[map['content'] as int],
      size: XtcSize.values[map['size'] as int],
      dosageMg: (map['dosageMg'] as num?)?.toDouble(),
      colorValue: map['colorValue'] as int,
      weightGrams: (map['weightGrams'] as num?)?.toDouble(),
      dateTime: DateTime.parse(map['dateTime'] as String),
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      timerStartTime: map['timerStartTime'] != null ? DateTime.parse(map['timerStartTime'] as String) : null,
      timerEndTime: map['timerEndTime'] != null ? DateTime.parse(map['timerEndTime'] as String) : null,
      timerCompleted: (map['timerCompleted'] as int?) == 1,
      timerNotificationSent: (map['timerNotificationSent'] as int?) == 1,
    );
  }

  /// Creates a copy of this XTC entry with updated fields.
  XtcEntry copyWith({
    String? id,
    String? substanceName,
    String? logo,
    XtcForm? form,
    int? bruchrillienAnzahl,
    XtcContent? content,
    XtcSize? size,
    double? dosageMg,
    int? colorValue,
    double? weightGrams,
    DateTime? dateTime,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? timerStartTime,
    DateTime? timerEndTime,
    bool? timerCompleted,
    bool? timerNotificationSent,
  }) {
    return XtcEntry(
      id: id ?? this.id,
      substanceName: substanceName ?? this.substanceName,
      logo: logo ?? this.logo,
      form: form ?? this.form,
      bruchrillienAnzahl: bruchrillienAnzahl ?? this.bruchrillienAnzahl,
      content: content ?? this.content,
      size: size ?? this.size,
      dosageMg: dosageMg ?? this.dosageMg,
      colorValue: colorValue ?? this.colorValue,
      weightGrams: weightGrams ?? this.weightGrams,
      dateTime: dateTime ?? this.dateTime,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      timerStartTime: timerStartTime ?? this.timerStartTime,
      timerEndTime: timerEndTime ?? this.timerEndTime,
      timerCompleted: timerCompleted ?? this.timerCompleted,
      timerNotificationSent: timerNotificationSent ?? this.timerNotificationSent,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is XtcEntry && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'XtcEntry(id: $id, substanceName: $substanceName, form: ${form.displayName}, content: ${content.displayName})';
  }
}