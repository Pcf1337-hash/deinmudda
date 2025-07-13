import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';
import '../../theme/spacing.dart';

enum DangerLevel {
  low,
  medium,
  high,
  critical,
}

extension DangerLevelExtension on DangerLevel {
  String get displayName {
    switch (this) {
      case DangerLevel.low:
        return 'Niedrig';
      case DangerLevel.medium:
        return 'Mittel';
      case DangerLevel.high:
        return 'Hoch';
      case DangerLevel.critical:
        return 'Kritisch';
    }
  }

  Color get color {
    switch (this) {
      case DangerLevel.low:
        return DesignTokens.successGreen;
      case DangerLevel.medium:
        return DesignTokens.warningYellow;
      case DangerLevel.high:
        return DesignTokens.warningOrange;
      case DangerLevel.critical:
        return DesignTokens.errorRed;
    }
  }

  IconData get icon {
    switch (this) {
      case DangerLevel.low:
        return Icons.check_circle_rounded;
      case DangerLevel.medium:
        return Icons.warning_rounded;
      case DangerLevel.high:
        return Icons.error_rounded;
      case DangerLevel.critical:
        return Icons.dangerous_rounded;
    }
  }
}

class DangerBadge extends StatelessWidget {
  final DangerLevel level;
  final bool showIcon;
  final bool isCompact;
  final double? fontSize;

  const DangerBadge({
    super.key,
    required this.level,
    this.showIcon = true,
    this.isCompact = false,
    this.fontSize,
  });

  factory DangerBadge.fromSubstance(String substanceName) {
    final name = substanceName.toLowerCase();
    
    DangerLevel level;
    if (name.contains('lsd') || name.contains('mdma') || name.contains('kokain') || name.contains('cocaine')) {
      level = DangerLevel.high;
    } else if (name.contains('ketamin') || name.contains('2c-b') || name.contains('amphetamin')) {
      level = DangerLevel.medium;
    } else if (name.contains('alkohol') || name.contains('psilocybin') || name.contains('mushroom')) {
      level = DangerLevel.medium;
    } else if (name.contains('cannabis') || name.contains('thc')) {
      level = DangerLevel.low;
    } else {
      level = DangerLevel.medium;
    }
    
    return DangerBadge(level: level);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = level.color;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? Spacing.xs : Spacing.sm,
        vertical: isCompact ? 2 : Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isCompact ? 8 : 12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              level.icon,
              color: color,
              size: isCompact ? 12 : 16,
            ),
            if (!isCompact) const SizedBox(width: 4),
          ],
          if (!isCompact)
            Text(
              level.displayName,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: fontSize ?? (isCompact ? 10 : 12),
              ),
            ),
        ],
      ),
    );
  }
}