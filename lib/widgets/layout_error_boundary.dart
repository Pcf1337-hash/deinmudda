import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/design_tokens.dart';

/// A widget that catches and handles layout errors gracefully
class LayoutErrorBoundary extends StatefulWidget {
  final Widget child;
  final String? debugLabel;
  final Widget? fallback;

  const LayoutErrorBoundary({
    super.key,
    required this.child,
    this.debugLabel,
    this.fallback,
  });

  @override
  State<LayoutErrorBoundary> createState() => _LayoutErrorBoundaryState();
}

class _LayoutErrorBoundaryState extends State<LayoutErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void initState() {
    super.initState();
    
    // Set up error handler for uncaught layout errors
    FlutterError.onError = (FlutterErrorDetails details) {
      // Check if this is a layout-related error
      if (_isLayoutError(details.exception.toString())) {
        print('🚨 Layout error caught by boundary: ${details.exception}');
        if (mounted) {
          setState(() {
            _error = details.exception;
            _stackTrace = details.stack;
          });
        }
      }
      
      // Call the original error handler
      FlutterError.presentError(details);
    };
  }

  bool _isLayoutError(String errorMessage) {
    final layoutErrorKeywords = [
      'RenderBox was not laid out',
      'RenderFlex overflowed',
      'RenderConstrainedBox',
      'Failed assertion: !_debugDoingThisLayout',
      'RenderBox overflow',
      'layout constraints',
      'constraints are not normalized',
      'unbounded height',
      'unbounded width',
    ];
    
    return layoutErrorKeywords.any((keyword) => 
      errorMessage.toLowerCase().contains(keyword.toLowerCase()));
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.fallback ?? _buildErrorFallback(context);
    }
    
    return ErrorBoundaryWrapper(
      onError: (error, stackTrace) {
        print('🚨 Error boundary caught: $error');
        if (mounted) {
          setState(() {
            _error = error;
            _stackTrace = stackTrace;
          });
        }
      },
      child: widget.child,
    );
  }

  Widget _buildErrorFallback(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      constraints: const BoxConstraints(
        minHeight: 100,
        maxHeight: 200,
      ),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: DesignTokens.warningYellow.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_rounded,
            color: DesignTokens.warningYellow,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            'Layout-Fehler aufgetreten',
            style: theme.textTheme.titleMedium?.copyWith(
              color: DesignTokens.warningYellow,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            widget.debugLabel ?? 'Ein Anzeigebereich konnte nicht korrekt geladen werden.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() {
                _error = null;
                _stackTrace = null;
              });
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Erneut versuchen'),
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignTokens.warningYellow,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A wrapper that catches errors during widget building
class ErrorBoundaryWrapper extends StatefulWidget {
  final Widget child;
  final void Function(Object error, StackTrace stackTrace)? onError;

  const ErrorBoundaryWrapper({
    super.key,
    required this.child,
    this.onError,
  });

  @override
  State<ErrorBoundaryWrapper> createState() => _ErrorBoundaryWrapperState();
}

class _ErrorBoundaryWrapperState extends State<ErrorBoundaryWrapper> {
  @override
  Widget build(BuildContext context) {
    try {
      return widget.child;
    } catch (error, stackTrace) {
      widget.onError?.call(error, stackTrace);
      
      // Return a simple fallback widget
      return Container(
        constraints: const BoxConstraints(
          minHeight: 50,
          maxHeight: 100,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: DesignTokens.errorRed.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: DesignTokens.errorRed,
                size: 24,
              ),
              SizedBox(height: 8),
              Text(
                'Inhalt nicht verfügbar',
                style: TextStyle(
                  color: DesignTokens.errorRed,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
  }
}

/// A safe wrapper for constrained layouts
class SafeLayoutBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, BoxConstraints constraints) builder;
  final String? debugLabel;

  const SafeLayoutBuilder({
    super.key,
    required this.builder,
    this.debugLabel,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutErrorBoundary(
      debugLabel: debugLabel,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Ensure constraints are valid
          final safeConstraints = BoxConstraints(
            minWidth: constraints.minWidth.isFinite ? constraints.minWidth : 0,
            maxWidth: constraints.maxWidth.isFinite ? constraints.maxWidth : double.infinity,
            minHeight: constraints.minHeight.isFinite ? constraints.minHeight : 0,
            maxHeight: constraints.maxHeight.isFinite ? constraints.maxHeight : double.infinity,
          );

          return builder(context, safeConstraints);
        },
      ),
    );
  }
}

/// A safe wrapper for scrollable content
class SafeScrollableColumn extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final EdgeInsets? padding;
  final ScrollPhysics? physics;

  const SafeScrollableColumn({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.padding,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutErrorBoundary(
      debugLabel: 'SafeScrollableColumn',
      child: SingleChildScrollView(
        physics: physics ?? const ClampingScrollPhysics(),
        padding: padding,
        child: Column(
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }
}

/// A safe wrapper for flexible layouts
class SafeFlexible extends StatelessWidget {
  final Widget child;
  final int flex;
  final FlexFit fit;

  const SafeFlexible({
    super.key,
    required this.child,
    this.flex = 1,
    this.fit = FlexFit.loose,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutErrorBoundary(
      debugLabel: 'SafeFlexible',
      child: Flexible(
        flex: flex,
        fit: fit,
        child: child,
      ),
    );
  }
}

/// A safe wrapper for expanded widgets
class SafeExpanded extends StatelessWidget {
  final Widget child;
  final int flex;

  const SafeExpanded({
    super.key,
    required this.child,
    this.flex = 1,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutErrorBoundary(
      debugLabel: 'SafeExpanded',
      child: Expanded(
        flex: flex,
        child: child,
      ),
    );
  }
}