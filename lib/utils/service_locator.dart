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
import '../interfaces/service_interfaces.dart';

/// Simple Service Locator implementation for dependency injection.
/// 
/// Provides a centralized registry for services and use cases,
/// ensuring proper initialization order and dependency management.
/// 
/// TODO: Consider replacing with get_it package for production
class ServiceLocator {
  /// Registry of all registered services by type
  static final Map<Type, Object> _services = {};
  
  /// Flag to track initialization state
  static bool _isInitialized = false;

  /// Initialize all services with proper dependency injection.
  /// 
  /// Services are initialized in dependency order to ensure
  /// all required dependencies are available when needed.
  /// 
  /// Throws [StateError] if initialization fails.
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
      _services[INotificationService] = notificationService;
      
      // Initialize settings service
      final settingsService = SettingsService();
      await settingsService.init();
      _services[SettingsService] = settingsService;
      _services[ISettingsService] = settingsService;
      
      // Initialize auth service
      final authService = AuthService();
      await authService.init();
      _services[AuthService] = authService;
      _services[IAuthService] = authService;
      
      // Initialize business logic services with repository dependencies
      final substanceService = SubstanceService(substanceRepository);
      final entryService = EntryService(entryRepository);
      _services[SubstanceService] = substanceService;
      _services[ISubstanceService] = substanceService;
      _services[EntryService] = entryService;
      _services[IEntryService] = entryService;
      
      // Initialize quick button service (depends on database and substance service)
      final quickButtonService = QuickButtonService(databaseService, substanceService);
      _services[QuickButtonService] = quickButtonService;
      _services[IQuickButtonService] = quickButtonService;
      
      // Initialize timer service (depends on other services)
      final timerService = TimerService(
        entryService,
        substanceService,
        notificationService,
      );
      await timerService.init();
      _services[TimerService] = timerService;
      _services[ITimerService] = timerService;
      
      // Initialize theme service
      final themeService = PsychedelicThemeService();
      await themeService.init();
      _services[PsychedelicThemeService] = themeService;
      _services[IPsychedelicThemeService] = themeService;

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

  /// Get service instance by type.
  /// 
  /// Returns the registered service instance of type [T].
  /// 
  /// Throws [StateError] if ServiceLocator is not initialized
  /// or if the requested service type is not registered.
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

  /// Register a service instance manually.
  /// 
  /// Primarily used for testing or manual service registration.
  /// The service will be registered under type [T].
  static void register<T>(T service) {
    _services[T] = service as Object;
  }

  /// Check if a service is registered.
  /// 
  /// Returns true if a service of type [T] is currently registered.
  static bool isRegistered<T>() {
    return _services.containsKey(T);
  }

  /// Initialize ServiceLocator for testing with mock services.
  /// 
  /// Replaces production services with mock implementations
  /// for unit testing. All existing services are disposed first.
  /// 
  /// [mockServices] Map of service names to mock implementations.
  static Future<void> initializeForTesting(Map<String, dynamic> mockServices) async {
    if (_isInitialized) {
      await dispose();
    }

    try {
      if (kDebugMode) {
        print('🧪 Initializing ServiceLocator for testing...');
      }

      // Register mock services
      if (mockServices.containsKey('entryService')) {
        _services[IEntryService] = mockServices['entryService'];
      }
      if (mockServices.containsKey('substanceService')) {
        _services[ISubstanceService] = mockServices['substanceService'];
      }
      if (mockServices.containsKey('timerService')) {
        _services[ITimerService] = mockServices['timerService'];
      }
      if (mockServices.containsKey('notificationService')) {
        _services[INotificationService] = mockServices['notificationService'];
      }
      if (mockServices.containsKey('settingsService')) {
        _services[ISettingsService] = mockServices['settingsService'];
      }
      if (mockServices.containsKey('authService')) {
        _services[IAuthService] = mockServices['authService'];
      }

      _isInitialized = true;

      if (kDebugMode) {
        print('✅ ServiceLocator initialized for testing with ${_services.length} mock services');
      }
    } catch (e) {
      if (kDebugMode) {
        print('🚨 Test ServiceLocator initialization failed: $e');
      }
      rethrow;
    }
  }

  /// Dispose all services and clear the locator.
  /// 
  /// Calls dispose() on services that implement the disposal pattern
  /// and clears the service registry to prevent memory leaks.
  /// 
  /// IMPORTANT: Call this before app shutdown to prevent memory leaks.
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

  /// Get all registered service types for debugging purposes.
  static List<Type> get registeredTypes => _services.keys.toList();
  
  /// Get service count for debugging purposes.
  static int get serviceCount => _services.length;
}

/// Extension for easier access to services from any object.
extension ServiceLocatorExtension on Object {
  /// Get service from locator with convenient syntax.
  T getService<T>() => ServiceLocator.get<T>();
}

// hints reduziert durch HintOptimiererAgent