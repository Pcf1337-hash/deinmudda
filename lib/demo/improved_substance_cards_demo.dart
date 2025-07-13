import 'package:flutter/material.dart';
import '../../../models/dosage_calculator_substance.dart';
import '../../../models/dosage_calculator_user.dart';
import '../../../widgets/dosage_calculator/improved_substance_card.dart';
import '../../../theme/design_tokens.dart';

/// Demo screen to showcase the improved substance cards
/// This demonstrates the glassmorphism design with neon effects as specified in the requirements
class ImprovedSubstanceCardsDemo extends StatefulWidget {
  const ImprovedSubstanceCardsDemo({super.key});

  @override
  State<ImprovedSubstanceCardsDemo> createState() => _ImprovedSubstanceCardsDemoState();
}

class _ImprovedSubstanceCardsDemoState extends State<ImprovedSubstanceCardsDemo> {
  late List<DosageCalculatorSubstance> _substances;
  late DosageCalculatorUser _user;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    // Sample user data
    _user = DosageCalculatorUser(
      id: 'demo-user',
      weightKg: 70.0,
      heightCm: 175.0,
      age: 25,
      gender: 'male',
      lastUpdated: DateTime.now(),
    );

    // Sample substances matching the demo_ui.html examples
    _substances = [
      DosageCalculatorSubstance(
        name: 'MDMA',
        lightDosePerKg: 1.0,
        normalDosePerKg: 1.5,
        strongDosePerKg: 2.5,
        administrationRoute: 'oral',
        duration: '4–6 Stunden',
        safetyNotes: 'Ausreichend trinken, Pausen einhalten, nicht mit anderen Stimulanzien kombinieren',
      ),
      DosageCalculatorSubstance(
        name: 'LSD',
        lightDosePerKg: 0.7,
        normalDosePerKg: 1.4,
        strongDosePerKg: 2.1,
        administrationRoute: 'oral',
        duration: '8–12 Stunden',
        safetyNotes: 'Set & Setting beachten, Tripsitter empfohlen, nicht bei psychischen Problemen',
      ),
      DosageCalculatorSubstance(
        name: 'Ketamin',
        lightDosePerKg: 0.3,
        normalDosePerKg: 0.6,
        strongDosePerKg: 1.0,
        administrationRoute: 'nasal',
        duration: '45–90 Minuten',
        safetyNotes: 'Nicht im Stehen konsumieren, K-Hole Gefahr bei hohen Dosen',
      ),
      DosageCalculatorSubstance(
        name: 'Kokain',
        lightDosePerKg: 0.4,
        normalDosePerKg: 0.8,
        strongDosePerKg: 1.4,
        administrationRoute: 'nasal',
        duration: '30–60 Minuten',
        safetyNotes: 'Hohes Suchtpotential, Herzprobleme möglich, nicht mit Alkohol',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0a0a0a)
          : Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Improved Substance Cards Demo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: isDark
            ? const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0a0a0a),
                    Color(0xFF1a0a1a),
                    Color(0xFF0a1a1a),
                  ],
                ),
              )
            : null,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header information
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      DesignTokens.accentCyan.withOpacity(0.1),
                      DesignTokens.accentPurple.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: DesignTokens.accentCyan.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Substance Card Improvements',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: DesignTokens.accentCyan,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Glassmorphism design with neon effects, responsive layout, and improved UX',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFeaturesList(context),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // User profile info
              Text(
                'User Profile',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.person,
                      color: DesignTokens.successGreen,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${_user.formattedWeight} • ${_user.formattedHeight} • ${_user.formattedAge}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Responsive grid demonstration
              Text(
                'Responsive Grid Layout',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Two cards side by side on wide screens, one per row on narrow screens',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 20),

              // Substance cards grid
              ResponsiveSubstanceCardGrid(
                substances: _substances,
                user: _user,
                onCardTap: (substance) => _showSubstanceDetails(substance),
              ),

              const SizedBox(height: 40),

              // Implementation details
              _buildImplementationDetails(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesList(BuildContext context) {
    final features = [
      '✨ Glassmorphism background with blur effects',
      '🎨 Substance-specific neon colors and borders',
      '⚡ Hover animations and glow effects',
      '📱 Responsive layout (2 cards wide, 1 narrow)',
      '💊 Recommended dose and optional dose (80%)',
      '🏷️ Danger level indicators with colors',
      '🔄 Proper text overflow handling',
      '🎯 Modern UI with BoxDecoration styling',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: features.map((feature) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            feature,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.8),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildImplementationDetails(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[900]
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Implementation Details',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailItem('Widget Used:', 'LayoutBuilder, Wrap, Flexible, FittedBox'),
          _buildDetailItem('Text Handling:', 'maxLines: 2, overflow: TextOverflow.ellipsis'),
          _buildDetailItem('Background:', 'BoxDecoration with glassmorphism gradient'),
          _buildDetailItem('Border:', 'Substance-specific colors with opacity'),
          _buildDetailItem('Shadows:', 'Neon glow effects using BoxShadow'),
          _buildDetailItem('Animation:', 'Hover effects with AnimationController'),
          _buildDetailItem('Responsive:', 'LayoutBuilder for different screen sizes'),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.8),
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSubstanceDetails(DosageCalculatorSubstance substance) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[900]
              : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    substance.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Administration:', substance.administrationRouteDisplayName),
                  _buildDetailRow('Duration:', substance.duration),
                  _buildDetailRow('Light dose:', '${substance.lightDosePerKg} mg/kg'),
                  _buildDetailRow('Normal dose:', '${substance.normalDosePerKg} mg/kg'),
                  _buildDetailRow('Strong dose:', '${substance.strongDosePerKg} mg/kg'),
                  const SizedBox(height: 16),
                  if (_user != null) ...[
                    Text(
                      'For your weight (${_user.formattedWeight}):',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow('Recommended:', substance.getFormattedDosage(_user.weightKg, DosageIntensity.normal)),
                    _buildDetailRow('Optional (80%):', '${(substance.calculateDosage(_user.weightKg, DosageIntensity.normal) * 0.8).toStringAsFixed(1)} mg'),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}