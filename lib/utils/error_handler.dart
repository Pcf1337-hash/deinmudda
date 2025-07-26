import 'package:flutter/foundation.dart';

class ErrorHandler {
  static void logError(String context, dynamic error, {StackTrace? stackTrace}) {
    if (kDebugMode) {
      print('❌ ERROR in $context: $error');
      if (stackTrace != null) {
        print('Stack trace: $stackTrace');
      }
    }
  }

  static void logWarning(String context, String message) {
    if (kDebugMode) {
      print('⚠️ WARNING in $context: $message');
    }
  }

  static void logInfo(String context, String message) {
    if (kDebugMode) {
      print('ℹ️ INFO in $context: $message');
    }
  }

  static void logSuccess(String context, String message) {
    if (kDebugMode) {
      print('✅ SUCCESS in $context: $message');
    }
  }

  static void logStartup(String phase, String message) {
    if (kDebugMode) {
      print('🚀 STARTUP [$phase]: $message');
    }
  }

  static void logTimer(String action, String message) {
    if (kDebugMode) {
      print('⏰ TIMER [$action]: $message');
    }
  }

  static void logUI(String component, String message) {
    if (kDebugMode) {
      print('🎨 UI [$component]: $message');
    }
  }

  static void logNavigation(String action, String message) {
    if (kDebugMode) {
      print('🧭 NAVIGATION [$action]: $message');
    }
  }

  static void logTheme(String action, String message) {
    if (kDebugMode) {
      print('🌈 THEME [$action]: $message');
    }
  }

  static void logDatabase(String action, String message) {
    if (kDebugMode) {
      print('🗄️ DATABASE [$action]: $message');
    }
  }

  static void logService(String service, String message) {
    if (kDebugMode) {
      print('🔧 SERVICE [$service]: $message');
    }
  }

  static void logDispose(String component, String message) {
    if (kDebugMode) {
      print('🧹 DISPOSE [$component]: $message');
    }
  }

  static void logPerformance(String action, String message) {
    if (kDebugMode) {
      print('⚡ PERFORMANCE [$action]: $message');
    }
  }

  static void logCrashPrevention(String context, String message) {
    if (kDebugMode) {
      print('🛡️ CRASH PREVENTION [$context]: $message');
    }
  }

  static void handleError(dynamic error, String message) {
    logError(message, error);
  }

  static void logWhiteScreenDebug(String context, String message) {
    if (kDebugMode) {
      print('⚪ WHITE SCREEN DEBUG [$context]: $message');
    }
  }

  static void logTimerCrashDebug(String context, String message) {
    if (kDebugMode) {
      print('💥 TIMER CRASH DEBUG [$context]: $message');
    }
  }

  static void logPlatform(String platform, String message) {
    if (kDebugMode) {
      print('🖥️ PLATFORM [$platform]: $message');
    }
  }

  static T? safeCall<T>(String context, T Function() function) {
    try {
      return function();
    } catch (e, stackTrace) {
      logError(context, e, stackTrace: stackTrace);
      return null;
    }
  }

  static Future<T?> safeCallAsync<T>(String context, Future<T> Function() function) async {
    try {
      return await function();
    } catch (e, stackTrace) {
      logError(context, e, stackTrace: stackTrace);
      return null;
    }
  }
}