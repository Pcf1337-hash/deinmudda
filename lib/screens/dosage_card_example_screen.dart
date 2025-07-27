import 'package:flutter/material.dart';
import '../widgets/dosage_card.dart';
import 'enhanced_dosage_cards_screen.dart';

/// Example screen demonstrating DosageCard usage
/// 
/// Shows 4 different substance cards (MDMA, LSD, Ketamin, Kokain)
/// in a responsive grid layout with glassmorphism design.
class DosageCardExampleScreen extends StatelessWidget {
  const DosageCardExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode 
          ? const Color(0xFF0A0A0A)
          : const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Dosis-Kacheln'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDarkMode ? Colors.white : Colors.black87,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [
                    const Color(0xFF0A0A0A),
                    const Color(0xFF1A1A2E),
                    const Color(0xFF16213E),
                  ]
                : [
                    const Color(0xFFF5F5F5),
                    const Color(0xFFE8E8FF),
                    const Color(0xFFFFE8F5),
                  ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with enhanced cards button
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Substanz-Übersicht',
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: isDarkMode ? Colors.white : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Dosis-Informationen mit modernem Glassmorphism-Design',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: isDarkMode 
                                        ? Colors.white.withOpacity(0.7)
                                        : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const EnhancedDosageCardsScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.upgrade, size: 18),
                            label: const Text('Erweitert'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Cards Grid
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Responsive layout: use GridView for wider screens, 
                      // Wrap for smaller screens
                      final screenWidth = constraints.maxWidth;
                      
                      if (screenWidth > 500) {
                        // Use GridView for larger screens with improved aspect ratio
                        return GridView.count(
                          crossAxisCount: 2,
                          childAspectRatio: 0.85, // Improved from 0.85 for more compact tiles
                          mainAxisSpacing: 6, // Reduced from 8
                          crossAxisSpacing: 6, // Reduced from 8
                          physics: const BouncingScrollPhysics(),
                          children: _buildDosageCards(),
                        );
                      } else {
                        // Use Wrap for smaller screens
                        return SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 6, // Reduced from 8
                            runSpacing: 6, // Reduced from 8
                            children: _buildDosageCards(),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the list of dosage cards with example data
  List<Widget> _buildDosageCards() {
    return [
      // MDMA Card (Oral)
      const DosageCard(
        title: 'MDMA',
        doseText: '85.0 mg',
        durationText: '4–6 Stunden',
        icon: Icons.favorite,
        gradientColors: [
          Color(0xFFFF10F0), // Pink
          Color(0xFFE91E63), // Deep Pink
        ],
        isOral: true,
        safetyWarning: 'Max. 1x/Monat',
        additionalInfo: 'Erhöht Empathie und Euphorie',
      ),
      
      // LSD Card (Oral)
      const DosageCard(
        title: 'LSD',
        doseText: '150 µg',
        durationText: '8–12 Stunden',
        icon: Icons.psychology,
        gradientColors: [
          Color(0xFF9D4EDD), // Purple
          Color(0xFF6A4C93), // Deep Purple
        ],
        isOral: true,
        safetyWarning: 'Set & Setting beachten',
        additionalInfo: 'Verändert Wahrnehmung drastisch',
      ),
      
      // Ketamin Card (Nasal)
      const DosageCard(
        title: 'Ketamin',
        doseText: '50.0 mg',
        durationText: '45–90 Min',
        icon: Icons.cloud,
        gradientColors: [
          Color(0xFF0080FF), // Electric Blue
          Color(0xFF0056B3), // Deep Blue
        ],
        isOral: false,
        safetyWarning: 'Nicht im Stehen konsumieren',
        additionalInfo: 'Dissoziative Wirkung',
      ),
      
      // Kokain Card (Nasal)
      const DosageCard(
        title: 'Kokain',
        doseText: '30.0 mg',
        durationText: '15–30 Min',
        icon: Icons.flash_on,
        gradientColors: [
          Color(0xFFFFD700), // Gold
          Color(0xFFFF8C00), // Dark Orange
        ],
        isOral: false,
        safetyWarning: 'Hoher Blutdruck, Herzinfarktrisiko',
        additionalInfo: 'Hohes Suchtpotential',
      ),
    ];
  }
}