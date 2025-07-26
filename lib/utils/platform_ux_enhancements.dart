import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart'; // fixed by FehlerbehebungAgent
import '../utils/platform_helper.dart';

/// Platform-specific UX enhancements for better user experience
class PlatformUXEnhancements {
  // Private constructor to prevent instantiation
  PlatformUXEnhancements._();

  /// Create platform-appropriate scroll behavior
  static ScrollBehavior createPlatformScrollBehavior() {
    return _PlatformScrollBehavior();
  }

  /// Create platform-appropriate text selection controls
  static TextSelectionControls createPlatformTextSelectionControls() {
    if (PlatformHelper.isIOS) {
      return CupertinoTextSelectionControls();
    } else {
      return MaterialTextSelectionControls();
    }
  }

  /// Get platform-appropriate text selection theme
  static TextSelectionThemeData getPlatformTextSelectionTheme(BuildContext context) {
    final theme = Theme.of(context);
    
    if (PlatformHelper.isIOS) {
      return TextSelectionThemeData(
        cursorColor: theme.colorScheme.primary,
        selectionColor: theme.colorScheme.primary.withOpacity(0.3),
        selectionHandleColor: theme.colorScheme.primary,
      );
    } else {
      return TextSelectionThemeData(
        cursorColor: theme.colorScheme.primary,
        selectionColor: theme.colorScheme.primary.withOpacity(0.3),
        selectionHandleColor: theme.colorScheme.primary,
      );
    }
  }

  /// Create platform-specific focus handling
  static FocusNode createPlatformFocusNode() {
    return FocusNode();
  }

  /// Handle platform-specific app lifecycle
  static void handleAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // App is in foreground
        if (PlatformHelper.isIOS) {
          // iOS-specific foreground handling
          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
            ),
          );
        } else {
          // Android-specific foreground handling
          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
            ),
          );
        }
        break;
      case AppLifecycleState.paused:
        // App is in background
        break;
      case AppLifecycleState.detached:
        // App is being terminated
        break;
      case AppLifecycleState.inactive:
        // App is inactive
        break;
      case AppLifecycleState.hidden:
        // App is hidden
        break;
    }
  }

  /// Create platform-specific shadow
  static List<BoxShadow> createPlatformShadow({
    Color? color,
    double blurRadius = 8.0,
    double spreadRadius = 0.0,
    Offset offset = const Offset(0, 2),
  }) {
    if (PlatformHelper.isIOS) {
      // iOS uses softer shadows
      return [
        BoxShadow(
          color: (color ?? Colors.black).withOpacity(0.15),
          blurRadius: blurRadius,
          spreadRadius: spreadRadius,
          offset: offset,
        ),
      ];
    } else {
      // Android uses more defined shadows
      return [
        BoxShadow(
          color: (color ?? Colors.black).withOpacity(0.2),
          blurRadius: blurRadius,
          spreadRadius: spreadRadius,
          offset: offset,
        ),
      ];
    }
  }

  /// Create platform-specific glow effect
  static BoxDecoration createPlatformGlow({
    required Color color,
    double blurRadius = 12.0,
    double spreadRadius = 0.0,
  }) {
    if (PlatformHelper.isIOS) {
      // iOS uses subtle glow
      return BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: blurRadius,
            spreadRadius: spreadRadius,
          ),
        ],
      );
    } else {
      // Android uses more prominent glow
      return BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: blurRadius,
            spreadRadius: spreadRadius,
          ),
        ],
      );
    }
  }

  /// Create platform-specific animation curve
  static Curve getPlatformAnimationCurve() {
    if (PlatformHelper.isIOS) {
      return Curves.easeInOut;
    } else {
      return Curves.fastOutSlowIn;
    }
  }

  /// Create platform-specific animation duration
  static Duration getPlatformAnimationDuration({
    Duration? defaultDuration,
    bool isLongAnimation = false,
  }) {
    final baseDuration = defaultDuration ?? const Duration(milliseconds: 300);
    
    if (PlatformHelper.isIOS) {
      // iOS prefers slightly longer animations
      return Duration(
        milliseconds: (baseDuration.inMilliseconds * 1.1).round(),
      );
    } else {
      // Android uses standard durations
      return baseDuration;
    }
  }

  /// Create platform-specific vibration pattern
  static void performPlatformVibration({
    required String pattern,
  }) {
    switch (pattern) {
      case 'light':
        PlatformHelper.performHapticFeedback(HapticFeedbackType.lightImpact);
        break;
      case 'medium':
        PlatformHelper.performHapticFeedback(HapticFeedbackType.mediumImpact);
        break;
      case 'heavy':
        PlatformHelper.performHapticFeedback(HapticFeedbackType.heavyImpact);
        break;
      case 'selection':
        PlatformHelper.performHapticFeedback(HapticFeedbackType.selectionClick);
        break;
      case 'error':
        if (PlatformHelper.isIOS) {
          // iOS error pattern
          PlatformHelper.performHapticFeedback(HapticFeedbackType.heavyImpact);
        } else {
          // Android error pattern
          PlatformHelper.performHapticFeedback(HapticFeedbackType.vibrate);
        }
        break;
      case 'success':
        if (PlatformHelper.isIOS) {
          // iOS success pattern
          PlatformHelper.performHapticFeedback(HapticFeedbackType.lightImpact);
        } else {
          // Android success pattern
          PlatformHelper.performHapticFeedback(HapticFeedbackType.selectionClick);
        }
        break;
    }
  }

  /// Create platform-specific safe area insets
  static EdgeInsets getPlatformSafeAreaInsets(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    
    if (PlatformHelper.isIOS) {
      // iOS has complex safe area handling
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

  /// Create platform-specific navigation bar styling
  static SystemUiOverlayStyle getPlatformNavigationBarStyle({
    required bool isDark,
    required Color backgroundColor,
  }) {
    if (PlatformHelper.isIOS) {
      return SystemUiOverlayStyle(
        systemNavigationBarColor: backgroundColor,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      );
    } else {
      return SystemUiOverlayStyle(
        systemNavigationBarColor: backgroundColor,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      );
    }
  }

  /// Create platform-specific pull-to-refresh indicator
  static Widget createPlatformRefreshIndicator({
    required Widget child,
    required RefreshCallback onRefresh,
    Color? color,
  }) {
    if (PlatformHelper.isIOS) {
      // iOS uses CupertinoSliverRefreshControl
      return CustomScrollView(
        slivers: [
          CupertinoSliverRefreshControl(
            onRefresh: onRefresh,
          ),
          SliverToBoxAdapter(
            child: child,
          ),
        ],
      );
    } else {
      // Android uses RefreshIndicator
      return RefreshIndicator(
        onRefresh: onRefresh,
        color: color,
        child: child,
      );
    }
  }

  /// Create platform-specific app bar styling
  static PreferredSizeWidget createPlatformAppBar({
    required String title,
    List<Widget>? actions,
    Widget? leading,
    bool centerTitle = false,
    Color? backgroundColor,
    Color? foregroundColor,
    double? elevation,
  }) {
    if (PlatformHelper.isIOS) {
      // iOS uses CupertinoNavigationBar
      return PreferredSize(
        preferredSize: const Size.fromHeight(44.0),
        child: CupertinoNavigationBar(
          middle: Text(title),
          leading: leading,
          trailing: actions != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: actions,
                )
              : null,
          backgroundColor: backgroundColor,
        ),
      );
    } else {
      // Android uses AppBar
      return AppBar(
        title: Text(title),
        actions: actions,
        leading: leading,
        centerTitle: centerTitle,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        elevation: elevation ?? PlatformHelper.getPlatformElevation(),
      );
    }
  }
}

