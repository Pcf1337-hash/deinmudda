import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../models/entry.dart';
import '../models/substance.dart';
import '../utils/service_locator.dart';
import '../use_cases/entry_use_cases.dart';
import '../use_cases/substance_use_cases.dart';
import '../interfaces/service_interfaces.dart';
import '../widgets/glass_card.dart';
import '../widgets/modern_fab.dart';
import '../theme/design_tokens.dart';
import '../theme/spacing.dart';

class EditEntryScreen extends StatefulWidget {
  final Entry entry;

  const EditEntryScreen({
    super.key,
    required this.entry,
  });

  @override
  State<EditEntryScreen> createState() => _EditEntryScreenState();
}

class _EditEntryScreenState extends State<EditEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  
  // Form controllers
  final _substanceController = TextEditingController();
  final _dosageController = TextEditingController();
  final _unitController = TextEditingController();
  final _costController = TextEditingController();
  final _notesController = TextEditingController();
  
  // Form state
  late DateTime _selectedDateTime;
  Substance? _selectedSubstance;
  List<Substance> _substances = [];
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isDeleting = false;
  bool _hasChanges = false;
  String? _errorMessage;
  bool _autoCalculateCost = false;
  double _calculatedCost = 0.0;

  // Use Cases and Services (injected via ServiceLocator)
  late final UpdateEntryUseCase _updateEntryUseCase;
  late final DeleteEntryUseCase _deleteEntryUseCase;
  late final GetSubstancesUseCase _getSubstancesUseCase;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _initializeForm();
    _loadSubstances();
    
    // Add listeners for auto-calculation
    _dosageController.addListener(_updateCalculatedCost);
    _unitController.addListener(_updateCalculatedCost);
  }

  /// Initialize use cases from ServiceLocator
  void _initializeServices() {
    try {
      _updateEntryUseCase = ServiceLocator.get<UpdateEntryUseCase>();
      _deleteEntryUseCase = ServiceLocator.get<DeleteEntryUseCase>();
      _getSubstancesUseCase = ServiceLocator.get<GetSubstancesUseCase>();
    } catch (e) {
      throw StateError('Failed to initialize EditEntryScreen services: $e');
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

  void _initializeForm() {
    _selectedDateTime = widget.entry.dateTime;
    _substanceController.text = widget.entry.substanceName;
    _dosageController.text = widget.entry.dosage.toString().replaceAll('.', ',');
    _unitController.text = widget.entry.unit;
    _costController.text = widget.entry.cost > 0 
        ? widget.entry.cost.toString().replaceAll('.', ',') 
        : '';
    _notesController.text = widget.entry.notes ?? '';

    // Add listeners to detect changes
    _substanceController.addListener(_onFormChanged);
    _dosageController.addListener(_onFormChanged);
    _unitController.addListener(_onFormChanged);
    _costController.addListener(_onFormChanged);
    _notesController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    final hasChanges = _substanceController.text != widget.entry.substanceName ||
        _dosageController.text != widget.entry.dosage.toString().replaceAll('.', ',') ||
        _unitController.text != widget.entry.unit ||
        _costController.text != (widget.entry.cost > 0 ? widget.entry.cost.toString().replaceAll('.', ',') : '') ||
        _notesController.text != (widget.entry.notes ?? '') ||
        _selectedDateTime != widget.entry.dateTime;

    if (hasChanges != _hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
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

    try {
      final substances = await _getSubstancesUseCase.getAllSubstances();
      setState(() {
        _substances = substances;
        
        // Try to find the substance by ID first, then by name
        if (substances.isNotEmpty) {
          _selectedSubstance = substances.firstWhere(
            (s) => s.id == widget.entry.substanceId,
            orElse: () => substances.firstWhere(
              (s) => s.name == widget.entry.substanceName,
              orElse: () => substances.first,
            ),
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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final updatedEntry = widget.entry.copyWith(
        substanceId: _selectedSubstance?.id ?? widget.entry.substanceId,
        substanceName: _selectedSubstance?.name ?? _substanceController.text,
        dosage: double.tryParse(_dosageController.text.replaceAll(',', '.')) ?? 0.0,
        unit: _unitController.text,
        dateTime: _selectedDateTime,
        cost: double.tryParse(_costController.text.replaceAll(',', '.')) ?? 0.0,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        updatedAt: DateTime.now(),
      );

      await _updateEntryUseCase.execute(updatedEntry);
      
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Eintrag erfolgreich aktualisiert'),
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

  Future<void> _deleteEntry() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eintrag löschen'),
        content: const Text('Möchten Sie diesen Eintrag wirklich löschen? Diese Aktion kann nicht rückgängig gemacht werden.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: DesignTokens.errorRed),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isDeleting = true;
      _errorMessage = null;
    });

    try {
      await _deleteEntryUseCase.execute(widget.entry.id);
      
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Eintrag erfolgreich gelöscht'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Fehler beim Löschen: $e';
        _isDeleting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async {
        if (_hasChanges) {
          final shouldPop = await _showUnsavedChangesDialog();
          return shouldPop ?? false;
        }
        return true;
      },
      child: Scaffold(
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
                  Spacing.verticalSpaceLg,
                  _buildDeleteButton(context, isDark),
                  const SizedBox(height: 120), // Bottom padding
                ]),
              ),
            ),
          ],
        ),
        floatingActionButton: _buildSaveButton(context, isDark),
      ),
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
        onPressed: () async {
          if (_hasChanges) {
            final shouldPop = await _showUnsavedChangesDialog();
            if (shouldPop == true && mounted) {
              Navigator.of(context).pop();
            }
          } else {
            Navigator.of(context).pop();
          }
        },
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Eintrag bearbeiten',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (_hasChanges)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Spacing.sm,
                            vertical: Spacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: DesignTokens.warningYellow.withOpacity(0.2),
                            borderRadius: Spacing.borderRadiusSm,
                            border: Border.all(
                              color: DesignTokens.warningYellow,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Ungespeichert',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: DesignTokens.warningYellow,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
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
              child: GlassCard(
                child: TextFormField(
                  controller: _unitController,
                  decoration: const InputDecoration(
                    labelText: 'Einheit',
                    border: InputBorder.none,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Bitte geben Sie eine Einheit ein';
                    }
                    return null;
                  },
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

  Widget _buildDeleteButton(BuildContext context, bool isDark) {
    return GlassCard(
      child: ListTile(
        leading: Icon(
          Icons.delete_outline_rounded,
          color: DesignTokens.errorRed,
        ),
        title: Text(
          'Eintrag löschen',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: DesignTokens.errorRed,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: const Text('Diese Aktion kann nicht rückgängig gemacht werden'),
        onTap: _isDeleting ? null : _deleteEntry,
        trailing: _isDeleting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                Icons.arrow_forward_ios_rounded,
                color: DesignTokens.errorRed,
                size: Spacing.iconSm,
              ),
      ),
    ).animate().fadeIn(
      duration: DesignTokens.animationMedium,
      delay: const Duration(milliseconds: 1500),
    ).slideY(
      begin: 0.3,
      end: 0,
      duration: DesignTokens.animationMedium,
      curve: DesignTokens.curveEaseOut,
    );
  }

  Widget _buildSaveButton(BuildContext context, bool isDark) {
    return ModernFAB(
      onPressed: (_isSaving || !_hasChanges) ? null : _saveEntry,
      icon: _isSaving ? null : Icons.save_rounded,
      label: _isSaving ? 'Speichern...' : 'Speichern',
      backgroundColor: _hasChanges ? DesignTokens.primaryIndigo : DesignTokens.neutral400,
      isLoading: _isSaving,
    ).animate().fadeIn(
      duration: DesignTokens.animationSlow,
      delay: const Duration(milliseconds: 1600),
    ).scale(
      begin: const Offset(0.8, 0.8),
      end: const Offset(1.0, 1.0),
      duration: DesignTokens.animationSlow,
      curve: DesignTokens.curveBack,
    );
  }

  Future<bool?> _showUnsavedChangesDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ungespeicherte Änderungen'),
        content: const Text('Sie haben ungespeicherte Änderungen. Möchten Sie diese verwerfen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: DesignTokens.errorRed),
            child: const Text('Verwerfen'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
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
        _onFormChanged();
      });
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
        _onFormChanged();
      });
    }
  }
}