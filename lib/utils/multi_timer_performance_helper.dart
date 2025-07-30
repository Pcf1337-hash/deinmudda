import 'dart:async';
import '../models/entry.dart';
import 'error_handler.dart';

/// Performance utility for managing multiple timer operations efficiently.
/// 
/// This helper provides optimized methods for handling multiple concurrent timers
/// without performance degradation or memory issues.
class MultiTimerPerformanceHelper {
  
  /// Maximum recommended concurrent timers for optimal performance
  static const int maxOptimalTimers = 12;
  
  /// Maximum absolute limit before performance degrades significantly
  static const int maxAbsoluteTimers = 20;
  
  /// Cache duration for expensive operations
  static const Duration cacheValidDuration = Duration(seconds: 3);
  
  static DateTime? _lastPerformanceCheck;
  static Map<String, dynamic>? _performanceCache;
  
  /// Analyzes timer performance and provides recommendations
  static Map<String, dynamic> analyzeTimerPerformance(List<Entry> activeTimers) {
    final now = DateTime.now();
    
    // Use cache if recent
    if (_performanceCache != null && _lastPerformanceCheck != null &&
        now.difference(_lastPerformanceCheck!).inSeconds < cacheValidDuration.inSeconds) {
      return _performanceCache!;
    }
    
    final timerCount = activeTimers.length;
    final analysis = <String, dynamic>{
      'timerCount': timerCount,
      'performanceLevel': _getPerformanceLevel(timerCount),
      'recommendations': _getRecommendations(timerCount),
      'animationSettings': _getOptimalAnimationSettings(timerCount),
      'refreshInterval': _getOptimalRefreshInterval(timerCount),
      'shouldUseSimplifiedUI': timerCount > 8,
      'memoryOptimizations': _getMemoryOptimizations(timerCount),
    };
    
    // Cache the results
    _performanceCache = analysis;
    _lastPerformanceCheck = now;
    
    ErrorHandler.logTimer('PERF_ANALYSIS', 
        'Timer performance analysis: ${timerCount} timers, '
        'level: ${analysis['performanceLevel']}, '
        'simplified UI: ${analysis['shouldUseSimplifiedUI']}');
    
    return analysis;
  }
  
  /// Determines performance level based on timer count
  static String _getPerformanceLevel(int timerCount) {
    if (timerCount <= 3) return 'optimal';
    if (timerCount <= 6) return 'good';
    if (timerCount <= maxOptimalTimers) return 'moderate';
    if (timerCount <= maxAbsoluteTimers) return 'degraded';
    return 'critical';
  }
  
  /// Provides performance recommendations
  static List<String> _getRecommendations(int timerCount) {
    final recommendations = <String>[];
    
    if (timerCount > maxOptimalTimers) {
      recommendations.add('Consider using simplified UI for better performance');
    }
    
    if (timerCount > 8) {
      recommendations.add('Disable complex animations');
      recommendations.add('Use faster refresh intervals');
    }
    
    if (timerCount > maxAbsoluteTimers) {
      recommendations.add('Warning: Performance may be significantly impacted');
      recommendations.add('Consider timer cleanup or grouping');
    }
    
    return recommendations;
  }
  
  /// Gets optimal animation settings based on timer count
  static Map<String, dynamic> _getOptimalAnimationSettings(int timerCount) {
    return {
      'enableAnimations': timerCount <= 8,
      'animationDuration': timerCount > 5 ? 200 : 400, // milliseconds
      'enableComplexAnimations': timerCount <= 5,
      'useStaggeredAnimations': timerCount <= 6,
      'animationDelay': timerCount > 8 ? 0 : 100, // milliseconds
    };
  }
  
  /// Gets optimal refresh interval based on timer count
  static Duration _getOptimalRefreshInterval(int timerCount) {
    if (timerCount <= 3) return const Duration(seconds: 30);
    if (timerCount <= 6) return const Duration(seconds: 20);
    if (timerCount <= 10) return const Duration(seconds: 15);
    return const Duration(seconds: 10); // More frequent for many timers
  }
  
  /// Gets memory optimization settings
  static Map<String, bool> _getMemoryOptimizations(int timerCount) {
    return {
      'enableCaching': timerCount > 5,
      'useDebouncing': timerCount > 3,
      'limitAnimationControllers': timerCount > 6,
      'enableLazyLoading': timerCount > 10,
      'useRepaintBoundaries': timerCount > 4,
    };
  }
  
  /// Efficiently filters active timers with performance optimizations
  static List<Entry> filterActiveTimers(List<Entry> allTimers, {bool useCaching = true}) {
    if (allTimers.isEmpty) return [];
    
    // For small numbers, don't use complex filtering
    if (allTimers.length <= 3) {
      return allTimers.where((timer) => 
        timer.isTimerActive && !timer.isTimerExpired).toList();
    }
    
    // Use more efficient filtering for larger lists
    final filtered = <Entry>[];
    for (final timer in allTimers) {
      if (timer.isTimerActive && !timer.isTimerExpired) {
        filtered.add(timer);
      }
    }
    
    return filtered;
  }
  
  /// Batches timer operations for better performance
  static Future<List<T>> batchTimerOperations<T>(
    List<Future<T> Function()> operations, {
    int batchSize = 5,
  }) async {
    final results = <T>[];
    
    for (int i = 0; i < operations.length; i += batchSize) {
      final batch = operations.skip(i).take(batchSize);
      final batchResults = await Future.wait(
        batch.map((op) => op()),
        eagerError: false,
      );
      results.addAll(batchResults);
      
      // Small delay between batches to prevent overwhelming the system
      if (i + batchSize < operations.length) {
        await Future.delayed(const Duration(milliseconds: 10));
      }
    }
    
    return results;
  }
  
  /// Validates timer configuration for performance
  static bool validateTimerConfiguration(int proposedTimerCount) {
    if (proposedTimerCount > maxAbsoluteTimers) {
      ErrorHandler.logWarning('MULTI_TIMER_PERF', 
          'Warning: Proposed timer count ($proposedTimerCount) exceeds recommended maximum ($maxAbsoluteTimers)');
      return false;
    }
    
    if (proposedTimerCount > maxOptimalTimers) {
      ErrorHandler.logWarning('MULTI_TIMER_PERF', 
          'Notice: Timer count ($proposedTimerCount) may impact performance. Consider optimization.');
    }
    
    return true;
  }
  
  /// Clears performance cache (useful for testing or manual refresh)
  static void clearCache() {
    _performanceCache = null;
    _lastPerformanceCheck = null;
  }
  
  /// Gets current performance status for debugging
  static Map<String, dynamic> getCurrentStatus() {
    return {
      'hasCachedData': _performanceCache != null,
      'lastCheckTime': _lastPerformanceCheck?.toIso8601String(),
      'cacheAge': _lastPerformanceCheck != null 
          ? DateTime.now().difference(_lastPerformanceCheck!).inSeconds
          : null,
    };
  }
}