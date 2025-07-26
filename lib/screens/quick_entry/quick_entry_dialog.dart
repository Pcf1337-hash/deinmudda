import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../models/entry.dart';
import '../../models/substance.dart';
import '../../services/entry_service.dart';
import '../../services/substance_service.dart';
import '../../services/timer_service.dart';
import '../../interfaces/service_interfaces.dart';
import '../../utils/service_locator.dart';
import '../../theme/design_tokens.dart';
import '../../theme/spacing.dart';
// removed unused import: ../../utils/validation_helper.dart // cleaned by BereinigungsAgent

class QuickEntryDialog extends StatefulWidget {
  final Substance? preselectedSubstance;
  final double? preselectedDosage;
  final String? preselectedUnit;

  const QuickEntryDialog({
    super.key,
    this.preselectedSubstance,
    this.preselectedDosage,
    this.preselectedUnit,
  });

  @override
  State<QuickEntryDialog> createState() => _QuickEntryDialogState();
}

class _QuickEntryDialogState extends State<QuickEntryDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _dosageController = TextEditingController();
  final _unitController = TextEditingController();
  
  // Form state
  Substance? _selectedSubstance;
  List<Substance> _substances = [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  bool _startTimer = true; // Default to starting timer

  // Services
  late final IEntryService _entryService;
  late final ISubstanceService _substanceService;
  late ITimerService _timerService;

  // Animation
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize services
    _entryService = ServiceLocator.get<IEntryService>();
    _substanceService = ServiceLocator.get<ISubstanceService>();
    _timerService = ServiceLocator.get<ITimerService>();
    
    _loadSubstances();
    _initializeForm();
    
    _animationController = AnimationController(
      duration: DesignTokens.animationMedium,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: DesignTokens.curveBack,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _dosageController.dispose();
    _unitController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _initializeForm() {
    if (widget.preselectedSubstance != null) {
      _selectedSubstance = widget.preselectedSubstance;
    }
    
    if (widget.preselectedDosage != null) {
      _dosageController.text = widget.preselectedDosage.toString().replaceAll('.', ',');
    }
    
    if (widget.preselectedUnit != null) {
      _unitController.text = widget.preselectedUnit!;
    }
  }

  Future<void> _loadSubstances() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final substances = await _substanceService.getAllSubstances();
      setState(() {
        _substances = substances;
        
        // If we have a preselected substance, find it in the list
        if (widget.preselectedSubstance != null) {
          _selectedSubstance = substances.firstWhere(
            (s) => s.id == widget.preselectedSubstance!.id,
            orElse: () => widget.preselectedSubstance!,
          );
        }
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Fehler beim Laden der Substanzen: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate() || _selectedSubstance == null) {
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final entry = Entry.create(
        substanceId: _selectedSubstance!.id,
        substanceName: _selectedSubstance!.name,
        dosage: double.tryParse(_dosageController.text.replaceAll(',', '.')) ?? 0.0,
        unit: _unitController.text,
        dateTime: DateTime.now(),
      );

      // Create entry with or without timer
      if (_startTimer && _selectedSubstance!.duration != null) {
        await _entryService.createEntryWithTimer(entry, customDuration: _selectedSubstance!.duration, timerService: _timerService);
      } else {
        await _entryService.addEntry(entry);
      }
      
      if (mounted) {
        Navigator.of(context).pop(true);
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

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: Spacing.paddingMd,
            child: Container(
              width: double.infinity,
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
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? DesignTokens.shadowDark.withOpacity(0.3)
                        : DesignTokens.shadowLight.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: Spacing.paddingLg,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Icon(
                          Icons.flash_on_rounded,
                          color: DesignTokens.primaryIndigo,
                          size: Spacing.iconLg,
                        ),
                        Spacing.horizontalSpaceMd,
                        Expanded(
                          child: Text(
                            'Schnelleingabe',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: DesignTokens.primaryIndigo,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    
                    Spacing.verticalSpaceMd,
                    
                    if (_errorMessage != null) ...[
                      Container(
                        padding: Spacing.paddingMd,
                        decoration: BoxDecoration(
                          color: DesignTokens.errorRed.withOpacity(0.1),
                          borderRadius: Spacing.borderRadiusMd,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              color: DesignTokens.errorRed,
                              size: Spacing.iconMd,
                            ),
                            Spacing.horizontalSpaceMd,
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: DesignTokens.errorRed,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Spacing.verticalSpaceMd,
                    ],
                    
                    // Form
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Substance dropdown
                          if (_isLoading)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(Spacing.md),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else
                            DropdownButtonFormField<Substance>(
                              value: _selectedSubstance,
                              decoration: InputDecoration(
                                labelText: 'Substanz',
                                border: OutlineInputBorder(
                                  borderRadius: Spacing.borderRadiusMd,
                                ),
                                prefixIcon: Icon(
                                  Icons.science_rounded,
                                  color: DesignTokens.primaryIndigo,
                                ),
                              ),
                              items: _substances.map((substance) => DropdownMenuItem<Substance>(
                                value: substance,
                                child: Text(substance.name),
                              )).toList(),
                              onChanged: (substance) {
                                setState(() {
                                  _selectedSubstance = substance;
                                  if (substance != null) {
                                    _unitController.text = substance.defaultUnit;
                                  }
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Bitte wählen Sie eine Substanz aus';
                                }
                                return null;
                              },
                            ),
                          
                          Spacing.verticalSpaceMd,
                          
                          // Dosage and unit
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: _dosageController,
                                  decoration: InputDecoration(
                                    labelText: 'Menge',
                                    border: OutlineInputBorder(
                                      borderRadius: Spacing.borderRadiusMd,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.straighten_rounded,
                                      color: DesignTokens.accentCyan,
                                    ),
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
                              ),
                              Spacing.horizontalSpaceMd,
                              Expanded(
                                child: TextFormField(
                                  controller: _unitController,
                                  decoration: InputDecoration(
                                    labelText: 'Einheit',
                                    border: OutlineInputBorder(
                                      borderRadius: Spacing.borderRadiusMd,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Bitte geben Sie eine Einheit ein';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          
                          Spacing.verticalSpaceMd,
                          
                          // Timer option
                          if (_selectedSubstance?.duration != null)
                            Row(
                              children: [
                                Checkbox(
                                  value: _startTimer,
                                  onChanged: (value) {
                                    setState(() {
                                      _startTimer = value ?? false;
                                    });
                                  },
                                  activeColor: DesignTokens.primaryIndigo,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Timer starten',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        'Benachrichtigung nach ${_selectedSubstance?.formattedDuration}',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    
                    Spacing.verticalSpaceLg,
                    
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                            ),
                            child: const Text('Abbrechen'),
                          ),
                        ),
                        Spacing.horizontalSpaceMd,
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _saveEntry,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: DesignTokens.primaryIndigo,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text('Speichern'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}