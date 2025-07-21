import 'package:flutter/material.dart';

/// A performance-optimized list view that uses ListView.builder with
/// RepaintBoundary and AnimatedSwitcher for smooth animations
class OptimizedListView extends StatefulWidget {
  final List<Widget> children;
  final ScrollPhysics? physics;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  final Duration animationDuration;

  const OptimizedListView({
    super.key,
    required this.children,
    this.physics,
    this.padding,
    this.shrinkWrap = false,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<OptimizedListView> createState() => _OptimizedListViewState();
}

class _OptimizedListViewState extends State<OptimizedListView> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: widget.physics,
      padding: widget.padding,
      shrinkWrap: widget.shrinkWrap,
      itemCount: widget.children.length,
      itemBuilder: (context, index) {
        return RepaintBoundary(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 200, // Prevent items from becoming too tall
            ),
            child: AnimatedSwitcher(
              duration: widget.animationDuration,
              child: widget.children[index],
            ),
          ),
        );
      },
    );
  }
}

/// A performance-optimized grid view with proper repaint boundaries
class OptimizedGridView extends StatefulWidget {
  final List<Widget> children;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const OptimizedGridView({
    super.key,
    required this.children,
    this.crossAxisCount = 2,
    this.crossAxisSpacing = 8.0,
    this.mainAxisSpacing = 8.0,
    this.childAspectRatio = 1.0,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  State<OptimizedGridView> createState() => _OptimizedGridViewState();
}

class _OptimizedGridViewState extends State<OptimizedGridView> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: widget.physics,
      padding: widget.padding,
      shrinkWrap: widget.shrinkWrap,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        crossAxisSpacing: widget.crossAxisSpacing,
        mainAxisSpacing: widget.mainAxisSpacing,
        childAspectRatio: widget.childAspectRatio,
      ),
      itemCount: widget.children.length,
      itemBuilder: (context, index) {
        return RepaintBoundary(
          child: widget.children[index],
        );
      },
    );
  }
}

/// A widget that smoothly fades between different states
class FadeTransitionWidget extends StatefulWidget {
  final Widget child;
  final bool show;
  final Duration duration;
  final Curve curve;

  const FadeTransitionWidget({
    super.key,
    required this.child,
    this.show = true,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  });

  @override
  State<FadeTransitionWidget> createState() => _FadeTransitionWidgetState();
}

class _FadeTransitionWidgetState extends State<FadeTransitionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );
    
    if (widget.show) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(FadeTransitionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.show != oldWidget.show) {
      if (widget.show) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}

/// A performance-optimized card with caching and const constructors
class OptimizedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;

  const OptimizedCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius,
    this.boxShadow,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        margin: margin,
        decoration: BoxDecoration(
          color: color ?? Theme.of(context).colorScheme.surface,
          borderRadius: borderRadius ?? BorderRadius.circular(12),
          boxShadow: boxShadow,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: borderRadius ?? BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: borderRadius ?? BorderRadius.circular(12),
            child: Padding(
              padding: padding ?? const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// A widget that prevents unnecessary rebuilds of expensive widgets
class CachedBuilder extends StatefulWidget {
  final Widget Function(BuildContext context) builder;
  final List<Object?> dependencies;

  const CachedBuilder({
    super.key,
    required this.builder,
    this.dependencies = const [],
  });

  @override
  State<CachedBuilder> createState() => _CachedBuilderState();
}

class _CachedBuilderState extends State<CachedBuilder> {
  Widget? _cachedWidget;
  List<Object?> _lastDependencies = [];

  @override
  Widget build(BuildContext context) {
    // Check if dependencies have changed
    bool dependenciesChanged = false;
    if (_lastDependencies.length != widget.dependencies.length) {
      dependenciesChanged = true;
    } else {
      for (int i = 0; i < widget.dependencies.length; i++) {
        if (_lastDependencies[i] != widget.dependencies[i]) {
          dependenciesChanged = true;
          break;
        }
      }
    }

    // Rebuild only if dependencies changed or no cache exists
    if (_cachedWidget == null || dependenciesChanged) {
      _cachedWidget = widget.builder(context);
      _lastDependencies = List.from(widget.dependencies);
    }

    return _cachedWidget!;
  }
}

/// A smooth sliding animation widget
class SlideTransitionWidget extends StatefulWidget {
  final Widget child;
  final bool show;
  final Duration duration;
  final Offset beginOffset;
  final Offset endOffset;
  final Curve curve;

  const SlideTransitionWidget({
    super.key,
    required this.child,
    this.show = true,
    this.duration = const Duration(milliseconds: 300),
    this.beginOffset = const Offset(0, 1),
    this.endOffset = Offset.zero,
    this.curve = Curves.easeInOut,
  });

  @override
  State<SlideTransitionWidget> createState() => _SlideTransitionWidgetState();
}

class _SlideTransitionWidgetState extends State<SlideTransitionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<Offset>(
      begin: widget.beginOffset,
      end: widget.endOffset,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    
    if (widget.show) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(SlideTransitionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.show != oldWidget.show) {
      if (widget.show) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: widget.child,
    );
  }
}