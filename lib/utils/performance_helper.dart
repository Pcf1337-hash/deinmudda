import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Helper class for performance optimization
class PerformanceHelper {
  // Private constructor to prevent instantiation
  PerformanceHelper._();
  
  /// Initialize performance optimizations
  static void init() {
    if (kReleaseMode) {
      // Disable debug prints
      debugPrint = (String? message, {int? wrapWidth}) {};
      
      // Disable debug flags
      debugPaintSizeEnabled = false;
      debugPaintBaselinesEnabled = false;
      debugPaintLayerBordersEnabled = false;
      debugPaintPointersEnabled = false;
      debugRepaintRainbowEnabled = false;
      
      // Disable checkerboard patterns
      // debugCheckElevationsEnabled = false; // This property doesn't exist in current Flutter version
      
      // Disable expensive assertions
      debugDisableShadows = false;
    }
  }
  
  /// Measure the execution time of a function
  static Future<T> measureExecutionTime<T>(
    Future<T> Function() function, {
    String? tag,
  }) async {
    if (kReleaseMode) return await function();
    
    final stopwatch = Stopwatch()..start();
    final result = await function();
    stopwatch.stop();
    
    debugPrint('${tag ?? 'Execution time'}: ${stopwatch.elapsedMilliseconds}ms');
    
    return result;
  }
  
  /// Check if the device is a low-end device
  static bool isLowEndDevice() {
    // This is a simple heuristic and might need adjustment
    return defaultTargetPlatform == TargetPlatform.android && 
           !kIsWeb && 
           PlatformDispatcher.instance.views.first.physicalSize.width < 1080;
  }
  
  /// Get appropriate image quality based on device capabilities
  static int getImageQuality() {
    if (isLowEndDevice()) {
      return 70; // Lower quality for low-end devices
    } else {
      return 90; // Higher quality for high-end devices
    }
  }
  
  /// Determine if animations should be enabled
  static bool shouldEnableAnimations() {
    // Check if reduced motion is enabled in accessibility settings
    bool disableAnimations = false;
    try {
      disableAnimations = MediaQueryData.fromView(
        PlatformDispatcher.instance.views.first
      ).disableAnimations;
    } catch (e) {
      print('Error checking animations settings: $e');
      // Default to false if there's an error
      disableAnimations = false;
    }
    
    // Disable animations if user has requested reduced motion
    if (disableAnimations) return false;
    
    // Disable animations on low-end devices
    // For now, always enable animations to fix UI issues
    return true; // !isLowEndDevice();
  }
  
  /// Get appropriate animation duration based on device capabilities
  static Duration getAnimationDuration(Duration normalDuration) {
    // For now, always use normal duration to fix UI issues
    return normalDuration;
    /*if (isLowEndDevice()) {
      // Shorter animations for low-end devices
      return Duration(milliseconds: (normalDuration.inMilliseconds * 0.7).round());
    } else {
      return normalDuration;
    }*/
  }
  
  /// Memory optimization - clear image cache
  static void clearImageCache() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }
  
  /// Reduce memory usage when app goes to background
  static void reduceMemoryUsageInBackground() {
    // Clear image cache
    clearImageCache();
    
    // Trigger garbage collection (note: this is just a suggestion to the VM)
    // ignore: avoid_print
    if (kDebugMode) print('Suggesting garbage collection');
  }
}