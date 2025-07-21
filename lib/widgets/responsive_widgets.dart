import 'package:flutter/material.dart';

/// Safe widgets that provide responsive constraints and error handling
/// These widgets help prevent UI overflow issues and provide better responsiveness

/// A safe wrapper around Column that prevents overflow and provides responsive constraints
class SafeScrollableColumn extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets padding;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final ScrollPhysics? physics;

  const SafeScrollableColumn({
    super.key,
    required this.children,
    this.padding = EdgeInsets.zero,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: physics ?? const ClampingScrollPhysics(),
          padding: padding,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
              maxWidth: constraints.maxWidth,
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: mainAxisAlignment,
                crossAxisAlignment: crossAxisAlignment,
                mainAxisSize: MainAxisSize.min,
                children: children,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A safe layout builder that handles errors gracefully
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
    return LayoutBuilder(
      builder: (context, constraints) {
        try {
          return builder(context, constraints);
        } catch (e) {
          // Log error and return fallback widget
          if (debugLabel != null) {
            debugPrint('SafeLayoutBuilder error in $debugLabel: $e');
          }
          
          return Container(
            constraints: BoxConstraints(
              maxWidth: constraints.maxWidth,
              maxHeight: constraints.maxHeight.isFinite ? constraints.maxHeight : 200,
            ),
            child: const Center(
              child: Text(
                'Layout-Fehler',
                style: TextStyle(color: Colors.red),
              ),
            ),
          );
        }
      },
    );
  }
}

/// A safe expanded widget that prevents flex overflow
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
    return Flexible(
      flex: flex,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: 0,
          maxHeight: double.infinity,
        ),
        child: child,
      ),
    );
  }
}

/// Responsive container that adapts to screen size
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? maxWidth;
  final double? minHeight;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.maxWidth,
    this.minHeight,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        
        // Calculate responsive padding
        final responsivePadding = padding ?? EdgeInsets.symmetric(
          horizontal: _calculateHorizontalPadding(screenWidth),
          vertical: _calculateVerticalPadding(screenWidth),
        );
        
        // Calculate responsive margin
        final responsiveMargin = margin ?? EdgeInsets.symmetric(
          horizontal: _calculateHorizontalMargin(screenWidth),
        );
        
        // Calculate responsive max width
        final responsiveMaxWidth = maxWidth ?? _calculateMaxWidth(screenWidth);
        
        return Container(
          constraints: BoxConstraints(
            maxWidth: responsiveMaxWidth,
            minHeight: minHeight ?? 0,
          ),
          padding: responsivePadding,
          margin: responsiveMargin,
          child: child,
        );
      },
    );
  }

  double _calculateHorizontalPadding(double screenWidth) {
    if (screenWidth < 600) {
      return 16.0; // Small screens
    } else if (screenWidth < 900) {
      return 24.0; // Medium screens
    } else {
      return 32.0; // Large screens
    }
  }

  double _calculateVerticalPadding(double screenWidth) {
    if (screenWidth < 600) {
      return 12.0; // Small screens
    } else {
      return 16.0; // Larger screens
    }
  }

  double _calculateHorizontalMargin(double screenWidth) {
    if (screenWidth < 600) {
      return 8.0; // Small screens
    } else if (screenWidth < 900) {
      return 16.0; // Medium screens
    } else {
      return 24.0; // Large screens
    }
  }

  double _calculateMaxWidth(double screenWidth) {
    if (screenWidth < 600) {
      return screenWidth * 0.95; // Small screens: use most of the width
    } else if (screenWidth < 900) {
      return 600.0; // Medium screens: limit to reasonable width
    } else {
      return 800.0; // Large screens: limit to even more reasonable width
    }
  }
}

/// Responsive grid that adapts column count based on screen size
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double? childAspectRatio;
  final double? crossAxisSpacing;
  final double? mainAxisSpacing;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.childAspectRatio,
    this.crossAxisSpacing,
    this.mainAxisSpacing,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final crossAxisCount = _calculateCrossAxisCount(screenWidth);
        final responsiveChildAspectRatio = childAspectRatio ?? _calculateChildAspectRatio(screenWidth);
        
        return GridView.builder(
          shrinkWrap: shrinkWrap,
          physics: physics,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: responsiveChildAspectRatio,
            crossAxisSpacing: crossAxisSpacing ?? 16.0,
            mainAxisSpacing: mainAxisSpacing ?? 16.0,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }

  int _calculateCrossAxisCount(double screenWidth) {
    if (screenWidth < 600) {
      return 1; // Small screens: 1 column
    } else if (screenWidth < 900) {
      return 2; // Medium screens: 2 columns
    } else {
      return 3; // Large screens: 3 columns
    }
  }

  double _calculateChildAspectRatio(double screenWidth) {
    if (screenWidth < 600) {
      return 1.2; // Wider cards on small screens
    } else {
      return 0.8; // Standard ratio for larger screens
    }
  }
}