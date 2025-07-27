import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/timer_service.dart';
import '../services/psychedelic_theme_service.dart';
import '../services/notification_service.dart';
import '../services/entry_service.dart';
import '../services/substance_service.dart';
import '../services/settings_service.dart';
import '../services/quick_button_service.dart';
import '../services/auth_service.dart';
import '../interfaces/service_interfaces.dart';
import 'service_locator.dart';
import 'error_handler.dart';

enum AppInitializationPhase {
  starting,
  database,
  services,
  theme,
  notifications,
  timer,
  complete,
  error,
}

class AppInitializationManager {
  static final AppInitializationManager _instance = AppInitializationManager._internal();
  factory AppInitializationManager() => _instance;
  AppInitializationManager._internal();

  AppInitializationPhase _currentPhase = AppInitializationPhase.starting;
  String _currentStepDescription = '';
  String? _errorMessage;
  bool _isInitialized = false;

  // Service instances
  DatabaseService? _databaseService;
  TimerService? _timerService;
  PsychedelicThemeService? _psychedelicThemeService;
  NotificationService? _notificationService;
  EntryService? _entryService;
  SubstanceService? _substanceService;
  SettingsService? _settingsService;
  QuickButtonService? _quickButtonService;
  AuthService? _authService;

  // Getters for services
  DatabaseService get databaseService => _databaseService!;
  TimerService get timerService => _timerService!;
  PsychedelicThemeService get psychedelicThemeService => _psychedelicThemeService!;
  NotificationService get notificationService => _notificationService!;
  EntryService get entryService => _entryService!;
  SubstanceService get substanceService => _substanceService!;
  SettingsService get settingsService => _settingsService!;
  QuickButtonService get quickButtonService => _quickButtonService!;
  AuthService get authService => _authService!;

  // Status getters
  AppInitializationPhase get currentPhase => _currentPhase;
  String get currentStepDescription => _currentStepDescription;
  String? get errorMessage => _errorMessage;
  bool get isInitialized => _isInitialized;
  bool get hasError => _currentPhase == AppInitializationPhase.error;

  /// Initialize all app services in the correct order
  Future<bool> initialize() async {
    try {
      ErrorHandler.logStartup('INIT_MANAGER', 'App-Initialisierung gestartet');
      
      // Phase 1: Database
      await _initializeDatabase();
      
      // Phase 2: Core Services
      await _initializeCoreServices();
      
      // Phase 3: Theme Service
      await _initializeThemeService();
      
      // Phase 4: Notifications
      await _initializeNotifications();
      
      // Phase 5: Timer Service
      await _initializeTimerService();
      
      // Phase 6: Complete
      _setPhase(AppInitializationPhase.complete, 'Initialisierung abgeschlossen');
      _isInitialized = true;
      
      ErrorHandler.logSuccess('INIT_MANAGER', 'App-Initialisierung erfolgreich abgeschlossen');
      return true;
      
    } catch (e, stackTrace) {
      ErrorHandler.logError('INIT_MANAGER', 'Kritischer Fehler bei App-Initialisierung: $e', stackTrace: stackTrace);
      _setPhase(AppInitializationPhase.error, 'Initialisierung fehlgeschlagen: $e');
      _errorMessage = e.toString();
      
      // Create fallback services
      await _createFallbackServices();
      
      return false;
    }
  }

  Future<void> _initializeDatabase() async {
    _setPhase(AppInitializationPhase.database, 'Initialisiere Datenbank...');
    
    try {
      _databaseService = DatabaseService(); // Bootstrap instance before ServiceLocator
      await _databaseService!.database;
      ErrorHandler.logSuccess('INIT_MANAGER', 'Datenbank erfolgreich initialisiert');
    } catch (e) {
      ErrorHandler.logError('INIT_MANAGER', 'Fehler bei Datenbank-Initialisierung: $e');
      _databaseService = DatabaseService(); // Bootstrap fallback before ServiceLocator
    }
  }

