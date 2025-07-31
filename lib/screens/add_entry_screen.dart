import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/entry.dart' hide SubstanceCategory;
import '../models/substance.dart';
import '../utils/service_locator.dart';
import '../use_cases/entry_use_cases.dart';
import '../use_cases/substance_use_cases.dart';
import '../interfaces/service_interfaces.dart';
import '../widgets/glass_card.dart';
import '../widgets/modern_fab.dart';
import '../widgets/unit_dropdown.dart';
import '../theme/design_tokens.dart';
import '../theme/spacing.dart';
// removed unused import: ../utils/validation_helper.dart // cleaned by BereinigungsAgent
import '../utils/performance_helper.dart';
import 'quick_entry/xtc_entry_dialog.dart';

class AddEntryScreen extends StatefulWidget {
  const AddEntryScreen({super.key});

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  
  // Form controllers
  final _substanceController = TextEditingController();
  final _dosageController = TextEditingController();
  final _unitController = TextEditingController();
  final _costController = TextEditingController();
  final _notesController = TextEditingController();
  
  // Form state
  DateTime _selectedDateTime = DateTime.now();
  Substance? _selectedSubstance;
  List<Substance> _substances = [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  double _calculatedCost = 0.0;
  bool _autoCalculateCost = true;
  bool _startTimer = true; // Default to starting timer

  // Use Cases and Services (injected via ServiceLocator)
  late final CreateEntryUseCase _createEntryUseCase;
  late final CreateEntryWithTimerUseCase _createEntryWithTimerUseCase;
  late final GetSubstancesUseCase _getSubstancesUseCase;
  late final ITimerService _timerService;

  // Helper methods for color/icon inheritance
  IconData? _getIconFromName(String iconName) {
    const iconMap = {
      'coffee': Icons.coffee,
      'leaf': Icons.eco,
      'wine': Icons.wine_bar,
      'sun': Icons.wb_sunny,
      'pill': Icons.medication,
      'cigarette': Icons.smoking_rooms,
      'moon': Icons.bedtime,
    };
    return iconMap[iconName];
  }

  Color? _getColorForSubstance(Substance? substance) {
    if (substance == null) return null;
    
    // Assign colors based on substance category
    const categoryColors = {
      SubstanceCategory.medication: Colors.blue,
      SubstanceCategory.stimulant: Colors.red,
      SubstanceCategory.depressant: Colors.purple,
      SubstanceCategory.supplement: Colors.green,
      SubstanceCategory.recreational: Colors.orange,
      SubstanceCategory.other: Colors.grey,
    };
    
    return categoryColors[substance.category];
  }

  @override
  void initState() {
    super.initState();
    
    // Initialize use cases and services from ServiceLocator
    _initializeServices();
    
    _loadSubstances();
    
    // Add listeners for auto-calculation
    _dosageController.addListener(_updateCalculatedCost);
    _unitController.addListener(_updateCalculatedCost);
  }

  /// Initialize use cases and services from ServiceLocator
  void _initializeServices() {
    try {
      _createEntryUseCase = ServiceLocator.get<CreateEntryUseCase>();
      _createEntryWithTimerUseCase = ServiceLocator.get<CreateEntryWithTimerUseCase>();
      _getSubstancesUseCase = ServiceLocator.get<GetSubstancesUseCase>();
      _timerService = ServiceLocator.get<ITimerService>();
      
      if (kDebugMode) {
        print('✅ AddEntryScreen: Services und Use Cases erfolgreich initialisiert');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ AddEntryScreen: Fehler beim Initialisieren der Services: $e');
      }
      throw StateError('Failed to initialize AddEntryScreen services: $e');
    }
  }

  @override
  void dispose() {
    _substanceController.dispose();
    _dosageController.dispose();
    _unitController.dispose();
    _costController.dispose();
    _notesController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _updateCalculatedCost() {
    if (_selectedSubstance != null && _autoCalculateCost) {
      final dosage = double.tryParse(_dosageController.text.replaceAll(',', '.')) ?? 0.0;
      final unit = _unitController.text;
      
      if (dosage > 0 && unit.isNotEmpty) {
        setState(() {
          _calculatedCost = _selectedSubstance!.calculateCostForAmount(dosage, unit);
          _costController.text = _calculatedCost.toStringAsFixed(2).replaceAll('.', ',');
        });
      }
    }
  }

  Future<void> _loadSubstances() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Use performance helper to measure execution time in debug mode
    await PerformanceHelper.measureExecutionTime(() async {
      try {
        final substances = await _getSubstancesUseCase.getAllSubstances();
        setState(() {
          _substances = substances;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'Fehler beim Laden der Substanzen: $e';
          _isLoading = false;
        });
      }
    }, tag: 'Load Substances');
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final entry = Entry.create(
        substanceId: _selectedSubstance?.id ?? '',
        substanceName: _selectedSubstance?.name ?? _substanceController.text,
        dosage: double.tryParse(_dosageController.text.replaceAll(',', '.')) ?? 0.0,
        unit: _unitController.text,
        dateTime: _selectedDateTime,
        cost: double.tryParse(_costController.text.replaceAll(',', '.')) ?? 0.0,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        // Inherit color and icon from substance if available
        icon: _selectedSubstance?.iconName != null 
            ? _getIconFromName(_selectedSubstance!.iconName!) 
            : null,
        color: _getColorForSubstance(_selectedSubstance),
      );

      // Create entry with or without timer using use cases
      if (_startTimer && _selectedSubstance?.duration != null) {
        // Use CreateEntryWithTimerUseCase for entries with timers
        await _createEntryWithTimerUseCase.execute(
          substanceId: _selectedSubstance?.id ?? '',
          dosage: double.tryParse(_dosageController.text.replaceAll(',', '.')) ?? 0.0,
          unit: _unitController.text,
          dateTime: _selectedDateTime,
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          customDuration: _selectedSubstance!.duration,
        );
      } else {
        // Use CreateEntryUseCase for regular entries
        await _createEntryUseCase.execute(
          substanceId: _selectedSubstance?.id ?? '',
          dosage: double.tryParse(_dosageController.text.replaceAll(',', '.')) ?? 0.0,
          unit: _unitController.text,
          dateTime: _selectedDateTime,
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        );
      }
      
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_startTimer && _selectedSubstance?.duration != null 
                ? 'Eintrag mit Timer erfolgreich gespeichert' 
                : 'Eintrag erfolgreich gespeichert'),
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

  Future<void> _showXtcEntryDialog() async {
    final result = await showDialog<dynamic>(
      context: context,
      builder: (context) => const XtcEntryDialog(),
    );
    
    if (result != null) {
      // XTC entry was successfully created
      // Navigate back to the main screen
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Determine if we should use animations based on device capabilities
    final useAnimations = PerformanceHelper.shouldEnableAnimations();

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(context, isDark),
          SliverPadding(
            padding: Spacing.paddingHorizontalMd,
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (_errorMessage != null) ...[
                  _buildErrorCard(context, isDark),
                  Spacing.verticalSpaceMd,
                ],
                _buildForm(context, isDark),
                const SizedBox(height: 120), // Bottom padding
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildSaveButton(context, isDark),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: isDark
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Neuer Eintrag',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ).animate(target: PerformanceHelper.shouldEnableAnimations() ? 1 : 0).fadeIn(
                    duration: PerformanceHelper.shouldEnableAnimations() 
                        ? PerformanceHelper.getAnimationDuration(DesignTokens.animationSlow)
                        : Duration.zero,
                    delay: const Duration(milliseconds: 200),
                  ).slideX(
                    begin: -0.3,
                    end: 0,
                    duration: PerformanceHelper.shouldEnableAnimations() 
                        ? PerformanceHelper.getAnimationDuration(DesignTokens.animationSlow)
                        : Duration.zero,
                    curve: DesignTokens.curveEaseOut,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
    ).animate().fadeIn(
      duration: DesignTokens.animationMedium,
    ).slideY(
      begin: -0.3,
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
          Spacing.verticalSpaceLg,
          _buildSubstanceSection(context, isDark),
          Spacing.verticalSpaceLg,
          _buildDosageSection(context, isDark),
          Spacing.verticalSpaceLg,
          _buildDateTimeSection(context, isDark),
          Spacing.verticalSpaceLg,
          _buildCostSection(context, isDark),
          Spacing.verticalSpaceLg,
          _buildNotesSection(context, isDark),
          Spacing.verticalSpaceLg,
          _buildTimerSection(context, isDark),
        ],
      ),
    );
  }

