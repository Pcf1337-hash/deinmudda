import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../models/enhanced_substance.dart';
import '../widgets/enhanced_dosage_card.dart';
import '../widgets/header_bar.dart';
import '../utils/app_icon_generator.dart';

/// Enhanced Dosage Card Demo Screen
/// 
/// Demonstrates the enhanced dosage cards with rich substance information
/// loaded from the enhanced substances JSON file.
class EnhancedDosageCardsScreen extends StatefulWidget {
  const EnhancedDosageCardsScreen({super.key});

  @override
  State<EnhancedDosageCardsScreen> createState() => _EnhancedDosageCardsScreenState();
}

class _EnhancedDosageCardsScreenState extends State<EnhancedDosageCardsScreen> {
  List<EnhancedSubstance> _substances = [];
  bool _isLoading = true;
  String? _errorMessage;
  double _userWeight = 70.0; // Default weight

  @override
  void initState() {
    super.initState();
    _loadEnhancedSubstances();
  }

  Future<void> _loadEnhancedSubstances() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/data/dosage_calculator_substances_enhanced.json'
      );
      final List<dynamic> data = json.decode(response);
      
      setState(() {
        _substances = data.map((json) => EnhancedSubstance.fromEnhancedJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Fehler beim Laden der Substanzdaten: $e';
        _isLoading = false;
      });
    }
  }

  void _showWeightDialog() {
    final controller = TextEditingController(text: _userWeight.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Körpergewicht eingeben'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Gewicht in kg',
            suffixText: 'kg',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () {
              final weight = double.tryParse(controller.text);
              if (weight != null && weight > 0 && weight < 300) {
                setState(() {
                  _userWeight = weight;
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Erweiterte Dosis-Kacheln'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: theme.colorScheme.onBackground,
        actions: [
          IconButton(
            onPressed: _showWeightDialog,
            icon: const Icon(Icons.person),
            tooltip: 'Gewicht: ${_userWeight.toStringAsFixed(1)} kg',
          ),
        ],
      ),
      body: _buildBody(context, theme),
    );
  }

  Widget _buildBody(BuildContext context, ThemeData theme) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _loadEnhancedSubstances();
                },
                child: const Text('Erneut versuchen'),
              ),
            ],
          ),
        ),
      );
    }

    if (_substances.isEmpty) {
      return const Center(
        child: Text('Keine Substanzdaten verfügbar'),
      );
    }

    return Column(
      children: [
        // Info header
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Erweiterte Dosiskacheln',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Diese Kacheln zeigen umfassende Informationen zu jeder Substanz:',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                '• Risikolevels mit farbigen Indikatoren\n'
                '• Chemische Wirkungsweise\n'
                '• Sicherheitswarnungen\n'
                '• Dosisbereiche (Leicht/Normal/Stark)\n'
                '• Wichtige Nebenwirkungen\n'
                '• Expandierbare Details',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Aktuelle Dosierung für ${_userWeight.toStringAsFixed(1)} kg',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _showWeightDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Ändern',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Grid of enhanced cards
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75, // Adjusted for expandable cards
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _substances.length,
            itemBuilder: (context, index) {
              final substance = _substances[index];
              return EnhancedDosageCard(
                substance: substance,
                userWeight: _userWeight,
                icon: AppIconGenerator.getSubstanceIcon(substance.name),
                gradientColors: _getGradientColorsForSubstance(substance.name),
                onTap: () => _showSubstanceDetails(substance),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showSubstanceDetails(EnhancedSubstance substance) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          final theme = Theme.of(context);
          return Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Title with risk indicator
                  Row(
                    children: [
                      Icon(
                        AppIconGenerator.getSubstanceIcon(substance.name),
                        size: 32,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              substance.name,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: substance.riskLevel.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    substance.riskLevel.icon,
                                    color: substance.riskLevel.color,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Risiko: ${substance.riskLevel.displayName}',
                                    style: TextStyle(
                                      color: substance.riskLevel.color,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Detailed information sections
                  _buildDetailSection(
                    'Dosierung (${_userWeight.toStringAsFixed(1)} kg)',
                    Icons.medication,
                    theme,
                    Column(
                      children: substance.getFormattedDosageRange(_userWeight)
                          .entries
                          .map((entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(entry.key, style: theme.textTheme.bodyMedium),
                                Text(
                                  entry.value,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ))
                          .toList(),
                    ),
                  ),
                  
                  _buildDetailSection(
                    'Wirkungsweise',
                    Icons.science,
                    theme,
                    Text(
                      substance.chemicalEffect,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  
                  _buildDetailSection(
                    'Sicherheitshinweise',
                    Icons.warning_amber,
                    theme,
                    Text(
                      substance.safetyNotes,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  
                  if (substance.sideEffects.isNotEmpty)
                    _buildDetailSection(
                      'Nebenwirkungen',
                      Icons.health_and_safety,
                      theme,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: substance.sideEffects
                            .map((effect) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                '• $effect',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ))
                            .toList(),
                      ),
                    ),
                  
                  if (substance.interactions.isNotEmpty)
                    _buildDetailSection(
                      'Wechselwirkungen',
                      Icons.warning,
                      theme,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: substance.interactions
                            .map((interaction) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                '• $interaction',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.red,
                                ),
                              ),
                            ))
                            .toList(),
                      ),
                    ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailSection(String title, IconData icon, ThemeData theme, Widget content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  List<Color> _getGradientColorsForSubstance(String name) {
    final substanceName = name.toLowerCase();
    
    if (substanceName.contains('mdma')) {
      return [
        const Color(0xFFFF10F0), // Pink
        const Color(0xFFE91E63), // Deep Pink
      ];
    } else if (substanceName.contains('lsd')) {
      return [
        const Color(0xFF9C27B0), // Purple
        const Color(0xFF673AB7), // Deep Purple
      ];
    } else if (substanceName.contains('ketamin')) {
      return [
        const Color(0xFF0080FF), // Electric Blue
        const Color(0xFF0056B3), // Deep Blue
      ];
    } else if (substanceName.contains('kokain') || substanceName.contains('cocaine')) {
      return [
        const Color(0xFFFF5722), // Deep Orange
        const Color(0xFFBF360C), // Dark Orange
      ];
    } else if (substanceName.contains('cannabis')) {
      return [
        const Color(0xFF4CAF50), // Green
        const Color(0xFF2E7D32), // Dark Green
      ];
    } else if (substanceName.contains('amphetamin')) {
      return [
        const Color(0xFFFF9800), // Orange
        const Color(0xFFEF6C00), // Dark Orange
      ];
    } else {
      return [
        const Color(0xFF2196F3), // Blue
        const Color(0xFF0D47A1), // Dark Blue
      ];
    }
  }
}