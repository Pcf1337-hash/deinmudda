import 'package:flutter/material.dart';
// removed unused import: package:flutter/foundation.dart // cleaned by BereinigungsAgent
import 'dart:ui';
import '../theme/design_tokens.dart';
import '../theme/spacing.dart';
import '../utils/performance_helper.dart';

/// A customizable glass-morphism card widget with blur effects.
/// 
/// Provides a modern glass-like appearance with customizable borders,
/// shadows, and optional psychedelic effects for dark themes.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final Color? borderColor;
  final double borderWidth;
  final Duration animationDuration;
  final bool showShadow;
  final bool usePsychedelicEffects;
  final Color? glowColor;

  /// Creates a glass card with glassmorphism effects.
  /// 
  /// The [child] parameter is required and will be wrapped in the glass container.
  /// Use [usePsychedelicEffects] to enable enhanced visual effects in dark theme.
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
    this.borderColor,
    this.borderWidth = 1.0,
    this.animationDuration = DesignTokens.animationMedium,
    this.showShadow = true,
    this.usePsychedelicEffects = false,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final card = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding ?? Spacing.paddingMd,
      decoration: BoxDecoration(
        gradient: _getGradient(isDark),
        borderRadius: Spacing.borderRadiusLg,
        border: Border.all(
          color: _getBorderColor(isDark),
          width: borderWidth,
        ),
        // Optimize by disabling shadows on low-end devices in release mode
        boxShadow: _getBoxShadow(isDark),
      ),
      child: usePsychedelicEffects && isDark
          ? _buildPsychedelicContent()
          : child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }

  /// Builds psychedelic content with enhanced blur effects.
  Widget _buildPsychedelicContent() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            gradient: DesignTokens.psychedelicGlassGradient,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: DesignTokens.psychedelicGlassBorder,
              width: 0.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  /// Gets appropriate gradient based on theme and effects.
  Gradient _getGradient(bool isDark) {
    if (usePsychedelicEffects && isDark) {
      return DesignTokens.psychedelicGlassGradient;
    }
    return isDark
        ? DesignTokens.glassGradientDark
        : DesignTokens.glassGradientLight;
  }

  /// Gets appropriate border color based on theme and effects.
  Color _getBorderColor(bool isDark) {
    if (borderColor != null) return borderColor!;
    if (usePsychedelicEffects && isDark) {
      return DesignTokens.psychedelicGlassBorder;
    }
    return isDark
        ? DesignTokens.glassBorderDark
        : DesignTokens.glassBorderLight;
  }

  /// Gets appropriate box shadow based on theme and performance settings.
  List<BoxShadow>? _getBoxShadow(bool isDark) {
    if (!showShadow || (kReleaseMode && PerformanceHelper.isLowEndDevice())) {
      return null;
    }
    
    if (usePsychedelicEffects && isDark) {
      return [
        BoxShadow(
          color: (glowColor ?? DesignTokens.neonPurple).withOpacity(0.2),
          blurRadius: 20,
          spreadRadius: 2,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: (glowColor ?? DesignTokens.neonPurple).withOpacity(0.1),
          blurRadius: 40,
          spreadRadius: 5,
          offset: const Offset(0, 8),
        ),
      ];
    }
    
    return [
      BoxShadow(
        color: isDark
            ? DesignTokens.shadowDark.withOpacity(0.2)
            : DesignTokens.shadowLight.withOpacity(0.1),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ];
  }
}

/// Enhanced glass card with psychedelic effects for dark themes.
/// 
/// Provides more intense visual effects and customizable glow intensity
/// specifically designed for dark mode interfaces.
class PsychedelicGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final Color? glowColor;
  final double intensity;

  /// Creates a psychedelic glass card with enhanced effects.
  /// 
  /// The [intensity] parameter controls the strength of the glow effects.
  /// Falls back to regular GlassCard in light themes.
  const PsychedelicGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
    this.glowColor,
    this.intensity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (!isDark) {
      // Fallback to regular glass card for light theme
      return GlassCard(
        width: width,
        height: height,
        margin: margin,
        padding: padding,
        onTap: onTap,
        child: child,
      );
    }

    final card = Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: padding ?? Spacing.paddingMd,
            decoration: BoxDecoration(
              gradient: DesignTokens.psychedelicGlassGradient,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: DesignTokens.psychedelicGlassBorder,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: (glowColor ?? DesignTokens.neonPurple)
                      .withOpacity(0.15 * intensity),
                  blurRadius: 30 * intensity,
                  spreadRadius: 3 * intensity,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: (glowColor ?? DesignTokens.neonPurple)
                      .withOpacity(0.08 * intensity),
                  blurRadius: 60 * intensity,
                  spreadRadius: 8 * intensity,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }
}

/// Glass-styled empty state widget with customizable content.
/// 
/// Displays an icon, title, subtitle, and optional action button
/// within a glass morphism container.
class GlassEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onAction;
  final bool usePsychedelicEffects;

  /// Creates a glass empty state widget.
  /// 
  /// Displays [title], [subtitle], and [icon] in a structured layout.
  /// Optionally includes an action button when [actionText] and [onAction] are provided.
  const GlassEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.actionText,
    this.onAction,
    this.usePsychedelicEffects = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final content = Column(
      children: [
        Icon(
          icon,
          size: Spacing.iconXl,
          color: (usePsychedelicEffects && isDark)
              ? DesignTokens.textPsychedelicSecondary.withOpacity(0.5)
              : Theme.of(context).iconTheme.color?.withOpacity(0.5),
        ),
        Spacing.verticalSpaceMd,
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: (usePsychedelicEffects && isDark)
                ? DesignTokens.textPsychedelicPrimary
                : null,
          ),
          textAlign: TextAlign.center,
        ),
        Spacing.verticalSpaceXs,
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: (usePsychedelicEffects && isDark)
                ? DesignTokens.textPsychedelicSecondary.withOpacity(0.7)
                : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
        if (actionText != null && onAction != null) ...[
          Spacing.verticalSpaceMd,
          ElevatedButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.add_rounded),
            label: Text(actionText!),
            style: ElevatedButton.styleFrom(
              backgroundColor: (usePsychedelicEffects && isDark)
                  ? DesignTokens.neonPurple
                  : DesignTokens.primaryIndigo,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ],
    );

    if (usePsychedelicEffects && isDark) {
      return PsychedelicGlassCard(child: content);
    }

    return GlassCard(child: content);
  }
}

// hints reduziert durch HintOptimiererAgent
