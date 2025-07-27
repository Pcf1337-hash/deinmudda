import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';
import '../services/database_service.dart';
import '../services/psychedelic_theme_service.dart' as service;
import '../interfaces/service_interfaces.dart'; // For AppThemeMode
import '../widgets/glass_card.dart';
import '../widgets/header_bar.dart';
import '../theme/design_tokens.dart';
import '../theme/spacing.dart';
import '../utils/safe_navigation.dart';
import 'substance_management_screen.dart';
import 'calendar_screen.dart';
import 'data_export_screen.dart';
import 'advanced_search_screen.dart';
import 'calendar/pattern_analysis_screen.dart';
import 'auth/security_settings_screen.dart'; // Import security settings
import 'notifications/notification_settings_screen.dart'; // Import notification settings
import 'timer_dashboard_screen.dart'; // Import timer dashboard
import 'dosage_card_example_screen.dart'; // Import dosage card example
import 'enhanced_dosage_cards_screen.dart'; // Import enhanced dosage cards
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

    return Consumer<service.PsychedelicThemeService>(
      builder: (context, psychedelicService, child) {
        final isPsychedelicMode = psychedelicService.isPsychedelicMode;
        
        return Scaffold(
          backgroundColor: isPsychedelicMode 
            ? DesignTokens.psychedelicBackground 
            : null,
          body: Container(
            decoration: isPsychedelicMode 
              ? const BoxDecoration(
                  gradient: DesignTokens.psychedelicBackground1,
                ) 
              : null,
            child: Column(
              children: [
                HeaderBar(
                  title: 'Menü',
                  subtitle: 'Einstellungen & Tools',
                  showLightningIcon: false,
                  customIcon: Icons.menu_rounded,
                  showBackButton: false, // This is in main navigation
                ),
                Expanded(
                  child: ListView(
                    padding: Spacing.paddingHorizontalMd,
                    children: [
                      Spacing.verticalSpaceLg,
                      _buildToolsSection(context, isDark, psychedelicService),
                      Spacing.verticalSpaceLg,
                      _buildSecuritySection(context, isDark, psychedelicService),
                      Spacing.verticalSpaceLg,
                      _buildAppearanceSection(context, isDark, psychedelicService),
                      Spacing.verticalSpaceLg,
                      _buildDataSection(context, isDark, psychedelicService),
                      Spacing.verticalSpaceLg,
                      _buildAboutSection(context, isDark, psychedelicService),
                      Spacing.verticalSpaceLg,
                      _buildCreditsSection(context, isDark, psychedelicService),
                      const SizedBox(height: 120), // Bottom padding
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark, service.PsychedelicThemeService psychedelicService) {
    final theme = Theme.of(context);

    return Container(
      height: 140,
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.menu_rounded,
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
                          'Menü & Einstellungen',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tools, Funktionen & Konfiguration',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolsSection(BuildContext context, bool isDark, service.PsychedelicThemeService psychedelicService) {
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
              const Divider(height: 1),
              ListTile(
                leading: Icon(
                  Icons.timer_rounded,
                  color: DesignTokens.accentPink,
                ),
                title: const Text('Timer Dashboard'),
                subtitle: const Text('Aktive Timer und Countdowns verwalten'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _navigateToTimerDashboard(),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(
                  Icons.dashboard_customize_rounded,
                  color: DesignTokens.accentPurple,
                ),
                title: const Text('Dosis-Kacheln'),
                subtitle: const Text('Moderne Glassmorphism Design-Beispiele'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _navigateToDosageCardExample(),
              ),
              ListTile(
                leading: Icon(
                  Icons.dashboard_customize_outlined,
                  color: DesignTokens.accentPurple.withOpacity(0.8),
                ),
                title: const Text('Erweiterte Dosis-Kacheln'),
                subtitle: const Text('Umfassende Substanzinformationen mit allen Details'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'NEU',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_ios),
                  ],
                ),
                onTap: () => _navigateToEnhancedDosageCards(),
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
  Widget _buildSecuritySection(BuildContext context, bool isDark, service.PsychedelicThemeService psychedelicService) {
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

  Widget _buildAppearanceSection(BuildContext context, bool isDark, service.PsychedelicThemeService psychedelicService) {
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
        // Updated to use PsychedelicThemeService instead of SettingsService
        GlassCard(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('🌗 Dark Mode'),
                subtitle: const Text('Dunkles Design verwenden'),
                value: psychedelicService.currentThemeMode == AppThemeMode.dark || psychedelicService.currentThemeMode == AppThemeMode.trippy,
                onChanged: (value) {
                  if (value) {
                    psychedelicService.setThemeMode(AppThemeMode.dark);
                  } else {
                    psychedelicService.setThemeMode(AppThemeMode.light);
                  }
                },
                secondary: Icon(
                  psychedelicService.currentThemeMode == AppThemeMode.light ? Icons.light_mode : Icons.dark_mode,
                  color: DesignTokens.primaryIndigo,
                ),
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('🌈 Trippy Mode'),
                subtitle: const Text('Psychedelisches Design mit Neon-Effekten'),
                value: psychedelicService.isTrippyMode,
                onChanged: (value) {
                  psychedelicService.toggleTrippyMode(value);
                },
                secondary: Icon(
                  Icons.auto_awesome_rounded,
                  color: psychedelicService.isTrippyMode ? const Color(0xFFff00ff) : DesignTokens.primaryIndigo,
                ),
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

  Widget _buildDataSection(BuildContext context, bool isDark, service.PsychedelicThemeService psychedelicService) {
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

  Widget _buildAboutSection(BuildContext context, bool isDark, service.PsychedelicThemeService psychedelicService) {
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

  Widget _buildCreditsSection(BuildContext context, bool isDark, service.PsychedelicThemeService psychedelicService) {
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
    SafeNavigation.pushSafe(context, const SubstanceManagementScreen());
  }

  void _navigateToCalendar() {
    SafeNavigation.pushSafe(context, const CalendarScreen());
  }

  void _navigateToAdvancedSearch() {
    SafeNavigation.pushSafe(context, const AdvancedSearchScreen());
  }

  void _navigateToPatternAnalysis() {
    SafeNavigation.pushSafe(context, const PatternAnalysisScreen());
  }

  void _navigateToTimerDashboard() {
    SafeNavigation.pushSafe(context, const TimerDashboardScreen());
  }

  void _navigateToDosageCardExample() {
    SafeNavigation.pushSafe(context, const DosageCardExampleScreen());
  }

  void _navigateToEnhancedDosageCards() {
    SafeNavigation.pushSafe(context, const EnhancedDosageCardsScreen());
  }

  void _navigateToDataExport() {
    SafeNavigation.pushSafe(context, const DataExportScreen());
  }

  // New navigation methods for security and notifications
  void _navigateToSecuritySettings() {
    SafeNavigation.pushSafe(context, const SecuritySettingsScreen());
  }

  void _navigateToNotificationSettings() {
    SafeNavigation.pushSafe(context, const NotificationSettingsScreen());
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