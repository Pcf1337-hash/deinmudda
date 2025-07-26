import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // fixed by FehlerbehebungAgent
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../models/entry.dart';
// Import substance.dart with a prefix to avoid conflicts
import '../models/substance.dart' as substance_model;
import '../services/entry_service.dart';
import '../services/substance_service.dart';
import '../utils/service_locator.dart';
import '../widgets/glass_card.dart';
import '../widgets/animated_entry_card.dart';
import '../theme/design_tokens.dart';
import '../theme/spacing.dart';
import 'edit_entry_screen.dart';

class AdvancedSearchScreen extends StatefulWidget {
  const AdvancedSearchScreen({super.key});

  @override
  State<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends State<AdvancedSearchScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  
  // Services
  late final EntryService _entryService;
  late final SubstanceService _substanceService;
  
  // Search state
  String _searchQuery = '';
  List<Entry> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;
  
  // Filter state
  DateTime? _startDate;
  DateTime? _endDate;
  List<substance_model.Substance> _substances = [];
  List<String> _selectedSubstanceIds = [];
  List<substance_model.SubstanceCategory> _selectedCategories = [];
  RangeValues _costRange = const RangeValues(0, 1000);
  double _maxCost = 1000;
  bool _onlyWithNotes = false;
  
  // Loading state
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _entryService = ServiceLocator.get<EntryService>();
    _substanceService = ServiceLocator.get<SubstanceService>();
    _searchController.addListener(_onSearchChanged);
    _loadSubstances();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  Future<void> _loadSubstances() async {
    try {
      final substances = await _substanceService.getAllSubstances();
      setState(() {
        _substances = substances;
      });
      
      // Get max cost from entries for the cost range slider
      final stats = await _entryService.getCostStatistics();
      if (stats.containsKey('maxCost')) {
        final maxCost = stats['maxCost'] as double;
        if (maxCost > 0) {
          setState(() {
            _maxCost = maxCost.ceilToDouble();
            _costRange = RangeValues(0, _maxCost);
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Fehler beim Laden der Substanzen: $e';
      });
    }
  }

  Future<void> _performSearch() async {
    if (_searchQuery.isEmpty && 
        _startDate == null && 
        _endDate == null && 
        _selectedSubstanceIds.isEmpty && 
        _selectedCategories.isEmpty && 
        _costRange.start == 0 && 
        _costRange.end == _maxCost &&
        !_onlyWithNotes) {
      setState(() {
        _searchResults = [];
        _hasSearched = true;
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    try {
      // Build search parameters
      final searchParams = <String, dynamic>{
        'query': _searchQuery,
      };
      
      if (_startDate != null) {
        searchParams['startDate'] = _startDate;
      }
      
      if (_endDate != null) {
        searchParams['endDate'] = _endDate;
      }
      
      if (_selectedSubstanceIds.isNotEmpty) {
        searchParams['substanceIds'] = _selectedSubstanceIds;
      }
      
      if (_selectedCategories.isNotEmpty) {
        searchParams['categories'] = _selectedCategories;
      }
      
      if (_costRange.start > 0 || _costRange.end < _maxCost) {
        searchParams['minCost'] = _costRange.start;
        searchParams['maxCost'] = _costRange.end;
      }
      
      if (_onlyWithNotes) {
        searchParams['onlyWithNotes'] = true;
      }
      
      // Perform search
      final results = await _entryService.advancedSearch(searchParams);
      
      setState(() {
        _searchResults = results;
        _hasSearched = true;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Fehler bei der Suche: $e';
        _isSearching = false;
      });
    }
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _startDate = null;
      _endDate = null;
      _selectedSubstanceIds = [];
      _selectedCategories = [];
      _costRange = RangeValues(0, _maxCost);
      _onlyWithNotes = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                _buildSearchBar(context, isDark),
                Spacing.verticalSpaceMd,
                _buildFilterSection(context, isDark),
                Spacing.verticalSpaceMd,
                _buildSearchResults(context, isDark),
                const SizedBox(height: 120), // Bottom padding
              ]),
            ),
          ),
        ],
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
                    'Erweiterte Suche',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ).animate().fadeIn(
                    duration: DesignTokens.animationSlow,
                    delay: const Duration(milliseconds: 200),
                  ).slideX(
                    begin: -0.3,
                    end: 0,
                    duration: DesignTokens.animationSlow,
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

  Widget _buildSearchBar(BuildContext context, bool isDark) {
    return GlassCard(
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Suche nach Substanzen, Notizen...',
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
            onSubmitted: (_) => _performSearch(),
          ),
          Spacing.verticalSpaceMd,
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _performSearch,
                  icon: const Icon(Icons.search_rounded),
                  label: const Text('Suchen'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignTokens.primaryIndigo,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              Spacing.horizontalSpaceMd,
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _resetFilters,
                  icon: const Icon(Icons.clear_all_rounded),
                  label: const Text('Zurücksetzen'),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(
      duration: DesignTokens.animationMedium,
      delay: const Duration(milliseconds: 300),
    ).slideY(
      begin: -0.3,
      end: 0,
      duration: DesignTokens.animationMedium,
      curve: DesignTokens.curveEaseOut,
    );
  }

  Widget _buildFilterSection(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.filter_list_rounded,
                color: DesignTokens.accentCyan,
                size: Spacing.iconMd,
              ),
              Spacing.horizontalSpaceSm,
              Text(
                'Filter',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Spacing.verticalSpaceMd,
          
          // Date range filter
          Text(
            'Zeitraum',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Spacing.verticalSpaceSm,
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectDate(context, isStartDate: true),
                  child: Container(
                    padding: Spacing.paddingMd,
                    decoration: BoxDecoration(
                      color: isDark
                          ? DesignTokens.neutral800.withOpacity(0.3)
                          : DesignTokens.neutral100.withOpacity(0.5),
                      borderRadius: Spacing.borderRadiusMd,
                      border: Border.all(
                        color: isDark
                            ? DesignTokens.neutral700
                            : DesignTokens.neutral300,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          color: DesignTokens.accentCyan,
                          size: Spacing.iconSm,
                        ),
                        Spacing.horizontalSpaceSm,
                        Expanded(
                          child: Text(
                            _startDate != null
                                ? DateFormat('dd.MM.yyyy', 'de_DE').format(_startDate!)
                                : 'Von',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        if (_startDate != null)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _startDate = null;
                              });
                            },
                            child: Icon(
                              Icons.clear_rounded,
                              color: theme.iconTheme.color?.withOpacity(0.5),
                              size: Spacing.iconSm,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Spacing.horizontalSpaceMd,
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectDate(context, isStartDate: false),
                  child: Container(
                    padding: Spacing.paddingMd,
                    decoration: BoxDecoration(
                      color: isDark
                          ? DesignTokens.neutral800.withOpacity(0.3)
                          : DesignTokens.neutral100.withOpacity(0.5),
                      borderRadius: Spacing.borderRadiusMd,
                      border: Border.all(
                        color: isDark
                            ? DesignTokens.neutral700
                            : DesignTokens.neutral300,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          color: DesignTokens.accentCyan,
                          size: Spacing.iconSm,
                        ),
                        Spacing.horizontalSpaceSm,
                        Expanded(
                          child: Text(
                            _endDate != null
                                ? DateFormat('dd.MM.yyyy', 'de_DE').format(_endDate!)
                                : 'Bis',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        if (_endDate != null)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _endDate = null;
                              });
                            },
                            child: Icon(
                              Icons.clear_rounded,
                              color: theme.iconTheme.color?.withOpacity(0.5),
                              size: Spacing.iconSm,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          Spacing.verticalSpaceMd,
          
          // Substance filter
          Text(
            'Substanzen',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Spacing.verticalSpaceSm,
          Wrap(
            spacing: Spacing.sm,
            runSpacing: Spacing.sm,
            children: _substances.map((substance) {
              final isSelected = _selectedSubstanceIds.contains(substance.id);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedSubstanceIds.remove(substance.id);
                    } else {
                      _selectedSubstanceIds.add(substance.id);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.sm,
                    vertical: Spacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? DesignTokens.primaryIndigo.withOpacity(0.1)
                        : isDark
                            ? DesignTokens.neutral800.withOpacity(0.3)
                            : DesignTokens.neutral100.withOpacity(0.5),
                    borderRadius: Spacing.borderRadiusSm,
                    border: Border.all(
                      color: isSelected
                          ? DesignTokens.primaryIndigo
                          : isDark
                              ? DesignTokens.neutral700
                              : DesignTokens.neutral300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    substance.name,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? DesignTokens.primaryIndigo : null,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          
          Spacing.verticalSpaceMd,
          
          // Category filter
          Text(
            'Kategorien',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Spacing.verticalSpaceSm,
          Wrap(
            spacing: Spacing.sm,
            runSpacing: Spacing.sm,
            children: substance_model.SubstanceCategory.values.map((category) {
              final isSelected = _selectedCategories.contains(category);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedCategories.remove(category);
                    } else {
                      _selectedCategories.add(category);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.sm,
                    vertical: Spacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? DesignTokens.accentCyan.withOpacity(0.1)
                        : isDark
                            ? DesignTokens.neutral800.withOpacity(0.3)
                            : DesignTokens.neutral100.withOpacity(0.5),
                    borderRadius: Spacing.borderRadiusSm,
                    border: Border.all(
                      color: isSelected
                          ? DesignTokens.accentCyan
                          : isDark
                              ? DesignTokens.neutral700
                              : DesignTokens.neutral300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    _getCategoryDisplayName(category),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? DesignTokens.accentCyan : null,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          
          Spacing.verticalSpaceMd,
          
          // Cost range filter
          Row(
            children: [
              Text(
                'Kosten',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Spacing.horizontalSpaceSm,
              Text(
                '${_costRange.start.toStringAsFixed(0)}€ - ${_costRange.end.toStringAsFixed(0)}€',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: DesignTokens.accentEmerald,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Spacing.verticalSpaceXs,
          RangeSlider(
            values: _costRange,
            min: 0,
            max: _maxCost,
            divisions: _maxCost > 100 ? 100 : _maxCost.toInt(),
            labels: RangeLabels(
              '${_costRange.start.toStringAsFixed(0)}€',
              '${_costRange.end.toStringAsFixed(0)}€',
            ),
            activeColor: DesignTokens.accentEmerald,
            inactiveColor: DesignTokens.accentEmerald.withOpacity(0.2),
            onChanged: (values) {
              setState(() {
                _costRange = values;
              });
            },
          ),
          
          Spacing.verticalSpaceMd,
          
          // Notes filter
          CheckboxListTile(
            value: _onlyWithNotes,
            onChanged: (value) {
              setState(() {
                _onlyWithNotes = value ?? false;
              });
            },
            title: Text(
              'Nur Einträge mit Notizen',
              style: theme.textTheme.bodyMedium,
            ),
            activeColor: DesignTokens.primaryIndigo,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
          ),
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
    );
  }

  Widget _buildSearchResults(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    if (_isSearching) {
      return _buildLoadingState();
    }

    if (!_hasSearched) {
      return GlassCard(
        child: Column(
          children: [
            Icon(
              Icons.search_rounded,
              size: Spacing.iconXl,
              color: theme.iconTheme.color?.withOpacity(0.5),
            ),
            Spacing.verticalSpaceMd,
            Text(
              'Suche starten',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            Spacing.verticalSpaceXs,
            Text(
              'Geben Sie Suchbegriffe ein und/oder wählen Sie Filter aus, um die Suche zu starten.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ).animate().fadeIn(
        duration: DesignTokens.animationMedium,
        delay: const Duration(milliseconds: 500),
      ).slideY(
        begin: 0.3,
        end: 0,
        duration: DesignTokens.animationMedium,
        curve: DesignTokens.curveEaseOut,
      );
    }

    if (_searchResults.isEmpty) {
      return GlassCard(
        child: Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              size: Spacing.iconXl,
              color: theme.iconTheme.color?.withOpacity(0.5),
            ),
            Spacing.verticalSpaceMd,
            Text(
              'Keine Ergebnisse',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            Spacing.verticalSpaceXs,
            Text(
              'Keine Einträge gefunden, die den Suchkriterien entsprechen. Versuchen Sie es mit anderen Suchbegriffen oder Filtern.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ).animate().fadeIn(
        duration: DesignTokens.animationMedium,
        delay: const Duration(milliseconds: 500),
      ).slideY(
        begin: 0.3,
        end: 0,
        duration: DesignTokens.animationMedium,
        curve: DesignTokens.curveEaseOut,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.search_rounded,
              color: DesignTokens.primaryIndigo,
              size: Spacing.iconMd,
            ),
            Spacing.horizontalSpaceSm,
            Text(
              'Suchergebnisse (${_searchResults.length})',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Spacing.verticalSpaceMd,
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _searchResults.length,
          itemBuilder: (context, index) {
            final entry = _searchResults[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: Spacing.sm),
              child: AnimatedEntryCard(
                entry: entry,
                onTap: () => _navigateToEditEntry(entry),
              ),
            );
          },
        ),
      ],
    ).animate().fadeIn(
      duration: DesignTokens.animationMedium,
      delay: const Duration(milliseconds: 500),
    ).slideY(
      begin: 0.3,
      end: 0,
      duration: DesignTokens.animationMedium,
      curve: DesignTokens.curveEaseOut,
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: Spacing.sm),
          child: const EntryCardSkeleton(),
        );
      }),
    );
  }

  Future<void> _selectDate(BuildContext context, {required bool isStartDate}) async {
    final initialDate = isStartDate ? _startDate : _endDate;
    final now = DateTime.now();
    
    try {
      final date = await showDatePicker(
        context: context,
        initialDate: initialDate ?? now,
        firstDate: DateTime(2020),
        lastDate: now.add(const Duration(days: 1)),
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
          if (isStartDate) {
            _startDate = date;
            // If end date is before start date, update end date
            if (_endDate != null && _endDate!.isBefore(_startDate!)) {
              _endDate = _startDate;
            }
          } else {
            _endDate = date;
            // If start date is after end date, update start date
            if (_startDate != null && _startDate!.isAfter(_endDate!)) {
              _startDate = _endDate;
            }
          }
        });
      }
    } catch (e) {
      // Handle any navigation errors gracefully
      if (kDebugMode) {
        print('Error in date picker: $e');
      }
    }
  }

  Future<void> _navigateToEditEntry(Entry entry) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditEntryScreen(entry: entry),
      ),
    );

    if (result == true) {
      _performSearch();
    }
  }

  String _getCategoryDisplayName(substance_model.SubstanceCategory category) {
    switch (category) {
      case substance_model.SubstanceCategory.medication:
        return 'Medikament';
      case substance_model.SubstanceCategory.stimulant:
        return 'Stimulans';
      case substance_model.SubstanceCategory.depressant:
        return 'Depressivum';
      case substance_model.SubstanceCategory.supplement:
        return 'Nahrungsergänzung';
      case substance_model.SubstanceCategory.recreational:
        return 'Freizeitsubstanz';
      case substance_model.SubstanceCategory.other:
        return 'Sonstiges';
    }
  }
}