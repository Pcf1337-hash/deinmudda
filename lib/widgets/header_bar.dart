import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../services/psychedelic_theme_service.dart' as service;
import '../theme/design_tokens.dart';
import '../theme/spacing.dart';
import '../utils/platform_helper.dart';

class HeaderBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Widget? trailing;
  final double? height;
  final bool showLightningIcon;
  final IconData? customIcon; // New parameter for custom icons

  const HeaderBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBackButton = true,
    this.onBackPressed,
    this.trailing,
    this.height,
    this.showLightningIcon = true,
    this.customIcon, // Custom icon for different screens
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<service.PsychedelicThemeService>(
      builder: (context, psychedelicService, child) {
        final isPsychedelicMode = psychedelicService.isPsychedelicMode;
        final substanceColors = psychedelicService.getCurrentSubstanceColors();

        return Container(
          // Use flexible constraints instead of fixed height
          constraints: BoxConstraints(
            minHeight: height ?? (PlatformHelper.isIOS ? 100 : 120),
            maxHeight: height != null ? height! : (PlatformHelper.isIOS ? 180 : 200),
          ),
          decoration: BoxDecoration(
            gradient: isPsychedelicMode
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      DesignTokens.psychedelicBackground,
                      substanceColors['primary']!.withOpacity(0.1),
                      DesignTokens.psychedelicBackground,
                    ],
                  )
                : isDark
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF1A1A2E),
                          Color(0xFF16213E),
                          Color(0xFF0F3460),
                        ],
                      )
                    : DesignTokens.primaryGradient,
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: PlatformHelper.isIOS ? 12.0 : 16.0,
                vertical: PlatformHelper.isIOS ? 8.0 : 12.0,
              ),
              child: Stack(
                children: [
                  // Back button
                  if (showBackButton)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () {
                          if (onBackPressed != null) {
                            onBackPressed!();
                          } else {
                            PlatformHelper.handleBackNavigation(context);
                          }
                          
                          // Platform-specific haptic feedback
                          PlatformHelper.performHapticFeedback(HapticFeedbackType.lightImpact);
                        },
                        icon: Icon(
                          PlatformHelper.isIOS ? Icons.arrow_back_ios_rounded : Icons.arrow_back_rounded,
                          color: isPsychedelicMode
                              ? DesignTokens.textPsychedelicPrimary
                              : Colors.white,
                          size: PlatformHelper.getPlatformIconSize(),
                        ),
                      ),
                    ),

                  // Trailing widget
                  if (trailing != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: trailing!,
                    ),

                  // Title and lightning icon
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: showBackButton ? 56.0 : 0.0,
                        right: trailing != null ? 56.0 : 0.0,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Improved title with better text scaling
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    return ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth: constraints.maxWidth * 0.9, // Use 90% of available width
                                      ),
                                      child: Text(
                                        title,
                                        style: theme.textTheme.headlineMedium?.copyWith(
                                          color: isPsychedelicMode
                                              ? DesignTokens.textPsychedelicPrimary
                                              : Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: _getResponsiveTitleSize(constraints.maxWidth),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1, // Reduced to 1 line to prevent overflow
                                        textAlign: TextAlign.left,
                                      ),
                                    );
                                  },
                                ),
                                if (subtitle != null) ...[
                                  const SizedBox(height: 2), // Reduced spacing to prevent overflow
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      return ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth: constraints.maxWidth * 0.85, // Slightly less width for subtitle
                                        ),
                                        child: Text(
                                          subtitle!,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: isPsychedelicMode
                                                ? DesignTokens.textPsychedelicSecondary
                                                : Colors.white.withOpacity(0.9), // Improved contrast
                                            fontSize: _getResponsiveSubtitleSize(constraints.maxWidth),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          textAlign: TextAlign.left,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (showLightningIcon || customIcon != null) ...[
                            const SizedBox(width: 12),
                            _buildHeaderIcon(isPsychedelicMode, substanceColors),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ).animate().fadeIn(
          duration: DesignTokens.animationSlow,
          delay: const Duration(milliseconds: 200),
        );
      },
    );
  }

  // Helper method to get responsive title size
  double _getResponsiveTitleSize(double availableWidth) {
    if (availableWidth < 300) {
      return 20.0; // Smaller screens
    } else if (availableWidth < 400) {
      return 22.0; // Medium screens
    } else {
      return 24.0; // Larger screens
    }
  }

  // Helper method to get responsive subtitle size
  double _getResponsiveSubtitleSize(double availableWidth) {
    if (availableWidth < 300) {
      return 14.0; // Smaller screens
    } else if (availableWidth < 400) {
      return 15.0; // Medium screens
    } else {
      return 16.0; // Larger screens
    }
  }

  Widget _buildHeaderIcon(bool isPsychedelicMode, Map<String, Color> substanceColors) {
    final iconToShow = customIcon ?? DesignTokens.lightningIcon;
    
    return Container(
      constraints: const BoxConstraints(
        minWidth: 36,
        minHeight: 36,
        maxWidth: 48,
        maxHeight: 48,
      ),
      padding: EdgeInsets.all(PlatformHelper.isIOS ? 6.0 : 8.0),
      decoration: BoxDecoration(
        // Improved background to prevent fragmentation
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isPsychedelicMode
              ? [
                  substanceColors['primary']!.withOpacity(0.3),
                  substanceColors['primary']!.withOpacity(0.1),
                ]
              : [
                  Colors.white.withOpacity(0.25),
                  Colors.white.withOpacity(0.1),
                ],
        ),
        borderRadius: PlatformHelper.getPlatformBorderRadius(),
        border: Border.all(
          color: isPsychedelicMode
              ? substanceColors['primary']!.withOpacity(0.4)
              : Colors.white.withOpacity(0.4),
          width: 1.5,
        ),
        // Add shadow for better visual separation
        boxShadow: [
          BoxShadow(
            color: (isPsychedelicMode 
                ? substanceColors['primary']! 
                : Colors.black).withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TweenAnimationBuilder<double>(
        duration: Duration(milliseconds: isPsychedelicMode ? 2000 : 3000),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.rotate(
            angle: isPsychedelicMode ? value * 0.05 : 0, // Reduced rotation for less distraction
            child: Icon(
              iconToShow,
              color: isPsychedelicMode
                  ? substanceColors['primary']!
                  : Colors.white,
              size: PlatformHelper.getPlatformIconSize(),
            ),
          );
        },
        onEnd: () {
          // Restart animation in psychedelic mode
          if (isPsychedelicMode) {
            // This will be handled by the parent widget's setState
          }
        },
      ),
    );
  }

  // Keep the old method for backwards compatibility
  Widget _buildLightningIcon(bool isPsychedelicMode, Map<String, Color> substanceColors) {
    return _buildHeaderIcon(isPsychedelicMode, substanceColors);
  }
}