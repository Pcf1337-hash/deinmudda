import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'utils/performance_helper.dart';
import 'utils/platform_helper.dart';
import 'utils/error_handler.dart';
import 'utils/app_initialization_manager.dart';

import 'screens/auth/auth_screen.dart';
import 'screens/main_navigation.dart';
import 'services/database_service.dart';
import 'services/entry_service.dart';
import 'services/substance_service.dart';
import 'services/settings_service.dart';
import 'services/quick_button_service.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'services/timer_service.dart';
import 'services/psychedelic_theme_service.dart';
import 'theme/modern_theme.dart';
import 'widgets/psychedelic_background.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  ErrorHandler.logStartup('MAIN', 'App-Initialisierung gestartet');
  
  // Initialize performance optimizations
  PerformanceHelper.init();
  
  // Enable performance optimization in release mode
  if (kReleaseMode) {
    // Disable debug prints
    debugPrint = (String? message, {int? wrapWidth}) {};
    
    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
  
  // Initialize locale data for German
  await initializeDateFormatting('de_DE', null);
  
  // Set platform-appropriate system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    PlatformHelper.getStatusBarStyle(
      isDark: true, // Will be updated dynamically in the app
      isPsychedelicMode: false,
    ),
  );
  
  // Set edge-to-edge display for modern look
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  
  // Initialize app with proper initialization manager
  final initManager = AppInitializationManager();
  
  ErrorHandler.logStartup('MAIN', 'Starte KonsumTrackerApp...');
  
  runApp(KonsumTrackerApp(
    initManager: initManager,
  ));
}

class KonsumTrackerApp extends StatelessWidget {
  final AppInitializationManager initManager;
  
  const KonsumTrackerApp({
    super.key,
    required this.initManager,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: initManager.initialize(),
      builder: (context, snapshot) {
        // Show initialization screen while loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: InitializationScreen(initManager: initManager),
            debugShowCheckedModeBanner: false,
          );
        }
        
        // Handle initialization completion
        if (snapshot.hasData) {
          return _buildMainApp();
        }
        
        // Handle initialization errors
        return MaterialApp(
          home: InitializationScreen(initManager: initManager),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }

  Widget _buildMainApp() {
    return MultiProvider(
      providers: [
        Provider<DatabaseService>.value(value: initManager.databaseService),
        Provider<EntryService>.value(value: initManager.entryService),
        Provider<SubstanceService>.value(value: initManager.substanceService),
        Provider<QuickButtonService>.value(value: initManager.quickButtonService),
        ChangeNotifierProvider<SettingsService>.value(value: initManager.settingsService),
        ChangeNotifierProvider<PsychedelicThemeService>.value(value: initManager.psychedelicThemeService),
        Provider<AuthService>.value(value: initManager.authService),
        Provider<NotificationService>.value(value: initManager.notificationService),
        Provider<TimerService>.value(value: initManager.timerService),
      ],
      child: Consumer2<SettingsService, PsychedelicThemeService>(
        builder: (context, settingsService, psychedelicService, child) {
          return MaterialApp(
            title: 'Konsum Tracker Pro',
            debugShowCheckedModeBanner: false,
            // Platform-specific theme with page transitions
            theme: psychedelicService.getTheme().copyWith(
              pageTransitionsTheme: PageTransitionsTheme(
                builders: {
                  TargetPlatform.android: PlatformHelper.getPageTransitionsBuilder(),
                  TargetPlatform.iOS: PlatformHelper.getPageTransitionsBuilder(),
                },
              ),
            ),
            home: FutureBuilder<bool>(
              future: _shouldShowAuthScreen(context),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Scaffold(
                    backgroundColor: psychedelicService.isPsychedelicMode 
                      ? const Color(0xFF2c2c2c) 
                      : null,
                    body: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text(
                            'Lade Konsum Tracker Pro...',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                // Handle errors gracefully
                if (snapshot.hasError) {
                  ErrorHandler.logError('MAIN_APP', 'Fehler beim Laden der Auth-Einstellungen: ${snapshot.error}');
                  // Default to main navigation on error
                  return _buildMainContent(psychedelicService, false);
                }
                
                final showAuth = snapshot.data ?? false;
                ErrorHandler.logInfo('MAIN_APP', 'Auth-Status: $showAuth');
                return _buildMainContent(psychedelicService, showAuth);
              },
            ),
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.noScaling,
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
  
  // Helper method to build main content with error handling
  Widget _buildMainContent(PsychedelicThemeService psychedelicService, bool showAuth) {
    try {
      ErrorHandler.logUI('MAIN_CONTENT', 'Baue Hauptinhalt, showAuth: $showAuth');
      
      final mainContent = showAuth ? const AuthScreen() : const MainNavigation();
      
      // Wrap with psychedelic background if enabled and in trippy mode
      if (psychedelicService.isPsychedelicMode) {
        ErrorHandler.logTheme('MAIN_CONTENT', 'Psychedelic-Modus aktiv, verwende PsychedelicBackground');
        return PsychedelicBackground(
          isEnabled: psychedelicService.isAnimatedBackgroundEnabled,
          child: mainContent,
        );
      }
      
      return mainContent;
    } catch (e) {
      ErrorHandler.logError('MAIN_CONTENT', 'Fehler beim Erstellen des Hauptinhalts: $e');
      
      // Fallback to basic navigation
      return const MainNavigation();
    }
  }
  
  // Determine if auth screen should be shown with error handling
  Future<bool> _shouldShowAuthScreen(BuildContext context) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final isAppLockEnabled = await authService.isAppLockEnabled();
      return isAppLockEnabled;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Fehler beim Prüfen der Auth-Einstellungen: $e');
      }
      // Default to false (no auth screen) on error
      return false;
    }
  }
  
}