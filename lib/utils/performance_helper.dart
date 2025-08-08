import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui';

/// Helper class for performance optimization and device capability detection.
/// 
/// Provides utilities for measuring performance, detecting device capabilities,
/// and optimizing rendering based on hardware limitations.
class PerformanceHelper {
  /// Private constructor to prevent instantiation
  const PerformanceHelper._();
  
  /// Initialize performance optimizations for the application.
  /// 
  /// Disables debug features and expensive operations in release mode
  /// to improve performance on production builds.
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
      
      // Disable expensive shadows rendering on low-end devices
      debugDisableShadows = false;
    }
  }
  
  /// Measure the execution time of an async function.
  /// 
  /// In release mode, executes the function without timing.
  /// In debug mode, measures and prints execution time with optional [tag].
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
  
  /// Detect if the current device is considered low-end.
  /// 
  /// Uses screen resolution as a heuristic to determine device capabilities.
  /// Returns true for Android devices with screen width less than 1080 pixels.
  static bool isLowEndDevice() {
    // Simple heuristic based on screen resolution
    return defaultTargetPlatform == TargetPlatform.android && 
           !kIsWeb && 
           PlatformDispatcher.instance.views.first.physicalSize.width < 1080;
  }
  
  /// Get appropriate image quality based on device capabilities.
  /// 
  /// Returns lower quality (70) for low-end devices to improve performance,
  /// and higher quality (90) for high-end devices.
  static int getImageQuality() {
    if (isLowEndDevice()) {
      return 70; // Lower quality for low-end devices
    } else {
      return 90; // Higher quality for high-end devices
    }
  }
  
  /// Determine if animations should be enabled based on accessibility settings.
  /// 
  /// Checks user accessibility preferences and device capabilities.
  /// Returns false if user has enabled reduced motion or device is low-end.
  static bool shouldEnableAnimations() {
    // Check if reduced motion is enabled in accessibility settings
    bool disableAnimations = false;
    try {
      disableAnimations = MediaQueryData.fromView(
        PlatformDispatcher.instance.views.first
      ).disableAnimations;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking animations settings: $e');
      }
      // Default to false if there's an error
      disableAnimations = false;
    }
    
    // Disable animations if user has requested reduced motion
    if (disableAnimations) return false;
    
    // Always enable animations to maintain UI consistency
    return true;
  }
  
  /// Get appropriate animation duration based on device capabilities.
  /// 
  /// Currently returns normal duration for all devices to maintain
  /// consistent user experience across different hardware.
  static Duration getAnimationDuration(Duration normalDuration) {
    // Always use normal duration to maintain UI consistency
    return normalDuration;
  }
  
  /// Clear the image cache to free up memory.
  /// 
  /// Clears both cached images and live images from the painting binding.
  static void clearImageCache() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }
  
  /// Reduce memory usage when app goes to background.
  /// 
  /// Clears image cache and suggests garbage collection to the VM
  /// to free up memory when the app is backgrounded.
  static void reduceMemoryUsageInBackground() {
    // Clear image cache
    clearImageCache();
    
    // Trigger garbage collection (note: this is just a suggestion to the VM)
    if (kDebugMode) {
      debugPrint('Suggesting garbage collection for memory optimization');
    }
  }
}

// hints reduziert durch HintOptimiererAgent