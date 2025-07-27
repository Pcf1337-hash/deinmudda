import 'package:flutter/material.dart';
import '../widgets/dosage_card.dart';
import '../theme/design_tokens.dart';

/// Demo screen showcasing the enhanced DosageCard widgets
/// 
/// Displays four substance cards in a responsive 2x2 grid layout
/// with modern Glassmorphism + Material 3 design
class DosageCardDemoScreen extends StatelessWidget {
  const DosageCardDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    return Scaffold(
      backgroundColor: isDark 
          ? const Color(0xFF0A0A0A)
          : const Color(0xFFF8FAFC),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0A0A0A),
                    Color(0xFF1A0A1A),
                    Color(0xFF0A1A1A),
                  ],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF8FAFC),
                    Color(0xFFE2E8F0),
                    Color(0xFFF1F5F9),
                  ],
                ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, isDark),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 32 : 16,
                    vertical: 16,
                  ),
                  child: _buildDosageGrid(context, isTablet),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showThemeToggle(context),
        backgroundColor: DesignTokens.primaryIndigo,
        icon: Icon(
          isDark ? Icons.light_mode : Icons.dark_mode,
          color: Colors.white,
        ),
        label: Text(
          isDark ? 'Light Mode' : 'Dark Mode',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  DesignTokens.primaryIndigo.withOpacity(0.3),
                  DesignTokens.primaryPurple.withOpacity(0.2),
                ]
              : [
                  DesignTokens.primaryIndigo.withOpacity(0.8),
                  DesignTokens.primaryPurple.withOpacity(0.6),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: DesignTokens.primaryIndigo.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.science_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enhanced Dosage Cards',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Glassmorphism + Material 3 Design',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDosageGrid(BuildContext context, bool isTablet) {
    final crossAxisCount = isTablet ? 4 : 2;
    final childAspectRatio = isTablet ? 0.9 : 0.85;
    
    return GridView.count(
      crossAxisCount: crossAxisCount,
      childAspectRatio: childAspectRatio,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      physics: const BouncingScrollPhysics(),
      children: [
        DosageCard.mdma(
          doseText: '125.0 mg',
          durationText: '4–6 Stunden',
          onTap: () => _showDosageDetails(context, 'MDMA'),
        ),
        DosageCard.lsd(
          doseText: '100.0 μg',
          durationText: '8–12 Stunden',
          onTap: () => _showDosageDetails(context, 'LSD'),
        ),
        DosageCard.ketamine(
          doseText: '75.0 mg',
          durationText: '1–2 Stunden',
          onTap: () => _showDosageDetails(context, 'Ketamin'),
        ),
        DosageCard.cocaine(
          doseText: '60.0 mg',
          durationText: '30–60 Min',
          onTap: () => _showDosageDetails(context, 'Kokain'),
        ),
      ],
    );
  }

  void _showDosageDetails(BuildContext context, String substance) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _DosageDetailsModal(substance: substance),
    );
  }

  void _showThemeToggle(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Theme toggle functionality would be implemented here'),
        backgroundColor: DesignTokens.primaryIndigo,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

/// Modal for showing dosage details
class _DosageDetailsModal extends StatelessWidget {
  final String substance;

  const _DosageDetailsModal({required this.substance});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: DesignTokens.primaryIndigo.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getSubstanceIcon(substance),
                    color: DesignTokens.primaryIndigo,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$substance Details',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Dosierungsinformationen',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(
                    context,
                    'Sicherheitshinweise',
                    'Immer mit der niedrigsten Dosis beginnen und die volle Wirkdauer abwarten.',
                    Icons.warning_rounded,
                    Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    context,
                    'Dosierungsempfehlung',
                    'Die angezeigte Dosis basiert auf aktuellen wissenschaftlichen Erkenntnissen.',
                    Icons.science_rounded,
                    DesignTokens.primaryIndigo,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    context,
                    'Wirkdauer',
                    'Die Wirkdauer kann je nach individueller Toleranz variieren.',
                    Icons.access_time_rounded,
                    DesignTokens.accentCyan,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSubstanceIcon(String substance) {
    switch (substance.toLowerCase()) {
      case 'mdma':
        return Icons.favorite_rounded;
      case 'lsd':
        return Icons.psychology_rounded;
      case 'ketamin':
        return Icons.medical_services_rounded;
      case 'kokain':
        return Icons.warning_rounded;
      default:
        return Icons.science_rounded;
    }
  }
}