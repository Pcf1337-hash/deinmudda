import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../models/entry.dart';
import '../../services/entry_service.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/animated_entry_card.dart';
import '../../theme/design_tokens.dart';
import '../../theme/spacing.dart';
import '../edit_entry_screen.dart';
import '../add_entry_screen.dart';

class DayDetailScreen extends StatefulWidget {
  final DateTime date;

  const DayDetailScreen({
    super.key,
    required this.date,
  });

  @override
  State<DayDetailScreen> createState() => _DayDetailScreenState();
}

class _DayDetailScreenState extends State<DayDetailScreen> {
  final EntryService _entryService = EntryService();
  
  List<Entry> _entries = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final startOfDay = DateTime(
        widget.date.year,
        widget.date.month,
        widget.date.day,
      );
      
      final endOfDay = DateTime(
        widget.date.year,
        widget.date.month,
        widget.date.day,
        23,
        59,
        59,
      );
      
      final entries = await _entryService.getEntriesByDateRange(startOfDay, endOfDay);
      
      // Sort by time
      entries.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      
      setState(() {
        _entries = entries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Fehler beim Laden der Einträge: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dateFormat = DateFormat('EEEE, d. MMMM yyyy', 'de_DE');

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, isDark, dateFormat),
          SliverPadding(
            padding: Spacing.paddingHorizontalMd,
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (_errorMessage != null) ...[
                  _buildErrorCard(context, isDark),
                  Spacing.verticalSpaceMd,
                ],
                _buildDaySummary(context, isDark),
                Spacing.verticalSpaceMd,
                _isLoading
                    ? _buildLoadingState()
                    : _entries.isEmpty
                        ? _buildEmptyState(context, isDark)
                        : _buildTimelineEntries(context, isDark),
                const SizedBox(height: 120), // Bottom padding
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildAddButton(context, isDark),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, bool isDark, DateFormat dateFormat) {
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
                    dateFormat.format(widget.date),
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

  Widget _buildDaySummary(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    
    // Calculate summary data
    final entryCount = _entries.length;
    final totalCost = _entries.fold<double>(
      0, (sum, entry) => sum + entry.cost,
    );
    final uniqueSubstances = _entries.map((e) => e.substanceName).toSet().length;
    
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tagesübersicht',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Spacing.verticalSpaceMd,
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  context,
                  'Einträge',
                  entryCount.toString(),
                  Icons.note_rounded,
                  DesignTokens.primaryIndigo,
                ),
              ),
              Spacing.horizontalSpaceMd,
              Expanded(
                child: _buildSummaryItem(
                  context,
                  'Kosten',
                  '${totalCost.toStringAsFixed(2).replaceAll('.', ',')}€',
                  Icons.euro_rounded,
                  DesignTokens.accentEmerald,
                ),
              ),
              Spacing.horizontalSpaceMd,
              Expanded(
                child: _buildSummaryItem(
                  context,
                  'Substanzen',
                  uniqueSubstances.toString(),
                  Icons.science_rounded,
                  DesignTokens.accentCyan,
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
      begin: 0.3,
      end: 0,
      duration: DesignTokens.animationMedium,
      curve: DesignTokens.curveEaseOut,
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Column(
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
    );
  }

  Widget _buildTimelineEntries(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('HH:mm', 'de_DE');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.timeline_rounded,
              color: DesignTokens.primaryIndigo,
              size: Spacing.iconMd,
            ),
            Spacing.horizontalSpaceSm,
            Text(
              'Zeitverlauf',
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
          itemCount: _entries.length,
          itemBuilder: (context, index) {
            final entry = _entries[index];
            final time = timeFormat.format(entry.dateTime);
            
            // Add time separator if this is the first entry or if the hour changed
            final showTimeSeparator = index == 0 || 
                entry.dateTime.hour != _entries[index - 1].dateTime.hour;
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showTimeSeparator) ...[
                  if (index > 0) Spacing.verticalSpaceMd,
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.sm,
                          vertical: Spacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: DesignTokens.accentCyan.withOpacity(0.1),
                          borderRadius: Spacing.borderRadiusSm,
                          border: Border.all(
                            color: DesignTokens.accentCyan.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              color: DesignTokens.accentCyan,
                              size: Spacing.iconSm,
                            ),
                            Spacing.horizontalSpaceXs,
                            Text(
                              time,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: DesignTokens.accentCyan,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Spacing.horizontalSpaceSm,
                      Expanded(
                        child: Container(
                          height: 1,
                          color: DesignTokens.accentCyan.withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),
                  Spacing.verticalSpaceSm,
                ],
                Padding(
                  padding: const EdgeInsets.only(
                    left: 24,
                    bottom: Spacing.sm,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 2,
                        height: 100, // Approximate height of the card
                        color: DesignTokens.accentCyan.withOpacity(0.3),
                      ),
                      Spacing.horizontalSpaceMd,
                      Expanded(
                        child: AnimatedEntryCard(
                          entry: entry,
                          onTap: () => _navigateToEditEntry(entry),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
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

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(Spacing.lg),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return GlassCard(
      child: Column(
        children: [
          Icon(
            Icons.event_busy_rounded,
            size: Spacing.iconXl,
            color: theme.iconTheme.color?.withOpacity(0.5),
          ),
          Spacing.verticalSpaceMd,
          Text(
            'Keine Einträge',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          Spacing.verticalSpaceXs,
          Text(
            'Keine Einträge für diesen Tag',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          Spacing.verticalSpaceMd,
          ElevatedButton.icon(
            onPressed: () => _navigateToAddEntry(),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Eintrag hinzufügen'),
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignTokens.primaryIndigo,
              foregroundColor: Colors.white,
            ),
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

  Widget _buildAddButton(BuildContext context, bool isDark) {
    return FloatingActionButton.extended(
      onPressed: () => _navigateToAddEntry(),
      icon: const Icon(Icons.add_rounded),
      label: const Text('Eintrag'),
      backgroundColor: DesignTokens.primaryIndigo,
      foregroundColor: Colors.white,
    ).animate().fadeIn(
      duration: DesignTokens.animationSlow,
      delay: const Duration(milliseconds: 500),
    ).scale(
      begin: const Offset(0.8, 0.8),
      end: const Offset(1.0, 1.0),
      duration: DesignTokens.animationSlow,
      curve: DesignTokens.curveBack,
    );
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
    // Create a DateTime for the selected date but with the current time
    final now = DateTime.now();
    final selectedDateTime = DateTime(
      widget.date.year,
      widget.date.month,
      widget.date.day,
      now.hour,
      now.minute,
    );
    
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddEntryScreen(),
      ),
    );

    if (result == true) {
      _loadEntries();
    }
  }
}