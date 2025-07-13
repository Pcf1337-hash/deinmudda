import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/dosage_calculator_substance.dart';
import '../../models/dosage_calculator_user.dart';
import '../../models/entry.dart';
import '../../theme/design_tokens.dart';
import '../../theme/spacing.dart';
import '../../utils/app_icon_generator.dart';

// Dosage calculation result class
class DosageCalculation {
  final String substance;
  final double lightDose;
  final double normalDose;
  final double strongDose;
  final double userWeight;
  final String unit;
  final String administrationRoute;
  final String duration;
  final List<String> safetyNotes;

  DosageCalculation({
    required this.substance,
    required this.lightDose,
    required this.normalDose,
    required this.strongDose,
    required this.userWeight,
    this.unit = 'mg',
    required this.administrationRoute,
    required this.duration,
    required this.safetyNotes,
  });
}

class DosageResultCard extends StatefulWidget {
  final DosageCalculatorSubstance substance;
  final DosageCalculation calculation;
  final DosageCalculatorUser user;
  final Function(Entry)? onSaveToEntry;
  final VoidCallback? onClose;

  const DosageResultCard({
    super.key,
    required this.substance,
    required this.calculation,
    required this.user,
    this.onSaveToEntry,
    this.onClose,
  });

  @override
  State<DosageResultCard> createState() => _DosageResultCardState();
}

