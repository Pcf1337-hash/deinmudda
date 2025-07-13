import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';
import '../services/psychedelic_theme_service.dart';
import '../services/database_service.dart';
import '../widgets/glass_card.dart';
import '../theme/design_tokens.dart';
import '../theme/spacing.dart';
import 'substance_management_screen.dart';
import 'psychedelic_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Column(
        children: [
          _buildAppBar(context, isDark),
          Expanded(
            child: SingleChildScrollView(
              padding: Spacing.paddingHorizontalMd,
              child: Column(
                children: [
                  Spacing.verticalSpaceLg,
                  _buildAppearanceSection(context, isDark),
                  Spacing.verticalSpaceLg,
                  _buildToolsSection(context, isDark),
                  Spacing.verticalSpaceLg,
                  _buildDataSection(context, isDark),
                  Spacing.verticalSpaceLg,
                  _buildAboutSection(context, isDark),
                  const SizedBox(height: 120), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A1A2E),
                  Color(0xFF16213E),
                  Color(0xFF0F3460),
                ],
              )
            : DesignTokens.primaryGradient,
      ),
      child: SafeArea(
        child: Padding(
          padding: Spacing.paddingMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Einstellungen',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ).animate().fadeIn(
                duration: DesignTokens.animationSlow,
                delay: const Duration(milliseconds: 200),
              ).slideX(
                begin: -0.3,
                end: 0,
                duration: DesignTokens.animationSlow,
                curve: DesignTokens.curveEaseOut,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppearanceSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Darstellung',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ).animate().fadeIn(
          duration: DesignTokens.animationMedium,
          delay: const Duration(milliseconds: 300),
        ),
        Spacing.verticalSpaceMd,
        Consumer<SettingsService>(
          builder: (context, settingsService, child) {
            return FutureBuilder<bool>(
              future: settingsService.isDarkMode,
              builder: (context, snapshot) {
                final isDarkModeEnabled = snapshot.data ?? false;
                
                return GlassCard(
                  child: SwitchListTile(
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Dunkles Design verwenden'),
                    value: isDarkModeEnabled,
                    onChanged: (value) {
                      settingsService.setDarkMode(value);
                    },
                    secondary: Icon(
                      isDarkModeEnabled ? Icons.dark_mode : Icons.light_mode,
                      color: DesignTokens.primaryIndigo,
                    ),
                  ),
                );
              },
            );
          },
        ).animate().fadeIn(
          duration: DesignTokens.animationMedium,
          delay: const Duration(milliseconds: 400),
        ).slideY(
          begin: 0.3,
          end: 0,
          duration: DesignTokens.animationMedium,
          curve: DesignTokens.curveEaseOut,
        ),
        
        Spacing.verticalSpaceMd,
        
        // Psychedelic Settings Card
        Consumer<PsychedelicThemeService>(
          builder: (context, psychedelicService, child) {
            return GlassCard(
              usePsychedelicEffects: psychedelicService.isPsychedelicMode,
              glowColor: psychedelicService.isPsychedelicMode 
                  ? DesignTokens.neonPurple 
                  : null,
              child: ListTile(
                leading: Icon(
                  Icons.psychology_rounded,
                  color: psychedelicService.isPsychedelicMode 
                      ? DesignTokens.neonPurple 
                      : DesignTokens.primaryIndigo,
                ),
                title: Text(
                  'Psychedelic Mode',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: psychedelicService.isPsychedelicMode && isDark
                        ? DesignTokens.textPsychedelicPrimary
                        : null,
                  ),
                ),
                subtitle: Text(
                  psychedelicService.isPsychedelicMode 
                      ? 'Aktiv - Optimiert für erweiterte Bewusstseinszustände'
                      : 'Erweiterte Einstellungen für immersive Erfahrung',
                  style: TextStyle(
                    color: psychedelicService.isPsychedelicMode && isDark
                        ? DesignTokens.textPsychedelicSecondary
                        : null,
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: psychedelicService.isPsychedelicMode && isDark
                      ? DesignTokens.textPsychedelicSecondary
                      : null,
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const PsychedelicSettingsScreen(),
                    ),
                  );
                },
              ),
            );
          },
        ).animate().fadeIn(
          duration: DesignTokens.animationMedium,
          delay: const Duration(milliseconds: 500),
        ).slideY(
          begin: 0.3,
          end: 0,
          duration: DesignTokens.animationMedium,
          curve: DesignTokens.curveEaseOut,
        ),
      ],
    );
  }

  Widget _buildToolsSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tools & Verwaltung',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ).animate().fadeIn(
          duration: DesignTokens.animationMedium,
          delay: const Duration(milliseconds: 450),
        ),
        Spacing.verticalSpaceMd,
        GlassCard(
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  Icons.science_rounded,
                  color: DesignTokens.primaryIndigo,
                ),
                title: const Text('Substanzen verwalten'),
                subtitle: const Text('Eigene Substanzen erstellen und bearbeiten'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _navigateToSubstanceManagement(),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(
                  Icons.settings_rounded,
                  color: DesignTokens.accentEmerald,
                ),
                title: const Text('Dosisrechner-Datenbank'),
                subtitle: const Text('Substanzen für den Dosisrechner verwalten'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _navigateToDosageSubstanceManagement(),
              ),
            ],
          ),
        ).animate().fadeIn(
          duration: DesignTokens.animationMedium,
          delay: const Duration(milliseconds: 500),
        ).slideY(
          begin: 0.3,
          end: 0,
          duration: DesignTokens.animationMedium,
          curve: DesignTokens.curveEaseOut,
        ),
      ],
    );
  }

  Widget _buildDataSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daten',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ).animate().fadeIn(
          duration: DesignTokens.animationMedium,
          delay: const Duration(milliseconds: 550),
        ),
        Spacing.verticalSpaceMd,
        GlassCard(
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  Icons.info_outline,
                  color: DesignTokens.infoBlue,
                ),
                title: const Text('Datenbank-Info'),
                subtitle: const Text('Informationen zur lokalen Datenbank'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _showDatabaseInfo(context),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(
                  Icons.download,
                  color: DesignTokens.accentEmerald,
                ),
                title: const Text('Daten exportieren'),
                subtitle: const Text('Alle Daten als JSON exportieren'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _exportData(context),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(
                  Icons.delete_forever,
                  color: DesignTokens.errorRed,
                ),
                title: const Text('Alle Daten löschen'),
                subtitle: const Text('Vorsicht: Nicht rückgängig machbar'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _confirmDeleteAllData(context),
              ),
            ],
          ),
        ).animate().fadeIn(
          duration: DesignTokens.animationMedium,
          delay: const Duration(milliseconds: 600),
        ).slideY(
          begin: 0.3,
          end: 0,
          duration: DesignTokens.animationMedium,
          curve: DesignTokens.curveEaseOut,
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Über die App',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ).animate().fadeIn(
          duration: DesignTokens.animationMedium,
          delay: const Duration(milliseconds: 650),
        ),
        Spacing.verticalSpaceMd,
        GlassCard(
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  Icons.info,
                  color: DesignTokens.primaryIndigo,
                ),
                title: const Text('Version'),
                subtitle: const Text('1.0.0 (Build 1)'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(
                  Icons.code,
                  color: DesignTokens.accentCyan,
                ),
                title: const Text('Entwickelt mit'),
                subtitle: const Text('Flutter & Dart'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(
                  Icons.favorite,
                  color: DesignTokens.errorRed,
                ),
                title: const Text('Made with ❤️'),
                subtitle: const Text('Konsum Tracker Pro'),
              ),
            ],
          ),
        ).animate().fadeIn(
          duration: DesignTokens.animationMedium,
          delay: const Duration(milliseconds: 700),
        ).slideY(
          begin: 0.3,
          end: 0,
          duration: DesignTokens.animationMedium,
          curve: DesignTokens.curveEaseOut,
        ),
      ],
    );
  }

  void _navigateToSubstanceManagement() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SubstanceManagementScreen(),
      ),
    );
  }

  void _navigateToDosageSubstanceManagement() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dosisrechner-Datenbank-Verwaltung wird in einer zukünftigen Version verfügbar sein'),
      ),
    );
  }

  void _showDatabaseInfo(BuildContext context) async {
    final databaseService = context.read<DatabaseService>();
    final info = await databaseService.getDatabaseInfo();
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Datenbank-Informationen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: ${info['version'] ?? 'Unbekannt'}'),
            Text('Pfad: ${info['path'] ?? 'Unbekannt'}'),
            const SizedBox(height: 16),
            Text('Einträge: ${info['entriesCount'] ?? 0}'),
            Text('Substanzen: ${info['substancesCount'] ?? 0}'),
            Text('Quick Buttons: ${info['quickButtonsCount'] ?? 0}'),
            Text('Benutzer: ${info['usersCount'] ?? 0}'),
            Text('Dosierungs-Substanzen: ${info['dosageSubstancesCount'] ?? 0}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Schließen'),
          ),
        ],
      ),
    );
  }

  void _exportData(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Datenexport wird in einer zukünftigen Version verfügbar sein'),
      ),
    );
  }

  void _confirmDeleteAllData(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alle Daten löschen'),
        content: const Text(
          'Sind Sie sicher, dass Sie alle Daten löschen möchten? '
          'Diese Aktion kann nicht rückgängig gemacht werden.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteAllData(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: DesignTokens.errorRed,
            ),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
  }

  void _deleteAllData(BuildContext context) async {
    try {
      final databaseService = context.read<DatabaseService>();
      await databaseService.deleteDatabase();
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alle Daten wurden erfolgreich gelöscht'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim Löschen der Daten: $e'),
          backgroundColor: DesignTokens.errorRed,
        ),
      );
    }
  }
}