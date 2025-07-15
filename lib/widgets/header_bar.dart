import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../services/psychedelic_theme_service.dart';
import '../theme/design_tokens.dart';
import '../theme/spacing.dart';

class HeaderBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Widget? trailing;
  final double? height;
  final bool showLightningIcon;

  const HeaderBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBackButton = true,
    this.onBackPressed,
    this.trailing,
    this.height,
    this.showLightningIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<PsychedelicThemeService>(
      builder: (context, psychedelicService, child) {
        final isPsychedelicMode = psychedelicService.isPsychedelicMode;
        final substanceColors = psychedelicService.getCurrentSubstanceColors();

        return Container(
          height: height ?? 120,
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
              padding: Spacing.paddingMd,
              child: Stack(
                children: [
                  // Back button
                  if (showBackButton)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          color: isPsychedelicMode
                              ? DesignTokens.textPsychedelicPrimary
                              : Colors.white,
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
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  title,
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    color: isPsychedelicMode
                                        ? DesignTokens.textPsychedelicPrimary
                                        : Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (subtitle != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    subtitle!,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: isPsychedelicMode
                                          ? DesignTokens.textPsychedelicSecondary
                                          : Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (showLightningIcon) ...[
                            const SizedBox(width: 12),
                            _buildLightningIcon(isPsychedelicMode, substanceColors),
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

  Widget _buildLightningIcon(bool isPsychedelicMode, Map<String, Color> substanceColors) {
    return Container(
      padding: const EdgeInsets.all(Spacing.xs),
      decoration: BoxDecoration(
        color: isPsychedelicMode
            ? substanceColors['primary']!.withOpacity(0.2)
            : Colors.white.withOpacity(0.2),
        borderRadius: Spacing.borderRadiusSm,
        border: Border.all(
          color: isPsychedelicMode
              ? substanceColors['primary']!.withOpacity(0.3)
              : Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 2000),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.rotate(
            angle: isPsychedelicMode ? value * 0.1 : 0,
            child: Icon(
              DesignTokens.lightningIcon,
              color: isPsychedelicMode
                  ? substanceColors['primary']!
                  : Colors.white,
              size: Spacing.iconMd,
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
}