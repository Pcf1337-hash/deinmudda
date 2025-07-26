import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'substance.dart';

/// Risk level enumeration for consumption entries.
enum RiskLevel {
  /// Low risk consumption level
  low,
  /// Medium risk consumption level  
  medium,
  /// High risk consumption level
  high,
  /// Critical risk consumption level
  critical
}

/// Represents a consumption entry in the tracking system.
/// 
/// Immutable data class that contains all information about
/// a substance consumption event including dosage, timing,
/// cost tracking, and timer functionality.
class Entry {
  final String id;
  final String substanceId;
  final String substanceName;
  final double dosage;
  final String unit;
  final DateTime dateTime;
  final double cost;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Timer fields
  final DateTime? timerStartTime;
  final DateTime? timerEndTime;
  final bool timerCompleted;
  final bool timerNotificationSent;
  
  // Visual customization fields
  final int? iconCodePoint; // Store icon as codePoint for serialization
  final int? colorValue; // Store color as int value for serialization

  /// Creates a new Entry with all required and optional parameters.
  const Entry({
    required this.id,
    required this.substanceId,
    required this.substanceName,
    required this.dosage,
    required this.unit,
    required this.dateTime,
    required this.cost,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.timerStartTime,
    this.timerEndTime,
    this.timerCompleted = false,
    this.timerNotificationSent = false,
    this.iconCodePoint,
    this.colorValue,
  });

  // Helper getters for icon and color
  
  /// Gets the MaterialIcon representation of the stored icon code point.
  IconData? get icon => iconCodePoint != null ? IconData(iconCodePoint!, fontFamily: 'MaterialIcons') : null;
  
  /// Gets the Color representation of the stored color value.
  Color? get color => colorValue != null ? Color(colorValue!) : null;

  /// Factory constructor for creating new entries with automatic ID generation.
  /// 
  /// Automatically generates a UUID for the entry and sets creation timestamps.
  factory Entry.create({
    required String substanceId,
    required String substanceName,
    required double dosage,
    required String unit,
    required DateTime dateTime,
    double cost = 0.0,
    String? notes,
    DateTime? timerStartTime,
    DateTime? timerEndTime,
    bool timerCompleted = false,
    bool timerNotificationSent = false,
    IconData? icon,
    Color? color,
  }) {
    final now = DateTime.now();
    return Entry(
      id: const Uuid().v4(),
      substanceId: substanceId,
      substanceName: substanceName,
      dosage: dosage,
      unit: unit,
      dateTime: dateTime,
      cost: cost,
      notes: notes,
      createdAt: now,
      updatedAt: now,
      timerStartTime: timerStartTime,
      timerEndTime: timerEndTime,
      timerCompleted: timerCompleted,
      timerNotificationSent: timerNotificationSent,
      iconCodePoint: icon?.codePoint,
      colorValue: color?.value,
    );
  }

  // Date-based getters
  
  /// Returns true if this entry was created today.
  bool get isToday {
    final now = DateTime.now();
    return dateTime.year == now.year && 
           dateTime.month == now.month && 
           dateTime.day == now.day;
  }

  /// Returns true if this entry was created within the current week.
  bool get isThisWeek {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    const weekDuration = Duration(days: 6);
    final weekEnd = weekStart.add(weekDuration);
    const dayDuration = Duration(days: 1);
    return dateTime.isAfter(weekStart.subtract(dayDuration)) && 
           dateTime.isBefore(weekEnd.add(dayDuration));
  }

  /// Returns true if this entry has cost data.
  bool get hasCostData => cost > 0;

  /// Returns formatted cost string with Euro symbol.
  String get formattedCost {
    return '${cost.toStringAsFixed(2).replaceAll('.', ',')}€';
  }

  /// Returns formatted dosage string with unit.
  String get formattedDosage {
    return '${dosage.toString().replaceAll('.', ',')} $unit';
  }

  /// Returns date part only (without time).
  DateTime get date => DateTime(dateTime.year, dateTime.month, dateTime.day);
  
  /// Returns the complete timestamp.
  DateTime get time => dateTime;

  // Timer-related getters
  
  /// Returns true if this entry has timer data.
  bool get hasTimer => timerStartTime != null && timerEndTime != null;
  
  /// Returns true if the timer is currently active (running and not expired).
  bool get isTimerActive => hasTimer && !timerCompleted && DateTime.now().isBefore(timerEndTime!);
  
  /// Returns true if the timer has expired but not been marked as completed.
  bool get isTimerExpired => hasTimer && DateTime.now().isAfter(timerEndTime!) && !timerCompleted;
  
  /// Returns the total duration of the timer if available.
  Duration? get timerDuration => hasTimer ? timerEndTime!.difference(timerStartTime!) : null;
  
  /// Returns the remaining time on an active timer.
  Duration? get remainingTime => isTimerActive ? timerEndTime!.difference(DateTime.now()) : null;
  
  /// Returns the elapsed time since timer start.
  Duration? get elapsedTime => hasTimer ? DateTime.now().difference(timerStartTime!) : null;
  
