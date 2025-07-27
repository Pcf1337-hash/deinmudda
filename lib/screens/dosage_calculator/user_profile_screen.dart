import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/dosage_calculator_user.dart';
import '../../services/dosage_calculator_service.dart';
import '../../utils/service_locator.dart'; // refactored by ArchitekturAgent
import '../../widgets/glass_card.dart';
import '../../widgets/dosage_calculator/bmi_indicator.dart';
import '../../widgets/modern_fab.dart';
import '../../theme/design_tokens.dart';
import '../../theme/spacing.dart';
import '../../utils/validation_helper.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  late final DosageCalculatorService _dosageService = ServiceLocator.get<DosageCalculatorService>(); // refactored by ArchitekturAgent

  // Form controllers
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();

  // Form state
  Gender _selectedGender = Gender.male;
  DosageStrategy _selectedDosageStrategy = DosageStrategy.optimal;
  double _weightKg = 70.0;
  double _heightCm = 175.0;
  int _ageYears = 25;
  
  DosageCalculatorUser? _existingUser;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  Map<String, String> _validationErrors = {};

  @override
  void initState() {
    super.initState();
    _loadExistingProfile();
    _setupControllers();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _setupControllers() {
    _weightController.text = _weightKg.toStringAsFixed(1);
    _heightController.text = _heightCm.toStringAsFixed(0);
    _ageController.text = _ageYears.toString();

    _weightController.addListener(_onWeightChanged);
    _heightController.addListener(_onHeightChanged);
    _ageController.addListener(_onAgeChanged);
  }

  void _onWeightChanged() {
    final value = double.tryParse(_weightController.text.replaceAll(',', '.'));
    if (value != null && value != _weightKg) {
      setState(() {
        _weightKg = value;
        _validateField('weight', _weightController.text);
      });
    }
  }

  void _onHeightChanged() {
    final value = double.tryParse(_heightController.text.replaceAll(',', '.'));
    if (value != null && value != _heightCm) {
      setState(() {
        _heightCm = value;
        _validateField('height', _heightController.text);
      });
    }
  }

  void _onAgeChanged() {
    final value = int.tryParse(_ageController.text);
    if (value != null && value != _ageYears) {
      setState(() {
        _ageYears = value;
        _validateField('age', _ageController.text);
      });
    }
  }

  void _validateField(String field, String value) {
    final error = ValidationHelper.getValidationError(field, value);
    setState(() {
      if (error != null) {
        _validationErrors[field] = error;
      } else {
        _validationErrors.remove(field);
      }
    });
  }

  Future<void> _loadExistingProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _dosageService.getUserProfile();
      if (user != null) {
        setState(() {
          _existingUser = user;
          _selectedGender = user.gender;
          _selectedDosageStrategy = user.dosageStrategy;
          _weightKg = user.weightKg;
          _heightCm = user.heightCm;
          _ageYears = user.ageYears;
          
          _weightController.text = _weightKg.toStringAsFixed(1);
          _heightController.text = _heightCm.toStringAsFixed(0);
          _ageController.text = _ageYears.toString();
        });
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Fehler beim Laden des Profils: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || _validationErrors.isNotEmpty) {
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final user = _existingUser?.copyWith(
        gender: _selectedGender,
        dosageStrategy: _selectedDosageStrategy,
        weightKg: _weightKg,
        heightCm: _heightCm,
        ageYears: _ageYears,
      ) ?? DosageCalculatorUser.create(
        gender: _selectedGender,
        dosageStrategy: _selectedDosageStrategy,
        weightKg: _weightKg,
        heightCm: _heightCm,
        ageYears: _ageYears,
      );

      if (_existingUser != null) {
        await _dosageService.updateUserProfile(user);
      } else {
        await _dosageService.createUserProfile(user);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil erfolgreich gespeichert'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Fehler beim Speichern: $e';
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEdit = _existingUser != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Profil bearbeiten' : 'Profil erstellen'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading 
          ? _buildLoadingState()
          : SingleChildScrollView(
              controller: _scrollController,
              padding: Spacing.paddingHorizontalMd,
              child: Column(
                children: [
                  if (_errorMessage != null) ...[
                    _buildErrorCard(context, isDark),
                    Spacing.verticalSpaceMd,
                  ],
                  _buildBMIPreview(context, isDark),
                  Spacing.verticalSpaceLg,
                  _buildForm(context, isDark),
                  const SizedBox(height: 120), // Bottom padding
                ],
              ),
            ),
      floatingActionButton: _buildSaveButton(context, isDark, isEdit),
    );
  }

  Widget _buildErrorCard(BuildContext context, bool isDark) {
    return GlassCard(
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: DesignTokens.errorRed,
            size: Spacing.iconLg,
          ),
          Spacing.horizontalSpaceMd,
          Expanded(
            child: Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: DesignTokens.errorRed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          Spacing.verticalSpaceMd,
          Text(
            'Lade Profil...',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildBMIPreview(BuildContext context, bool isDark) {
    final bmi = _dosageService.calculateBMI(_weightKg, _heightCm);

    return LargeBMIIndicator(
      bmi: bmi,
      weightKg: _weightKg,
      heightCm: _heightCm,
    ).animate().fadeIn(
      duration: DesignTokens.animationMedium,
      delay: const Duration(milliseconds: 300),
    ).slideY(
      begin: 0.3,
      end: 0,
      duration: DesignTokens.animationMedium,
      curve: DesignTokens.curveEaseOut,
    );
  }

  Widget _buildForm(BuildContext context, bool isDark) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGenderSection(context, isDark),
          Spacing.verticalSpaceLg,
          _buildWeightSection(context, isDark),
          Spacing.verticalSpaceLg,
          _buildHeightSection(context, isDark),
          Spacing.verticalSpaceLg,
          _buildAgeSection(context, isDark),
          Spacing.verticalSpaceLg,
          _buildDosageStrategySection(context, isDark),
          Spacing.verticalSpaceLg,
          _buildHealthAssessmentSection(context, isDark),
        ],
      ),
    );
  }

  Widget _buildGenderSection(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Geschlecht',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ).animate().fadeIn(
          duration: DesignTokens.animationMedium,
          delay: const Duration(milliseconds: 400),
        ),
        Spacing.verticalSpaceMd,
        Row(
          children: Gender.values.map((gender) {
            final isSelected = gender == _selectedGender;
            final color = _getGenderColor(gender);

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: gender != Gender.values.last ? Spacing.sm : 0,
                ),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedGender = gender;
                    });
                  },
                  child: AnimatedContainer(
                    duration: DesignTokens.animationFast,
                    padding: Spacing.paddingMd,
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? (isDark
                              ? DesignTokens.glassGradientDark
                              : DesignTokens.glassGradientLight)
                          : null,
                      color: isSelected ? null : Colors.transparent,
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
                          _getGenderIcon(gender),
                          color: isSelected ? color : theme.iconTheme.color?.withOpacity(0.7),
                          size: Spacing.iconLg,
                        ),
                        Spacing.verticalSpaceXs,
                        Text(
                          _getGenderDisplayName(gender),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected ? color : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ).animate().fadeIn(
          duration: DesignTokens.animationMedium,
          delay: const Duration(milliseconds: 500),
        ).slideY(
          begin: 0.3,
          end: 0,
          duration: DesignTokens.animationMedium,
          curve: DesignTokens.curveEaseOut,
        ),
      ],
    );
  }

  Widget _buildWeightSection(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gewicht',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ).animate().fadeIn(
          duration: DesignTokens.animationMedium,
          delay: const Duration(milliseconds: 600),
        ),
        Spacing.verticalSpaceMd,
        GlassCard(
          child: Column(
            children: [
              TextFormField(
                controller: _weightController,
                decoration: InputDecoration(
                  labelText: 'Gewicht in kg',
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.monitor_weight_rounded,
                    color: DesignTokens.primaryIndigo,
                  ),
                  errorText: _validationErrors['weight'],
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Bitte geben Sie Ihr Gewicht ein';
                  }
                  return ValidationHelper.getValidationError('weight', value);
                },
              ),
              Spacing.verticalSpaceMd,
              Slider(
                value: _weightKg.clamp(30.0, 200.0),
                min: 30.0,
                max: 200.0,
                divisions: 170,
                activeColor: DesignTokens.primaryIndigo,
                onChanged: (value) {
                  setState(() {
                    _weightKg = value;
                    _weightController.text = value.toStringAsFixed(1);
                    _validateField('weight', _weightController.text);
                  });
                },
              ),
              Text(
                '${_weightKg.toStringAsFixed(1)} kg',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: DesignTokens.primaryIndigo,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(
          duration: DesignTokens.animationMedium,
          delay: const Duration(milliseconds: 700),
        ).slideY(
          begin: 0.3,
          end: 0,
          duration: DesignTokens.animationMedium,
          curve: DesignTokens.curveEaseOut,
        ),
      ],
    );
  }

  Widget _buildHeightSection(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Größe',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ).animate().fadeIn(
          duration: DesignTokens.animationMedium,
          delay: const Duration(milliseconds: 800),
        ),
        Spacing.verticalSpaceMd,
        GlassCard(
          child: Column(
            children: [
              TextFormField(
                controller: _heightController,
                decoration: InputDecoration(
                  labelText: 'Größe in cm',
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.height_rounded,
                    color: DesignTokens.accentCyan,
                  ),
                  errorText: _validationErrors['height'],
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Bitte geben Sie Ihre Größe ein';
                  }
                  return ValidationHelper.getValidationError('height', value);
                },
              ),
              Spacing.verticalSpaceMd,
              Slider(
                value: _heightCm.clamp(120.0, 220.0),
                min: 120.0,
                max: 220.0,
                divisions: 100,
                activeColor: DesignTokens.accentCyan,
                onChanged: (value) {
                  setState(() {
                    _heightCm = value;
                    _heightController.text = value.toStringAsFixed(0);
                    _validateField('height', _heightController.text);
                  });
                },
              ),
              Text(
                '${_heightCm.toStringAsFixed(0)} cm',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: DesignTokens.accentCyan,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(
          duration: DesignTokens.animationMedium,
          delay: const Duration(milliseconds: 900),
        ).slideY(
          begin: 0.3,
          end: 0,
          duration: DesignTokens.animationMedium,
          curve: DesignTokens.curveEaseOut,
        ),
      ],
    );
  }

  Widget _buildAgeSection(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alter',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ).animate().fadeIn(
          duration: DesignTokens.animationMedium,
          delay: const Duration(milliseconds: 1000),
        ),
        Spacing.verticalSpaceMd,
        GlassCard(
          child: Column(
            children: [
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(
                  labelText: 'Alter in Jahren',
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.person_rounded,
                    color: DesignTokens.accentEmerald,
                  ),
                  errorText: _validationErrors['age'],
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Bitte geben Sie Ihr Alter ein';
                  }
                  return ValidationHelper.getValidationError('age', value);
                },
              ),
              Spacing.verticalSpaceMd,
              Slider(
                value: _ageYears.toDouble().clamp(18.0, 80.0),
                min: 18.0,
                max: 80.0,
                divisions: 62,
                activeColor: DesignTokens.accentEmerald,
                onChanged: (value) {
                  setState(() {
                    _ageYears = value.round();
                    _ageController.text = _ageYears.toString();
                    _validateField('age', _ageController.text);
                  });
                },
              ),
              Text(
                '$_ageYears Jahre',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: DesignTokens.accentEmerald,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(
          duration: DesignTokens.animationMedium,
          delay: const Duration(milliseconds: 1100),
        ).slideY(
          begin: 0.3,
          end: 0,
          duration: DesignTokens.animationMedium,
          curve: DesignTokens.curveEaseOut,
        ),
      ],
    );
  }

  Widget _buildDosageStrategySection(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dosierungsstrategie',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ).animate().fadeIn(
          duration: DesignTokens.animationMedium,
          delay: const Duration(milliseconds: 1150),
        ),
        Spacing.verticalSpaceMd,
        Text(
          'Wählen Sie Ihren bevorzugten Ansatz für Dosierungsempfehlungen:',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
          ),
        ),
        Spacing.verticalSpaceMd,
        Column(
          children: DosageStrategy.values.map((strategy) {
            final isSelected = strategy == _selectedDosageStrategy;
            final color = _getDosageStrategyColor(strategy);

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDosageStrategy = strategy;
                  });
                },
                child: AnimatedContainer(
                  duration: DesignTokens.animationFast,
                  padding: Spacing.paddingMd,
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? (isDark
                            ? DesignTokens.glassGradientDark
                            : DesignTokens.glassGradientLight)
                        : null,
                    color: isSelected ? null : Colors.transparent,
                    borderRadius: Spacing.borderRadiusMd,
                    border: Border.all(
                      color: isSelected
                          ? color
                          : (isDark ? Colors.white24 : Colors.black12),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getDosageStrategyIcon(strategy),
                          color: color,
                          size: 20,
                        ),
                      ),
                      Spacing.horizontalSpaceMd,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              strategy.shortName,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isSelected ? color : null,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '-${strategy.percentageDisplay}%',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: color,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle_rounded,
                          color: color,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ).animate().fadeIn(
          duration: DesignTokens.animationMedium,
          delay: const Duration(milliseconds: 1175),
        ).slideY(
          begin: 0.3,
          end: 0,
          duration: DesignTokens.animationMedium,
          curve: DesignTokens.curveEaseOut,
        ),
      ],
    );
  }

  Widget _buildHealthAssessmentSection(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final bmi = _dosageService.calculateBMI(_weightKg, _heightCm);
    final bmiCategory = _dosageService.getBMICategory(bmi);
    final isHealthy = _dosageService.isHealthyBMI(bmi);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gesundheitsbewertung',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ).animate().fadeIn(
          duration: DesignTokens.animationMedium,
          delay: const Duration(milliseconds: 1200),
        ),
        Spacing.verticalSpaceMd,
        GlassCard(
          borderColor: isHealthy
              ? DesignTokens.successGreen.withOpacity(0.3)
              : DesignTokens.warningYellow.withOpacity(0.3),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    isHealthy ? Icons.check_circle_rounded : Icons.warning_rounded,
                    color: isHealthy ? DesignTokens.successGreen : DesignTokens.warningYellow,
                    size: Spacing.iconMd,
                  ),
                  Spacing.horizontalSpaceMd,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BMI: ${bmi.toStringAsFixed(1)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isHealthy ? DesignTokens.successGreen : DesignTokens.warningYellow,
                          ),
                        ),
                        Text(
                          bmiCategory,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Spacing.verticalSpaceMd,
              Text(
                isHealthy
                    ? 'Ihr BMI liegt im gesunden Bereich. Die Dosierungsberechnungen sind für Sie optimal.'
                    : 'Ihr BMI liegt außerhalb des Normalbereichs. Dosierungsberechnungen können weniger präzise sein.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(
          duration: DesignTokens.animationMedium,
          delay: const Duration(milliseconds: 1300),
        ).slideY(
          begin: 0.3,
          end: 0,
          duration: DesignTokens.animationMedium,
          curve: DesignTokens.curveEaseOut,
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context, bool isDark, bool isEdit) {
    final hasValidData = _validationErrors.isEmpty &&
        _weightKg >= 30 && _weightKg <= 200 &&
        _heightCm >= 120 && _heightCm <= 220 &&
        _ageYears >= 18 && _ageYears <= 80;

    return ModernFAB(
      onPressed: (_isSaving || !hasValidData) ? null : _saveProfile,
      icon: _isSaving ? null : Icons.save_rounded,
      label: _isSaving ? 'Speichern...' : 'Speichern',
      backgroundColor: hasValidData ? DesignTokens.primaryIndigo : DesignTokens.neutral400,
      isLoading: _isSaving,
    ).animate().fadeIn(
      duration: DesignTokens.animationSlow,
      delay: const Duration(milliseconds: 1400),
    ).scale(
      begin: const Offset(0.8, 0.8),
      end: const Offset(1.0, 1.0),
      duration: DesignTokens.animationSlow,
      curve: DesignTokens.curveBack,
    );
  }

  Color _getGenderColor(Gender gender) {
    switch (gender) {
      case Gender.male:
        return DesignTokens.infoBlue;
      case Gender.female:
        return DesignTokens.accentPurple;
      case Gender.other:
        return DesignTokens.accentEmerald;
    }
  }

  IconData _getGenderIcon(Gender gender) {
    switch (gender) {
      case Gender.male:
        return Icons.male_rounded;
      case Gender.female:
        return Icons.female_rounded;
      case Gender.other:
        return Icons.transgender_rounded;
    }
  }

  String _getGenderDisplayName(Gender gender) {
    switch (gender) {
      case Gender.male:
        return 'Männlich';
      case Gender.female:
        return 'Weiblich';
      case Gender.other:
        return 'Divers';
    }
  }

  Color _getDosageStrategyColor(DosageStrategy strategy) {
    switch (strategy) {
      case DosageStrategy.calculated:
        return DesignTokens.accentCyan;
      case DosageStrategy.optimal:
        return DesignTokens.successGreen;
      case DosageStrategy.safe:
        return DesignTokens.warningYellow;
      case DosageStrategy.beginner:
        return DesignTokens.accentPurple;
    }
  }

  IconData _getDosageStrategyIcon(DosageStrategy strategy) {
    switch (strategy) {
      case DosageStrategy.calculated:
        return Icons.calculate_rounded;
      case DosageStrategy.optimal:
        return Icons.verified_rounded;
      case DosageStrategy.safe:
        return Icons.shield_rounded;
      case DosageStrategy.beginner:
        return Icons.school_rounded;
    }
  }
}