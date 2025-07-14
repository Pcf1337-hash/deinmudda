import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/psychedelic_theme_service.dart' as service;
import '../theme/design_tokens.dart';

class ThemeSwitcher extends StatelessWidget {
  final bool showLabels;
  final Axis direction;

  const ThemeSwitcher({
    super.key,
    this.showLabels = true,
    this.direction = Axis.horizontal,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<service.PsychedelicThemeService>(
      builder: (context, themeService, child) {
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: direction == Axis.horizontal
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: _buildThemeButtons(context, themeService),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _buildThemeButtons(context, themeService),
                ),
        );
      },
    );
  }

  List<Widget> _buildThemeButtons(BuildContext context, service.PsychedelicThemeService themeService) {
    return [
      _ThemeButton(
        themeMode: service.ThemeMode.light,
        currentMode: themeService.currentThemeMode,
        onTap: () => themeService.setThemeMode(service.ThemeMode.light),
        icon: Icons.light_mode_rounded,
        label: showLabels ? 'Light' : null,
        color: Colors.orange,
      ),
      if (direction == Axis.horizontal) const SizedBox(width: 4) else const SizedBox(height: 4),
      _ThemeButton(
        themeMode: service.ThemeMode.dark,
        currentMode: themeService.currentThemeMode,
        onTap: () => themeService.setThemeMode(service.ThemeMode.dark),
        icon: Icons.dark_mode_rounded,
        label: showLabels ? 'Dark' : null,
        color: Colors.indigo,
      ),
      if (direction == Axis.horizontal) const SizedBox(width: 4) else const SizedBox(height: 4),
      _ThemeButton(
        themeMode: service.ThemeMode.trippy,
        currentMode: themeService.currentThemeMode,
        onTap: () => themeService.setThemeMode(service.ThemeMode.trippy),
        icon: Icons.auto_awesome_rounded,
        label: showLabels ? 'Trippy' : null,
        color: const Color(0xFFff00ff), // Neon magenta
      ),
    ];
  }
}

class _ThemeButton extends StatefulWidget {
  final service.ThemeMode themeMode;
  final service.ThemeMode currentMode;
  final VoidCallback onTap;
  final IconData icon;
  final String? label;
  final Color color;

  const _ThemeButton({
    required this.themeMode,
    required this.currentMode,
    required this.onTap,
    required this.icon,
    this.label,
    required this.color,
  });

  @override
  State<_ThemeButton> createState() => _ThemeButtonState();
}

class _ThemeButtonState extends State<_ThemeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // If this is the trippy mode and it's active, start a pulsing animation
    if (widget.themeMode == service.ThemeMode.trippy && widget.themeMode == widget.currentMode) {
      _startPulsingAnimation();
    }
  }

  void _startPulsingAnimation() {
    _animationController.repeat(reverse: true);
  }

  void _stopPulsingAnimation() {
    _animationController.stop();
    _animationController.reset();
  }

  @override
  void didUpdateWidget(_ThemeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.themeMode == service.ThemeMode.trippy && widget.themeMode == widget.currentMode) {
      _startPulsingAnimation();
    } else {
      _stopPulsingAnimation();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.themeMode == widget.currentMode;
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.themeMode == service.ThemeMode.trippy && isSelected
              ? 1.0 + (_glowAnimation.value * 0.1)
              : _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _animationController.forward(),
            onTapUp: (_) => _animationController.reverse(),
            onTapCancel: () => _animationController.reverse(),
            onTap: widget.onTap,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: widget.label != null ? 12 : 8,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? widget.color.withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: isSelected
                    ? Border.all(color: widget.color, width: 2)
                    : null,
                boxShadow: widget.themeMode == service.ThemeMode.trippy && isSelected
                    ? [
                        BoxShadow(
                          color: widget.color.withOpacity(0.5 * _glowAnimation.value),
                          blurRadius: 12 * _glowAnimation.value,
                          spreadRadius: 2 * _glowAnimation.value,
                        ),
                      ]
                    : null,
              ),
              child: widget.label != null
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.icon,
                          color: isSelected ? widget.color : theme.iconTheme.color?.withOpacity(0.7),
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.label!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isSelected ? widget.color : theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    )
                  : Icon(
                      widget.icon,
                      color: isSelected ? widget.color : theme.iconTheme.color?.withOpacity(0.7),
                      size: 20,
                    ),
            ),
          ),
        );
      },
    );
  }
}

// Quick theme cycle button for FABs or quick access
class ThemeCycleButton extends StatelessWidget {
  final double size;
  final bool showCurrentModeIcon;

  const ThemeCycleButton({
    super.key,
    this.size = 48,
    this.showCurrentModeIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<service.PsychedelicThemeService>(
      builder: (context, themeService, child) {
        IconData currentIcon;
        Color currentColor;
        
        switch (themeService.currentThemeMode) {
          case service.ThemeMode.light:
            currentIcon = Icons.light_mode_rounded;
            currentColor = Colors.orange;
            break;
          case service.ThemeMode.dark:
            currentIcon = Icons.dark_mode_rounded;
            currentColor = Colors.indigo;
            break;
          case service.ThemeMode.trippy:
            currentIcon = Icons.auto_awesome_rounded;
            currentColor = const Color(0xFFff00ff);
            break;
        }

        return GestureDetector(
          onTap: () => themeService.cycleThemeMode(),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: currentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(size / 2),
              border: Border.all(
                color: currentColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              showCurrentModeIcon ? currentIcon : Icons.palette_rounded,
              color: currentColor,
              size: size * 0.5,
            ),
          ),
        );
      },
    );
  }
}