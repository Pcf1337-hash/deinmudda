class DosageCalculation {
  final String substance;
  final double lightDose;
  final double normalDose;
  final double strongDose;
  final double userWeight;
  final String unit;
  final String administrationRoute;
  final String duration;
  final List<String> safetyNotes;

  DosageCalculation({
    required this.substance,
    required this.lightDose,
    required this.normalDose,
    required this.strongDose,
    required this.userWeight,
    this.unit = 'mg',
    required this.administrationRoute,
    required this.duration,
    required this.safetyNotes,
  });

  Map<String, dynamic> toJson() {
    return {
      'substance': substance,
      'lightDose': lightDose,
      'normalDose': normalDose,
      'strongDose': strongDose,
      'userWeight': userWeight,
      'unit': unit,
      'administrationRoute': administrationRoute,
      'duration': duration,
      'safetyNotes': safetyNotes,
    };
  }

  factory DosageCalculation.fromJson(Map<String, dynamic> json) {
    return DosageCalculation(
      substance: json['substance'] ?? '',
      lightDose: (json['lightDose'] ?? 0.0).toDouble(),
      normalDose: (json['normalDose'] ?? 0.0).toDouble(),
      strongDose: (json['strongDose'] ?? 0.0).toDouble(),
      userWeight: (json['userWeight'] ?? 0.0).toDouble(),
      unit: json['unit'] ?? 'mg',
      administrationRoute: json['administrationRoute'] ?? '',
      duration: json['duration'] ?? '',
      safetyNotes: List<String>.from(json['safetyNotes'] ?? []),
    );
  }
}
