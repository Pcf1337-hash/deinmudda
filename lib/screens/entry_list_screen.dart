import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../models/entry.dart';
import '../utils/service_locator.dart';
import '../use_cases/entry_use_cases.dart';
import '../widgets/glass_card.dart';
import '../widgets/animated_entry_card.dart';
import '../widgets/modern_fab.dart';
import 'add_entry_screen.dart';
import 'edit_entry_screen.dart';
import '../theme/design_tokens.dart';
import '../theme/spacing.dart';

enum SortOption {
  dateNewest,
  dateOldest,
  substanceName,
  dosageHighest,
  dosageLowest,
  costHighest,
  costLowest,
}

enum FilterOption {
  all,
  today,
  thisWeek,
  thisMonth,
  withCost,
  withNotes,
}

class EntryListScreen extends StatefulWidget {
  const EntryListScreen({super.key});

  @override
  State<EntryListScreen> createState() => _EntryListScreenState();
}

class _EntryListScreenState extends State<EntryListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  
  List<Entry> _allEntries = [];
  List<Entry> _filteredEntries = [];
  bool _isLoading = true;
  bool _isSearching = false;
  String? _errorMessage;
  
  SortOption _currentSort = SortOption.dateNewest;
  FilterOption _currentFilter = FilterOption.all;
  String _searchQuery = '';

  // Use Cases (injected via ServiceLocator)
  late final GetEntriesUseCase _getEntriesUseCase;
  late final DeleteEntryUseCase _deleteEntryUseCase;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _loadEntries();
    _searchController.addListener(_onSearchChanged);
  }

  /// Initialize use cases from ServiceLocator
  void _initializeServices() {
    try {
      _getEntriesUseCase = ServiceLocator.get<GetEntriesUseCase>();
      _deleteEntryUseCase = ServiceLocator.get<DeleteEntryUseCase>();
    } catch (e) {
      throw StateError('Failed to initialize EntryListScreen services: $e');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _applyFiltersAndSort();
    });
  }

  Future<void> _loadEntries() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final entries = await _getEntriesUseCase.getAllEntries();
      setState(() {
        _allEntries = entries;
        _applyFiltersAndSort();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Fehler beim Laden der Einträge: $e';
        _isLoading = false;
      });
    }
  }

  void _applyFiltersAndSort() {
    List<Entry> filtered = List.from(_allEntries);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((entry) {
        return entry.substanceName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               (entry.notes?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      }).toList();
    }

    // Apply date/content filters
    final now = DateTime.now();
    switch (_currentFilter) {
      case FilterOption.today:
        filtered = filtered.where((entry) {
          return entry.dateTime.year == now.year &&
                 entry.dateTime.month == now.month &&
                 entry.dateTime.day == now.day;
        }).toList();
        break;
      case FilterOption.thisWeek:
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        filtered = filtered.where((entry) {
          return entry.dateTime.isAfter(weekStart);
        }).toList();
        break;
      case FilterOption.thisMonth:
        filtered = filtered.where((entry) {
          return entry.dateTime.year == now.year &&
                 entry.dateTime.month == now.month;
        }).toList();
        break;
      case FilterOption.withCost:
        filtered = filtered.where((entry) => entry.cost > 0).toList();
        break;
      case FilterOption.withNotes:
        filtered = filtered.where((entry) => entry.notes != null && entry.notes!.isNotEmpty).toList();
        break;
      case FilterOption.all:
        break;
    }

    // Apply sorting
    switch (_currentSort) {
      case SortOption.dateNewest:
        filtered.sort((a, b) => b.dateTime.compareTo(a.dateTime));
        break;
      case SortOption.dateOldest:
        filtered.sort((a, b) => a.dateTime.compareTo(b.dateTime));
        break;
      case SortOption.substanceName:
        filtered.sort((a, b) => a.substanceName.compareTo(b.substanceName));
        break;
      case SortOption.dosageHighest:
        filtered.sort((a, b) => b.dosage.compareTo(a.dosage));
        break;
      case SortOption.dosageLowest:
        filtered.sort((a, b) => a.dosage.compareTo(b.dosage));
        break;
      case SortOption.costHighest:
        filtered.sort((a, b) => b.cost.compareTo(a.cost));
        break;
      case SortOption.costLowest:
        filtered.sort((a, b) => a.cost.compareTo(b.cost));
        break;
    }

    setState(() {
      _filteredEntries = filtered;
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
                _buildSearchBar(context, isDark),
                Spacing.verticalSpaceMd,
                _buildFilterAndSortRow(context, isDark),
                Spacing.verticalSpaceMd,
                if (_errorMessage != null) ...[
                  _buildErrorCard(context, isDark),
                  Spacing.verticalSpaceMd,
                ],
                _buildEntriesList(context, isDark),
                const SizedBox(height: 120), // Bottom padding
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildAddButton(context, isDark),
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Alle Einträge',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (_filteredEntries.isNotEmpty)
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
                            '${_filteredEntries.length}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
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

  Widget _buildSearchBar(BuildContext context, bool isDark) {
    return GlassCard(
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Einträge durchsuchen...',
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
    ).slideY(
      begin: -0.3,
      end: 0,
      duration: DesignTokens.animationMedium,
      curve: DesignTokens.curveEaseOut,
    );
  }

  Widget _buildFilterAndSortRow(BuildContext context, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: GlassCard(
            onTap: () => _showFilterDialog(context),
            child: Padding(
              padding: Spacing.paddingMd,
              child: Row(
                children: [
                  Icon(
                    Icons.filter_list_rounded,
                    color: DesignTokens.accentCyan,
                    size: Spacing.iconMd,
                  ),
                  Spacing.horizontalSpaceSm,
                  Expanded(
                    child: Text(
                      _getFilterText(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down_rounded,
                    color: Theme.of(context).iconTheme.color?.withOpacity(0.7),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(
            duration: DesignTokens.animationMedium,
            delay: const Duration(milliseconds: 400),
          ).slideY(
            begin: -0.3,
            end: 0,
            duration: DesignTokens.animationMedium,
            curve: DesignTokens.curveEaseOut,
          ),
        ),
        Spacing.horizontalSpaceMd,
        Expanded(
          child: GlassCard(
            onTap: () => _showSortDialog(context),
            child: Padding(
              padding: Spacing.paddingMd,
              child: Row(
                children: [
                  Icon(
                    Icons.sort_rounded,
                    color: DesignTokens.accentEmerald,
                    size: Spacing.iconMd,
                  ),
                  Spacing.horizontalSpaceSm,
                  Expanded(
                    child: Text(
                      _getSortText(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down_rounded,
                    color: Theme.of(context).iconTheme.color?.withOpacity(0.7),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(
            duration: DesignTokens.animationMedium,
            delay: const Duration(milliseconds: 500),
          ).slideY(
            begin: -0.3,
            end: 0,
            duration: DesignTokens.animationMedium,
            curve: DesignTokens.curveEaseOut,
          ),
        ),
      ],
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fehler beim Laden',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: DesignTokens.errorRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Spacing.verticalSpaceXs,
                Text(
                  _errorMessage!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _loadEntries,
            icon: const Icon(Icons.refresh_rounded),
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

  Widget _buildEntriesList(BuildContext context, bool isDark) {
    if (_isLoading) {
      return _buildLoadingList();
    }

    if (_filteredEntries.isEmpty) {
      return _buildEmptyState(context, isDark);
    }

    return Column(
      children: _filteredEntries.asMap().entries.map((entry) {
        final index = entry.key;
        final entryData = entry.value;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: Spacing.sm),
          child: AnimatedEntryCard(
            entry: entryData,
            onTap: () => _navigateToEditEntry(entryData),
            onDelete: () => _deleteEntry(entryData),
          ).animate().fadeIn(
            duration: DesignTokens.animationMedium,
            delay: Duration(milliseconds: 600 + (index * 50)),
          ).slideY(
            begin: 0.3,
            end: 0,
            duration: DesignTokens.animationMedium,
            curve: DesignTokens.curveEaseOut,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLoadingList() {
    return Column(
      children: List.generate(5, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: Spacing.sm),
          child: const EntryCardSkeleton(),
        );
      }),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    String title;
    String subtitle;
    IconData icon;

    if (_searchQuery.isNotEmpty) {
      title = 'Keine Ergebnisse';
      subtitle = 'Keine Einträge für "$_searchQuery" gefunden';
      icon = Icons.search_off_rounded;
    } else if (_currentFilter != FilterOption.all) {
      title = 'Keine gefilterten Einträge';
      subtitle = 'Keine Einträge für den gewählten Filter gefunden';
      icon = Icons.filter_list_off_rounded;
    } else {
      title = 'Noch keine Einträge';
      subtitle = 'Fügen Sie Ihren ersten Eintrag hinzu';
      icon = Icons.note_add_outlined;
    }

    return GlassEmptyState(
      title: title,
      subtitle: subtitle,
      icon: icon,
      actionText: _searchQuery.isEmpty && _currentFilter == FilterOption.all ? 'Eintrag hinzufügen' : null,
      onAction: _searchQuery.isEmpty && _currentFilter == FilterOption.all ? () => _navigateToAddEntry() : null,
    ).animate().fadeIn(
      duration: DesignTokens.animationMedium,
      delay: const Duration(milliseconds: 600),
    ).slideY(
      begin: 0.3,
      end: 0,
      duration: DesignTokens.animationMedium,
      curve: DesignTokens.curveEaseOut,
    );
  }

  Widget _buildAddButton(BuildContext context, bool isDark) {
    return ModernFAB(
      onPressed: _navigateToAddEntry,
      icon: Icons.add_rounded,
      label: 'Eintrag',
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

  String _getFilterText() {
    switch (_currentFilter) {
      case FilterOption.all:
        return 'Alle';
      case FilterOption.today:
        return 'Heute';
      case FilterOption.thisWeek:
        return 'Diese Woche';
      case FilterOption.thisMonth:
        return 'Dieser Monat';
      case FilterOption.withCost:
        return 'Mit Kosten';
      case FilterOption.withNotes:
        return 'Mit Notizen';
    }
  }

  String _getSortText() {
    switch (_currentSort) {
      case SortOption.dateNewest:
        return 'Neueste zuerst';
      case SortOption.dateOldest:
        return 'Älteste zuerst';
      case SortOption.substanceName:
        return 'Substanz A-Z';
      case SortOption.dosageHighest:
        return 'Höchste Dosis';
      case SortOption.dosageLowest:
        return 'Niedrigste Dosis';
      case SortOption.costHighest:
        return 'Höchste Kosten';
      case SortOption.costLowest:
        return 'Niedrigste Kosten';
    }
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: FilterOption.values.map((option) {
            return RadioListTile<FilterOption>(
              title: Text(_getFilterOptionText(option)),
              value: option,
              groupValue: _currentFilter,
              onChanged: (value) {
                setState(() {
                  _currentFilter = value!;
                  _applyFiltersAndSort();
                });
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showSortDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sortierung'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: SortOption.values.map((option) {
            return RadioListTile<SortOption>(
              title: Text(_getSortOptionText(option)),
              value: option,
              groupValue: _currentSort,
              onChanged: (value) {
                setState(() {
                  _currentSort = value!;
                  _applyFiltersAndSort();
                });
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getFilterOptionText(FilterOption option) {
    switch (option) {
      case FilterOption.all:
        return 'Alle Einträge';
      case FilterOption.today:
        return 'Heute';
      case FilterOption.thisWeek:
        return 'Diese Woche';
      case FilterOption.thisMonth:
        return 'Dieser Monat';
      case FilterOption.withCost:
        return 'Mit Kosten';
      case FilterOption.withNotes:
        return 'Mit Notizen';
    }
  }

  String _getSortOptionText(SortOption option) {
    switch (option) {
      case SortOption.dateNewest:
        return 'Neueste zuerst';
      case SortOption.dateOldest:
        return 'Älteste zuerst';
      case SortOption.substanceName:
        return 'Substanz A-Z';
      case SortOption.dosageHighest:
        return 'Höchste Dosis zuerst';
      case SortOption.dosageLowest:
        return 'Niedrigste Dosis zuerst';
      case SortOption.costHighest:
        return 'Höchste Kosten zuerst';
      case SortOption.costLowest:
        return 'Niedrigste Kosten zuerst';
    }
  }

  Future<void> _navigateToEditEntry(Entry entry) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditEntryScreen(entry: entry),
      ),
    );

    if (result == true) {
      _loadEntries();
    }
  }

  Future<void> _navigateToAddEntry() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddEntryScreen(),
      ),
    );

    if (result == true) {
      _loadEntries();
    }
  }

  Future<void> _deleteEntry(Entry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eintrag löschen'),
        content: Text('Möchten Sie den Eintrag "${entry.substanceName}" wirklich löschen?'),
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
      await _deleteEntryUseCase.execute(entry.id);
      _loadEntries();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Eintrag erfolgreich gelöscht'),
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
