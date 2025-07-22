/// Service Locator for Dependency Injection
/// 
/// CRITICAL FIX: Replaces singleton anti-pattern with proper DI
/// This prevents memory leaks and improves testability
/// 
/// Author: Code Quality Improvement Agent
/// Date: Phase 1 - Critical Fixes

import 'package:flutter/foundation.dart';
import '../services/database_service.dart';
import '../services/timer_service.dart';
import '../services/notification_service.dart';
import '../services/auth_service.dart';
import '../services/entry_service.dart';
import '../services/substance_service.dart';
import '../services/settings_service.dart';
import '../services/quick_button_service.dart';
import '../services/psychedelic_theme_service.dart';
import '../repositories/entry_repository.dart';
import '../repositories/substance_repository.dart';
import '../use_cases/entry_use_cases.dart';
import '../use_cases/substance_use_cases.dart';

/// Simple Service Locator implementation
/// TODO: Consider replacing with get_it package for production
class ServiceLocator {
  static final Map<Type, Object> _services = {};
  static bool _isInitialized = false;

  /// Initialize all services with proper dependency injection
  static Future<void> initialize() async {
    if (_isInitialized) {
      if (kDebugMode) {
        print('⚠️ ServiceLocator already initialized');
      }
      return;
    }

    try {
      if (kDebugMode) {
        print('🔧 Initializing ServiceLocator...');
      }

      // Initialize core services first (order matters for dependencies)
      final databaseService = DatabaseService();
      _services[DatabaseService] = databaseService;
      
      // Initialize repositories (depend on database service)
      final entryRepository = EntryRepository(databaseService);
      final substanceRepository = SubstanceRepository(databaseService);
      _services[IEntryRepository] = entryRepository;
      _services[ISubstanceRepository] = substanceRepository;
      
      // Initialize notification service
      final notificationService = NotificationService();
      await notificationService.init();
      _services[NotificationService] = notificationService;
      
      // Initialize auth service
      _services[AuthService] = AuthService();
      
      // Initialize business logic services
      _services[SubstanceService] = SubstanceService();
      _services[EntryService] = EntryService();
      _services[SettingsService] = SettingsService();
      _services[QuickButtonService] = QuickButtonService();
      
      // Initialize timer service (depends on other services)
      final timerService = TimerService();
      await timerService.init();
      _services[TimerService] = timerService;
      
      // Initialize theme service
      _services[PsychedelicThemeService] = PsychedelicThemeService();

      // Initialize use cases (depend on repositories and services)
      _services[CreateEntryUseCase] = CreateEntryUseCase(entryRepository, substanceRepository);
      _services[CreateEntryWithTimerUseCase] = CreateEntryWithTimerUseCase(
        entryRepository, 
        substanceRepository, 
        timerService,
      );
      _services[UpdateEntryUseCase] = UpdateEntryUseCase(entryRepository, substanceRepository);
      _services[DeleteEntryUseCase] = DeleteEntryUseCase(entryRepository, timerService);
      _services[GetEntriesUseCase] = GetEntriesUseCase(entryRepository);
      
      _services[CreateSubstanceUseCase] = CreateSubstanceUseCase(substanceRepository);
      _services[UpdateSubstanceUseCase] = UpdateSubstanceUseCase(substanceRepository);
      _services[DeleteSubstanceUseCase] = DeleteSubstanceUseCase(substanceRepository, entryRepository);
      _services[GetSubstancesUseCase] = GetSubstancesUseCase(substanceRepository);
      _services[SubstanceStatisticsUseCase] = SubstanceStatisticsUseCase(substanceRepository, entryRepository);

      _isInitialized = true;
      
      if (kDebugMode) {
        print('✅ ServiceLocator initialized with ${_services.length} services');
      }
    } catch (e) {
      if (kDebugMode) {
        print('🚨 ServiceLocator initialization failed: $e');
      }
      rethrow;
    }
  }

  /// Get service instance by type
  static T get<T>() {
    if (!_isInitialized) {
      throw StateError(
        'ServiceLocator not initialized. Call ServiceLocator.initialize() first.'
      );
    }
    
    final service = _services[T];
    if (service == null) {
      throw StateError('Service of type $T not found in ServiceLocator');
    }
    
    return service as T;
  }

  /// Register a service instance (for testing or manual registration)
  static void register<T>(T service) {
    _services[T] = service as Object;
  }

  /// Check if a service is registered
  static bool isRegistered<T>() {
    return _services.containsKey(T);
  }

  /// Dispose all services and clear the locator
  /// IMPORTANT: Call this before app shutdown to prevent memory leaks
  static Future<void> dispose() async {
    if (kDebugMode) {
      print('🧹 Disposing ServiceLocator...');
    }

    // Dispose services that implement dispose pattern
    for (final service in _services.values) {
      if (service is TimerService) {
        service.dispose();
      }
      // Add other services that need disposal here
    }

    _services.clear();
    _isInitialized = false;
    
    if (kDebugMode) {
      print('✅ ServiceLocator disposed');
    }
  }

  /// Get all registered service types (for debugging)
  static List<Type> get registeredTypes => _services.keys.toList();
  
  /// Get service count (for debugging)
  static int get serviceCount => _services.length;
}

/// Extension for easier access to services
extension ServiceLocatorExtension on Object {
  /// Get service from locator
  T getService<T>() => ServiceLocator.get<T>();
}