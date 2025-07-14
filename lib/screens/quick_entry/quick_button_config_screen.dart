import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../../models/quick_button_config.dart';
import '../../models/substance.dart';
import '../../services/quick_button_service.dart';
import '../../services/substance_service.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/modern_fab.dart';
import '../../theme/design_tokens.dart';
import '../../theme/spacing.dart';
import '../../utils/validation_helper.dart';
import '../../utils/app_icon_generator.dart';

class QuickButtonConfigScreen extends StatefulWidget {
  final QuickButtonConfig? existingConfig;

  const QuickButtonConfigScreen({
    super.key,
    this.existingConfig,
  });

  @override
  State<QuickButtonConfigScreen> createState() => _QuickButtonConfigScreenState();
}

class _QuickButtonConfigScreenState extends State<QuickButtonConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  
  // Form controllers
  final _dosageController = TextEditingController();
  final _unitController = TextEditingController();
  final _priceController = TextEditingController();
  
  // Form state
  Substance? _selectedSubstance;
  List<Substance> _substances = [];
  String _selectedUnit = ''; // Selected unit from dropdown
  double _calculatedCost = 0.0;
  double _manualPrice = 0.0;
  bool _autoCalculateCost = true;
  List<String> _commonUnits = ['mg', 'g', 'ml', 'Stück', 'Tablette', 'Flasche', 'Bong', 'Joint'];
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isDisposed = false;
  String? _errorMessage;

  // Services
  final QuickButtonService _quickButtonService = QuickButtonService();
  final SubstanceService _substanceService = SubstanceService();

  @override
  void initState() {
    super.initState();
    _loadSubstances();
    _initializeForm();
  }
  
  void _updateCalculatedCost() {
    if (_selectedSubstance != null && _autoCalculateCost) {
      final dosage = double.tryParse(_dosageController.text.replaceAll(',', '.')) ?? 0.0;
      final unit = _unitController.text;
      
      if (dosage > 0 && unit.isNotEmpty) {
        setState(() {
          _calculatedCost = _selectedSubstance!.calculateCostForAmount(dosage, unit);
        });
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _dosageController.dispose();
    _unitController.dispose();
    _priceController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeForm() {
    if (widget.existingConfig != null) {
      final config = widget.existingConfig!;
      _dosageController.text = config.dosage.toString().replaceAll('.', ',');
      _selectedUnit = config.unit;
      _unitController.text = _selectedUnit;
      // Load saved price if available
      _priceController.text = _calculatedCost.toString().replaceAll('.', ',');
      // Trigger cost calculation after form is initialized
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateCalculatedCost();
      });
    }
  }

  Future<void> _loadSubstances() async {
    if (_isDisposed) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final substances = await _substanceService.getAllSubstances();
      
      if (_isDisposed) return;
      
      setState(() {
        _substances = substances;
        
        // Sammle alle einzigartigen Einheiten aus den Substanzen
        final unitSet = <String>{};
        for (final substance in substances) {
          if (substance.defaultUnit.isNotEmpty) {
            unitSet.add(substance.defaultUnit);
          }
        }
        // Füge die gesammelten Einheiten zu den Standard-Einheiten hinzu
        _commonUnits = [..._commonUnits, ...unitSet.toList()];
        // Entferne Duplikate und sortiere
        _commonUnits = _commonUnits.toSet().toList()..sort();
        
        // Set selected substance if editing
        if (widget.existingConfig != null) {
          _selectedSubstance = substances.firstWhere(
            (s) => s.id == widget.existingConfig!.substanceId,
            orElse: () => substances.first,
          );
          if (_selectedSubstance != null) {
            _unitController.text = _selectedSubstance!.defaultUnit;
            _selectedUnit = _selectedSubstance!.defaultUnit;
            _updateCalculatedCost(); // Update cost when editing
            // Set price in the price controller
            _priceController.text = _calculatedCost.toString().replaceAll('.', ',');
          }
        }
        
        _isLoading = false;
      });
    } catch (e) {
      if (_isDisposed) return;
      
      setState(() {
        _errorMessage = 'Fehler beim Laden der Substanzen: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveQuickButton() async {
    if (!_formKey.currentState!.validate() || _selectedSubstance == null) {
      // Scroll to the top to show validation errors
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      return;
    }

    if (_isDisposed) return;
    
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final dosage = double.tryParse(_dosageController.text.replaceAll(',', '.')) ?? 0.0;
      final position = widget.existingConfig?.position ?? await _quickButtonService.getNextOrderIndex();

      // Ensure unit is set
      final unit = _selectedUnit.isNotEmpty ? _selectedUnit : _unitController.text;

      final config = widget.existingConfig?.copyWith(
        substanceId: _selectedSubstance!.id,
        substanceName: _selectedSubstance!.name,
        dosage: dosage,
        unit: unit,
      ) ?? QuickButtonConfig.create(
        substanceId: _selectedSubstance!.id,
        substanceName: _selectedSubstance!.name,
        dosage: dosage,
        unit: unit,
        position: position,
      );

      if (widget.existingConfig != null) {
        await _quickButtonService.updateQuickButton(config);
      } else {
        await _quickButtonService.createQuickButton(config);
      }

      if (_isDisposed) return;
      
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingConfig != null 
                ? 'Quick Button erfolgreich aktualisiert' 
                : 'Quick Button erfolgreich erstellt'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (_isDisposed) return;
      
      setState(() {
        _errorMessage = 'Fehler beim Speichern: $e';
        _isSaving = false;
      });
    }
  }

  Future<void> _deleteQuickButton() async {
    if (widget.existingConfig == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quick Button löschen'),
        content: const Text('Möchten Sie diesen Quick Button wirklich löschen?'),
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

    try {
      await _quickButtonService.deleteQuickButton(widget.existingConfig!.id);
      
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quick Button erfolgreich gelöscht'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Löschen: $e'),
            backgroundColor: DesignTokens.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEdit = widget.existingConfig != null; 

    return Scaffold(
      body: Column(
        children: [
          _buildAppBar(context, isDark, isEdit),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: Spacing.paddingHorizontalMd,
              child: Column(
                children: [
                  if (_errorMessage != null) ...[
                    Spacing.verticalSpaceMd,
                    _buildErrorCard(context, isDark),
                    Spacing.verticalSpaceMd,
                  ],
                  if (_isLoading)
                    _buildLoadingState()
                  else
                    _buildForm(context, isDark),
                  if (isEdit) ...[
                    Spacing.verticalSpaceLg,
                    _buildDeleteButton(context, isDark),
                  ],
                  const SizedBox(height: 120), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildSaveButton(context, isDark, isEdit),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark, bool isEdit) {
    final theme = Theme.of(context);

    return Container(
      height: 120,
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
          child: Stack(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 56.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          isEdit ? 'Quick Button bearbeiten' : 'Quick Button erstellen',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(Spacing.xs),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: Spacing.borderRadiusSm,
                        ),
                        child: Icon(
                          Icons.flash_on_rounded,
                          color: Colors.white,
                          size: Spacing.iconMd,
                        ),
                      ),
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
    return Column(
      children: List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: Spacing.md),
          child: GlassCard(
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: Spacing.borderRadiusMd,
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: const Duration(milliseconds: 1500)),
        );
      }),
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
          _buildPriceSection(context, isDark),
          Spacing.verticalSpaceLg,
          _buildPreviewSection(context, isDark),
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
          child: DropdownButtonFormField<Substance>(
            value: _selectedSubstance,
            decoration: const InputDecoration(
              labelText: 'Substanz auswählen',
              border: InputBorder.none,
              prefixIcon: Icon(Icons.science_rounded),
            ),
            items: _substances.map((substance) => DropdownMenuItem<Substance>(
              value: substance,
              child: Text(substance.name),
            )).toList(),
            onChanged: (substance) {
              setState(() {
                _selectedSubstance = substance;
                if (substance != null) {
                  _selectedUnit = substance.defaultUnit;
                  _unitController.text = _selectedUnit;
                  _updateCalculatedCost();
                  // Auto-load price when substance is selected
                  _priceController.text = _calculatedCost.toString().replaceAll('.', ',');
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
                    prefixIcon: Icon(Icons.straighten_rounded),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                  ],
                    onChanged: (value) {
                      _updateCalculatedCost();
                      // Update price display
                      _priceController.text = _calculatedCost.toString().replaceAll('.', ',');
                    },
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
                  readOnly: true, // Make it read-only since we're using dropdown
                  decoration: InputDecoration(
                    labelText: 'Einheit',
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.straighten_rounded),
                    suffixIcon: PopupMenuButton<String>(
                      icon: const Icon(Icons.arrow_drop_down),
                      onSelected: (String value) {
                        setState(() {
                          _selectedUnit = value;
                          _unitController.text = value;
                          _updateCalculatedCost(); // Update cost when unit changes
                          // Update price display
                          _priceController.text = _calculatedCost.toString().replaceAll('.', ',');
                        });
                      },
                      itemBuilder: (BuildContext context) {
                        return _commonUnits.map<PopupMenuItem<String>>((String value) {
                          return PopupMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Bitte geben Sie eine Einheit ein';
                     } else if (_selectedUnit.isEmpty && value.trim().isEmpty) {
                       return 'Bitte wählen Sie eine Einheit aus';
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

  Widget _buildPriceSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preis',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ).animate().fadeIn(
          duration: DesignTokens.animationMedium,
          delay: const Duration(milliseconds: 600),
        ),
        Spacing.verticalSpaceSm,
        GlassCard(
          child: TextFormField(
            controller: _priceController,
            decoration: const InputDecoration(
              labelText: 'Preis (€)',
              border: InputBorder.none,
              prefixIcon: Icon(Icons.euro_rounded),
              suffixText: '€',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
            ],
            onChanged: (value) {
              final price = double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
              setState(() {
                _manualPrice = price;
              });
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Bitte geben Sie einen Preis ein';
              }
              final price = double.tryParse(value.replaceAll(',', '.'));
              if (price == null || price < 0) {
                return 'Bitte geben Sie einen gültigen Preis ein';
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
        Spacing.verticalSpaceXs,
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.blue.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: Colors.blue,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Berechneter Preis: ${_calculatedCost.toStringAsFixed(2).replaceAll('.', ',')}€',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(
          duration: DesignTokens.animationMedium,
          delay: const Duration(milliseconds: 800),
        ),
      ],
    );
  }

  Widget _buildPreviewSection(BuildContext context, bool isDark) {
    if (_selectedSubstance == null || _dosageController.text.isEmpty || _unitController.text.isEmpty) {
      return const SizedBox.shrink();
    }

    final dosage = double.tryParse(_dosageController.text.replaceAll(',', '.')) ?? 0.0;
    final formattedDosage = '${dosage.toString().replaceAll('.', ',')} ${_unitController.text}';
    final priceToShow = _priceController.text.isNotEmpty 
        ? double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0.0
        : _calculatedCost;
    final formattedCost = '${priceToShow.toStringAsFixed(2).replaceAll('.', ',')}€';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vorschau',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ).animate().fadeIn(
          duration: DesignTokens.animationMedium,
          delay: const Duration(milliseconds: 800),
        ),
        Spacing.verticalSpaceSm,
        Center(
          child: Container(
            width: 80,
            height: 120, // Increased height to accommodate cost display
            decoration: BoxDecoration(
              gradient: isDark
                  ? DesignTokens.glassGradientDark
                  : DesignTokens.glassGradientLight,
              borderRadius: Spacing.borderRadiusLg,
              border: Border.all(
                color: DesignTokens.primaryIndigo.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: DesignTokens.primaryIndigo.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: Spacing.paddingMd,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(Spacing.xs),
                    decoration: BoxDecoration(
                      color: DesignTokens.primaryIndigo.withOpacity(0.1),
                      borderRadius: Spacing.borderRadiusSm,
                    ),
                    child: Icon(
                      AppIconGenerator.getSubstanceIcon(_selectedSubstance!.name),
                      color: DesignTokens.primaryIndigo,
                      size: Spacing.iconMd,
                    ),
                  ),
                  Spacing.verticalSpaceXs,
                  Text(
                    _selectedSubstance!.name,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    formattedDosage,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: DesignTokens.primaryIndigo,
                      fontWeight: FontWeight.w500,
                      fontSize: 9,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Spacing.verticalSpaceXs,
                  // Add cost display
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.xs,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: Spacing.borderRadiusXs,
                    ),
                    child: Text(
                      formattedCost,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ).animate().fadeIn(
          duration: DesignTokens.animationMedium,
          delay: const Duration(milliseconds: 900),
        ).scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
          duration: DesignTokens.animationMedium,
          curve: DesignTokens.curveBack,
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
          'Quick Button löschen',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: DesignTokens.errorRed,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: const Text('Diese Aktion kann nicht rückgängig gemacht werden'),
        onTap: _deleteQuickButton,
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          color: DesignTokens.errorRed,
          size: Spacing.iconSm,
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
    );
  }

  Widget _buildSaveButton(BuildContext context, bool isDark, bool isEdit) {
    final hasValidData = _selectedSubstance != null &&
        _dosageController.text.isNotEmpty &&
        (_selectedUnit.isNotEmpty || _unitController.text.isNotEmpty) &&
        _priceController.text.isNotEmpty;

    return ModernFAB(
      onPressed: (_isSaving || !hasValidData) ? null : _saveQuickButton,
      icon: _isSaving ? null : Icons.save_rounded,
      label: _isSaving ? 'Speichern...' : (isEdit ? 'Aktualisieren' : 'Erstellen'),
      backgroundColor: hasValidData ? DesignTokens.primaryIndigo : DesignTokens.neutral400,
      isLoading: _isSaving,
    ).animate().fadeIn(
      duration: DesignTokens.animationSlow,
      delay: const Duration(milliseconds: 1100),
    ).scale(
      begin: const Offset(0.8, 0.8),
      end: const Offset(1.0, 1.0),
      duration: DesignTokens.animationSlow,
      curve: DesignTokens.curveBack,
    );
  }
}