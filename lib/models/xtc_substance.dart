import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// Enum for XTC pill forms
enum XTCForm {
  rechteck,
  stern,
  kreis,
  dreieck,
  blume,
  oval,
  viereck,
  pillenSpezifisch,
}

/// Enum for XTC content types
enum XTCContent {
  mdma,
  mda,
  amphetamin,
  unbekannt,
}

/// Specialized substance model for XTC/Ecstasy pills
/// 
/// Contains specific fields for XTC substances that don't appear 
/// in the regular substance manager but can be used for quick entries.
class XTCSubstance {
  final String id;
  final String name;
  final String? logo; // Logo/image identifier
  final XTCForm form;
  final bool bruchrillen; // Breaking lines/grooves
  final XTCContent inhalt; // Content type
  final double menge; // Amount in mg
  final Color farbe; // Color
  final double? gewicht; // Optional weight in mg
  final DateTime createdAt;
  final DateTime updatedAt;

  const XTCSubstance({
    required this.id,
    required this.name,
    this.logo,
    required this.form,
    required this.bruchrillen,
    required this.inhalt,
    required this.menge,
    required this.farbe,
    this.gewicht,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Factory constructor for creating new XTC substances
  factory XTCSubstance.create({
    required String name,
    String? logo,
    required XTCForm form,
    required bool bruchrillen,
    required XTCContent inhalt,
    required double menge,
    required Color farbe,
    double? gewicht,
  }) {
    final now = DateTime.now();
    return XTCSubstance(
      id: const Uuid().v4(),
      name: name,
      logo: logo,
      form: form,
      bruchrillen: bruchrillen,
      inhalt: inhalt,
      menge: menge,
      farbe: farbe,
      gewicht: gewicht,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Display getters for German localization
  
  String get formDisplayName {
    switch (form) {
      case XTCForm.rechteck:
        return 'Rechteck';
      case XTCForm.stern:
        return 'Stern';
      case XTCForm.kreis:
        return 'Kreis';
      case XTCForm.dreieck:
        return 'Dreieck';
      case XTCForm.blume:
        return 'Blume';
      case XTCForm.oval:
        return 'Oval';
      case XTCForm.viereck:
        return 'Viereck';
      case XTCForm.pillenSpezifisch:
        return 'Pillen-Spezifisch';
    }
  }

  String get inhaltDisplayName {
    switch (inhalt) {
      case XTCContent.mdma:
        return 'MDMA';
      case XTCContent.mda:
        return 'MDA';
      case XTCContent.amphetamin:
        return 'Amph.';
      case XTCContent.unbekannt:
        return 'Unbekannt';
    }
  }

  String get bruchrillenlDisplayName {
    return bruchrillen ? 'Ja' : 'Nein';
  }

  String get formattedMenge {
    return '${menge.toStringAsFixed(menge.truncateToDouble() == menge ? 0 : 1)} mg';
  }

  String get formattedGewicht {
    if (gewicht == null) return 'Nicht angegeben';
    return '${gewicht!.toStringAsFixed(gewicht!.truncateToDouble() == gewicht! ? 0 : 1)} mg';
  }

  /// Icon for the form type
  IconData get formIcon {
    switch (form) {
      case XTCForm.rechteck:
      case XTCForm.viereck:
        return Icons.rectangle_outlined;
      case XTCForm.stern:
        return Icons.star_outline_rounded;
      case XTCForm.kreis:
        return Icons.circle_outlined;
      case XTCForm.dreieck:
        return Icons.change_history_outlined;
      case XTCForm.blume:
        return Icons.local_florist_outlined;
      case XTCForm.oval:
        return Icons.circle_outlined; // Use circle for oval as there's no oval icon
      case XTCForm.pillenSpezifisch:
        return Icons.medication_outlined;
    }
  }

  /// Icon for the content type
  IconData get inhaltIcon {
    switch (inhalt) {
      case XTCContent.mdma:
        return Icons.psychology_outlined;
      case XTCContent.mda:
        return Icons.science_outlined;
      case XTCContent.amphetamin:
        return Icons.flash_on_outlined;
      case XTCContent.unbekannt:
        return Icons.help_outline_rounded;
    }
  }

  /// Converts XTC substance to database map for storage
  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'name': name,
      'logo': logo,
      'form': form.index,
      'bruchrillen': bruchrillen ? 1 : 0,
      'inhalt': inhalt.index,
      'menge': menge,
      'farbe': farbe.value,
      'gewicht': gewicht,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Creates XTC substance from database map
  factory XTCSubstance.fromDatabase(Map<String, dynamic> map) {
    return XTCSubstance(
      id: map['id'] as String,
      name: map['name'] as String,
      logo: map['logo'] as String?,
      form: XTCForm.values[map['form'] as int],
      bruchrillen: (map['bruchrillen'] as int) == 1,
      inhalt: XTCContent.values[map['inhalt'] as int],
      menge: (map['menge'] as num).toDouble(),
      farbe: Color(map['farbe'] as int),
      gewicht: map['gewicht'] != null ? (map['gewicht'] as num).toDouble() : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Converts XTC substance to JSON map for export/import
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo': logo,
      'form': form.index,
      'bruchrillen': bruchrillen,
      'inhalt': inhalt.index,
      'menge': menge,
      'farbe': farbe.value,
      'gewicht': gewicht,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Creates XTC substance from JSON map
  factory XTCSubstance.fromJson(Map<String, dynamic> json) {
    return XTCSubstance(
      id: json['id'] as String,
      name: json['name'] as String,
      logo: json['logo'] as String?,
      form: XTCForm.values[json['form'] as int],
      bruchrillen: json['bruchrillen'] as bool,
      inhalt: XTCContent.values[json['inhalt'] as int],
      menge: (json['menge'] as num).toDouble(),
      farbe: Color(json['farbe'] as int),
      gewicht: json['gewicht'] != null ? (json['gewicht'] as num).toDouble() : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Creates a copy with updated fields
  XTCSubstance copyWith({
    String? id,
    String? name,
    String? logo,
    XTCForm? form,
    bool? bruchrillen,
    XTCContent? inhalt,
    double? menge,
    Color? farbe,
    double? gewicht,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return XTCSubstance(
      id: id ?? this.id,
      name: name ?? this.name,
      logo: logo ?? this.logo,
      form: form ?? this.form,
      bruchrillen: bruchrillen ?? this.bruchrillen,
      inhalt: inhalt ?? this.inhalt,
      menge: menge ?? this.menge,
      farbe: farbe ?? this.farbe,
      gewicht: gewicht ?? this.gewicht,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is XTCSubstance && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'XTCSubstance(id: $id, name: $name, form: $formDisplayName, inhalt: $inhaltDisplayName)';
  }
}