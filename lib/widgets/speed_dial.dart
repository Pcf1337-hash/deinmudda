import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/design_tokens.dart';
import '../theme/spacing.dart';

class SpeedDial extends StatefulWidget {
  final List<SpeedDialAction> actions;
  final Widget child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? tooltip;
  final bool closeOnAction;

  const SpeedDial({
    super.key,
    required this.actions,
    required this.child,
    this.backgroundColor,
    this.foregroundColor,
    this.tooltip,
    this.closeOnAction = true,
  });

  @override
  State<SpeedDial> createState() => _SpeedDialState();
}

class _SpeedDialState extends State<SpeedDial>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotationAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    
    _expandAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.125, // 45 degrees
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _onActionTap(VoidCallback? onTap) {
    if (widget.closeOnAction) {
      _toggleExpanded();
    }
    onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Background overlay
        if (_isExpanded)
          GestureDetector(
            onTap: _toggleExpanded,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withOpacity(0.3),
            ),
          ).animate().fadeIn(
            duration: const Duration(milliseconds: 250),
          ),
        
        // Action buttons
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ...widget.actions.asMap().entries.map((entry) {
              final index = entry.key;
              final action = entry.value;
              
              return AnimatedBuilder(
                animation: _expandAnimation,
                builder: (context, child) {
                  final offset = _expandAnimation.value * (index + 1) * 70.0;
                  
                  return Transform.translate(
                    offset: Offset(0, -offset),
                    child: Opacity(
                      opacity: _expandAnimation.value,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: Spacing.sm),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (action.label != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Spacing.sm,
                                  vertical: Spacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.grey[800]
                                      : Colors.grey[100],
                                  borderRadius: Spacing.borderRadiusMd,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  action.label!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            const SizedBox(width: Spacing.sm),
                            FloatingActionButton(
                              mini: true,
                              heroTag: 'speed_dial_${index}',
                              onPressed: () => _onActionTap(action.onTap),
                              backgroundColor: action.backgroundColor ?? DesignTokens.accentCyan,
                              foregroundColor: action.foregroundColor ?? Colors.white,
                              tooltip: action.tooltip,
                              child: action.child,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
            
            // Main FAB
            AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationAnimation.value * 2 * 3.14159,
                  child: FloatingActionButton(
                    heroTag: 'speed_dial_main',
                    onPressed: _toggleExpanded,
                    backgroundColor: widget.backgroundColor ?? DesignTokens.accentPink,
                    foregroundColor: widget.foregroundColor ?? Colors.white,
                    tooltip: widget.tooltip,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _isExpanded
                          ? const Icon(Icons.close_rounded, key: ValueKey('close'))
                          : widget.child,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

class SpeedDialAction {
  final Widget child;
  final VoidCallback? onTap;
  final String? label;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const SpeedDialAction({
    required this.child,
    this.onTap,
    this.label,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
  });
}