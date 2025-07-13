import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'utils/performance_helper.dart';

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
  WidgetsFlutterBinding.ensureInitialized();
  
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
  
  // Initialize database
  final databaseService = DatabaseService();
  await databaseService.database;
  
  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.init();
  
  // Initialize timer service
  final timerService = TimerService();
  await timerService.init();
  
  // Initialize psychedelic theme service
  final psychedelicThemeService = PsychedelicThemeService();
  await psychedelicThemeService.init();
    
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
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
            theme: psychedelicService.getTheme(),
            home: FutureBuilder<bool>(
              future: _shouldShowAuthScreen(context),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                
                final showAuth = snapshot.data ?? false;
                final mainContent = showAuth ? const AuthScreen() : const MainNavigation();
                
                // Wrap with psychedelic background if enabled and in trippy mode
                if (psychedelicService.isPsychedelicMode) {
                  return PsychedelicBackground(
                    isEnabled: psychedelicService.isAnimatedBackgroundEnabled,
                    child: mainContent,
                  );
                }
                
                return mainContent;
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
  
  // Determine if auth screen should be shown
  Future<bool> _shouldShowAuthScreen(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final isAppLockEnabled = await authService.isAppLockEnabled();
    return isAppLockEnabled;
  }
  
}