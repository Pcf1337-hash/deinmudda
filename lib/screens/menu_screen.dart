import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';
import '../services/database_service.dart';
import '../widgets/glass_card.dart';
import '../theme/design_tokens.dart';
import '../theme/spacing.dart';
import 'substance_management_screen.dart';
import 'calendar_screen.dart';
import 'data_export_screen.dart';
import 'advanced_search_screen.dart';
import 'calendar/pattern_analysis_screen.dart';
import 'auth/security_settings_screen.dart'; // Import security settings
import 'notifications/notification_settings_screen.dart'; // Import notification settings
import '../utils/performance_helper.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Determine if we should use animations based on device capabilities
    final useAnimations = PerformanceHelper.shouldEnableAnimations();

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
                  _buildToolsSection(context, isDark),
                  Spacing.verticalSpaceLg,
                  _buildSecuritySection(context, isDark), // New security section
                  Spacing.verticalSpaceLg,
                  _buildAppearanceSection(context, isDark),
                  Spacing.verticalSpaceLg,
                  _buildDataSection(context, isDark),
                  Spacing.verticalSpaceLg,
                  _buildAboutSection(context, isDark),
                  Spacing.verticalSpaceLg,
                  _buildCreditsSection(context, isDark),
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
                'Menü',
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

  Widget _buildToolsSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tools & Funktionen',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ).animate().fadeIn(
          duration: PerformanceHelper.getAnimationDuration(DesignTokens.animationMedium),
          delay: const Duration(milliseconds: 300),
        ),
        Spacing.verticalSpaceMd,
        GlassCard(
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  Icons.calendar_today_rounded,
                  color: DesignTokens.accentCyan,
                ),
                title: const Text('Kalender'),
                subtitle: const Text('Tages-, Wochen- und Monatsansicht'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _navigateToCalendar(),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(
                  Icons.science_rounded,
                  color: DesignTokens.accentCyan,
                ),
                title: const Text('Substanzen verwalten'),
                subtitle: const Text('Eigene Substanzen erstellen und bearbeiten'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _navigateToSubstanceManagement(),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(
                  Icons.search_rounded,
                  color: DesignTokens.accentPurple,
                ),
                title: const Text('Erweiterte Suche'),
                subtitle: const Text('Detaillierte Filteroptionen für Einträge'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _navigateToAdvancedSearch(),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(
                  Icons.insights_rounded,
                  color: DesignTokens.warningYellow,
                ),
                title: const Text('Muster-Analyse'),
                subtitle: const Text('Erkennung von Konsummustern'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _navigateToPatternAnalysis(),
              ),
            ],
          ),
        ).animate().fadeIn(
          duration: PerformanceHelper.getAnimationDuration(DesignTokens.animationMedium),
          delay: const Duration(milliseconds: 400),
        ).slideY(
          begin: 0.3,
          end: 0,
          duration: PerformanceHelper.getAnimationDuration(DesignTokens.animationMedium),
          curve: DesignTokens.curveEaseOut,
        ),
      ],
    );
  }

  // New security section
  Widget _buildSecuritySection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sicherheit & Benachrichtigungen',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ).animate().fadeIn(
          duration: DesignTokens.animationMedium,
          delay: const Duration(milliseconds: 425),
        ),
        Spacing.verticalSpaceMd,
        GlassCard(
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  Icons.security_rounded,
                  color: DesignTokens.successGreen,
                ),
                title: const Text('Sicherheitseinstellungen'),
                subtitle: const Text('App-Sperre und Authentifizierung'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _navigateToSecuritySettings(),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(
                  Icons.notifications_rounded,
                  color: DesignTokens.warningYellow,
                ),
                title: const Text('Benachrichtigungen'),
                subtitle: const Text('Erinnerungen und Benachrichtigungen'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _navigateToNotificationSettings(),
              ),
            ],
          ),
        ).animate().fadeIn(
          duration: DesignTokens.animationMedium,
          delay: const Duration(milliseconds: 450),
        ).slideY(
          begin: 0.3,
          end: 0,
          duration: DesignTokens.animationMedium,
          curve: DesignTokens.curveEaseOut,
        ),
      ],
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
          delay: const Duration(milliseconds: 450),
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
                  Icons.import_export_rounded,
                  color: DesignTokens.accentEmerald,
                ),
                title: const Text('Daten-Export & Import'),
                subtitle: const Text('Daten sichern und wiederherstellen'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _navigateToDataExport(),
              ),
              const Divider(height: 1),
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
                  Icons.security_rounded,
                  color: DesignTokens.successGreen,
                ),
                title: const Text('Datenschutz'),
                subtitle: const Text('Alle Daten bleiben lokal auf Ihrem Gerät'),
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

  Widget _buildCreditsSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Credits',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ).animate().fadeIn(
          duration: DesignTokens.animationMedium,
          delay: const Duration(milliseconds: 750),
        ),
        Spacing.verticalSpaceMd,
        GlassCard(
          child: Column(
            children: [
              Padding(
                padding: Spacing.paddingMd,
                child: Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      color: DesignTokens.errorRed,
                      size: Spacing.iconLg,
                    ),
                    Spacing.horizontalSpaceMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Made with 👃',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Nos Kovsky',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontStyle: FontStyle.italic,
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
        ).animate().fadeIn(
          duration: DesignTokens.animationMedium,
          delay: const Duration(milliseconds: 800),
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

  void _navigateToCalendar() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CalendarScreen(),
      ),
    );
  }

  void _navigateToAdvancedSearch() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AdvancedSearchScreen(),
      ),
    );
  }

  void _navigateToPatternAnalysis() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PatternAnalysisScreen(),
      ),
    );
  }

  void _navigateToDataExport() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const DataExportScreen(),
      ),
    );
  }

  // New navigation methods for security and notifications
  void _navigateToSecuritySettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SecuritySettingsScreen(),
      ),
    );
  }

  void _navigateToNotificationSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NotificationSettingsScreen(),
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