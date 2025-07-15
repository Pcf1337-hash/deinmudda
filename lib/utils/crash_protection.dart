import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'error_handler.dart';

/// A widget that catches and handles errors to prevent crashes
class CrashProtectionWrapper extends StatefulWidget {
  final Widget child;
  final String context;
  final Widget? fallbackWidget;
  final bool showErrorInDebug;

  const CrashProtectionWrapper({
    super.key,
    required this.child,
    required this.context,
    this.fallbackWidget,
    this.showErrorInDebug = true,
  });

  @override
  State<CrashProtectionWrapper> createState() => _CrashProtectionWrapperState();
}

class _CrashProtectionWrapperState extends State<CrashProtectionWrapper> {
  bool _hasError = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return widget.fallbackWidget ?? _buildErrorFallback();
    }

    return _SafeWidget(
      context: widget.context,
      onError: (error, stackTrace) {
        ErrorHandler.logError(widget.context, error, stackTrace: stackTrace);
        
        if (mounted) {
          setState(() {
            _hasError = true;
            _errorMessage = error.toString();
          });
        }
      },
      child: widget.child,
    );
  }

  Widget _buildErrorFallback() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Ein Fehler ist aufgetreten',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          if (widget.showErrorInDebug && kDebugMode && _errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (mounted) {
                setState(() {
                  _hasError = false;
                  _errorMessage = null;
                });
              }
            },
            child: const Text('Erneut versuchen'),
          ),
        ],
      ),
    );
  }
}

class _SafeWidget extends StatelessWidget {
  final Widget child;
  final String context;
  final Function(dynamic error, StackTrace? stackTrace) onError;

  const _SafeWidget({
    required this.child,
    required this.context,
    required this.onError,
  });

  @override
  Widget build(BuildContext context) {
    try {
      return child;
    } catch (e, stackTrace) {
      onError(e, stackTrace);
      return const SizedBox.shrink();
    }
  }
}

/// A mixin that provides safe setState functionality
mixin SafeStateMixin<T extends StatefulWidget> on State<T> {
  void safeSetState(VoidCallback fn) {
    try {
      if (mounted) {
        setState(fn);
      } else {
        ErrorHandler.logWarning(
          runtimeType.toString(),
          'setState aufgerufen, aber Widget ist nicht mounted',
        );
      }
    } catch (e) {
      ErrorHandler.logError(
        runtimeType.toString(),
        'Fehler beim safeSetState: $e',
      );
    }
  }
}

/// A mixin that provides safe animation controller functionality
mixin SafeAnimationMixin<T extends StatefulWidget> on State<T>, TickerProviderStateMixin<T> {
  late AnimationController _controller;
  bool _isControllerInitialized = false;

  void initSafeAnimationController({
    required Duration duration,
    Duration? reverseDuration,
    String? debugLabel,
  }) {
    try {
      _controller = AnimationController(
        duration: duration,
        reverseDuration: reverseDuration,
        debugLabel: debugLabel,
        vsync: this,
      );
      _isControllerInitialized = true;
    } catch (e) {
      ErrorHandler.logError(
        runtimeType.toString(),
        'Fehler beim Initialisieren des AnimationController: $e',
      );
    }
  }

  AnimationController get safeAnimationController => _controller;

  bool get isAnimationControllerInitialized => _isControllerInitialized;

  void disposeSafeAnimationController() {
    try {
      if (_isControllerInitialized) {
        _controller.dispose();
        _isControllerInitialized = false;
      }
    } catch (e) {
      ErrorHandler.logError(
        runtimeType.toString(),
        'Fehler beim Dispose des AnimationController: $e',
      );
    }
  }

  void safeAnimationControllerForward() {
    try {
      if (_isControllerInitialized && mounted) {
        _controller.forward();
      }
    } catch (e) {
      ErrorHandler.logError(
        runtimeType.toString(),
        'Fehler beim Forward des AnimationController: $e',
      );
    }
  }

  void safeAnimationControllerReverse() {
    try {
      if (_isControllerInitialized && mounted) {
        _controller.reverse();
      }
    } catch (e) {
      ErrorHandler.logError(
        runtimeType.toString(),
        'Fehler beim Reverse des AnimationController: $e',
      );
    }
  }

  void safeAnimationControllerStop() {
    try {
      if (_isControllerInitialized) {
        _controller.stop();
      }
    } catch (e) {
      ErrorHandler.logError(
        runtimeType.toString(),
        'Fehler beim Stop des AnimationController: $e',
      );
    }
  }

  void safeAnimationControllerRepeat({bool reverse = false}) {
    try {
      if (_isControllerInitialized && mounted) {
        _controller.repeat(reverse: reverse);
      }
    } catch (e) {
      ErrorHandler.logError(
        runtimeType.toString(),
        'Fehler beim Repeat des AnimationController: $e',
      );
    }
  }
}

/// A safe wrapper for Future operations
class SafeFuture {
  static Future<T?> safeFuture<T>(
    String context,
    Future<T> Function() future,
  ) async {
    try {
      return await future();
    } catch (e, stackTrace) {
      ErrorHandler.logError(context, e, stackTrace: stackTrace);
      return null;
    }
  }
}

/// A safe wrapper for Stream operations
class SafeStream {
  static Stream<T> safeStream<T>(
    String context,
    Stream<T> Function() stream,
  ) {
    try {
      return stream().handleError((error, stackTrace) {
        ErrorHandler.logError(context, error, stackTrace: stackTrace);
      });
    } catch (e, stackTrace) {
      ErrorHandler.logError(context, e, stackTrace: stackTrace);
      return Stream.empty();
    }
  }
}