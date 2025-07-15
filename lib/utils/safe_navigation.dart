import 'package:flutter/material.dart';

/// Safe navigation utility to prevent context errors
class SafeNavigation {
  /// Safely navigate to a new screen with mounted check
  static void pushSafe(BuildContext context, Widget screen) {
    if (context.mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        }
      });
    }
  }

  /// Safely navigate and replace current screen with mounted check
  static void pushReplacementSafe(BuildContext context, Widget screen) {
    if (context.mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        }
      });
    }
  }

  /// Safely pop with mounted check
  static void popSafe(BuildContext context) {
    if (context.mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
    }
  }

  /// Safely show dialog with mounted check
  static void showDialogSafe(BuildContext context, Widget dialog) {
    if (context.mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) => dialog,
          );
        }
      });
    }
  }

  /// Safely show bottom sheet with mounted check
  static void showBottomSheetSafe(BuildContext context, Widget sheet) {
    if (context.mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          showModalBottomSheet(
            context: context,
            builder: (context) => sheet,
          );
        }
      });
    }
  }
}