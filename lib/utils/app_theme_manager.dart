/// App Theme Manager - Handles theme and UI configuration
/// 
/// CRITICAL FIX: Separates theme logic from main.dart
/// Improves maintainability and reduces complexity
/// 
/// Author: Code Quality Improvement Agent
/// Date: Phase 1 - Critical Fixes

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/psychedelic_theme_service.dart' as service;
import '../interfaces/service_interfaces.dart' show AppThemeMode;
import '../services/auth_service.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/main_navigation.dart';
import '../widgets/psychedelic_background.dart';
import '../utils/error_handler.dart';
import '../utils/service_locator.dart';
import '../utils/keyboard_handler.dart';

/// Manages theme configuration and main app structure
class AppThemeManager {
  
  /// Build the main MaterialApp with proper theme configuration
  static Widget buildMaterialApp() {
    // Get theme service from service locator
    final psychedelicService = ServiceLocator.get<service.PsychedelicThemeService>();
    
    return Consumer<service.PsychedelicThemeService>(
      builder: (context, themeService, child) {
        return MaterialApp(
          title: 'Konsum Tracker Pro',
          debugShowCheckedModeBanner: false,
          
          // Navigation key for global access
          navigatorKey: NavigationService.navigatorKey,
          
          // Theme configuration
          theme: themeService.getTheme(),
          darkTheme: themeService.getTheme(), 
          themeMode: _getThemeMode(themeService),
          
          // Main app content
          home: AppContentBuilder(),
          
          // Global text scaling disabled for consistent UI
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
    );
  }

  /// Convert service theme mode to Flutter theme mode
  static ThemeMode _getThemeMode(service.PsychedelicThemeService themeService) {
    switch (themeService.currentThemeMode) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.trippy:
        return ThemeMode.dark; // Use dark mode as base for trippy mode
    }
  }
}

/// Builds the main app content with proper loading and error states
class AppContentBuilder extends StatefulWidget {
  const AppContentBuilder({super.key});

  @override
  State<AppContentBuilder> createState() => _AppContentBuilderState();
}

class _AppContentBuilderState extends State<AppContentBuilder> {
  
  @override
  Widget build(BuildContext context) {
    final psychedelicService = ServiceLocator.get<service.PsychedelicThemeService>();
    
    return FutureBuilder<bool>(
      future: _shouldShowAuthScreen(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen(psychedelicService);
        }
        
        // Error state
        if (snapshot.hasError) {
          ErrorHandler.logError('APP_CONTENT', 'Fehler beim Laden der Auth-Einstellungen: ${snapshot.error}');
          return _buildMainContent(psychedelicService, false);
        }
        
        // Success state
        final showAuth = snapshot.data ?? false;
        ErrorHandler.logInfo('APP_CONTENT', 'Auth-Status: $showAuth');
        return _buildMainContent(psychedelicService, showAuth);
      },
    );
  }

  /// Build loading screen with app branding
  Widget _buildLoadingScreen(service.PsychedelicThemeService psychedelicService) {
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

  /// Build main app content with proper error handling
  Widget _buildMainContent(service.PsychedelicThemeService psychedelicService, bool showAuth) {
    try {
      ErrorHandler.logUI('APP_CONTENT', 'Baue Hauptinhalt, showAuth: $showAuth');
      
      final mainContent = showAuth ? const AuthScreen() : const MainNavigation();
      
      // Wrap with psychedelic background if enabled
      if (psychedelicService.isPsychedelicMode) {
        ErrorHandler.logTheme('APP_CONTENT', 'Psychedelic-Modus aktiv, verwende PsychedelicBackground');
        return PsychedelicBackground(
          isEnabled: psychedelicService.isAnimatedBackgroundEnabled,
          child: mainContent,
        );
      }
      
      return mainContent;
    } catch (e) {
      ErrorHandler.logError('APP_CONTENT', 'Fehler beim Erstellen des Hauptinhalts: $e');
      
      // Fallback to basic navigation
      return const MainNavigation();
    }
  }

  /// Determine if auth screen should be shown
  Future<bool> _shouldShowAuthScreen() async {
    try {
      final authService = ServiceLocator.get<AuthService>();
      final isAppLockEnabled = await authService.isAppLockEnabled();
      return isAppLockEnabled;
    } catch (e) {
      ErrorHandler.logError('APP_CONTENT', 'Fehler beim Prüfen der Auth-Einstellungen: $e');
      // Default to false (no auth screen) on error
      return false;
    }
  }
}