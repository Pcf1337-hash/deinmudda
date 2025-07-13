import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../../theme/design_tokens.dart';
import '../../theme/spacing.dart';

class BMIIndicator extends StatefulWidget {
  final double bmi;
  final double size;
  final bool showLabel;
  final bool showCategory;
  final Duration animationDuration;

  const BMIIndicator({
    super.key,
    required this.bmi,
    this.size = 80,
    this.showLabel = true,
    this.showCategory = true,
    this.animationDuration = const Duration(milliseconds: 1500),
  });

  @override
  State<BMIIndicator> createState() => _BMIIndicatorState();
}

class _BMIIndicatorState extends State<BMIIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: _getBMIProgress(widget.bmi),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: DesignTokens.curveEaseOut,
    ));

    _animationController.forward();
  }

  @override
  void didUpdateWidget(BMIIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bmi != widget.bmi) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: _getBMIProgress(widget.bmi),
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: DesignTokens.curveEaseOut,
      ));
      _animationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  double _getBMIProgress(double bmi) {
    // Map BMI to progress (0.0 - 1.0)
    // BMI ranges: <18.5 (underweight), 18.5-24.9 (normal), 25-29.9 (overweight), >=30 (obese)
    if (bmi <= 15) return 0.0;
    if (bmi >= 40) return 1.0;
    return (bmi - 15) / 25; // Map 15-40 BMI range to 0-1 progress
  }

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) {
      return DesignTokens.infoBlue; // Underweight
    } else if (bmi < 25.0) {
      return DesignTokens.successGreen; // Normal
    } else if (bmi < 30.0) {
      return DesignTokens.warningYellow; // Overweight
    } else {
      return DesignTokens.errorRed; // Obese
    }
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) {
      return 'Untergewicht';
    } else if (bmi < 25.0) {
      return 'Normalgewicht';
    } else if (bmi < 30.0) {
      return 'Übergewicht';
    } else if (bmi < 35.0) {
      return 'Adipositas I';
    } else if (bmi < 40.0) {
      return 'Adipositas II';
    } else {
      return 'Adipositas III';
    }
  }

  IconData _getBMIIcon(double bmi) {
    if (bmi < 18.5) {
      return Icons.trending_down_rounded;
    } else if (bmi < 25.0) {
      return Icons.check_circle_rounded;
    } else if (bmi < 30.0) {
      return Icons.trending_up_rounded;
    } else {
      return Icons.warning_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bmiColor = _getBMIColor(widget.bmi);
    final bmiCategory = _getBMICategory(widget.bmi);
    final bmiIcon = _getBMIIcon(widget.bmi);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Circular Progress Indicator
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return SizedBox(
              width: widget.size,
              height: widget.size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle
                  SizedBox(
                    width: widget.size,
                    height: widget.size,
                    child: CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 6,
                      backgroundColor: theme.brightness == Brightness.dark
                          ? DesignTokens.neutral800
                          : DesignTokens.neutral200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.brightness == Brightness.dark
                            ? DesignTokens.neutral800
                            : DesignTokens.neutral200,
                      ),
                    ),
                  ),
                  // Progress circle
                  SizedBox(
                    width: widget.size,
                    height: widget.size,
                    child: CircularProgressIndicator(
                      value: _progressAnimation.value,
                      strokeWidth: 6,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(bmiColor),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  // Center content
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        bmiIcon,
                        color: bmiColor,
                        size: widget.size * 0.25,
                      ),
                      if (widget.showLabel) ...[
                        const SizedBox(height: 2),
                        Text(
                          widget.bmi.toStringAsFixed(1),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: bmiColor,
                            fontSize: widget.size * 0.12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            );
          },
        ),

        // BMI Category Label
        if (widget.showCategory) ...[
          const SizedBox(height: Spacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.sm,
              vertical: Spacing.xs,
            ),
            decoration: BoxDecoration(
              color: bmiColor.withOpacity(0.1),
              borderRadius: Spacing.borderRadiusSm,
              border: Border.all(
                color: bmiColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              bmiCategory,
              style: theme.textTheme.bodySmall?.copyWith(
                color: bmiColor,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    ).animate().fadeIn(
      duration: DesignTokens.animationMedium,
    ).scale(
      begin: const Offset(0.8, 0.8),
      end: const Offset(1.0, 1.0),
      duration: DesignTokens.animationMedium,
      curve: DesignTokens.curveBack,
    );
  }
}

// Large BMI Indicator for detailed views
class LargeBMIIndicator extends StatelessWidget {
  final double bmi;
  final double weightKg;
  final double heightCm;

  const LargeBMIIndicator({
    super.key,
    required this.bmi,
    required this.weightKg,
    required this.heightCm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: Spacing.paddingLg,
      decoration: BoxDecoration(
        gradient: isDark
            ? DesignTokens.glassGradientDark
            : DesignTokens.glassGradientLight,
        borderRadius: Spacing.borderRadiusLg,
        border: Border.all(
          color: isDark
              ? DesignTokens.glassBorderDark
              : DesignTokens.glassBorderLight,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Large BMI Indicator
          BMIIndicator(
            bmi: bmi,
            size: 120,
            showLabel: true,
            showCategory: true,
          ),
          
          Spacing.verticalSpaceLg,
          
          // BMI Details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDetailItem(
                context,
                'Gewicht',
                '${weightKg.toStringAsFixed(1)} kg',
                Icons.monitor_weight_rounded,
                DesignTokens.primaryIndigo,
              ),
              _buildDetailItem(
                context,
                'Größe',
                '${heightCm.toStringAsFixed(0)} cm',
                Icons.height_rounded,
                DesignTokens.accentCyan,
              ),
              _buildDetailItem(
                context,
                'BMI',
                bmi.toStringAsFixed(1),
                Icons.analytics_rounded,
                _getBMIColor(bmi),
              ),
            ],
          ),
          
          Spacing.verticalSpaceMd,
          
          // BMI Range Indicator
          _buildBMIRangeIndicator(context, bmi),
          
          Spacing.verticalSpaceMd,
          
          // Health Assessment
          _buildHealthAssessment(context, bmi),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(Spacing.sm),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: Spacing.borderRadiusMd,
          ),
          child: Icon(
            icon,
            color: color,
            size: Spacing.iconMd,
          ),
        ),
        Spacing.verticalSpaceXs,
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildBMIRangeIndicator(BuildContext context, double bmi) {
    final ranges = [
      {'label': 'Unter', 'min': 0.0, 'max': 18.5, 'color': DesignTokens.infoBlue},
      {'label': 'Normal', 'min': 18.5, 'max': 25.0, 'color': DesignTokens.successGreen},
      {'label': 'Über', 'min': 25.0, 'max': 30.0, 'color': DesignTokens.warningYellow},
      {'label': 'Adipös', 'min': 30.0, 'max': 40.0, 'color': DesignTokens.errorRed},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BMI-Bereiche',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Spacing.verticalSpaceSm,
        Row(
          children: ranges.map((range) {
            final isActive = bmi >= (range['min'] as double) && bmi < (range['max'] as double);
            final color = range['color'] as Color;
            
            return Expanded(
              child: Container(
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: isActive ? color : color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }).toList(),
        ),
        Spacing.verticalSpaceXs,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ranges.map((range) {
            return Text(
              range['label'] as String,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 10,
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildHealthAssessment(BuildContext context, double bmi) {
    final assessment = _getHealthAssessment(bmi);
    
    return Container(
      padding: Spacing.paddingMd,
      decoration: BoxDecoration(
        color: assessment['color'].withOpacity(0.1),
        borderRadius: Spacing.borderRadiusMd,
        border: Border.all(
          color: assessment['color'].withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            assessment['icon'],
            color: assessment['color'],
            size: Spacing.iconMd,
          ),
          Spacing.horizontalSpaceMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assessment['title'],
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: assessment['color'],
                  ),
                ),
                Text(
                  assessment['description'],
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) {
      return DesignTokens.infoBlue;
    } else if (bmi < 25.0) {
      return DesignTokens.successGreen;
    } else if (bmi < 30.0) {
      return DesignTokens.warningYellow;
    } else {
      return DesignTokens.errorRed;
    }
  }

  Map<String, dynamic> _getHealthAssessment(double bmi) {
    if (bmi < 18.5) {
      return {
        'title': 'Untergewicht',
        'description': 'Möglicherweise erhöhtes Gesundheitsrisiko. Konsultieren Sie einen Arzt.',
        'icon': Icons.trending_down_rounded,
        'color': DesignTokens.infoBlue,
      };
    } else if (bmi < 25.0) {
      return {
        'title': 'Normalgewicht',
        'description': 'Ihr BMI liegt im gesunden Bereich. Weiter so!',
        'icon': Icons.check_circle_rounded,
        'color': DesignTokens.successGreen,
      };
    } else if (bmi < 30.0) {
      return {
        'title': 'Übergewicht',
        'description': 'Leicht erhöhtes Gesundheitsrisiko. Gesunde Ernährung empfohlen.',
        'icon': Icons.trending_up_rounded,
        'color': DesignTokens.warningYellow,
      };
    } else {
      return {
        'title': 'Adipositas',
        'description': 'Erhöhtes Gesundheitsrisiko. Ärztliche Beratung empfohlen.',
        'icon': Icons.warning_rounded,
        'color': DesignTokens.errorRed,
      };
    }
  }
}