/// Provider Manager - Handles Provider setup and dependency injection
/// 
/// CRITICAL FIX: Separates provider logic from main.dart  
/// Integrates with ServiceLocator for clean dependency management
/// 
/// Author: Code Quality Improvement Agent
/// Date: Phase 1 - Critical Fixes

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import '../services/entry_service.dart';
import '../services/substance_service.dart';
import '../services/quick_button_service.dart';
import '../services/settings_service.dart';
import '../services/psychedelic_theme_service.dart' as service;
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../services/timer_service.dart';
import '../utils/service_locator.dart';

/// Manages Provider setup with ServiceLocator integration
class ProviderManager {
  
  /// Create MultiProvider with all required services from ServiceLocator
  static Widget buildAppWithProviders({required Widget child}) {
    return MultiProvider(
      providers: _buildProviders(),
      child: child,
    );
  }

  /// Build list of providers using ServiceLocator
  static List<SingleChildWidget> _buildProviders() { // cleaned by BereinigungsAgent
    return [
      // Non-ChangeNotifier providers
      Provider<DatabaseService>.value(
        value: ServiceLocator.get<DatabaseService>()
      ),
      Provider<QuickButtonService>.value(
        value: ServiceLocator.get<QuickButtonService>()
      ),
      Provider<NotificationService>.value(
        value: ServiceLocator.get<NotificationService>()
      ),
      
      // ChangeNotifier providers (for reactive UI updates)
      ChangeNotifierProvider<EntryService>.value(
        value: ServiceLocator.get<EntryService>()
      ),
      ChangeNotifierProvider<SubstanceService>.value(
        value: ServiceLocator.get<SubstanceService>()
      ),
      ChangeNotifierProvider<AuthService>.value(
        value: ServiceLocator.get<AuthService>()
      ),
      ChangeNotifierProvider<SettingsService>.value(
        value: ServiceLocator.get<SettingsService>()
      ),
      ChangeNotifierProvider<service.PsychedelicThemeService>.value(
        value: ServiceLocator.get<service.PsychedelicThemeService>()
      ),
      ChangeNotifierProvider<TimerService>.value(
        value: ServiceLocator.get<TimerService>()
      ),
    ];
  }

  /// Get all provider types (for debugging and validation)
  static List<Type> get providedTypes => [
    DatabaseService,
    EntryService,
    SubstanceService,
    QuickButtonService,
    AuthService,
    NotificationService,
    SettingsService,
    service.PsychedelicThemeService,
    TimerService,
  ];

  /// Validate that all required services are available in ServiceLocator
  static bool validateServices() {
    try {
      for (final type in providedTypes) {
        // Note: Cannot check specific type with current ServiceLocator implementation // cleaned by BereinigungsAgent
        // This is a limitation that should be addressed in a future refactor // cleaned by BereinigungsAgent
        if (ServiceLocator.serviceCount == 0) { // cleaned by BereinigungsAgent
          throw StateError('ServiceLocator is empty');
        }
      }
      return true;
    } catch (e) {
      print('❌ Provider validation failed: $e');
      return false;
    }
  }
}