import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/substance.dart';
import '../services/substance_service.dart';
import '../utils/unit_manager.dart';
import '../widgets/glass_card.dart';
import '../widgets/modern_fab.dart';
import '../theme/design_tokens.dart';
import '../theme/spacing.dart';
import '../utils/validation_helper.dart';
import '../utils/app_icon_generator.dart';

class SubstanceManagementScreen extends StatefulWidget {
  const SubstanceManagementScreen({super.key});

  @override
  State<SubstanceManagementScreen> createState() => _SubstanceManagementScreenState();
}

class _SubstanceManagementScreenState extends State<SubstanceManagementScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  final SubstanceService _substanceService = SubstanceService();

  List<Substance> _allSubstances = [];
  List<Substance> _filteredSubstances = [];
  String _searchQuery = '';
  SubstanceCategory? _selectedCategory;
  bool _isLoading = true;
  bool _isDisposed = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSubstances();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _applyFilters();
    });
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
        _allSubstances = substances;
        _applyFilters();
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

  void _applyFilters() {
    List<Substance> filtered = List.from(_allSubstances);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((substance) {
        return substance.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               (substance.notes?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      }).toList();
    }

    // Apply category filter
    if (_selectedCategory != null) {
      filtered = filtered.where((substance) => substance.category == _selectedCategory).toList();
    }

    setState(() {
      _filteredSubstances = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Column(
        children: [
          _buildAppBar(context, isDark),
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
                  _buildSearchAndFilter(context, isDark),
                  Spacing.verticalSpaceMd,
                  if (_isLoading)
                    _buildLoadingState()
                  else
                    _buildSubstancesList(context, isDark),
                  const SizedBox(height: 120), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildAddButton(context, isDark),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return Container(
      height: 140,
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
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.science_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Substanzen verwalten',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Eigene Substanzen erstellen & bearbeiten',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_filteredSubstances.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Spacing.sm,
                            vertical: Spacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: Spacing.borderRadiusSm,
                          ),
                          child: Text(
                            '${_filteredSubstances.length}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
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
          IconButton(
            onPressed: _loadSubstances,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter(BuildContext context, bool isDark) {
    return Column(
      children: [
        // Search bar
        GlassCard(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Substanzen durchsuchen...',
              border: InputBorder.none,
              prefixIcon: Icon(
                Icons.search_rounded,
                color: DesignTokens.primaryIndigo,
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                      },
                      icon: const Icon(Icons.clear_rounded),
                    )
                  : null,
            ),
          ),
        ).animate().fadeIn(
          duration: DesignTokens.animationMedium,
          delay: const Duration(milliseconds: 300),
        ),
        
        Spacing.verticalSpaceMd,
        
        // Category filter
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: SubstanceCategory.values.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                final isSelected = _selectedCategory == null;
                return Padding(
                  padding: const EdgeInsets.only(right: Spacing.sm),
                  child: _buildCategoryChip('Alle', isSelected, null),
                );
              }
              
              final category = SubstanceCategory.values[index - 1];
              final isSelected = _selectedCategory == category;
              return Padding(
                padding: EdgeInsets.only(
                  right: index < SubstanceCategory.values.length ? Spacing.sm : 0,
                ),
                child: _buildCategoryChip(
                  category.name,
                  isSelected,
                  category,
                ),
              );
            },
          ),
        ).animate().fadeIn(
          duration: DesignTokens.animationMedium,
          delay: const Duration(milliseconds: 400),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected, SubstanceCategory? category) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = category != null 
        ? AppIconGenerator.getSubstanceCategoryColor(category.name)
        : DesignTokens.primaryIndigo;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
          _applyFilters();
        });
      },
      child: AnimatedContainer(
        duration: DesignTokens.animationFast,
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? (isDark
                  ? DesignTokens.glassGradientDark
                  : DesignTokens.glassGradientLight)
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: Spacing.borderRadiusFull,
          border: Border.all(
            color: isSelected
                ? color
                : (isDark
                    ? DesignTokens.glassBorderDark
                    : DesignTokens.glassBorderLight),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          _getCategoryDisplayName(label),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? color : null,
          ),
        ),
      ),
    );
  }

  String _getCategoryDisplayName(String category) {
    switch (category.toLowerCase()) {
      case 'alle':
        return 'Alle';
      case 'medication':
        return 'Medikamente';
      case 'stimulant':
        return 'Stimulanzien';
      case 'depressant':
        return 'Depressiva';
      case 'supplement':
        return 'Supplements';
      case 'recreational':
        return 'Freizeit';
      case 'other':
        return 'Sonstiges';
      default:
        return category;
    }
  }

  Widget _buildLoadingState() {
    return Column(
      children: List.generate(5, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: Spacing.sm),
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

  Widget _buildSubstancesList(BuildContext context, bool isDark) {
    if (_filteredSubstances.isEmpty) {
      return _buildEmptyState(context, isDark);
    }

    return Column(
      children: _filteredSubstances.asMap().entries.map((entry) {
        final index = entry.key;
        final substance = entry.value;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: Spacing.sm),
          child: _buildSubstanceCard(context, substance),
        ).animate().fadeIn(
          duration: DesignTokens.animationMedium,
          delay: Duration(milliseconds: 500 + (index * 50)),
        ).slideY(
          begin: 0.3,
          end: 0,
          duration: DesignTokens.animationMedium,
          curve: DesignTokens.curveEaseOut,
        );
      }).toList(),
    );
  }

  Widget _buildSubstanceCard(BuildContext context, Substance substance) {
    final theme = Theme.of(context);
    final substanceColor = AppIconGenerator.getSubstanceCategoryColor(substance.category.name);
    final riskColor = AppIconGenerator.getRiskLevelColor(substance.defaultRiskLevel.name);

    return GlassCard(
      onTap: () => _editSubstance(substance),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(Spacing.sm),
            decoration: BoxDecoration(
              color: substanceColor.withOpacity(0.1),
              borderRadius: Spacing.borderRadiusMd,
            ),
            child: Icon(
              AppIconGenerator.getSubstanceCategoryIcon(substance.category.name),
              color: substanceColor,
              size: Spacing.iconLg,
            ),
          ),
          Spacing.horizontalSpaceMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        substance.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.xs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: riskColor.withOpacity(0.1),
                        borderRadius: Spacing.borderRadiusSm,
                      ),
                      child: Text(
                        substance.riskLevelDisplayName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: riskColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                Spacing.verticalSpaceXs,
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        substance.categoryDisplayName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: substanceColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      substance.formattedPrice,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: DesignTokens.accentEmerald,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Spacing.horizontalSpaceSm,
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _editSubstance(substance);
                  break;
                case 'delete':
                  _deleteSubstance(substance);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_rounded),
                    SizedBox(width: 8),
                    Text('Bearbeiten'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_rounded, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Löschen', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.all(Spacing.xs),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withOpacity(0.5),
                borderRadius: Spacing.borderRadiusSm,
              ),
              child: Icon(
                Icons.more_vert_rounded,
                size: Spacing.iconSm,
                color: theme.iconTheme.color?.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return GlassCard(
      child: Column(
        children: [
          Icon(
            Icons.science_outlined,
            size: Spacing.iconXl,
            color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
          ),
          Spacing.verticalSpaceMd,
          Text(
            _searchQuery.isNotEmpty ? 'Keine Ergebnisse' : 'Noch keine Substanzen',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          Spacing.verticalSpaceXs,
          Text(
            _searchQuery.isNotEmpty
                ? 'Keine Substanzen für "$_searchQuery" gefunden'
                : 'Fügen Sie Ihre erste Substanz hinzu',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          if (_searchQuery.isEmpty) ...[
            Spacing.verticalSpaceMd,
            ElevatedButton.icon(
              onPressed: () => _addSubstance(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Erste Substanz hinzufügen'),
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignTokens.primaryIndigo,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, bool isDark) {
    return ModernFAB(
      onPressed: _addSubstance,
      icon: Icons.add_rounded,
      label: 'Substanz',
      backgroundColor: DesignTokens.primaryIndigo,
    ).animate().fadeIn(
      duration: DesignTokens.animationSlow,
      delay: const Duration(milliseconds: 800),
    ).scale(
      begin: const Offset(0.8, 0.8),
      end: const Offset(1.0, 1.0),
      duration: DesignTokens.animationSlow,
      curve: DesignTokens.curveBack,
    );
  }

  Future<void> _addSubstance() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddEditSubstanceScreen(),
      ),
    );

    if (result == true) {
      _loadSubstances();
    }
  }

  Future<void> _editSubstance(Substance substance) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditSubstanceScreen(substance: substance),
      ),
    );

    if (result == true) {
      _loadSubstances();
    }
  }

  Future<void> _deleteSubstance(Substance substance) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Substanz löschen'),
        content: Text('Möchten Sie "${substance.name}" wirklich löschen?'),
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
      await _substanceService.deleteSubstance(substance.id);
      _loadSubstances();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Substanz erfolgreich gelöscht'),
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
}

// Add/Edit Substance Screen
class AddEditSubstanceScreen extends StatefulWidget {
  final Substance? substance;

  const AddEditSubstanceScreen({super.key, this.substance});

  @override
  State<AddEditSubstanceScreen> createState() => _AddEditSubstanceScreenState();
}

class _AddEditSubstanceScreenState extends State<AddEditSubstanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _unitController = TextEditingController();
  final _notesController = TextEditingController();

  SubstanceCategory _selectedCategory = SubstanceCategory.other;
  RiskLevel _selectedRiskLevel = RiskLevel.low;
  String _selectedUnit = '';
  List<String> _suggestedUnits = [];
  List<String> _recommendedUnits = [];
  bool _isSaving = false;
  bool _isDisposed = false;
  bool _isLoadingUnits = false;
  String? _errorMessage;

  final SubstanceService _substanceService = SubstanceService();

  @override
  void initState() {
    super.initState();
    if (widget.substance != null) {
      _initializeForm();
    }
    _loadUnits();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _nameController.dispose();
    _priceController.dispose();
    _unitController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _initializeForm() {
    final substance = widget.substance!;
    _nameController.text = substance.name;
    _priceController.text = substance.pricePerUnit.toString().replaceAll('.', ',');
    _unitController.text = substance.defaultUnit;
    _selectedUnit = substance.defaultUnit;
    _notesController.text = substance.notes ?? '';
    _selectedCategory = substance.category;
    _selectedRiskLevel = substance.defaultRiskLevel;
    
    // Load recommended units for the category
    _updateRecommendedUnits();
  }

  Future<void> _loadUnits() async {
    if (_isDisposed) return;
    
    setState(() {
      _isLoadingUnits = true;
    });

    try {
      final suggestedUnits = await _substanceService.getSuggestedUnits();
      
      if (_isDisposed) return;
      
      setState(() {
        _suggestedUnits = suggestedUnits;
        _isLoadingUnits = false;
      });
    } catch (e) {
      if (_isDisposed) return;
      
      setState(() {
        _suggestedUnits = UnitManager.validUnits;
        _isLoadingUnits = false;
      });
    }
  }

  void _updateRecommendedUnits() {
    setState(() {
      _recommendedUnits = _substanceService.getRecommendedUnitsForCategory(_selectedCategory);
    });
  }

  Future<void> _saveSubstance() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isDisposed) return;
    
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final substance = widget.substance?.copyWith(
        name: _nameController.text.trim(),
        category: _selectedCategory,
        defaultRiskLevel: _selectedRiskLevel,
        pricePerUnit: double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0.0,
        defaultUnit: _selectedUnit.isNotEmpty ? _selectedUnit : _unitController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      ) ?? Substance.create(
        name: _nameController.text.trim(),
        category: _selectedCategory,
        defaultRiskLevel: _selectedRiskLevel,
        pricePerUnit: double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0.0,
        defaultUnit: _selectedUnit.isNotEmpty ? _selectedUnit : _unitController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      if (widget.substance != null) {
        await _substanceService.updateSubstance(substance);
      } else {
        await _substanceService.createSubstance(substance);
      }

      if (_isDisposed) return;
      
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.substance != null 
                ? 'Substanz erfolgreich aktualisiert' 
                : 'Substanz erfolgreich erstellt'),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEdit = widget.substance != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Substanz bearbeiten' : 'Substanz hinzufügen'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: Spacing.paddingMd,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_errorMessage != null) ...[
                GlassCard(
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
              
              // Name field
              GlassCard(
                child: TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Substanzname',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.science_rounded),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Bitte geben Sie einen Namen ein';
                    }
                    return ValidationHelper.getValidationError('substance', value);
                  },
                ),
              ),
              
              Spacing.verticalSpaceMd,
              
              // Category selection
              GlassCard(
                child: DropdownButtonFormField<SubstanceCategory>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Kategorie',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.category_rounded),
                  ),
                  items: SubstanceCategory.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(_getCategoryDisplayName(category.name)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                      _updateRecommendedUnits();
                    });
                  },
                ),
              ),
              
              Spacing.verticalSpaceMd,
              
              // Risk level selection
              GlassCard(
                child: DropdownButtonFormField<RiskLevel>(
                  value: _selectedRiskLevel,
                  decoration: const InputDecoration(
                    labelText: 'Risikostufe',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.warning_rounded),
                  ),
                  items: RiskLevel.values.map((risk) {
                    return DropdownMenuItem(
                      value: risk,
                      child: Row(
                        children: [
                          Icon(
                            AppIconGenerator.getRiskLevelIcon(risk.name),
                            color: AppIconGenerator.getRiskLevelColor(risk.name),
                            size: Spacing.iconSm,
                          ),
                          const SizedBox(width: 8),
                          Text(_getRiskDisplayName(risk.name)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRiskLevel = value!;
                    });
                  },
                ),
              ),
              
              Spacing.verticalSpaceMd,
              
              // Price and unit
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: GlassCard(
                      child: TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Preis pro Einheit',
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.euro_rounded),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                        ],
                        validator: (value) {
                          return ValidationHelper.getValidationError('cost', value ?? '');
                        },
                      ),
                    ),
                  ),
                  Spacing.horizontalSpaceMd,
                  Expanded(
                    child: GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _unitController,
                            decoration: InputDecoration(
                              labelText: 'Einheit',
                              border: InputBorder.none,
                              suffixIcon: _isLoadingUnits
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : PopupMenuButton<String>(
                                      icon: const Icon(Icons.arrow_drop_down),
                                      onSelected: (String value) {
                                        setState(() {
                                          _selectedUnit = value;
                                          _unitController.text = value;
                                        });
                                      },
                                      itemBuilder: (BuildContext context) {
                                        final allUnits = <String>{};
                                        
                                        // Add recommended units for category first
                                        if (_recommendedUnits.isNotEmpty) {
                                          allUnits.addAll(_recommendedUnits);
                                        }
                                        
                                        // Add suggested units from database
                                        allUnits.addAll(_suggestedUnits);
                                        
                                        return allUnits.map<PopupMenuItem<String>>((String value) {
                                          final isRecommended = _recommendedUnits.contains(value);
                                          return PopupMenuItem<String>(
                                            value: value,
                                            child: Row(
                                              children: [
                                                Text(value),
                                                if (isRecommended) ...[
                                                  const SizedBox(width: 8),
                                                  Icon(
                                                    Icons.star,
                                                    size: 16,
                                                    color: DesignTokens.primaryIndigo,
                                                  ),
                                                ],
                                              ],
                                            ),
                                          );
                                        }).toList();
                                      },
                                    ),
                            ),
                            validator: (value) {
                              final unitValidation = _substanceService.validateUnit(value);
                              if (unitValidation != null) {
                                return unitValidation;
                              }
                              return ValidationHelper.getValidationError('unit', value ?? '');
                            },
                            onChanged: (value) {
                              setState(() {
                                _selectedUnit = value;
                              });
                            },
                          ),
                          if (_recommendedUnits.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Empfohlene Einheiten für ${_getCategoryDisplayName(_selectedCategory.name)}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: DesignTokens.primaryIndigo,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 4,
                              children: _recommendedUnits.take(3).map((unit) {
                                return ActionChip(
                                  label: Text(unit),
                                  onPressed: () {
                                    setState(() {
                                      _selectedUnit = unit;
                                      _unitController.text = unit;
                                    });
                                  },
                                  backgroundColor: DesignTokens.primaryIndigo.withOpacity(0.1),
                                  labelStyle: TextStyle(
                                    color: DesignTokens.primaryIndigo,
                                    fontSize: 12,
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              Spacing.verticalSpaceMd,
              
              // Notes
              GlassCard(
                child: TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notizen (optional)',
                    border: InputBorder.none,
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                  maxLength: 500,
                  validator: (value) {
                    return ValidationHelper.getValidationError('notes', value ?? '');
                  },
                ),
              ),
              
              Spacing.verticalSpaceXl,
              
              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveSubstance,
                  icon: _isSaving 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(_isSaving 
                      ? 'Speichern...' 
                      : (isEdit ? 'Aktualisieren' : 'Erstellen')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignTokens.primaryIndigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCategoryDisplayName(String category) {
    switch (category.toLowerCase()) {
      case 'medication':
        return 'Medikament';
      case 'stimulant':
        return 'Stimulans';
      case 'depressant':
        return 'Depressivum';
      case 'supplement':
        return 'Nahrungsergänzung';
      case 'recreational':
        return 'Freizeitsubstanz';
      case 'other':
        return 'Sonstiges';
      default:
        return category;
    }
  }

  String _getRiskDisplayName(String risk) {
    switch (risk.toLowerCase()) {
      case 'low':
        return 'Niedrig';
      case 'medium':
        return 'Mittel';
      case 'high':
        return 'Hoch';
      case 'critical':
        return 'Kritisch';
      default:
        return risk;
    }
  }
}