  Future<void> _initializeCoreServices() async {
    _setPhase(AppInitializationPhase.services, 'Initialisiere Kern-Services...');
    
    try {
      // Use ServiceLocator to initialize all services with proper dependencies
      await ServiceLocator.initialize();
      
      // Get service instances from ServiceLocator
      _databaseService = ServiceLocator.get<DatabaseService>();
      _entryService = ServiceLocator.get<EntryService>();
      _substanceService = ServiceLocator.get<SubstanceService>();
      _settingsService = ServiceLocator.get<SettingsService>();
      _quickButtonService = ServiceLocator.get<QuickButtonService>();
      _authService = ServiceLocator.get<AuthService>();
      _notificationService = ServiceLocator.get<NotificationService>();
      _timerService = ServiceLocator.get<TimerService>();
      _psychedelicThemeService = ServiceLocator.get<PsychedelicThemeService>();
      
      // Initialize default quick buttons for common substances
      try {
        final createdButtons = await _quickButtonService!.createDefaultQuickButtons();
        if (createdButtons.isNotEmpty) {
          ErrorHandler.logInfo('INIT_MANAGER', 'Standard-Quick-Buttons erstellt: ${createdButtons.length}');
        }
      } catch (e) {
        ErrorHandler.logWarning('INIT_MANAGER', 'Warnung beim Erstellen der Standard-Quick-Buttons: $e');
        // Don't fail initialization if quick buttons creation fails
      }
      
      ErrorHandler.logSuccess('INIT_MANAGER', 'Kern-Services erfolgreich initialisiert');
    } catch (e) {
      ErrorHandler.logError('INIT_MANAGER', 'Fehler bei Kern-Service-Initialisierung: $e');
      
      // In case of error, still try to get what services we can from ServiceLocator
      try {
        _databaseService = ServiceLocator.get<DatabaseService>();
        _entryService = ServiceLocator.get<EntryService>();
        _substanceService = ServiceLocator.get<SubstanceService>();
        _settingsService = ServiceLocator.get<SettingsService>();
        _quickButtonService = ServiceLocator.get<QuickButtonService>();
        _authService = ServiceLocator.get<AuthService>();
        _notificationService = ServiceLocator.get<NotificationService>();
        _timerService = ServiceLocator.get<TimerService>();
        _psychedelicThemeService = ServiceLocator.get<PsychedelicThemeService>();
      } catch (serviceError) {
        ErrorHandler.logError('INIT_MANAGER', 'Fallback-Services konnten nicht geladen werden: $serviceError');
        // Services will remain null, which will be handled by the app
      }
    }
  }

  Future<void> _initializeThemeService() async {
    _setPhase(AppInitializationPhase.theme, 'Initialisiere Theme-Service...');
    
    try {
      // Theme service is already initialized by ServiceLocator
      // Just verify it's available
      _psychedelicThemeService ??= ServiceLocator.get<PsychedelicThemeService>();
      ErrorHandler.logSuccess('INIT_MANAGER', 'Theme-Service erfolgreich initialisiert');
    } catch (e) {
      ErrorHandler.logError('INIT_MANAGER', 'Fehler bei Theme-Service-Initialisierung: $e');
      // Theme service will remain null, which will be handled by the app
    }
  }

  Future<void> _initializeNotifications() async {
    _setPhase(AppInitializationPhase.notifications, 'Initialisiere Benachrichtigungen...');
    
    try {
      // Notification service is already initialized by ServiceLocator
      // Just verify it's available
      _notificationService ??= ServiceLocator.get<NotificationService>();
      ErrorHandler.logSuccess('INIT_MANAGER', 'Benachrichtigungen erfolgreich initialisiert');
    } catch (e) {
      ErrorHandler.logError('INIT_MANAGER', 'Fehler bei Benachrichtigungs-Initialisierung: $e');
      // Notification service will remain null, which will be handled by the app
    }
  }

  Future<void> _initializeTimerService() async {
    _setPhase(AppInitializationPhase.timer, 'Initialisiere Timer-Service...');
    
    try {
      // Timer service is already initialized by ServiceLocator
      // Just verify it's available
      _timerService ??= ServiceLocator.get<TimerService>();
      ErrorHandler.logSuccess('INIT_MANAGER', 'Timer-Service erfolgreich initialisiert');
    } catch (e) {
      ErrorHandler.logError('INIT_MANAGER', 'Fehler bei Timer-Service-Initialisierung: $e');
      // Timer service will remain null, which will be handled by the app
    }
  }