class _DosageResultCardState extends State<DosageResultCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  DosageIntensity _selectedIntensity = DosageIntensity.light;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: DesignTokens.animationMedium,
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: DesignTokens.curveEaseOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: DesignTokens.curveEaseOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          height: mediaQuery.size.height * 0.85,
          decoration: BoxDecoration(
            color: isDark ? DesignTokens.backgroundDark : DesignTokens.backgroundLight,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value * 50),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Column(
                children: [
                  _buildHeader(context, isDark),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: Spacing.paddingMd,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSubstanceInfo(context, isDark),
                          Spacing.verticalSpaceLg,
                          _buildUserInfo(context, isDark),
                          Spacing.verticalSpaceLg,
                          _buildDosageSelection(context, isDark),
                          Spacing.verticalSpaceLg,
                          _buildSelectedDosageInfo(context, isDark),
                          Spacing.verticalSpaceLg,
                          _buildAdministrationInfo(context, isDark),
                          Spacing.verticalSpaceLg,
                          _buildSafetyWarnings(context, isDark),
                          Spacing.verticalSpaceLg,
                          _buildActionButtons(context, isDark),
                          const SizedBox(height: 40), // Bottom padding
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return Container(
      padding: Spacing.paddingMd,
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A1A2E),
                  Color(0xFF16213E),
                ],
              )
            : DesignTokens.primaryGradient,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Spacing.verticalSpaceMd,
          
          // Header content
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(Spacing.sm),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: Spacing.borderRadiusMd,
                ),
                child: Icon(
                  Icons.calculate_rounded,
                  color: Colors.white,
                  size: Spacing.iconLg,
                ),
              ),
              Spacing.horizontalSpaceMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dosierungsberechnung',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      widget.substance.name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  widget.onClose?.call();
                  Navigator.of(context).pop();
                },
                icon: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubstanceInfo(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final substanceColor = AppIconGenerator.getSubstanceColor(widget.substance.name);

    return Container(
      padding: Spacing.paddingMd,
      decoration: BoxDecoration(
        gradient: isDark
            ? DesignTokens.glassGradientDark
            : DesignTokens.glassGradientLight,
        borderRadius: Spacing.borderRadiusLg,
        border: Border.all(
          color: substanceColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(Spacing.md),
            decoration: BoxDecoration(
              color: substanceColor.withOpacity(0.1),
              borderRadius: Spacing.borderRadiusMd,
            ),
            child: Icon(
              AppIconGenerator.getSubstanceIcon(widget.substance.name),
              color: substanceColor,
              size: Spacing.iconXl,
            ),
          ),
          Spacing.horizontalSpaceMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.substance.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: substanceColor,
                  ),
                ),
                Spacing.verticalSpaceXs,
                Text(
                  'Dosierungsbereich: ${widget.substance.lightDosePerKg.toStringAsFixed(1)} - ${widget.substance.strongDosePerKg.toStringAsFixed(1)} mg/kg',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return Container(
      padding: Spacing.paddingMd,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Benutzerdaten',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Spacing.verticalSpaceMd,
          Row(
            children: [
              _buildUserDataItem(
                context,
                'Gewicht',
                widget.user.formattedWeight,
                Icons.monitor_weight_rounded,
                DesignTokens.primaryIndigo,
              ),
              Spacing.horizontalSpaceLg,
              _buildUserDataItem(
                context,
                'BMI',
                widget.user.formattedBmi,
                Icons.analytics_rounded,
                _getBMIColor(widget.user.bmi),
              ),
              Spacing.horizontalSpaceLg,
              _buildUserDataItem(
                context,
                'Alter',
                widget.user.formattedAge,
                Icons.person_rounded,
                DesignTokens.accentCyan,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserDataItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Expanded(
      child: Column(
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
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDosageSelection(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dosierungsstärke wählen',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Spacing.verticalSpaceMd,
        Wrap(
          spacing: Spacing.sm,
          runSpacing: Spacing.md,
          children: DosageIntensity.values.map((intensity) {
            final isSelected = intensity == _selectedIntensity;
            final color = _getDosageColor(intensity);
            final dose = _getDoseForIntensity(intensity);

            return SizedBox(
              width: 100,
              child: Container(
                padding: Spacing.paddingSm,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIntensity = intensity;
                    });
                  },
                  child: AnimatedContainer(
                    duration: DesignTokens.animationFast,
                    padding: Spacing.paddingMd,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: Spacing.borderRadiusMd,
                      border: Border.all(
                        color: isSelected
                            ? color
                            : (isDark
                                ? DesignTokens.glassBorderDark
                                : DesignTokens.glassBorderLight),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _getDosageIcon(intensity),
                          color: isSelected ? color : theme.iconTheme.color?.withOpacity(0.7),
                          size: Spacing.iconMd,
                        ),
                        Spacing.verticalSpaceXs,
                        Text(
                          intensity.displayName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected ? color : null,
                          ),
                        ),
                        Text(
                          '${dose.toStringAsFixed(1)} mg',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isSelected ? color : theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSelectedDosageInfo(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final color = _getDosageColor(_selectedIntensity);
    final dose = _getDoseForIntensity(_selectedIntensity);
    final warning = _getDosageWarning(_selectedIntensity);

    return Container(
      padding: Spacing.paddingLg,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: Spacing.borderRadiusLg,
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(Spacing.md),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: Spacing.borderRadiusFull,
                ),
                child: Icon(
                  _getDosageIcon(_selectedIntensity),
                  color: color,
                  size: Spacing.iconXl,
                ),
              ),
              Spacing.horizontalSpaceLg,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Empfohlene Dosis',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    Text(
                      '${dose.toStringAsFixed(1)} mg',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                    Text(
                      '${_selectedIntensity.displayName} Intensität',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          if (warning != null) ...[
            Spacing.verticalSpaceMd,
            Container(
              padding: Spacing.paddingMd,
              decoration: BoxDecoration(
                color: DesignTokens.warningYellow.withOpacity(0.1),
                borderRadius: Spacing.borderRadiusMd,
                border: Border.all(
                  color: DesignTokens.warningYellow.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_rounded,
                    color: DesignTokens.warningYellow,
                    size: Spacing.iconMd,
                  ),
                  Spacing.horizontalSpaceMd,
                  Expanded(
                    child: Text(
                      warning,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: DesignTokens.warningYellow,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAdministrationInfo(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return Container(
      padding: Spacing.paddingMd,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Anwendungsinformationen',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Spacing.verticalSpaceMd,
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  context,
                  'Verabreichung',
                  widget.substance.administrationRouteDisplayName,
                  Icons.route_rounded,
                  DesignTokens.accentCyan,
                ),
              ),
              Spacing.horizontalSpaceMd,
              Expanded(
                child: _buildInfoItem(
                  context,
                  'Wirkdauer',
                  widget.substance.duration,
                  Icons.access_time_rounded,
                  DesignTokens.accentPurple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: Spacing.paddingMd,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: Spacing.borderRadiusMd,
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: Spacing.iconMd,
          ),
          Spacing.verticalSpaceXs,
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyWarnings(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final selectedDose = _getDoseForIntensity(_selectedIntensity);
    final substanceWarning = widget.substance.getSafetyWarning(selectedDose, widget.user.weightKg);

    return Container(
      padding: Spacing.paddingMd,
      decoration: BoxDecoration(
        color: DesignTokens.errorRed.withOpacity(0.1),
        borderRadius: Spacing.borderRadiusLg,
        border: Border.all(
          color: DesignTokens.errorRed.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_rounded,
                color: DesignTokens.errorRed,
                size: Spacing.iconMd,
              ),
              Spacing.horizontalSpaceSm,
              Text(
                'Sicherheitshinweise',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: DesignTokens.errorRed,
                ),
              ),
            ],
          ),
          Spacing.verticalSpaceMd,
          
          // Dosage-specific warning if exists
          if (substanceWarning != null) ...[
            Container(
              padding: Spacing.paddingMd,
              decoration: BoxDecoration(
                color: DesignTokens.errorRed.withOpacity(0.2),
                borderRadius: Spacing.borderRadiusMd,
                border: Border.all(
                  color: DesignTokens.errorRed.withOpacity(0.4),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: DesignTokens.errorRed,
                    size: Spacing.iconMd,
                  ),
                  Spacing.horizontalSpaceSm,
                  Expanded(
                    child: Text(
                      substanceWarning,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: DesignTokens.errorRed,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Spacing.verticalSpaceMd,
          ],
          
          // Substance-specific safety notes
          Text(
            widget.substance.safetyNotes,
            style: theme.textTheme.bodyMedium,
          ),
          Spacing.verticalSpaceMd,
          
          // Dosage intensity specific warnings
          _buildIntensitySpecificWarning(context, theme),
          Spacing.verticalSpaceMd,
          
          // General safety principles
          Text(
            'Grundlegende Sicherheitsprinzipien:',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: DesignTokens.errorRed,
            ),
          ),
          Spacing.verticalSpaceXs,
          Text(
            '• Beginnen Sie immer mit der niedrigsten Dosis\n• Warten Sie die volle Wirkdauer ab (${widget.substance.duration})\n• Kombinieren Sie niemals verschiedene Substanzen\n• Verwenden Sie eine Feinwaage für genaue Dosierung\n• Sorgen Sie für eine sichere Umgebung und Begleitung\n• Bei Problemen sofort medizinische Hilfe suchen',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
            ),
          ),
          Spacing.verticalSpaceMd,
          
          // Additional context-specific warnings
          _buildContextSpecificWarnings(context, theme),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isDark) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _saveToEntry(),
            icon: const Icon(Icons.save_rounded),
            label: const Text('Als Eintrag speichern'),
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignTokens.primaryIndigo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: Spacing.md),
            ),
          ),
        ),
        Spacing.verticalSpaceMd,
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              widget.onClose?.call();
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.close_rounded),
            label: const Text('Schließen'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: Spacing.md),
            ),
          ),
        ),
      ],
    );
  }

  void _saveToEntry() {
    final dose = _getDoseForIntensity(_selectedIntensity);
    
    final entry = Entry.create(
      substanceId: '', // Will be filled by the service
      substanceName: widget.substance.name,
      dosage: dose,
      unit: 'mg',
      dateTime: DateTime.now(),
      notes: 'Dosierung berechnet für ${_selectedIntensity.displayName} Intensität (${widget.user.formattedWeight})',
    );

    widget.onSaveToEntry?.call(entry);
  }

  double _getDoseForIntensity(DosageIntensity intensity) {
    switch (intensity) {
      case DosageIntensity.light:
        return widget.calculation.lightDose;
      case DosageIntensity.normal:
        return widget.calculation.normalDose;
      case DosageIntensity.strong:
        return widget.calculation.strongDose;
    }
  }

  Color _getDosageColor(DosageIntensity intensity) {
    switch (intensity) {
      case DosageIntensity.light:
        return DesignTokens.successGreen;
      case DosageIntensity.normal:
        return DesignTokens.warningYellow;
      case DosageIntensity.strong:
        return DesignTokens.errorRed;
    }
  }

  IconData _getDosageIcon(DosageIntensity intensity) {
    switch (intensity) {
      case DosageIntensity.light:
        return Icons.eco_rounded;
      case DosageIntensity.normal:
        return Icons.balance_rounded;
      case DosageIntensity.strong:
        return Icons.warning_rounded;
    }
  }

  String? _getDosageWarning(DosageIntensity intensity) {
    switch (intensity) {
      case DosageIntensity.light:
        return null;
      case DosageIntensity.normal:
        return 'Nur für erfahrene Nutzer empfohlen';
      case DosageIntensity.strong:
        return 'ACHTUNG: Hohe Dosis! Nur für sehr erfahrene Nutzer!';
    }
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

  Widget _buildIntensitySpecificWarning(BuildContext context, ThemeData theme) {
    String warning;
    Color warningColor;
    IconData warningIcon;
    
    switch (_selectedIntensity) {
      case DosageIntensity.light:
        warning = 'Leichte Dosierung: Ideal für Einsteiger oder wenn Sie diese Substanz zum ersten Mal verwenden.';
        warningColor = DesignTokens.successGreen;
        warningIcon = Icons.info_outline_rounded;
        break;
      case DosageIntensity.normal:
        warning = 'Normale Dosierung: Nur für Personen mit Erfahrung empfohlen. Wirkung kann intensiv sein.';
        warningColor = DesignTokens.warningYellow;
        warningIcon = Icons.warning_amber_rounded;
        break;
      case DosageIntensity.strong:
        warning = 'STARKE DOSIERUNG: Nur für sehr erfahrene Benutzer! Erhöhtes Risiko für Nebenwirkungen und Überdosierung.';
        warningColor = DesignTokens.errorRed;
        warningIcon = Icons.dangerous_rounded;
        break;
    }
    
    return Container(
      padding: Spacing.paddingMd,
      decoration: BoxDecoration(
        color: warningColor.withOpacity(0.1),
        borderRadius: Spacing.borderRadiusMd,
        border: Border.all(
          color: warningColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            warningIcon,
            color: warningColor,
            size: Spacing.iconMd,
          ),
          Spacing.horizontalSpaceSm,
          Expanded(
            child: Text(
              warning,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: warningColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContextSpecificWarnings(BuildContext context, ThemeData theme) {
    final List<String> warnings = [];
    
    // BMI-specific warnings
    final bmi = widget.user.bmi;
    if (bmi < 18.5) {
      warnings.add('Niedriger BMI: Möglicherweise erhöhte Sensitivität gegenüber der Substanz.');
    } else if (bmi > 30.0) {
      warnings.add('Hoher BMI: Berücksichtigen Sie mögliche Auswirkungen auf die Dosierung.');
    }
    
    // Age-specific warnings
    if (widget.user.ageYears < 21) {
      warnings.add('Junge Erwachsene: Erhöhtes Risiko für negative Langzeiteffekte.');
    } else if (widget.user.ageYears > 65) {
      warnings.add('Ältere Erwachsene: Möglicherweise erhöhte Sensitivität und verlangsamter Abbau.');
    }
    
    // Administration route specific warnings
    switch (widget.substance.administrationRoute.toLowerCase()) {
      case 'nasal':
        warnings.add('Nasale Anwendung: Schnellerer Wirkungseintritt, aber kürzere Wirkdauer.');
        break;
      case 'oral':
        warnings.add('Orale Anwendung: Langsamerer Wirkungseintritt (30-90 Min), aber längere Wirkdauer.');
        break;
      case 'intravenous':
      case 'iv':
        warnings.add('INTRAVENÖSE ANWENDUNG: Extrem hohes Risiko! Sofortiger Wirkungseintritt, keine Umkehr möglich.');
        break;
      case 'sublingual':
        warnings.add('Sublinguale Anwendung: Mittlerer Wirkungseintritt (10-30 Min), nicht schlucken.');
        break;
    }
    
    if (warnings.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Spezifische Hinweise für Ihre Situation:',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: DesignTokens.warningYellow,
          ),
        ),
        Spacing.verticalSpaceXs,
        ...warnings.map((warning) => Padding(
          padding: const EdgeInsets.only(bottom: Spacing.xs),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.circle,
                size: 6,
                color: DesignTokens.warningYellow,
              ),
              Spacing.horizontalSpaceXs,
              Expanded(
                child: Text(
                  warning,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}