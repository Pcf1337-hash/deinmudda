import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../../models/dosage_calculator_substance.dart';
import '../../models/dosage_calculator_user.dart';
import '../../models/dosage_calculation.dart';
import '../../services/dosage_calculator_service.dart';
import '../../utils/service_locator.dart'; // refactored by ArchitekturAgent
import '../../theme/design_tokens.dart';
import '../../theme/spacing.dart';

class SubstanceSearchScreen extends StatefulWidget {
  const SubstanceSearchScreen({super.key});

  @override
  State<SubstanceSearchScreen> createState() => _SubstanceSearchScreenState();
}

class _SubstanceSearchScreenState extends State<SubstanceSearchScreen> {
  final _searchController = TextEditingController();
  late final DosageCalculatorService _dosageService = ServiceLocator.get<DosageCalculatorService>(); // refactored by ArchitekturAgent
  
  List<DosageCalculatorSubstance> _allSubstances = [];
  List<DosageCalculatorSubstance> _filteredSubstances = [];
  DosageCalculatorUser? _currentUser;
  String _searchQuery = '';
  String _selectedCategory = 'Alle';
  bool _isLoading = true;
  String? _errorMessage;

  final List<String> _categories = [
    'Alle',
    'Stimulanzien',
    'Depressiva',
    'Psychedelika',
    'Dissoziativa',
    'Cannabinoide',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _applyFilters();
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final substances = await _dosageService.getAllDosageSubstances();
      final user = await _dosageService.getUserProfile();

      if (mounted) {
        setState(() {
          _allSubstances = substances;
          _currentUser = user;
          _applyFilters();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Fehler beim Laden der Daten: $e';
          _isLoading = false;
          _allSubstances = [];
          _filteredSubstances = [];
        });
      }
    }
  }

  void _applyFilters() {
    List<DosageCalculatorSubstance> filtered = List.from(_allSubstances);

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((substance) {
        return substance.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               substance.safetyNotes.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    if (_selectedCategory != 'Alle') {
      filtered = filtered.where((substance) {
        return _getSubstanceCategory(substance.name) == _selectedCategory;
      }).toList();
    }

    setState(() {
      _filteredSubstances = filtered;
    });
  }

  String _getSubstanceCategory(String substanceName) {
    final name = substanceName.toLowerCase();
    
    if (name.contains('mdma') || name.contains('amphetamin') || name.contains('kokain') || name.contains('mephedron')) {
      return 'Stimulanzien';
    } else if (name.contains('alkohol') || name.contains('ghb') || name.contains('benzo') || name.contains('opiat') || name.contains('opioid')) {
      return 'Depressiva';
    } else if (name.contains('lsd') || name.contains('psilocybin') || name.contains('2c-b') || name.contains('mescalin') || name.contains('dmt')) {
      return 'Psychedelika';
    } else if (name.contains('ketamin') || name.contains('dxm') || name.contains('lachgas')) {
      return 'Dissoziativa';
    } else if (name.contains('thc') || name.contains('cannabis')) {
      return 'Cannabinoide';
    } else {
      return 'Sonstiges';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Substanz suchen',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.indigo,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
        actions: [
          if (_filteredSubstances.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_filteredSubstances.length}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: theme.scaffoldBackgroundColor,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (_errorMessage != null) ...[
                  _buildErrorCard(context, isDark),
                  const SizedBox(height: 16),
                ],
                _buildSearchBar(context, isDark),
                const SizedBox(height: 16),
                _buildCategoryFilter(context, isDark),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _buildSubstancesList(context, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: Colors.red,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Substanz suchen...',
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.indigo,
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
    );
  }

  Widget _buildCategoryFilter(BuildContext context, bool isDark) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;

          return Padding(
            padding: EdgeInsets.only(
              right: index < _categories.length - 1 ? 8 : 0,
            ),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                  _applyFilters();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.indigo : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Colors.indigo : Colors.grey,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  category,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? Colors.white : null,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubstancesList(BuildContext context, bool isDark) {
    if (_filteredSubstances.isEmpty) {
      return _buildEmptyState(context, isDark);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredSubstances.length,
      itemBuilder: (context, index) {
        final substance = _filteredSubstances[index];
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildSimpleSubstanceCard(context, substance),
        );
      },
    );
  }

  Widget _buildSimpleSubstanceCard(BuildContext context, DosageCalculatorSubstance substance) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final substanceColor = _getSubstanceColor(substance.name);
    final riskColor = _getRiskColor(substance.name);

    // Calculate dosage preview if user exists
    double? calculatedDose;
    double? optimalDose;
    if (_currentUser != null) {
      calculatedDose = substance.calculateDosage(_currentUser!.weightKg, DosageIntensity.normal);
      optimalDose = _currentUser!.getRecommendedDose(calculatedDose);
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _calculateDosage(substance),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: substanceColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getSubstanceIcon(substance.name),
                        color: substanceColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            substance.name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: substanceColor,
                            ),
                          ),
                          Text(
                            _getSubstanceCategory(substance.name),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: riskColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: riskColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getRiskIcon(substance.name),
                            color: riskColor,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getRiskLevel(substance.name),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: riskColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Add recommended dose display with enhanced styling if user exists
                if (_currentUser != null && optimalDose != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          substanceColor.withOpacity(0.15),
                          substanceColor.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: substanceColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.auto_awesome_rounded,
                              color: substanceColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _currentUser!.getDosageLabel(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: substanceColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${optimalDose!.toStringAsFixed(1)} mg bei ${_currentUser!.formattedWeight}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: substanceColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Enhanced duration display with better styling
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              color: Colors.white,
                              size: 14,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 2,
                                  offset: const Offset(1, 1),
                                ),
                              ],
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '⏱ ${substance.duration}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.7),
                                      blurRadius: 2,
                                      offset: const Offset(1, 1),
                                    ),
                                  ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ] else ...[
                  // Show basic duration info even without user profile
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: substanceColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: substanceColor.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          color: Colors.white,
                          size: 14,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 2,
                              offset: const Offset(1, 1),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            substance.durationWithIcon,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.7),
                                  blurRadius: 2,
                                  offset: const Offset(1, 1),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: substanceColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: substanceColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildDosageInfo('Leicht', substance.lightDosePerKg, Colors.green),
                      _buildDosageInfo('Normal', substance.normalDosePerKg, Colors.orange),
                      _buildDosageInfo('Stark', substance.strongDosePerKg, Colors.red),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.route_rounded,
                            color: Colors.cyan,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              substance.administrationRouteDisplayName,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.cyan,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            color: Colors.purple,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              substance.duration,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.purple,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _calculateDosage(substance),
                    icon: const Icon(Icons.calculate_rounded),
                    label: Text(_currentUser != null ? 'Detailberechnung starten' : 'Profil erstellen & berechnen'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: substanceColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDosageInfo(String label, double dosePerKg, Color color) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${dosePerKg.toStringAsFixed(1)}mg/kg',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
                fontSize: 16,
              ),
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Keine Substanzen gefunden',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Keine Ergebnisse für "$_searchQuery"'
                  : 'Keine Substanzen in dieser Kategorie',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _calculateDosage(DosageCalculatorSubstance substance) async {
    if (_currentUser == null) {
      _showCreateProfileDialog();
      return;
    }

    try {
      final lightDose = substance.calculateDosage(_currentUser!.weightKg, DosageIntensity.light);
      final normalDose = substance.calculateDosage(_currentUser!.weightKg, DosageIntensity.normal);
      final strongDose = substance.calculateDosage(_currentUser!.weightKg, DosageIntensity.strong);
      
      final calculation = DosageCalculation(
        substance: substance.name,
        lightDose: lightDose,
        normalDose: normalDose,
        strongDose: strongDose,
        userWeight: _currentUser!.weightKg,
        administrationRoute: substance.administrationRoute,
        duration: substance.duration,
        safetyNotes: [substance.safetyNotes],
      );
      
      _showDosageResult(substance, calculation);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler bei der Berechnung: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCreateProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.person_add_rounded,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 8),
            const Text('Profil erforderlich'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Für präzise Dosierungsberechnungen benötigen Sie ein Benutzerprofil mit Ihren körperlichen Daten.',
            ),
            const SizedBox(height: 16),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.blue,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Vorteile eines Profils:',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Gewichtsbasierte Dosierung\n• Automatische Sicherheitsreduktion\n• Personalisierte Empfehlungen\n• BMI-berücksichtigte Berechnungen',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Return to main dosage calculator
            },
            icon: const Icon(Icons.person_add_rounded),
            label: const Text('Profil erstellen'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showDosageResult(DosageCalculatorSubstance substance, DosageCalculation calculation) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SimpleDosageResultCard(
        substance: substance,
        calculation: calculation,
        user: _currentUser!,
      ),
    );
  }

  // Helper methods
  Color _getSubstanceColor(String substanceName) {
    final hash = substanceName.hashCode;
    final colors = [
      Colors.indigo,
      Colors.cyan,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.pink,
    ];
    return colors[hash.abs() % colors.length];
  }

  Color _getRiskColor(String substanceName) {
    final name = substanceName.toLowerCase();
    
    if (name.contains('mdma') || name.contains('lsd') || name.contains('kokain')) {
      return Colors.red;
    } else if (name.contains('ketamin') || name.contains('amphetamin')) {
      return Colors.orange;
    } else if (name.contains('alkohol') || name.contains('cannabis')) {
      return Colors.yellow[700]!;
    } else {
      return Colors.green;
    }
  }

  IconData _getRiskIcon(String substanceName) {
    final color = _getRiskColor(substanceName);
    
    if (color == Colors.red) {
      return Icons.dangerous_rounded;
    } else if (color == Colors.orange || color == Colors.yellow[700]) {
      return Icons.warning_rounded;
    } else {
      return Icons.check_circle_rounded;
    }
  }

  String _getRiskLevel(String substanceName) {
    final color = _getRiskColor(substanceName);
    
    if (color == Colors.red) {
      return 'Hoch';
    } else if (color == Colors.orange || color == Colors.yellow[700]) {
      return 'Mittel';
    } else {
      return 'Niedrig';
    }
  }

  IconData _getSubstanceIcon(String substanceName) {
    final name = substanceName.toLowerCase();
    
    if (name.contains('mdma')) {
      return Icons.favorite_rounded;
    } else if (name.contains('lsd') || name.contains('psilocybin')) {
      return Icons.psychology_rounded;
    } else if (name.contains('ketamin')) {
      return Icons.medical_services_rounded;
    } else if (name.contains('kokain') || name.contains('amphetamin')) {
      return Icons.bolt_rounded;
    } else if (name.contains('alkohol')) {
      return Icons.local_bar_rounded;
    } else if (name.contains('cannabis') || name.contains('thc')) {
      return Icons.local_florist_rounded;
    } else {
      return Icons.science_rounded;
    }
  }
}

