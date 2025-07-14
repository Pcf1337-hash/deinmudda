import 'package:uuid/uuid.dart';

enum SubstanceCategory {
  medication,
  stimulant,
  depressant,
  supplement,
  recreational,
  other
}

enum RiskLevel {
  low,
  medium,
  high,
  critical
}

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
  });

  // Factory constructor for creating new entries
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
    );
  }

  // Getters
  bool get isToday {
    final now = DateTime.now();
    return dateTime.year == now.year && 
           dateTime.month == now.month && 
           dateTime.day == now.day;
  }

  bool get isThisWeek {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    return dateTime.isAfter(weekStart.subtract(const Duration(days: 1))) && 
           dateTime.isBefore(weekEnd.add(const Duration(days: 1)));
  }

  bool get hasCostData => cost > 0;

  String get formattedCost {
    return '${cost.toStringAsFixed(2).replaceAll('.', ',')}€';
  }

  String get formattedDosage {
    return '${dosage.toString().replaceAll('.', ',')} $unit';
  }

  DateTime get date => DateTime(dateTime.year, dateTime.month, dateTime.day);
  DateTime get time => dateTime;

  // Timer-related getters
  bool get hasTimer => timerStartTime != null && timerEndTime != null;
  
  bool get isTimerActive => hasTimer && !timerCompleted && DateTime.now().isBefore(timerEndTime!);
  
  bool get isTimerExpired => hasTimer && DateTime.now().isAfter(timerEndTime!) && !timerCompleted;
  
  Duration? get timerDuration => hasTimer ? timerEndTime!.difference(timerStartTime!) : null;
  
  Duration? get remainingTime => isTimerActive ? timerEndTime!.difference(DateTime.now()) : null;
  
  Duration? get elapsedTime => hasTimer ? DateTime.now().difference(timerStartTime!) : null;
  
  double get timerProgress {
    if (!hasTimer) return 0.0;
    final total = timerEndTime!.difference(timerStartTime!);
    final elapsed = DateTime.now().difference(timerStartTime!);
    final progress = elapsed.inMilliseconds / total.inMilliseconds;
    return progress.clamp(0.0, 1.0);
  }
  
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

  // JSON serialization
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
    };
  }

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
    );
  }

  // Database serialization
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
    };
  }

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
    );
  }

  // Copy with method
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
