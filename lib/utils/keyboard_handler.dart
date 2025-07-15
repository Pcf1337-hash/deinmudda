import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/platform_helper.dart';

/// Cross-platform keyboard handling utilities
class KeyboardHandler {
  // Private constructor to prevent instantiation
  KeyboardHandler._();

  /// Handle keyboard visibility changes
  static void handleKeyboardVisibilityChange({
    required BuildContext context,
    required bool isVisible,
    VoidCallback? onShow,
    VoidCallback? onHide,
  }) {
    if (isVisible) {
      onShow?.call();
    } else {
      onHide?.call();
    }
  }

  /// Get platform-appropriate keyboard padding
  static EdgeInsets getKeyboardPadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final viewInsets = mediaQuery.viewInsets;
    
    if (PlatformHelper.isIOS) {
      // iOS keyboard behavior
      return EdgeInsets.only(
        bottom: viewInsets.bottom,
      );
    } else {
      // Android keyboard behavior
      return EdgeInsets.only(
        bottom: viewInsets.bottom,
      );
    }
  }

  /// Handle keyboard dismissal
  static void dismissKeyboard(BuildContext context) {
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      currentFocus.focusedChild!.unfocus();
    }
  }

  /// Create a keyboard dismissal wrapper
  static Widget createKeyboardDismissalWrapper({
    required BuildContext context,
    required Widget child,
  }) {
    return GestureDetector(
      onTap: () => dismissKeyboard(context),
      child: child,
    );
  }

  /// Handle platform-specific text input actions
  static TextInputAction getPlatformTextInputAction({
    bool isLastField = false,
    bool isMultiline = false,
  }) {
    if (isMultiline) {
      return TextInputAction.newline;
    }
    
    if (isLastField) {
      return TextInputAction.done;
    }
    
    if (PlatformHelper.isIOS) {
      return TextInputAction.next;
    } else {
      return TextInputAction.next;
    }
  }

  /// Handle platform-specific keyboard type
  static TextInputType getPlatformKeyboardType({
    required String inputType,
    bool allowDecimal = false,
  }) {
    switch (inputType.toLowerCase()) {
      case 'number':
        if (PlatformHelper.isIOS) {
          return allowDecimal
              ? const TextInputType.numberWithOptions(decimal: true)
              : const TextInputType.numberWithOptions(decimal: false);
        } else {
          return allowDecimal
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.number;
        }
      case 'phone':
        return TextInputType.phone;
      case 'email':
        return TextInputType.emailAddress;
      case 'url':
        return TextInputType.url;
      case 'multiline':
        return TextInputType.multiline;
      default:
        return TextInputType.text;
    }
  }

  /// Handle platform-specific input formatters
  static List<TextInputFormatter> getPlatformInputFormatters({
    required String inputType,
    int? maxLength,
    bool allowDecimal = false,
  }) {
    List<TextInputFormatter> formatters = [];

    // Add length formatter if specified
    if (maxLength != null) {
      formatters.add(LengthLimitingTextInputFormatter(maxLength));
    }

    // Add type-specific formatters
    switch (inputType.toLowerCase()) {
      case 'number':
        if (allowDecimal) {
          formatters.add(FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')));
        } else {
          formatters.add(FilteringTextInputFormatter.digitsOnly);
        }
        break;
      case 'phone':
        formatters.add(FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s\(\)]')));
        break;
      case 'email':
        formatters.add(FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@._\-]')));
        break;
      case 'alphanumeric':
        formatters.add(FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')));
        break;
      case 'letters':
        formatters.add(FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')));
        break;
    }

    return formatters;
  }

  /// Handle platform-specific text capitalization
  static TextCapitalization getPlatformTextCapitalization({
    required String inputType,
  }) {
    switch (inputType.toLowerCase()) {
      case 'name':
        return TextCapitalization.words;
      case 'sentence':
        return TextCapitalization.sentences;
      case 'email':
      case 'url':
        return TextCapitalization.none;
      default:
        return TextCapitalization.none;
    }
  }

  /// Create platform-appropriate text field decoration
  static InputDecoration getPlatformInputDecoration({
    String? labelText,
    String? hintText,
    String? errorText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool isEnabled = true,
    bool isRequired = false,
    Color? borderColor,
    Color? focusedBorderColor,
    Color? errorBorderColor,
  }) {
    final theme = ThemeData(); // Get current theme in actual implementation
    
    return InputDecoration(
      labelText: isRequired && labelText != null ? '$labelText *' : labelText,
      hintText: hintText,
      errorText: errorText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      enabled: isEnabled,
      filled: true,
      fillColor: isEnabled
          ? (PlatformHelper.isIOS 
              ? const Color(0xFFF7F7F7) 
              : theme.colorScheme.surface)
          : (PlatformHelper.isIOS 
              ? const Color(0xFFF0F0F0) 
              : theme.colorScheme.surface.withOpacity(0.5)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          PlatformHelper.isIOS ? 8.0 : 12.0,
        ),
        borderSide: BorderSide(
          color: borderColor ?? theme.colorScheme.outline,
          width: 1.0,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          PlatformHelper.isIOS ? 8.0 : 12.0,
        ),
        borderSide: BorderSide(
          color: borderColor ?? theme.colorScheme.outline,
          width: 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          PlatformHelper.isIOS ? 8.0 : 12.0,
        ),
        borderSide: BorderSide(
          color: focusedBorderColor ?? theme.colorScheme.primary,
          width: 2.0,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          PlatformHelper.isIOS ? 8.0 : 12.0,
        ),
        borderSide: BorderSide(
          color: errorBorderColor ?? theme.colorScheme.error,
          width: 1.0,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          PlatformHelper.isIOS ? 8.0 : 12.0,
        ),
        borderSide: BorderSide(
          color: errorBorderColor ?? theme.colorScheme.error,
          width: 2.0,
        ),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: PlatformHelper.isIOS ? 12.0 : 16.0,
        vertical: PlatformHelper.isIOS ? 12.0 : 16.0,
      ),
    );
  }

  /// Handle platform-specific focus behavior
  static void handleFocusChange({
    required BuildContext context,
    required bool hasFocus,
    VoidCallback? onFocusGained,
    VoidCallback? onFocusLost,
  }) {
    if (hasFocus) {
      onFocusGained?.call();
    } else {
      onFocusLost?.call();
    }
  }

  /// Create platform-appropriate scroll behavior for text fields
  static ScrollBehavior getPlatformScrollBehavior() {
    return ScrollConfiguration.of(
      // This would need context in actual implementation
      NavigationService.navigatorKey.currentContext!,
    ).copyWith(
      physics: PlatformHelper.getScrollPhysics(),
      scrollbars: !PlatformHelper.isIOS,
    );
  }

  /// Handle platform-specific keyboard shortcuts
  static Map<ShortcutActivator, Intent> getPlatformKeyboardShortcuts() {
    if (PlatformHelper.isIOS) {
      return <ShortcutActivator, Intent>{
        const SingleActivator(LogicalKeyboardKey.escape): const DismissIntent(),
        const SingleActivator(LogicalKeyboardKey.enter): const ActivateIntent(),
      };
    } else {
      return <ShortcutActivator, Intent>{
        const SingleActivator(LogicalKeyboardKey.escape): const DismissIntent(),
        const SingleActivator(LogicalKeyboardKey.enter): const ActivateIntent(),
        const SingleActivator(LogicalKeyboardKey.tab): const NextFocusIntent(),
        const SingleActivator(LogicalKeyboardKey.tab, shift: true): const PreviousFocusIntent(),
      };
    }
  }
}

/// Global navigation service for accessing context
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}

/// Custom scroll behavior for platform consistency
class PlatformScrollBehavior extends ScrollBehavior {
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