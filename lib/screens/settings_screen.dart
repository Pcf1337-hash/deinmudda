import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';
import '../services/psychedelic_theme_service.dart';
import '../interfaces/service_interfaces.dart'; // for AppThemeMode
import '../services/database_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/header_bar.dart';
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
          HeaderBar(
            title: 'Einstellungen',
            subtitle: 'App-Konfiguration',
            showBackButton: false,
            showLightningIcon: true,
          ),
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
            return Consumer<service.PsychedelicThemeService>(
              builder: (context, psychedelicService, child) {
                return GlassCard(
                  usePsychedelicEffects: psychedelicService.isPsychedelicMode,
                  glowColor: psychedelicService.isPsychedelicMode 
                      ? const Color(0xFFff00ff) 
                      : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.palette_rounded,
                          color: psychedelicService.isPsychedelicMode 
                              ? const Color(0xFFff00ff) 
                              : DesignTokens.primaryIndigo,
                        ),
                        title: Text(
                          'Design Theme',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: psychedelicService.isPsychedelicMode && isDark
                                ? Colors.white
                                : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          _getThemeDescription(psychedelicService.currentThemeMode),
                          style: TextStyle(
                            color: psychedelicService.isPsychedelicMode && isDark
                                ? Colors.white70
                                : null,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildThemeSelector(psychedelicService),
                          ],
                        ),
                      ),
                    ],
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
        
        // Add TrippyMode toggle
        Consumer<service.PsychedelicThemeService>(
          builder: (context, themeService, child) {
            return GlassCard(
              usePsychedelicEffects: themeService.isPsychedelicMode,
              glowColor: themeService.isPsychedelicMode 
                  ? const Color(0xFFff00ff) 
                  : null,
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Dark Mode'),
                    value: themeService.currentThemeMode == AppThemeMode.dark || 
                           themeService.currentThemeMode == AppThemeMode.trippy,
                    onChanged: (value) {
                      if (value) {
                        themeService.setThemeMode(AppThemeMode.dark);
                      } else {
                        themeService.setThemeMode(AppThemeMode.light);
                      }
                    },
                    secondary: Icon(
                      themeService.currentThemeMode == AppThemeMode.light 
                          ? Icons.light_mode_rounded 
                          : Icons.dark_mode_rounded,
                      color: themeService.isPsychedelicMode 
                          ? const Color(0xFFff00ff) 
                          : DesignTokens.primaryIndigo,
                    ),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Trippy Mode'),
                    value: themeService.isTrippyMode,
                    onChanged: (value) => themeService.toggleTrippyMode(value),
                    secondary: Icon(
                      Icons.auto_awesome_rounded,
                      color: themeService.isTrippyMode 
                          ? const Color(0xFFff00ff) 
                          : DesignTokens.primaryIndigo,
                    ),
                  ),
                ],
              ),
            );
          },
        ).animate().fadeIn(
          duration: DesignTokens.animationMedium,
          delay: const Duration(milliseconds: 450),
        ).slideY(
          begin: 0.3,
          end: 0,
          duration: DesignTokens.animationMedium,
          curve: DesignTokens.curveEaseOut,
        ),
        
        Spacing.verticalSpaceMd,
        
        // Psychedelic Settings Card
        Consumer<service.PsychedelicThemeService>(
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
                subtitle: const Text(
                  'Eigene Substanzen erstellen und bearbeiten',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
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
                subtitle: const Text(
                  'Substanzen für den Dosisrechner verwalten',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
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
                subtitle: const Text(
                  'Informationen zur lokalen Datenbank',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
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
                subtitle: const Text(
                  'Alle Daten als JSON exportieren',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
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
                subtitle: const Text(
                  'Vorsicht: Nicht rückgängig machbar',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
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
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Version: ${info['version'] ?? 'Unbekannt'}',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'Pfad: ${info['path'] ?? 'Unbekannt'}',
                style: const TextStyle(fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Text(
                'Einträge: ${info['entriesCount'] ?? 0}',
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                'Substanzen: ${info['substancesCount'] ?? 0}',
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                'Quick Buttons: ${info['quickButtonsCount'] ?? 0}',
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                'Benutzer: ${info['usersCount'] ?? 0}',
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                'Dosierungs-Substanzen: ${info['dosageSubstancesCount'] ?? 0}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
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
          style: TextStyle(fontSize: 14),
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

  String _getThemeDescription(AppThemeMode themeMode) {
    switch (themeMode) {
      case AppThemeMode.light:
        return 'Helles Design für die tägliche Nutzung';
      case AppThemeMode.dark:
        return 'Dunkles Design für bessere Augenentspannung';
      case AppThemeMode.system:
        return 'Folgt den Systemeinstellungen automatisch';
      case AppThemeMode.trippy:
        return 'Psychedelisches Design mit Neon-Effekten';
    }
  }

  Widget _buildThemeSelector(PsychedelicThemeService psychedelicService) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildThemeButton(
            AppThemeMode.light,
            psychedelicService.currentThemeMode,
            () => psychedelicService.setThemeMode(AppThemeMode.light),
            Icons.light_mode_rounded,
            'Light',
            Colors.orange,
          ),
          const SizedBox(width: 4),
          _buildThemeButton(
            AppThemeMode.dark,
            psychedelicService.currentThemeMode,
            () => psychedelicService.setThemeMode(AppThemeMode.dark),
            Icons.dark_mode_rounded,
            'Dark',
            Colors.indigo,
          ),
          const SizedBox(width: 4),
          _buildThemeButton(
            AppThemeMode.system,
            psychedelicService.currentThemeMode,
            () => psychedelicService.setThemeMode(AppThemeMode.system),
            Icons.settings_system_daydream_rounded,
            'System',
            Colors.green,
          ),
          const SizedBox(width: 4),
          _buildThemeButton(
            AppThemeMode.trippy,
            psychedelicService.currentThemeMode,
            () => psychedelicService.setThemeMode(AppThemeMode.trippy),
            Icons.auto_awesome_rounded,
            'Trippy',
            const Color(0xFFff00ff),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeButton(
    AppThemeMode themeMode,
    AppThemeMode currentMode,
    VoidCallback onTap,
    IconData icon,
    String label,
    Color color,
  ) {
    final isSelected = themeMode == currentMode;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: color, width: 2) : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? color : theme.iconTheme.color?.withOpacity(0.7),
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected ? color : theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}