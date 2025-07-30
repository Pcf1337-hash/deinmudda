/// App Bootstrapper - Handles application initialization
/// 
/// CRITICAL FIX: Separates initialization logic from main.dart
/// Reduces main.dart complexity from 367 lines to manageable size
/// 
/// Author: Code Quality Improvement Agent  
/// Date: Phase 1 - Critical Fixes

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../utils/performance_helper.dart';
import '../utils/platform_helper.dart';
import '../utils/error_handler.dart';
import '../utils/impeller_helper.dart';
import '../utils/service_locator.dart';

/// Handles all app initialization in a clean, organized way
class AppBootstrapper {
  static bool _isInitialized = false;

  /// Initialize the entire application
  static Future<void> initialize() async {
    if (_isInitialized) {
      if (kDebugMode) {
        print('⚠️ App already initialized');
      }
      return;
    }

    try {
      ErrorHandler.logStartup('BOOTSTRAP', 'App-Initialisierung gestartet');

      // 1. Ensure Flutter is initialized
      WidgetsBinding.instance.ensureInitialized();

      // 2. Setup error handlers first
      _setupGlobalErrorHandlers();

      // 3. Initialize locale data
      await initializeDateFormatting('de_DE', null);

      // 4. Initialize performance optimizations
      PerformanceHelper.init();

      // 5. Initialize Impeller detection for rendering optimization
      await _initializeRenderingOptimizations();

      // 6. Initialize all services via Service Locator
      await ServiceLocator.initialize();

      // 7. Perform platform-specific initialization
      await _initializePlatformSpecific();

      _isInitialized = true;
      ErrorHandler.logSuccess('BOOTSTRAP', 'App-Initialisierung erfolgreich abgeschlossen');

    } catch (e) {
      ErrorHandler.logError('BOOTSTRAP', 'Kritischer Fehler bei der App-Initialisierung: $e');
      if (kDebugMode) {
        print('Stack trace: ${StackTrace.current}');
      }
      rethrow;
    }
  }

  /// Setup global error handlers
  static void _setupGlobalErrorHandlers() {
    // Flutter widget error handler
    FlutterError.onError = (FlutterErrorDetails details) {
      ErrorHandler.logError('FLUTTER_ERROR', 'Unbehandelter Flutter-Fehler: ${details.exception}');
      ErrorHandler.logError('FLUTTER_ERROR', 'Stack trace: ${details.stack}');
      
      // Check if it's a layout error
      final errorStr = details.exception.toString();
      if (_isLayoutError(errorStr)) {
        ErrorHandler.logError('LAYOUT_ERROR', 'Layout-Fehler erkannt: $errorStr');
        ImpellerHelper.logPerformanceIssue('Layout', errorStr);
      }
      
      // Continue with default error handling in debug mode
      if (kDebugMode) {
        FlutterError.presentError(details);
      } else {
        // In release mode, use fallback error presentation
        _showVisualErrorFallback(details);
      }
    };
    
    // Platform error handler (for async errors)
    PlatformDispatcher.instance.onError = (error, stack) {
      ErrorHandler.logError('PLATFORM_ERROR', 'Platform-Fehler: $error');
      ErrorHandler.logError('PLATFORM_ERROR', 'Stack trace: $stack');
      return true;
    };
  }

  /// Check if an error is a layout-related error
  static bool _isLayoutError(String errorStr) {
    return errorStr.contains('RenderBox was not laid out') ||
           errorStr.contains('RenderFlex overflowed') ||
           errorStr.contains('unbounded height') ||
           errorStr.contains('unbounded width');
  }

  /// Visual error fallback for release mode
  static void _showVisualErrorFallback(FlutterErrorDetails details) {
    try {
      // Log the error for debugging
      if (kDebugMode) {
        debugPrint('Visual Error Fallback: ${details.exception}');
      }
      
      // In release mode, continue with graceful handling
      try {
        FlutterError.presentError(details);
      } catch (e) {
        // If even the error presentation fails, handle gracefully
        if (kDebugMode) {
          debugPrint('Failed to present error: $e');
        }
      }
    } catch (e) {
      // Absolute fallback - do nothing to prevent crash loops
      if (kDebugMode) {
        debugPrint('Error in error fallback: $e');
      }
    }
  }

  /// Initialize rendering optimizations
  static Future<void> _initializeRenderingOptimizations() async {
    try {
      await ImpellerHelper.initialize();
      
      final impellerInfo = ImpellerHelper.getDebugInfo();
      ErrorHandler.logPlatform('RENDER', 'Rendering-Backend: ${impellerInfo['backend']}');
      ErrorHandler.logPlatform('RENDER', 'Impeller: ${impellerInfo['impeller']}');
      
      if (impellerInfo['backend'] == 'vulkan') {
        ErrorHandler.logPlatform('RENDER', 'Vulkan-Renderer erkannt - optimiert für Performance');
      }
    } catch (e) {
      ErrorHandler.logError('RENDER', 'Fehler bei Rendering-Initialisierung: $e');
      // Don't rethrow - this is not critical for app startup
    }
  }

  /// Platform-specific initialization
  static Future<void> _initializePlatformSpecific() async {
    try {
      // Android-specific initialization
      if (PlatformHelper.isAndroid) {
        await _initializeAndroid();
      }
      
      // iOS-specific initialization  
      if (PlatformHelper.isIOS) {
        await _initializeIOS();
      }
      
      // Desktop-specific initialization
      if (PlatformHelper.isDesktop) {
        await _initializeDesktop();
      }
    } catch (e) {
      ErrorHandler.logError('PLATFORM_INIT', 'Fehler bei plattformspezifischer Initialisierung: $e');
      // Don't rethrow - continue with app startup
    }
  }

  /// Android-specific initialization
  static Future<void> _initializeAndroid() async {
    try {
      // Set preferred orientations for Android
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      
      // Android-specific optimizations
      ErrorHandler.logPlatform('ANDROID', 'Android-spezifische Initialisierung abgeschlossen');
    } catch (e) {
      ErrorHandler.logError('ANDROID', 'Android-Initialisierung fehlgeschlagen: $e');
    }
  }

  /// iOS-specific initialization
  static Future<void> _initializeIOS() async {
    try {
      // iOS-specific optimizations would go here
      ErrorHandler.logPlatform('IOS', 'iOS-spezifische Initialisierung abgeschlossen');
    } catch (e) {
      ErrorHandler.logError('IOS', 'iOS-Initialisierung fehlgeschlagen: $e');
    }
  }

  /// Desktop-specific initialization
  static Future<void> _initializeDesktop() async {
    try {
      // Desktop-specific optimizations would go here
      ErrorHandler.logPlatform('DESKTOP', 'Desktop-spezifische Initialisierung abgeschlossen');
    } catch (e) {
      ErrorHandler.logError('DESKTOP', 'Desktop-Initialisierung fehlgeschlagen: $e');
    }
  }

  /// Dispose app resources (call before app shutdown)
  static Future<void> dispose() async {
    try {
      ErrorHandler.logInfo('BOOTSTRAP', 'App-Shutdown gestartet');
      
      // Dispose service locator
      await ServiceLocator.dispose();
      
      _isInitialized = false;
      ErrorHandler.logSuccess('BOOTSTRAP', 'App-Shutdown erfolgreich');
    } catch (e) {
      ErrorHandler.logError('BOOTSTRAP', 'Fehler beim App-Shutdown: $e');
    }
  }

  /// Check if app is initialized
  static bool get isInitialized => _isInitialized;
}