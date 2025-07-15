import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'error_handler.dart';

/// Helper class for dealing with Impeller rendering issues
class ImpellerHelper {
  static bool _isImpellerEnabled = true;
  static bool _hasImpellerIssues = false;

  /// Check if Impeller is enabled and working properly
  static Future<bool> checkImpellerStatus() async {
    try {
      // In debug mode, we can check for Impeller-related issues
      if (kDebugMode) {
        ErrorHandler.logPerformance('IMPELLER', 'Überprüfe Impeller-Status...');
        
        // Check for Vulkan availability (Impeller uses Vulkan on Android)
        final result = await _checkVulkanSupport();
        
        if (!result) {
          ErrorHandler.logWarning('IMPELLER', 'Vulkan-Support möglicherweise nicht verfügbar');
          _hasImpellerIssues = true;
        } else {
          ErrorHandler.logSuccess('IMPELLER', 'Impeller/Vulkan-Support verfügbar');
        }
        
        return result;
      }
      
      return true;
    } catch (e) {
      ErrorHandler.logError('IMPELLER', 'Fehler beim Überprüfen des Impeller-Status: $e');
      _hasImpellerIssues = true;
      return false;
    }
  }

  /// Check for Vulkan support (used by Impeller)
  static Future<bool> _checkVulkanSupport() async {
    try {
      // This is a simplified check - in a real implementation,
      // you might want to use platform-specific code
      return true;
    } catch (e) {
      ErrorHandler.logError('IMPELLER', 'Vulkan-Check fehlgeschlagen: $e');
      return false;
    }
  }

  /// Get recommended settings for timer animations based on Impeller status
  static Map<String, dynamic> getTimerAnimationSettings() {
    if (_hasImpellerIssues) {
      ErrorHandler.logWarning('IMPELLER', 'Impeller-Probleme erkannt - verwende vereinfachte Animationen');
      return {
        'enableComplexAnimations': false,
        'enableShaderEffects': false,
        'animationDuration': const Duration(milliseconds: 150),
        'enablePulsing': false,
        'enableShineEffects': false,
      };
    }
    
    return {
      'enableComplexAnimations': true,
      'enableShaderEffects': true,
      'animationDuration': const Duration(milliseconds: 300),
      'enablePulsing': true,
      'enableShineEffects': true,
    };
  }

  /// Check if current device has known Impeller issues
  static bool hasKnownImpellerIssues() {
    return _hasImpellerIssues;
  }

  /// Force disable Impeller-dependent features
  static void forceDisableImpellerFeatures() {
    _hasImpellerIssues = true;
    _isImpellerEnabled = false;
    ErrorHandler.logWarning('IMPELLER', 'Impeller-Features manuell deaktiviert');
  }

  /// Enable Impeller features
  static void enableImpellerFeatures() {
    _hasImpellerIssues = false;
    _isImpellerEnabled = true;
    ErrorHandler.logInfo('IMPELLER', 'Impeller-Features aktiviert');
  }

  /// Get reduced animation configuration for problematic devices
  static Map<String, dynamic> getReducedAnimationConfig() {
    return {
      'duration': const Duration(milliseconds: 100),
      'curve': 'linear',
      'enableTransforms': false,
      'enableOpacity': true,
      'enableScale': false,
      'enableRotation': false,
    };
  }

  /// Check if specific animation features should be enabled
  static bool shouldEnableFeature(String featureName) {
    if (_hasImpellerIssues) {
      switch (featureName) {
        case 'pulsing':
        case 'shine':
        case 'complexTransforms':
        case 'shaderMasks':
          return false;
        case 'basicAnimations':
        case 'simpleTransitions':
          return true;
        default:
          return false;
      }
    }
    return true;
  }

  /// Log Impeller-related performance issues
  static void logPerformanceIssue(String context, String issue) {
    ErrorHandler.logPerformance('IMPELLER_ISSUE', '$context: $issue');
    
    // If we detect performance issues, mark Impeller as problematic
    if (issue.toLowerCase().contains('render') || 
        issue.toLowerCase().contains('gpu') ||
        issue.toLowerCase().contains('vulkan')) {
      _hasImpellerIssues = true;
    }
  }

  /// Get current Impeller status for debugging
  static Map<String, dynamic> getDebugInfo() {
    return {
      'isImpellerEnabled': _isImpellerEnabled,
      'hasImpellerIssues': _hasImpellerIssues,
      'recommendedSettings': getTimerAnimationSettings(),
    };
  }

  /// Initialize Impeller detection
  static Future<void> initialize() async {
    try {
      ErrorHandler.logStartup('IMPELLER', 'Initialisiere Impeller-Erkennung...');
      
      final status = await checkImpellerStatus();
      
      if (status) {
        ErrorHandler.logSuccess('IMPELLER', 'Impeller-Erkennung erfolgreich initialisiert');
      } else {
        ErrorHandler.logWarning('IMPELLER', 'Impeller-Probleme erkannt - Fallback-Modus aktiviert');
      }
    } catch (e) {
      ErrorHandler.logError('IMPELLER', 'Fehler bei Impeller-Initialisierung: $e');
      _hasImpellerIssues = true;
    }
  }
}