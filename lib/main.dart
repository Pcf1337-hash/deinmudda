import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'utils/performance_helper.dart';
import 'utils/platform_helper.dart';

import 'screens/auth/auth_screen.dart'; // Import the auth screen
import 'screens/main_navigation.dart';
import 'services/database_service.dart';
import 'services/entry_service.dart';
import 'services/substance_service.dart';
import 'services/settings_service.dart';
import 'services/quick_button_service.dart';
import 'services/auth_service.dart'; // Import the auth service
import 'services/notification_service.dart'; // Import the notification service
import 'services/timer_service.dart'; // Import the timer service
import 'services/psychedelic_theme_service.dart'; // Import the psychedelic theme service
import 'theme/modern_theme.dart';
import 'widgets/psychedelic_background.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  if (kDebugMode) {
    print('🚀 Initialisiere Theme...');
  }
  
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
  
  // Initialize services with proper error handling
  late DatabaseService databaseService;
  late NotificationService notificationService;
  late TimerService timerService;
  late PsychedelicThemeService psychedelicThemeService;
  
  try {
    // Initialize database
    if (kDebugMode) {
      print('🗄️ Initialisiere Database...');
    }
    databaseService = DatabaseService();
    await databaseService.database;
    
    // Initialize notification service
    if (kDebugMode) {
      print('🔔 Initialisiere Notifications...');
    }
    notificationService = NotificationService();
    await notificationService.init();
    
    // Initialize timer service
    if (kDebugMode) {
      print('⏰ Initialisiere TimerService...');
    }
    timerService = TimerService();
    await timerService.init();
    
    // Initialize psychedelic theme service
    if (kDebugMode) {
      print('🎨 Initialisiere PsychedelicThemeService...');
    }
    psychedelicThemeService = PsychedelicThemeService();
    await psychedelicThemeService.init();
    
    if (kDebugMode) {
      print('✅ Alle Services initialisiert');
    }
  } catch (e) {
    if (kDebugMode) {
      print('❌ Fehler bei Service-Initialisierung: $e');
    }
    
    // Create fallback services to prevent white screen
    databaseService = DatabaseService();
    notificationService = NotificationService();
    timerService = TimerService();
    psychedelicThemeService = PsychedelicThemeService();
  }
    
  // Set platform-appropriate system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    PlatformHelper.getStatusBarStyle(
      isDark: true, // Will be updated dynamically in the app
      isPsychedelicMode: false,
    ),
  );
  
  // Set edge-to-edge display for modern look
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  
  if (kDebugMode) {
    print('🏁 Starte App...');
  }
  
  runApp(KonsumTrackerApp(
    psychedelicThemeService: psychedelicThemeService,
  ));
}

class KonsumTrackerApp extends StatelessWidget {
  final PsychedelicThemeService psychedelicThemeService;
  
  const KonsumTrackerApp({
    super.key,
    required this.psychedelicThemeService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DatabaseService>(
          create: (_) => DatabaseService(),
        ),
        ProxyProvider<DatabaseService, EntryService>(
          update: (_, db, __) => EntryService(),
        ),
        ProxyProvider<DatabaseService, SubstanceService>(
          update: (_, db, __) => SubstanceService(),
        ),
        ProxyProvider<DatabaseService, QuickButtonService>(
          update: (_, db, __) => QuickButtonService(),
        ),
        ChangeNotifierProvider<SettingsService>(
          create: (_) => SettingsService(),
        ),
        ChangeNotifierProvider<PsychedelicThemeService>.value(
          value: psychedelicThemeService,
        ),
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        Provider<NotificationService>(
          create: (_) => NotificationService(),
        ),
        Provider<TimerService>(
          create: (_) => TimerService(),
        ),
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
                  if (kDebugMode) {
                    print('❌ Fehler beim Laden der Auth-Einstellungen: ${snapshot.error}');
                  }
                  // Default to main navigation on error
                  return _buildMainContent(psychedelicService, false);
                }
                
                final showAuth = snapshot.data ?? false;
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
      final mainContent = showAuth ? const AuthScreen() : const MainNavigation();
      
      // Wrap with psychedelic background if enabled and in trippy mode
      if (psychedelicService.isPsychedelicMode) {
        return PsychedelicBackground(
          isEnabled: psychedelicService.isAnimatedBackgroundEnabled,
          child: mainContent,
        );
      }
      
      return mainContent;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Fehler beim Erstellen des Hauptinhalts: $e');
      }
      
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