  Future<void> _createFallbackServices() async {
    try {
      ErrorHandler.logWarning('INIT_MANAGER', 'Erstelle Fallback-Services...');
      
      // Try to get services from ServiceLocator as fallback
      try {
        _databaseService ??= ServiceLocator.get<DatabaseService>();
        _entryService ??= ServiceLocator.get<EntryService>();
        _substanceService ??= ServiceLocator.get<SubstanceService>();
        _settingsService ??= ServiceLocator.get<SettingsService>();
        _quickButtonService ??= ServiceLocator.get<QuickButtonService>();
        _authService ??= ServiceLocator.get<AuthService>();
        _notificationService ??= ServiceLocator.get<NotificationService>();
        _timerService ??= ServiceLocator.get<TimerService>();
        _psychedelicThemeService ??= ServiceLocator.get<PsychedelicThemeService>();
      } catch (serviceError) {
        ErrorHandler.logError('INIT_MANAGER', 'ServiceLocator-Fallback fehlgeschlagen: $serviceError');
        // Services will remain null, which will be handled by the app
      }
      
      _isInitialized = true;
      ErrorHandler.logSuccess('INIT_MANAGER', 'Fallback-Services erfolgreich erstellt');
    } catch (e) {
      ErrorHandler.logError('INIT_MANAGER', 'Fehler beim Erstellen der Fallback-Services: $e');
    }
  }

  void _setPhase(AppInitializationPhase phase, String description) {
    _currentPhase = phase;
    _currentStepDescription = description;
    
    ErrorHandler.logStartup('INIT_PHASE', '$phase: $description');
  }

  /// Reset initialization state (for testing purposes)
  void reset() {
    _currentPhase = AppInitializationPhase.starting;
    _currentStepDescription = '';
    _errorMessage = null;
    _isInitialized = false;
    
    // Clear services
    _databaseService = null;
    _entryService = null;
    _substanceService = null;
    _settingsService = null;
    _quickButtonService = null;
    _authService = null;
    _notificationService = null;
    _timerService = null;
    _psychedelicThemeService = null;
    
    ErrorHandler.logInfo('INIT_MANAGER', 'Initialisierung zurückgesetzt');
  }

  /// Get initialization progress as percentage
  double get initializationProgress {
    switch (_currentPhase) {
      case AppInitializationPhase.starting:
        return 0.0;
      case AppInitializationPhase.database:
        return 0.2;
      case AppInitializationPhase.services:
        return 0.4;
      case AppInitializationPhase.theme:
        return 0.6;
      case AppInitializationPhase.notifications:
        return 0.8;
      case AppInitializationPhase.timer:
        return 0.9;
      case AppInitializationPhase.complete:
        return 1.0;
      case AppInitializationPhase.error:
        return 0.0;
    }
  }

  /// Dispose all services
  void dispose() {
    try {
      ErrorHandler.logDispose('INIT_MANAGER', 'Dispose aller Services...');
      
      _timerService?.dispose();
      
      ErrorHandler.logSuccess('INIT_MANAGER', 'Alle Services erfolgreich disposed');
    } catch (e) {
      ErrorHandler.logError('INIT_MANAGER', 'Fehler beim Dispose der Services: $e');
    }
  }
}

/// Widget that shows initialization progress
class InitializationScreen extends StatefulWidget {
  final AppInitializationManager initManager;
  
  const InitializationScreen({
    super.key,
    required this.initManager,
  });

  @override
  State<InitializationScreen> createState() => _InitializationScreenState();
}

class _InitializationScreenState extends State<InitializationScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = widget.initManager.initializationProgress;
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo/Icon
              Icon(
                Icons.psychology,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              
              const SizedBox(height: 32),
              
              // App Name
              Text(
                'Konsum Tracker Pro',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 48),
              
              // Progress Indicator
              SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: theme.colorScheme.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Current Step Description
              Text(
                widget.initManager.currentStepDescription,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              
              // Error Message (if any)
              if (widget.initManager.hasError) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: theme.colorScheme.onErrorContainer,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Initialisierung fehlgeschlagen',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onErrorContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Die App wird mit Standard-Einstellungen gestartet.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onErrorContainer,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}