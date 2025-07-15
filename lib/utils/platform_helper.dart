import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';

/// Platform-specific utilities for cross-platform UI consistency
class PlatformHelper {
  // Private constructor to prevent instantiation
  PlatformHelper._();

  /// Check if running on iOS
  static bool get isIOS => !kIsWeb && Platform.isIOS;

  /// Check if running on Android
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;

  /// Check if running on Web
  static bool get isWeb => kIsWeb;

  /// Check if running on mobile (iOS or Android)
  static bool get isMobile => isIOS || isAndroid;

  /// Check if running on desktop
  static bool get isDesktop => !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);

  /// Get platform-appropriate status bar icon brightness
  static SystemUiOverlayStyle getStatusBarStyle({
    required bool isDark,
    required bool isPsychedelicMode,
  }) {
    if (isIOS) {
      return SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark || isPsychedelicMode ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: isDark || isPsychedelicMode ? Brightness.light : Brightness.dark,
      );
    } else {
      return SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark || isPsychedelicMode ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: isDark || isPsychedelicMode ? Brightness.light : Brightness.dark,
      );
    }
  }

  /// Get platform-appropriate edge insets for safe area
  static EdgeInsets getSafeAreaPadding(MediaQueryData mediaQuery) {
    if (isIOS) {
      // iOS has more complex safe area handling
      return EdgeInsets.only(
        top: mediaQuery.padding.top,
        bottom: mediaQuery.padding.bottom,
        left: mediaQuery.padding.left,
        right: mediaQuery.padding.right,
      );
    } else {
      // Android typically has simpler safe area handling
      return EdgeInsets.only(
        top: mediaQuery.padding.top,
        bottom: mediaQuery.padding.bottom,
      );
    }
  }

  /// Get platform-appropriate scroll physics
  static ScrollPhysics getScrollPhysics() {
    if (isIOS) {
      return const BouncingScrollPhysics();
    } else {
      return const ClampingScrollPhysics();
    }
  }

  /// Get platform-appropriate page transition
  static PageTransitionsBuilder getPageTransitionsBuilder() {
    if (isIOS) {
      return const CupertinoPageTransitionsBuilder();
    } else {
      return const FadeUpwardsPageTransitionsBuilder();
    }
  }

  /// Get platform-appropriate border radius
  static BorderRadius getPlatformBorderRadius() {
    if (isIOS) {
      return BorderRadius.circular(12.0); // iOS prefers slightly smaller radius
    } else {
      return BorderRadius.circular(16.0); // Android Material 3 standard
    }
  }

  /// Get platform-appropriate elevation
  static double getPlatformElevation() {
    if (isIOS) {
      return 0.0; // iOS doesn't use elevation
    } else {
      return 8.0; // Android Material elevation
    }
  }

  /// Get platform-appropriate haptic feedback
  static void performHapticFeedback(HapticFeedbackType type) {
    if (isIOS) {
      switch (type) {
        case HapticFeedbackType.lightImpact:
          HapticFeedback.lightImpact();
          break;
        case HapticFeedbackType.mediumImpact:
          HapticFeedback.mediumImpact();
          break;
        case HapticFeedbackType.heavyImpact:
          HapticFeedback.heavyImpact();
          break;
        case HapticFeedbackType.selectionClick:
          HapticFeedback.selectionClick();
          break;
        case HapticFeedbackType.vibrate:
          HapticFeedback.vibrate();
          break;
      }
    } else {
      // Android has simpler haptic feedback
      HapticFeedback.selectionClick();
    }
  }

  /// Get platform-appropriate font family
  static String? getPlatformFontFamily() {
    if (isIOS) {
      return '.SF Pro Display'; // iOS system font
    } else {
      return 'Roboto'; // Android system font
    }
  }

  /// Get platform-appropriate text scale factor
  static double getPlatformTextScaleFactor() {
    if (isIOS) {
      return 1.0; // iOS handles text scaling differently
    } else {
      return 1.0; // Android text scaling
    }
  }

  /// Get platform-appropriate icon size
  static double getPlatformIconSize() {
    if (isIOS) {
      return 22.0; // iOS icons are typically smaller
    } else {
      return 24.0; // Android Material icons
    }
  }

  /// Get platform-appropriate back button behavior
  static bool shouldShowBackButton(BuildContext context) {
    if (isIOS) {
      return Navigator.of(context).canPop();
    } else {
      return Navigator.of(context).canPop();
    }
  }

  /// Handle platform-specific back navigation
  static void handleBackNavigation(BuildContext context) {
    if (isIOS) {
      // iOS uses swipe gestures primarily
      Navigator.of(context).maybePop();
    } else {
      // Android uses back button
      Navigator.of(context).maybePop();
    }
  }

  /// Get platform-appropriate modal presentation
  static void showPlatformModal<T>({
    required BuildContext context,
    required Widget child,
    bool useRootNavigator = true,
    bool isDismissible = true,
  }) {
    if (isIOS) {
      showCupertinoModalPopup<T>(
        context: context,
        useRootNavigator: useRootNavigator,
        builder: (context) => child,
      );
    } else {
      showModalBottomSheet<T>(
        context: context,
        useRootNavigator: useRootNavigator,
        isDismissible: isDismissible,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => child,
      );
    }
  }

  /// Get platform-appropriate dialog
  static Future<T?> showPlatformDialog<T>({
    required BuildContext context,
    required Widget child,
    bool barrierDismissible = true,
  }) {
    if (isIOS) {
      return showCupertinoDialog<T>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (context) => child,
      );
    } else {
      return showDialog<T>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (context) => child,
      );
    }
  }

  /// Get platform-appropriate loading indicator
  static Widget getPlatformLoadingIndicator() {
    if (isIOS) {
      return const CupertinoActivityIndicator();
    } else {
      return const CircularProgressIndicator();
    }
  }

  /// Get platform-appropriate switch widget
  static Widget getPlatformSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
    Color? activeColor,
  }) {
    if (isIOS) {
      return CupertinoSwitch(
        value: value,
        onChanged: onChanged,
        activeColor: activeColor,
      );
    } else {
      return Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: activeColor,
      );
    }
  }

  /// Get platform-appropriate slider widget
  static Widget getPlatformSlider({
    required double value,
    required ValueChanged<double> onChanged,
    double min = 0.0,
    double max = 1.0,
    int? divisions,
    Color? activeColor,
  }) {
    if (isIOS) {
      return CupertinoSlider(
        value: value,
        onChanged: onChanged,
        min: min,
        max: max,
        divisions: divisions,
        activeColor: activeColor,
      );
    } else {
      return Slider.adaptive(
        value: value,
        onChanged: onChanged,
        min: min,
        max: max,
        divisions: divisions,
        activeColor: activeColor,
      );
    }
  }

  /// Get platform-appropriate keyboard type
  static TextInputType getPlatformKeyboardType(String inputType) {
    switch (inputType) {
      case 'number':
        return isIOS ? TextInputType.numberWithOptions(decimal: true) : TextInputType.number;
      case 'email':
        return TextInputType.emailAddress;
      case 'phone':
        return TextInputType.phone;
      case 'url':
        return TextInputType.url;
      default:
        return TextInputType.text;
    }
  }

  /// Get platform-appropriate text input action
  static TextInputAction getPlatformTextInputAction() {
    if (isIOS) {
      return TextInputAction.done;
    } else {
      return TextInputAction.done;
    }
  }
}

/// Enum for haptic feedback types
enum HapticFeedbackType {
  lightImpact,
  mediumImpact,
  heavyImpact,
  selectionClick,
  vibrate,
}