  Widget _buildSubstanceSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Substanz',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ).animate().fadeIn(
          duration: DesignTokens.animationMedium,
          delay: const Duration(milliseconds: 300),
        ),
        Spacing.verticalSpaceSm,
        GlassCard(
          child: Column(
            children: [
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(Spacing.md),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_substances.isNotEmpty) ...[
                DropdownButtonFormField<Substance>(
                  value: _selectedSubstance,
                  decoration: const InputDecoration(
                    labelText: 'Substanz auswählen',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  items: [
                    const DropdownMenuItem<Substance>(
                      value: null,
                      child: Text('Neue Substanz eingeben'),
                    ),
                    // Special XTC option (not a real substance)
                    DropdownMenuItem<Substance>(
                      value: null, // Keep null but handle specially
                      child: Row(
                        children: [
                          Icon(Icons.medication_rounded, size: 16, color: Colors.pink),
                          const SizedBox(width: 8),
                          const Text('XTC (Ecstasy)'),
                        ],
                      ),
                      onTap: () {
                        // Handle XTC selection specially
                        Future.delayed(Duration.zero, () => _showXtcEntryDialog());
                      },
                    ),
                    ..._substances.map((substance) => DropdownMenuItem<Substance>(
                      value: substance,
                      child: Text(substance.name),
                    )),
                  ],
                  onChanged: (substance) {
                    setState(() {
                      _selectedSubstance = substance;
                      if (substance != null) {
                        _substanceController.text = substance.name;
                        _unitController.text = substance.defaultUnit;
                        _updateCalculatedCost();
                        // Enable timer by default if substance has duration
                        _startTimer = substance.duration != null;
                      } else {
                        _substanceController.clear();
                        _unitController.clear();
                      }
                    });
                  },
                  validator: (value) {
                    if (value == null && _substanceController.text.trim().isEmpty) {
                      return 'Bitte wählen Sie eine Substanz aus oder geben Sie eine neue ein';
                    }
                    return null;
                  },
                ),
                if (_selectedSubstance == null) ...[
                  Spacing.verticalSpaceSm,
                  TextFormField(
                    controller: _substanceController,
                    decoration: const InputDecoration(
                      labelText: 'Substanzname',
                      border: InputBorder.none,
                    ),
                    validator: (value) {
                      if (_selectedSubstance == null && (value == null || value.trim().isEmpty)) {
                        return 'Bitte geben Sie einen Substanznamen ein';
                      }
                      return null;
                    },
                  ),
                ],
              ] else ...[
                TextFormField(
                  controller: _substanceController,
                  decoration: const InputDecoration(
                    labelText: 'Substanzname',
                    border: InputBorder.none,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Bitte geben Sie einen Substanznamen ein';
                    }
                    return null;
                  },
                ),
              ],
            ],
          ),
        ).animate().fadeIn(
          duration: DesignTokens.animationMedium,
          delay: const Duration(milliseconds: 400),
        ).slideY(
          begin: 0.3,
          end: 0,
          duration: DesignTokens.animationMedium,
          curve: DesignTokens.curveEaseOut,
        ),
      ],
    );
  }

  Widget _buildDosageSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dosierung',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ).animate().fadeIn(
          duration: DesignTokens.animationMedium,
          delay: const Duration(milliseconds: 500),
        ),
        Spacing.verticalSpaceSm,
        Row(
          children: [
            Expanded(
              flex: 2,
              child: GlassCard(
                child: TextFormField(
                  controller: _dosageController,
                  decoration: const InputDecoration(
                    labelText: 'Menge',
                    border: InputBorder.none,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Bitte geben Sie eine Dosierung ein';
                    }
                    final dosage = double.tryParse(value.replaceAll(',', '.'));
                    if (dosage == null || dosage <= 0) {
                      return 'Bitte geben Sie eine gültige Dosierung ein';
                    }
                    return null;
                  },
                ),
              ).animate().fadeIn(
                duration: DesignTokens.animationMedium,
                delay: const Duration(milliseconds: 600),
              ).slideY(
                begin: 0.3,
                end: 0,
                duration: DesignTokens.animationMedium,
                curve: DesignTokens.curveEaseOut,
              ),
            ),
            Spacing.horizontalSpaceMd,
            Expanded(
              child: UnitDropdown(
                controller: _unitController,
                substances: _substances,
                selectedCategory: _selectedSubstance?.category,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Bitte wählen Sie eine Einheit';
                  }
                  return null;
                },
              ).animate().fadeIn(
                duration: DesignTokens.animationMedium,
                delay: const Duration(milliseconds: 700),
              ).slideY(
                begin: 0.3,
                end: 0,
                duration: DesignTokens.animationMedium,
                curve: DesignTokens.curveEaseOut,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateTimeSection(BuildContext context, bool isDark) {
    final dateFormat = DateFormat('dd.MM.yyyy', 'de_DE');
    final timeFormat = DateFormat('HH:mm', 'de_DE');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Datum & Uhrzeit',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ).animate().fadeIn(
          duration: DesignTokens.animationMedium,
          delay: const Duration(milliseconds: 800),
        ),
        Spacing.verticalSpaceSm,
        Row(
          children: [
            Expanded(
              child: GlassCard(
                onTap: () => _selectDate(context),
                child: Padding(
                  padding: Spacing.paddingMd,
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        color: DesignTokens.primaryIndigo,
                        size: Spacing.iconMd,
                      ),
                      Spacing.horizontalSpaceSm,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Datum',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                              ),
                            ),
                            Text(
                              dateFormat.format(_selectedDateTime),
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
            ),
            Spacing.horizontalSpaceMd,
            Expanded(
              child: GlassCard(
                onTap: () => _selectTime(context),
                child: Padding(
                  padding: Spacing.paddingMd,
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        color: DesignTokens.accentCyan,
                        size: Spacing.iconMd,
                      ),
                      Spacing.horizontalSpaceSm,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Uhrzeit',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                              ),
                            ),
                            Text(
                              timeFormat.format(_selectedDateTime),
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(
                duration: DesignTokens.animationMedium,
                delay: const Duration(milliseconds: 1000),
              ).slideY(
                begin: 0.3,
                end: 0,
                duration: DesignTokens.animationMedium,
                curve: DesignTokens.curveEaseOut,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCostSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Kosten',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_selectedSubstance != null)
              Row(
                children: [
                  Text(
                    'Auto-Berechnung',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Spacing.horizontalSpaceXs,
                  Switch(
                    value: _autoCalculateCost,
                    onChanged: (value) {
                      setState(() {
                        _autoCalculateCost = value;
                        if (value) {
                          _updateCalculatedCost();
                        }
                      });
                    },
                    activeColor: DesignTokens.primaryIndigo,
                  ),
                ],
              ),
          ],
        ).animate().fadeIn(
          duration: DesignTokens.animationMedium,
          delay: const Duration(milliseconds: 1100),
        ),
        Spacing.verticalSpaceSm,
        GlassCard(
          child: Column(
            children: [
              TextFormField(
                controller: _costController,
                decoration: const InputDecoration(
                  labelText: 'Kosten in €',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.euro_rounded),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                ],
                enabled: !_autoCalculateCost || _selectedSubstance == null,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final cost = double.tryParse(value.replaceAll(',', '.'));
                    if (cost == null || cost < 0) {
                      return 'Bitte geben Sie gültige Kosten ein';
                    }
                  }
                  return null;
                },
              ),
              if (_selectedSubstance != null) ...[
                Spacing.verticalSpaceSm,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: DesignTokens.infoBlue,
                        size: Spacing.iconSm,
                      ),
                      Spacing.horizontalSpaceSm,
                      Expanded(
                        child: Text(
                          'Preis: ${_selectedSubstance!.formattedPrice}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: DesignTokens.infoBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ).animate().fadeIn(
          duration: DesignTokens.animationMedium,
          delay: const Duration(milliseconds: 1200),
        ).slideY(
          begin: 0.3,
          end: 0,
          duration: DesignTokens.animationMedium,
          curve: DesignTokens.curveEaseOut,
        ),
      ],
    );
  }

  Widget _buildNotesSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notizen (optional)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ).animate().fadeIn(
          duration: DesignTokens.animationMedium,
          delay: const Duration(milliseconds: 1300),
        ),
        Spacing.verticalSpaceSm,
        GlassCard(
          child: TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Zusätzliche Informationen',
              border: InputBorder.none,
              alignLabelWithHint: true,
            ),
            maxLines: 3,
            maxLength: 500,
          ),
        ).animate().fadeIn(
          duration: DesignTokens.animationMedium,
          delay: const Duration(milliseconds: 1400),
        ).slideY(
          begin: 0.3,
          end: 0,
          duration: DesignTokens.animationMedium,
          curve: DesignTokens.curveEaseOut,
        ),
      ],
    );
  }

  Widget _buildTimerSection(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Timer & Countdown',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ).animate().fadeIn(
          duration: DesignTokens.animationMedium,
          delay: const Duration(milliseconds: 1500),
        ),
        Spacing.verticalSpaceSm,
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: DesignTokens.accentPink.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: GlassCard(
            child: Padding(
              padding: Spacing.paddingMd,
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _startTimer
                              ? DesignTokens.accentPink.withOpacity(0.2)
                              : Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.timer_rounded,
                          color: _startTimer ? DesignTokens.accentPink : Colors.grey,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Timer automatisch starten',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (_selectedSubstance?.duration != null)
                              Text(
                                'Benachrichtigung nach ${_selectedSubstance?.formattedDuration ?? 'N/A'}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _startTimer,
                        onChanged: (value) {
                          setState(() {
                            _startTimer = value;
                          });
                        },
                        activeColor: DesignTokens.accentPink,
                      ),
                    ],
                  ),
                  if (_startTimer && _selectedSubstance?.duration != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: DesignTokens.accentPink.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: DesignTokens.accentPink.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: DesignTokens.accentPink,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Timer Dashboard zeigt alle aktiven Countdowns',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: DesignTokens.accentPink,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ).animate().fadeIn(
          duration: DesignTokens.animationMedium,
          delay: const Duration(milliseconds: 1600),
        ).slideY(
          begin: 0.3,
          end: 0,
          duration: DesignTokens.animationMedium,
          curve: DesignTokens.curveEaseOut,
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context, bool isDark) {
    return ModernFAB(
      onPressed: _isSaving ? null : _saveEntry,
      icon: _isSaving ? null : Icons.save_rounded,
      label: _isSaving ? 'Speichern...' : 'Speichern',
      backgroundColor: DesignTokens.primaryIndigo,
      isLoading: _isSaving,
    ).animate().fadeIn(
      duration: DesignTokens.animationSlow,
      delay: const Duration(milliseconds: 1500),
    ).scale(
      begin: const Offset(0.8, 0.8),
      end: const Offset(1.0, 1.0),
      duration: DesignTokens.animationSlow,
      curve: DesignTokens.curveBack,
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    try {
      final date = await showDatePicker(
        context: context,
        initialDate: _selectedDateTime,
        firstDate: DateTime(2020),
        lastDate: DateTime.now().add(const Duration(days: 1)),
        // Ensure proper theming and navigation
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              // Ensure back button is visible and functional
              appBarTheme: Theme.of(context).appBarTheme.copyWith(
                iconTheme: const IconThemeData(color: Colors.white),
              ),
            ),
            child: child!,
          );
        },
      );

      if (date != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            _selectedDateTime.hour,
            _selectedDateTime.minute,
          );
        });
      }
    } catch (e) {
      // Handle any navigation errors gracefully
      if (kDebugMode) {
        print('Error in date picker: $e');
      }
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );

    if (time != null) {
      setState(() {
        _selectedDateTime = DateTime(
          _selectedDateTime.year,
          _selectedDateTime.month,
          _selectedDateTime.day,
          time.hour,
          time.minute,
        );
      });
    }
  }
}