// Vereinfachte DosageResultCard ohne Animationen
class _SimpleDosageResultCard extends StatefulWidget {
  final DosageCalculatorSubstance substance;
  final DosageCalculation calculation;
  final DosageCalculatorUser user;

  const _SimpleDosageResultCard({
    required this.substance,
    required this.calculation,
    required this.user,
  });

  @override
  State<_SimpleDosageResultCard> createState() => _SimpleDosageResultCardState();
}

class _SimpleDosageResultCardState extends State<_SimpleDosageResultCard> {
  DosageIntensity _selectedIntensity = DosageIntensity.normal; // Start with normal/optimal dose

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);

    return Container(
      height: mediaQuery.size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(context, isDark),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSubstanceInfo(context, isDark),
                  const SizedBox(height: 24),
                  _buildUserInfo(context, isDark),
                  const SizedBox(height: 24),
                  _buildDosageSelection(context, isDark),
                  const SizedBox(height: 24),
                  _buildSelectedDosageInfo(context, isDark),
                  const SizedBox(height: 24),
                  _buildSafetyWarnings(context, isDark),
                  const SizedBox(height: 24),
                  _buildActionButtons(context, isDark),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
              : [Colors.indigo, Colors.purple],
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calculate_rounded,
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
                onPressed: () => Navigator.of(context).pop(),
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.science_rounded,
              color: Colors.indigo,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.substance.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(height: 4),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
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
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Icon(Icons.monitor_weight_rounded, color: Colors.indigo),
                    const SizedBox(height: 4),
                    Text(
                      widget.user.formattedWeight,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.indigo,
                      ),
                    ),
                    Text('Gewicht', style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Icon(Icons.analytics_rounded, color: Colors.green),
                    const SizedBox(height: 4),
                    Text(
                      widget.user.formattedBmi,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                    Text('BMI', style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Icon(Icons.person_rounded, color: Colors.cyan),
                    const SizedBox(height: 4),
                    Text(
                      widget.user.formattedAge,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.cyan,
                      ),
                    ),
                    Text('Alter', style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ],
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
        const SizedBox(height: 16),
        Row(
          children: DosageIntensity.values.map((intensity) {
            final isSelected = intensity == _selectedIntensity;
            final color = _getDosageColor(intensity);
            final dose = _getDoseForIntensity(intensity);

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIntensity = intensity;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? color : Colors.grey,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _getDosageIcon(intensity),
                          color: isSelected ? color : Colors.grey,
                          size: 24,
                        ),
                        const SizedBox(height: 8),
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
                            color: isSelected ? color : Colors.grey,
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

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              _getDosageIcon(_selectedIntensity),
              color: color,
              size: 32,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Optimale Dosis',
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
                const SizedBox(height: 8),
                // Enhanced duration display
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      color: Colors.white,
                      size: 16,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 2,
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.substance.durationWithIcon,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.7),
                              blurRadius: 2,
                              offset: const Offset(1, 1),
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyWarnings(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
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
                color: Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Sicherheitshinweise',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.substance.safetyNotes,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Text(
            '• Beginnen Sie immer mit der niedrigsten Dosis\n• Warten Sie die volle Wirkdauer ab\n• Kombinieren Sie niemals verschiedene Substanzen\n• Bei Problemen sofort medizinische Hilfe suchen',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
            ),
          ),
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
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Diese Funktion ist in der eigenständigen Dosisrechner-Version nicht verfügbar'),
                ),
              );
            },
            icon: const Icon(Icons.save_rounded),
            label: const Text('Als Eintrag speichern'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
            label: const Text('Schließen'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  double _getDoseForIntensity(DosageIntensity intensity) {
    double baseDose;
    switch (intensity) {
      case DosageIntensity.light:
        baseDose = widget.calculation.lightDose;
        break;
      case DosageIntensity.normal:
        baseDose = widget.calculation.normalDose;
        break;
      case DosageIntensity.strong:
        baseDose = widget.calculation.strongDose;
        break;
    }
    
    // Apply user's dosage strategy (e.g., -20% for optimal)
    return widget.user.getRecommendedDose(baseDose);
  }

  Color _getDosageColor(DosageIntensity intensity) {
    switch (intensity) {
      case DosageIntensity.light:
        return Colors.green;
      case DosageIntensity.normal:
        return Colors.orange;
      case DosageIntensity.strong:
        return Colors.red;
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
}
