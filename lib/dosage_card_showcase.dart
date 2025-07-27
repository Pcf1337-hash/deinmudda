import 'package:flutter/material.dart';
import 'widgets/dosage_card.dart';
import 'theme/design_tokens.dart';

void main() {
  runApp(const DosageCardShowcaseApp());
}

/// Standalone app to showcase the enhanced DosageCard widgets
class DosageCardShowcaseApp extends StatelessWidget {
  const DosageCardShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Enhanced Dosage Cards',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(
          seedColor: DesignTokens.primaryIndigo,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(
          seedColor: DesignTokens.primaryIndigo,
          brightness: Brightness.dark,
        ),
      ),
      home: const DosageCardShowcaseScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Main showcase screen for the enhanced DosageCard widgets
class DosageCardShowcaseScreen extends StatefulWidget {
  const DosageCardShowcaseScreen({super.key});

  @override
  State<DosageCardShowcaseScreen> createState() => _DosageCardShowcaseScreenState();
}

class _DosageCardShowcaseScreenState extends State<DosageCardShowcaseScreen> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _isDarkMode 
          ? ThemeData(
              useMaterial3: true,
              fontFamily: 'Inter',
              colorScheme: ColorScheme.fromSeed(
                seedColor: DesignTokens.primaryIndigo,
                brightness: Brightness.dark,
              ),
            )
          : ThemeData(
              useMaterial3: true,
              fontFamily: 'Inter',
              colorScheme: ColorScheme.fromSeed(
                seedColor: DesignTokens.primaryIndigo,
                brightness: Brightness.light,
              ),
            ),
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;
          
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
                        padding: const EdgeInsets.all(16),
                        child: _buildDosageGrid(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                setState(() {
                  _isDarkMode = !_isDarkMode;
                });
              },
              backgroundColor: DesignTokens.primaryIndigo,
              foregroundColor: Colors.white,
              child: Icon(
                _isDarkMode ? Icons.light_mode : Icons.dark_mode,
              ),
            ),
          );
        },
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

  Widget _buildDosageGrid(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$substance Details'),
        content: Text(
          'Enhanced DosageCard für $substance wurde erfolgreich implementiert!\n\n'
          'Features:\n'
          '• Glassmorphism-Effekte mit BackdropFilter\n'
          '• Material 3 Design\n'
          '• Responsive Layout\n'
          '• Hover-Animationen\n'
          '• Dark/Light Mode Support\n'
          '• Substance-spezifische Gradienten',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}