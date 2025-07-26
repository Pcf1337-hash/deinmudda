import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import '../services/psychedelic_theme_service.dart';
import '../widgets/trippy_fab.dart';
import '../widgets/platform_adaptive_fab.dart';
import '../theme/design_tokens.dart';
import '../utils/platform_helper.dart';

/// A platform-adaptive floating action button with speed dial functionality.
/// 
/// Automatically switches between TrippyFAB for psychedelic mode and
/// standard SpeedDial for normal mode, providing consistent behavior
/// across different visual themes.
class ConsistentFAB extends StatelessWidget {
  final List<SpeedDialChild> speedDialChildren;
  final VoidCallback? onMainAction;
  final IconData mainIcon;
  final String? mainLabel;
  final Color? backgroundColor;
  final bool isExtended;

  /// Creates a consistent FAB that adapts to psychedelic theme mode.
  /// 
  /// The [speedDialChildren] define the available actions in the speed dial.
  /// [onMainAction] is called when the main FAB is tapped in psychedelic mode.
  const ConsistentFAB({
    super.key,
    required this.speedDialChildren,
    this.onMainAction,
    this.mainIcon = Icons.speed_rounded,
    this.mainLabel,
    this.backgroundColor,
    this.isExtended = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PsychedelicThemeService>(
      builder: (context, psychedelicService, child) {
        final isPsychedelicMode = psychedelicService.isPsychedelicMode;
        
        if (isPsychedelicMode) {
          // Use TrippyFAB for psychedelic mode
          return TrippyFAB(
            onPressed: onMainAction ?? () {},
            icon: mainIcon,
            label: mainLabel ?? 'Aktionen',
            isExtended: isExtended,
          );
        }
        
        // Use platform-adaptive SpeedDial for normal mode
        return SpeedDial(
          tooltip: 'Aktionen',
          backgroundColor: backgroundColor ?? DesignTokens.accentPink,
          overlayOpacity: 0.4,
          overlayColor: Colors.black,
          spaceBetweenChildren: 12,
          buttonSize: Size(
            PlatformHelper.isIOS ? 52 : 56,
            PlatformHelper.isIOS ? 52 : 56,
          ),
          childrenButtonSize: Size(
            PlatformHelper.isIOS ? 44 : 48,
            PlatformHelper.isIOS ? 44 : 48,
          ),
          direction: SpeedDialDirection.up,
          switchLabelPosition: false,
          closeManually: false,
          elevation: PlatformHelper.getPlatformElevation(),
          shape: RoundedRectangleBorder(
            borderRadius: PlatformHelper.getPlatformBorderRadius(),
          ),
          children: speedDialChildren,
          child: Icon(
            mainIcon,
            size: PlatformHelper.getPlatformIconSize(),
          ),
          // Platform-specific animation curves
          animationCurve: PlatformHelper.isIOS ? Curves.easeInOut : Curves.fastOutSlowIn,
          // Haptic feedback on interaction
          onOpen: () => PlatformHelper.performHapticFeedback(HapticFeedbackType.lightImpact),
          onClose: () => PlatformHelper.performHapticFeedback(HapticFeedbackType.lightImpact),
        );
      },
    );
  }
}

/// Helper class for creating consistent SpeedDialChild widgets.
/// 
/// Provides factory methods for creating uniformly styled speed dial
/// children with consistent appearance and behavior.
class FABHelper {
  /// Private constructor to prevent instantiation
  const FABHelper._();
  
  /// Creates a standardized SpeedDialChild with consistent styling.
  /// 
  /// The [icon], [label], and [onTap] parameters are required.
  /// [backgroundColor] determines the child's color scheme.
  static SpeedDialChild createSpeedDialChild({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color backgroundColor,
    Color foregroundColor = Colors.white,
  }) {
    return SpeedDialChild(
      child: Icon(icon),
      label: label,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      labelStyle: const TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      labelBackgroundColor: backgroundColor.withOpacity(0.9),
      onTap: onTap,
    );
  }
}

// hints reduziert durch HintOptimiererAgent