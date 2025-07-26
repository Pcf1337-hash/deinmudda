import 'package:uuid/uuid.dart';
import '../utils/unit_manager.dart';

/// Categories for classifying different types of substances.
enum SubstanceCategory {
  /// Medical medication
  medication,
  /// Stimulating substances
  stimulant,
  /// Depressing substances
  depressant,
  /// Nutritional supplements
  supplement,
  /// Recreational substances
  recreational,
  /// Other uncategorized substances
  other,
}

/// Risk levels for substance consumption.
enum RiskLevel {
  /// Low risk level
  low,
  /// Medium risk level
  medium,
  /// High risk level
  high,
  /// Critical risk level
  critical,
}

/// Represents a substance that can be tracked in the system.
/// 
/// Contains information about pricing, risk level, category,
/// and timing information for consumption tracking.
class Substance {
  final String id;
  final String name;
  final SubstanceCategory category;
  final RiskLevel defaultRiskLevel;
  final double pricePerUnit;
  final String defaultUnit;
  final String? notes;
  final String? iconName;
  final Duration? duration; // Timer duration for minimal effect time
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Creates a substance with all required parameters.
  const Substance({
    required this.id,
    required this.name,
    required this.category,
    required this.defaultRiskLevel,
    required this.pricePerUnit,
    required this.defaultUnit,
    this.notes,
    this.iconName,
    this.duration,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Factory constructor for creating new substances with automatic ID generation.
  factory Substance.create({
    required String name,
    required SubstanceCategory category,
    required RiskLevel defaultRiskLevel,
    required double pricePerUnit,
    required String defaultUnit,
    String? notes,
    String? iconName,
    Duration? duration,
  }) {
    final now = DateTime.now();
    return Substance(
      id: const Uuid().v4(),
      name: name,
      category: category,
      defaultRiskLevel: defaultRiskLevel,
      pricePerUnit: pricePerUnit,
      defaultUnit: defaultUnit,
      notes: notes,
      iconName: iconName,
      duration: duration,
      createdAt: now,
      updatedAt: now,
    );
  }

  // Display getters
  
  /// Returns formatted price string with currency and unit.
  String get formattedPrice {
    return '${pricePerUnit.toStringAsFixed(2).replaceAll('.', ',')}€/$defaultUnit';
  }

  /// Returns human-readable duration string.
  String get formattedDuration {
    if (duration == null) return 'Nicht festgelegt';
    final hours = duration!.inHours;
    final minutes = duration!.inMinutes % 60;
    if (hours > 0) {
      return minutes > 0 ? '${hours}h ${minutes}min' : '${hours}h';
    }
    return '${minutes}min';
  }

  /// Returns localized category display name.
  String get categoryDisplayName {
    switch (category) {
      case SubstanceCategory.medication:
        return 'Medikament';
      case SubstanceCategory.stimulant:
        return 'Stimulans';
      case SubstanceCategory.depressant:
        return 'Depressivum';
      case SubstanceCategory.supplement:
        return 'Nahrungsergänzung';
      case SubstanceCategory.recreational:
        return 'Freizeitsubstanz';
      case SubstanceCategory.other:
        return 'Sonstiges';
    }
  }

  /// Returns localized risk level display name.
  String get riskLevelDisplayName {
    switch (defaultRiskLevel) {
      case RiskLevel.low:
        return 'Niedrig';
      case RiskLevel.medium:
        return 'Mittel';
      case RiskLevel.high:
        return 'Hoch';
      case RiskLevel.critical:
        return 'Kritisch';
    }
  }

  // Calculation methods
  
  /// Calculates total price for a given amount.
  double calculatePrice(double amount) {
    return pricePerUnit * amount;
  }

  /// Returns formatted price string for calculated amount.
  String formatCalculatedPrice(double amount) {
    final totalPrice = calculatePrice(amount);
    return '${totalPrice.toStringAsFixed(2).replaceAll('.', ',')}€';
  }

  /// Converts amount from one unit to the standard unit for calculation.
  double convertToStandardUnit(double amount, String fromUnit) {
    return UnitManager.convertAmount(amount, fromUnit, defaultUnit);
  }

  /// Calculates cost for a specific amount in any unit.
  double calculateCostForAmount(double amount, String unit) {
    final standardAmount = convertToStandardUnit(amount, unit);
    return calculatePrice(standardAmount);
  }

  /// Formats cost for a specific amount in any unit.
  String formatCostForAmount(double amount, String unit) {
    final cost = calculateCostForAmount(amount, unit);
    return '${cost.toStringAsFixed(2).replaceAll('.', ',')}€';
  }

  /// Converts substance to database map for storage.
  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'name': name,
      'category': category.index,
      'defaultRiskLevel': defaultRiskLevel.index,
      'pricePerUnit': pricePerUnit,
      'defaultUnit': defaultUnit,
      'notes': notes,
      'iconName': iconName,
      'duration': duration?.inMinutes, // Store duration in minutes
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Creates Substance from database map.
  factory Substance.fromDatabase(Map<String, dynamic> map) {
    return Substance(
      id: map['id'] as String,
      name: map['name'] as String,
      category: SubstanceCategory.values[map['category'] as int],
      defaultRiskLevel: RiskLevel.values[map['defaultRiskLevel'] as int],
      pricePerUnit: (map['pricePerUnit'] as num).toDouble(),
      defaultUnit: map['defaultUnit'] as String,
      notes: map['notes'] as String?,
      iconName: map['iconName'] as String?,
      duration: map['duration'] != null ? Duration(minutes: map['duration'] as int) : null,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : DateTime.now(),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at'] as String) : DateTime.now(),
    );
  }

  /// Converts substance to JSON map for export/import.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category.index,
      'defaultRiskLevel': defaultRiskLevel.index,
      'pricePerUnit': pricePerUnit,
      'defaultUnit': defaultUnit,
      'notes': notes,
      'iconName': iconName,
      'duration': duration?.inMinutes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Creates Substance from JSON map.
  factory Substance.fromJson(Map<String, dynamic> json) {
    return Substance(
      id: json['id'] as String,
      name: json['name'] as String,
      category: SubstanceCategory.values[json['category'] as int],
      defaultRiskLevel: RiskLevel.values[json['defaultRiskLevel'] as int],
      pricePerUnit: (json['pricePerUnit'] as num).toDouble(),
      defaultUnit: json['defaultUnit'] as String,
      notes: json['notes'] as String?,
      iconName: json['iconName'] as String?,
      duration: json['duration'] != null ? Duration(minutes: json['duration'] as int) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : DateTime.now(),
    );
  }

  /// Creates a copy of this substance with updated fields.
  Substance copyWith({
    String? id,
    String? name,
    SubstanceCategory? category,
    RiskLevel? defaultRiskLevel,
    double? pricePerUnit,
    String? defaultUnit,
    String? notes,
    String? iconName,
    Duration? duration,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Substance(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      defaultRiskLevel: defaultRiskLevel ?? this.defaultRiskLevel,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      defaultUnit: defaultUnit ?? this.defaultUnit,
      notes: notes ?? this.notes,
      iconName: iconName ?? this.iconName,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Substance && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Substance(id: $id, name: $name, category: $categoryDisplayName)';
  }

  /// Returns a list of pre-configured default substances.
  static List<Substance> getDefaultSubstances() {
    return [
      Substance.create(
        name: 'Koffein',
        category: SubstanceCategory.stimulant,
        defaultRiskLevel: RiskLevel.low,
        pricePerUnit: 0.05,
        defaultUnit: 'mg',
        notes: 'Häufig in Kaffee, Tee und Energy-Drinks enthalten',
        iconName: 'coffee',
        duration: const Duration(hours: 4), // 4 hours for caffeine
      ),
      Substance.create(
        name: 'Cannabis',
        category: SubstanceCategory.recreational,
        defaultRiskLevel: RiskLevel.medium,
        pricePerUnit: 10.0,
        defaultUnit: 'g',
        notes: 'THC-haltige Cannabisprodukte',
        iconName: 'leaf',
        duration: const Duration(hours: 2), // 2 hours for cannabis
      ),
      Substance.create(
        name: 'Alkohol',
        category: SubstanceCategory.depressant,
        defaultRiskLevel: RiskLevel.medium,
        pricePerUnit: 2.5,
        defaultUnit: 'ml',
        notes: 'Ethanol in alkoholischen Getränken',
        iconName: 'wine',
        duration: const Duration(hours: 2), // 2 hours for alcohol
      ),
      Substance.create(
        name: 'Vitamin D',
        category: SubstanceCategory.supplement,
        defaultRiskLevel: RiskLevel.low,
        pricePerUnit: 0.1,
        defaultUnit: 'IE',
        notes: 'Wichtig für Knochengesundheit und Immunsystem',
        iconName: 'sun',
        duration: const Duration(hours: 24), // 24 hours for vitamin D
      ),
      Substance.create(
        name: 'Ibuprofen',
        category: SubstanceCategory.medication,
        defaultRiskLevel: RiskLevel.low,
        pricePerUnit: 0.02,
        defaultUnit: 'mg',
        notes: 'Nichtsteroidales Antirheumatikum (NSAR)',
        iconName: 'pill',
        duration: const Duration(hours: 6), // 6 hours for ibuprofen
      ),
      Substance.create(
        name: 'Nikotin',
        category: SubstanceCategory.stimulant,
        defaultRiskLevel: RiskLevel.high,
        pricePerUnit: 0.5,
        defaultUnit: 'mg',
        notes: 'Hauptwirkstoff in Tabakprodukten',
        iconName: 'cigarette',
        duration: const Duration(minutes: 30), // 30 minutes for nicotine
      ),
      Substance.create(
        name: 'Melatonin',
        category: SubstanceCategory.supplement,
        defaultRiskLevel: RiskLevel.low,
        pricePerUnit: 0.3,
        defaultUnit: 'mg',
        notes: 'Natürliches Schlafhormon',
        iconName: 'moon',
        duration: const Duration(hours: 8), // 8 hours for melatonin
      ),
      Substance.create(
        name: 'Paracetamol',
        category: SubstanceCategory.medication,
        defaultRiskLevel: RiskLevel.low,
        pricePerUnit: 0.01,
        defaultUnit: 'mg',
        notes: 'Schmerzmittel und Fiebersenkend',
        iconName: 'pill',
        duration: const Duration(hours: 4), // 4 hours for paracetamol
      ),
      Substance.create(
        name: 'Multivitamin',
        category: SubstanceCategory.supplement,
        defaultRiskLevel: RiskLevel.low,
        pricePerUnit: 0.25,
        defaultUnit: 'Stück',
        notes: 'Tägliche Vitamin- und Mineralstoffergänzung',
        iconName: 'pill',
      ),
    ];
  }
}

// hints reduziert durch HintOptimiererAgent