  /// Returns timer progress as a value between 0.0 and 1.0.
  double get timerProgress {
    if (!hasTimer) return 0.0;
    final total = timerEndTime!.difference(timerStartTime!);
    final elapsed = DateTime.now().difference(timerStartTime!);
    final progress = elapsed.inMilliseconds / total.inMilliseconds;
    return progress.clamp(0.0, 1.0);
  }
  
  /// Returns human-readable remaining time string.
  String get formattedRemainingTime {
    final remaining = remainingTime;
    if (remaining == null) return 'Timer nicht aktiv';
    
    if (remaining.isNegative) return 'Timer abgelaufen';
    
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;
    final seconds = remaining.inSeconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    } else if (minutes > 0) {
      return '${minutes}min ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// Converts entry to JSON map for serialization.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'substanceId': substanceId,
      'substanceName': substanceName,
      'dosage': dosage,
      'unit': unit,
      'dateTime': dateTime.toIso8601String(),
      'cost': cost,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'timerStartTime': timerStartTime?.toIso8601String(),
      'timerEndTime': timerEndTime?.toIso8601String(),
      'timerCompleted': timerCompleted,
      'timerNotificationSent': timerNotificationSent,
      'iconCodePoint': iconCodePoint,
      'colorValue': colorValue,
    };
  }

  /// Creates Entry from JSON map.
  factory Entry.fromJson(Map<String, dynamic> json) {
    return Entry(
      id: json['id'] as String,
      substanceId: json['substanceId'] as String,
      substanceName: json['substanceName'] as String,
      dosage: (json['dosage'] as num).toDouble(),
      unit: json['unit'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      cost: (json['cost'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      timerStartTime: json['timerStartTime'] != null ? DateTime.parse(json['timerStartTime'] as String) : null,
      timerEndTime: json['timerEndTime'] != null ? DateTime.parse(json['timerEndTime'] as String) : null,
      timerCompleted: json['timerCompleted'] as bool? ?? false,
      timerNotificationSent: json['timerNotificationSent'] as bool? ?? false,
      iconCodePoint: json['iconCodePoint'] as int?,
      colorValue: json['colorValue'] as int?,
    );
  }

  /// Converts entry to database map for storage.
  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'substanceId': substanceId,
      'substanceName': substanceName,
      'dosage': dosage,
      'unit': unit,
      'dateTime': dateTime.toIso8601String(),
      'cost': cost,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'timerStartTime': timerStartTime?.toIso8601String(),
      'timerEndTime': timerEndTime?.toIso8601String(),
      'timerCompleted': timerCompleted ? 1 : 0,
      'timerNotificationSent': timerNotificationSent ? 1 : 0,
      'iconCodePoint': iconCodePoint,
      'colorValue': colorValue,
    };
  }

  /// Creates Entry from database map.
  factory Entry.fromDatabase(Map<String, dynamic> map) {
    return Entry(
      id: map['id'] as String,
      substanceId: map['substanceId'] as String,
      substanceName: map['substanceName'] as String,
      dosage: (map['dosage'] as num).toDouble(),
      unit: map['unit'] as String,
      dateTime: DateTime.parse(map['dateTime'] as String),
      cost: (map['cost'] as num?)?.toDouble() ?? 0.0,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      timerStartTime: map['timerStartTime'] != null ? DateTime.parse(map['timerStartTime'] as String) : null,
      timerEndTime: map['timerEndTime'] != null ? DateTime.parse(map['timerEndTime'] as String) : null,
      timerCompleted: (map['timerCompleted'] as int?) == 1,
      timerNotificationSent: (map['timerNotificationSent'] as int?) == 1,
      iconCodePoint: map['iconCodePoint'] as int?,
      colorValue: map['colorValue'] as int?,
    );
  }

  /// Creates a copy of this entry with updated fields.
  /// 
  /// Automatically updates the updatedAt timestamp to current time.
  Entry copyWith({
    String? id,
    String? substanceId,
    String? substanceName,
    double? dosage,
    String? unit,
    DateTime? dateTime,
    double? cost,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? timerStartTime,
    DateTime? timerEndTime,
    bool? timerCompleted,
    bool? timerNotificationSent,
    int? iconCodePoint,
    int? colorValue,
  }) {
    return Entry(
      id: id ?? this.id,
      substanceId: substanceId ?? this.substanceId,
      substanceName: substanceName ?? this.substanceName,
      dosage: dosage ?? this.dosage,
      unit: unit ?? this.unit,
      dateTime: dateTime ?? this.dateTime,
      cost: cost ?? this.cost,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      timerStartTime: timerStartTime ?? this.timerStartTime,
      timerEndTime: timerEndTime ?? this.timerEndTime,
      timerCompleted: timerCompleted ?? this.timerCompleted,
      timerNotificationSent: timerNotificationSent ?? this.timerNotificationSent,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      colorValue: colorValue ?? this.colorValue,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Entry && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Entry(id: $id, substanceName: $substanceName, dosage: $dosage, dateTime: $dateTime)';
  }
}

// hints reduziert durch HintOptimiererAgent