/// Custom scroll behavior for platform consistency
class _PlatformScrollBehavior extends ScrollBehavior {
  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    if (PlatformHelper.isIOS) {
      return child; // iOS doesn't show scrollbars by default
    }
    return super.buildScrollbar(context, child, details);
  }

  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    if (PlatformHelper.isIOS) {
      return child; // iOS uses bounce effect instead
    }
    return super.buildOverscrollIndicator(context, child, details);
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return PlatformHelper.getScrollPhysics();
  }
}

/// Platform-specific text selection controls
class CupertinoTextSelectionControls extends TextSelectionControls {
  @override
  Size getHandleSize(double textLineHeight) {
    return const Size(24.0, 24.0);
  }

  @override
  Widget buildHandle(BuildContext context, TextSelectionHandleType type, double textLineHeight, [VoidCallback? onTap]) {
    return SizedBox(
      width: 24.0,
      height: 24.0,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  @override
  Widget buildToolbar(
    BuildContext context,
    Rect globalEditableRegion,
    double textLineHeight,
    Offset selectionMidpoint,
    List<TextSelectionPoint> endpoints,
    TextSelectionDelegate delegate,
    ValueListenable<ClipboardStatus>? clipboardStatus,
    Offset? lastSecondaryTapDownPosition,
  ) {
    return const SizedBox.shrink();
  }

  @override
  Offset getHandleAnchor(TextSelectionHandleType type, double textLineHeight) {
    return const Offset(12.0, 12.0);
  }

  @override
  bool canCut(TextSelectionDelegate delegate) {
    return delegate.cutEnabled;
  }

  @override
  bool canCopy(TextSelectionDelegate delegate) {
    return delegate.copyEnabled;
  }

  @override
  bool canPaste(TextSelectionDelegate delegate) {
    return delegate.pasteEnabled;
  }

  @override
  bool canSelectAll(TextSelectionDelegate delegate) {
    return delegate.selectAllEnabled;
  }

  @override
  void handleCut(TextSelectionDelegate delegate) {
    delegate.cutSelection(SelectionChangedCause.toolbar);
  }

  @override
  void handleCopy(TextSelectionDelegate delegate) {
    delegate.copySelection(SelectionChangedCause.toolbar);
  }

  @override
  void handlePaste(TextSelectionDelegate delegate) {
    delegate.pasteText(SelectionChangedCause.toolbar);
  }

  @override
  void handleSelectAll(TextSelectionDelegate delegate) {
    delegate.selectAll(SelectionChangedCause.toolbar);
  }
}