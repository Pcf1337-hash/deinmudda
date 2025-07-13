import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/entry.dart';
import '../services/entry_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/animated_entry_card.dart';
import '../widgets/reflective_app_bar_logo.dart';
import '../theme/design_tokens.dart';
import '../theme/spacing.dart';
import 'edit_entry_screen.dart';

enum CalendarViewType {
  month,
  week,
  day,
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final _scrollController = ScrollController();
  final EntryService _entryService = EntryService();
  
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  CalendarViewType _currentView = CalendarViewType.month;
  
  Map<DateTime, List<Entry>> _groupedEntries = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadEntries() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final entries = await _entryService.getAllEntries();
      final grouped = <DateTime, List<Entry>>{};
      
      for (final entry in entries) {
        final date = DateTime(
          entry.dateTime.year,
          entry.dateTime.month,
          entry.dateTime.day,
        );
        
        if (!grouped.containsKey(date)) {
          grouped[date] = [];
        }
        
        grouped[date]!.add(entry);
      }
      
      setState(() {
        _groupedEntries = grouped;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Fehler beim Laden der Einträge: $e';
        _isLoading = false;
      });
    }
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      
      // If selecting a date outside the current month/week, update focused date
      if (_currentView == CalendarViewType.month && 
          (_selectedDate.month != _focusedDate.month || _selectedDate.year != _focusedDate.year)) {
        _focusedDate = date;
      } else if (_currentView == CalendarViewType.week) {
        final weekStart = _getWeekStart(_focusedDate);
        final weekEnd = weekStart.add(const Duration(days: 6));
        
        if (_selectedDate.isBefore(weekStart) || _selectedDate.isAfter(weekEnd)) {
          _focusedDate = date;
        }
      }
    });
  }

  void _onViewChanged(CalendarViewType viewType) {
    setState(() {
      _currentView = viewType;
    });
  }

  void _previousPeriod() {
    setState(() {
      switch (_currentView) {
        case CalendarViewType.month:
          _focusedDate = DateTime(
            _focusedDate.year,
            _focusedDate.month - 1,
            _focusedDate.day,
          );
          break;
        case CalendarViewType.week:
          _focusedDate = _focusedDate.subtract(const Duration(days: 7));
          break;
        case CalendarViewType.day:
          _focusedDate = _focusedDate.subtract(const Duration(days: 1));
          _selectedDate = _focusedDate;
          break;
      }
    });
  }

  void _nextPeriod() {
    setState(() {
      switch (_currentView) {
        case CalendarViewType.month:
          _focusedDate = DateTime(
            _focusedDate.year,
            _focusedDate.month + 1,
            _focusedDate.day,
          );
          break;
        case CalendarViewType.week:
          _focusedDate = _focusedDate.add(const Duration(days: 7));
          break;
        case CalendarViewType.day:
          _focusedDate = _focusedDate.add(const Duration(days: 1));
          _selectedDate = _focusedDate;
          break;
      }
    });
  }

  void _goToToday() {
    setState(() {
      _focusedDate = DateTime.now();
      _selectedDate = DateTime.now();
    });
  }

  DateTime _getWeekStart(DateTime date) {
    // Get the first day of the week (Monday)
    return date.subtract(Duration(days: date.weekday - 1));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Column(
        children: [
          _buildAppBar(context, isDark),
          _buildCalendarControls(context, isDark),
          _buildViewSelector(context, isDark),
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _errorMessage != null
                    ? _buildErrorState(context, isDark)
                    : _buildCalendarContent(context, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // Center the content
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const ReflectiveAppBarLogo().animate().fadeIn(
                duration: DesignTokens.animationSlow,
                delay: const Duration(milliseconds: 200),
              ).slideY(
                begin: -0.3,
                end: 0,
                duration: DesignTokens.animationSlow,
                curve: DesignTokens.curveEaseOut,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarControls(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final monthFormat = DateFormat('MMMM yyyy', 'de_DE');
    final weekFormat = DateFormat('d. MMMM', 'de_DE');
    final dayFormat = DateFormat('EEEE, d. MMMM yyyy', 'de_DE');
    
    String periodText;
    switch (_currentView) {
      case CalendarViewType.month:
        periodText = monthFormat.format(_focusedDate);
        break;
      case CalendarViewType.week:
        final weekStart = _getWeekStart(_focusedDate);
        final weekEnd = weekStart.add(const Duration(days: 6));
        periodText = '${weekFormat.format(weekStart)} - ${weekFormat.format(weekEnd)}';
        break;
      case CalendarViewType.day:
        periodText = dayFormat.format(_focusedDate);
        break;
    }

    return GlassCard(
      margin: Spacing.paddingHorizontalMd,
      child: Row(
        children: [
          IconButton(
            onPressed: _previousPeriod,
            icon: const Icon(Icons.chevron_left_rounded),
            tooltip: 'Vorheriger Zeitraum',
          ),
          Expanded(
            child: GestureDetector(
              onTap: _goToToday,
              child: Column(
                children: [
                  Text(
                    periodText,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Tippen für Heute',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: _nextPeriod,
            icon: const Icon(Icons.chevron_right_rounded),
            tooltip: 'Nächster Zeitraum',
          ),
        ],
      ),
    ).animate().fadeIn(
      duration: DesignTokens.animationMedium,
      delay: const Duration(milliseconds: 300),
    );
  }

  Widget _buildViewSelector(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.md,
        Spacing.md,
        Spacing.md,
        0,
      ),
      child: Row(
        children: [
          _buildViewButton(
            context,
            'Monat',
            CalendarViewType.month,
            Icons.calendar_view_month_rounded,
          ),
          Spacing.horizontalSpaceSm,
          _buildViewButton(
            context,
            'Woche',
            CalendarViewType.week,
            Icons.calendar_view_week_rounded,
          ),
          Spacing.horizontalSpaceSm,
          _buildViewButton(
            context,
            'Tag',
            CalendarViewType.day,
            Icons.calendar_view_day_rounded,
          ),
        ],
      ),
    ).animate().fadeIn(
      duration: DesignTokens.animationMedium,
      delay: const Duration(milliseconds: 400),
    );
  }

  Widget _buildViewButton(
    BuildContext context,
    String label,
    CalendarViewType viewType,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = _currentView == viewType;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onViewChanged(viewType),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: Spacing.sm,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? DesignTokens.primaryIndigo.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: Spacing.borderRadiusMd,
            border: Border.all(
              color: isSelected
                  ? DesignTokens.primaryIndigo
                  : (isDark
                      ? DesignTokens.glassBorderDark
                      : DesignTokens.glassBorderLight),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? DesignTokens.primaryIndigo
                    : theme.iconTheme.color?.withOpacity(0.7),
                size: Spacing.iconSm,
              ),
              Spacing.verticalSpaceXs,
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? DesignTokens.primaryIndigo : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarContent(BuildContext context, bool isDark) {
    switch (_currentView) {
      case CalendarViewType.month:
        return _buildMonthView(context, isDark);
      case CalendarViewType.week:
        return _buildWeekView(context, isDark);
      case CalendarViewType.day:
        return _buildDayView(context, isDark);
    }
  }

  Widget _buildMonthView(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final daysInMonth = DateTime(
      _focusedDate.year,
      _focusedDate.month + 1,
      0,
    ).day;
    
    final firstDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month, 1);
    final firstWeekdayOfMonth = firstDayOfMonth.weekday;
    
    // Calculate days from previous month to show
    final daysFromPreviousMonth = firstWeekdayOfMonth - 1;
    
    // Calculate total days to show (including days from previous and next month)
    final totalDays = daysFromPreviousMonth + daysInMonth;
    final totalWeeks = (totalDays / 7).ceil();
    
    return Column(
      children: [
        // Weekday headers
        Padding(
          padding: Spacing.paddingHorizontalMd,
          child: Row(
            children: [
              for (int i = 0; i < 7; i++)
                Expanded(
                  child: Center(
                    child: Text(
                      _getWeekdayName(i + 1),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: i >= 5 // Saturday and Sunday
                            ? DesignTokens.accentCyan
                            : theme.textTheme.bodySmall?.color,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        Spacing.verticalSpaceSm,
        
        // Calendar grid
        Expanded(
          child: GridView.builder(
            padding: Spacing.paddingHorizontalMd,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: totalWeeks * 7,
            itemBuilder: (context, index) {
              // Calculate the day to display
              final dayOffset = index - daysFromPreviousMonth;
              final day = dayOffset + 1;
              
              DateTime date;
              bool isCurrentMonth = true;
              
              if (dayOffset < 0) {
                // Previous month
                final prevMonth = DateTime(_focusedDate.year, _focusedDate.month - 1, 1);
                final daysInPrevMonth = DateTime(_focusedDate.year, _focusedDate.month, 0).day;
                date = DateTime(prevMonth.year, prevMonth.month, daysInPrevMonth + dayOffset + 1);
                isCurrentMonth = false;
              } else if (dayOffset >= daysInMonth) {
                // Next month
                final nextMonth = DateTime(_focusedDate.year, _focusedDate.month + 1, 1);
                date = DateTime(nextMonth.year, nextMonth.month, dayOffset - daysInMonth + 1);
                isCurrentMonth = false;
              } else {
                // Current month
                date = DateTime(_focusedDate.year, _focusedDate.month, day);
              }
              
              final isToday = _isToday(date);
              final isSelected = _isSameDay(date, _selectedDate);
              final hasEntries = _groupedEntries.containsKey(date) && _groupedEntries[date]!.isNotEmpty;
              final entryCount = hasEntries ? _groupedEntries[date]!.length : 0;
              
              return _buildCalendarDay(
                context,
                date,
                isCurrentMonth,
                isToday,
                isSelected,
                hasEntries,
                entryCount,
              );
            },
          ),
        ),
        
        // Selected day entries
        if (_groupedEntries.containsKey(_selectedDate) && _groupedEntries[_selectedDate]!.isNotEmpty)
          _buildSelectedDayEntries(context, isDark),
      ],
    ).animate().fadeIn(
      duration: DesignTokens.animationMedium,
      delay: const Duration(milliseconds: 500),
    );
  }

  Widget _buildWeekView(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final weekStart = _getWeekStart(_focusedDate);
    
    return Column(
      children: [
        // Week days
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: Spacing.paddingHorizontalMd,
            itemCount: 7,
            itemBuilder: (context, index) {
              final date = weekStart.add(Duration(days: index));
              final isToday = _isToday(date);
              final isSelected = _isSameDay(date, _selectedDate);
              final hasEntries = _groupedEntries.containsKey(date) && _groupedEntries[date]!.isNotEmpty;
              final entryCount = hasEntries ? _groupedEntries[date]!.length : 0;
              
              return Container(
                width: 60,
                margin: const EdgeInsets.only(right: Spacing.sm),
                child: GestureDetector(
                  onTap: () => _onDateSelected(date),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? DesignTokens.primaryIndigo.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: Spacing.borderRadiusMd,
                      border: Border.all(
                        color: isSelected
                            ? DesignTokens.primaryIndigo
                            : isToday
                                ? DesignTokens.accentCyan
                                : (isDark
                                    ? DesignTokens.glassBorderDark
                                    : DesignTokens.glassBorderLight),
                        width: isSelected || isToday ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getWeekdayName(date.weekday, short: true),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isSelected
                                ? DesignTokens.primaryIndigo
                                : date.weekday >= 6
                                    ? DesignTokens.accentCyan
                                    : theme.textTheme.bodySmall?.color,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          date.day.toString(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? DesignTokens.primaryIndigo
                                : isToday
                                    ? DesignTokens.accentCyan
                                    : null,
                          ),
                        ),
                        if (hasEntries)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Spacing.xs,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? DesignTokens.primaryIndigo.withOpacity(0.2)
                                  : DesignTokens.accentEmerald.withOpacity(0.2),
                              borderRadius: Spacing.borderRadiusSm,
                            ),
                            child: Text(
                              entryCount.toString(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? DesignTokens.primaryIndigo
                                    : DesignTokens.accentEmerald,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        
        Spacing.verticalSpaceMd,
        
        // Day entries
        Expanded(
          child: _buildDayEntries(context, isDark, _selectedDate),
        ),
      ],
    ).animate().fadeIn(
      duration: DesignTokens.animationMedium,
      delay: const Duration(milliseconds: 500),
    );
  }

  Widget _buildDayView(BuildContext context, bool isDark) {
    return _buildDayEntries(context, isDark, _selectedDate, showTimeline: true)
        .animate().fadeIn(
          duration: DesignTokens.animationMedium,
          delay: const Duration(milliseconds: 500),
        );
  }

  Widget _buildCalendarDay(
    BuildContext context,
    DateTime date,
    bool isCurrentMonth,
    bool isToday,
    bool isSelected,
    bool hasEntries,
    int entryCount,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _onDateSelected(date),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? DesignTokens.primaryIndigo.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: Spacing.borderRadiusSm,
          border: Border.all(
            color: isSelected
                ? DesignTokens.primaryIndigo
                : isToday
                    ? DesignTokens.accentCyan
                    : Colors.transparent,
            width: isSelected || isToday ? 2 : 0,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                date.day.toString(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: isToday || isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: !isCurrentMonth
                      ? theme.textTheme.bodyMedium?.color?.withOpacity(0.3)
                      : isSelected
                          ? DesignTokens.primaryIndigo
                          : isToday
                              ? DesignTokens.accentCyan
                              : null,
                ),
              ),
            ),
            if (hasEntries)
              Positioned(
                bottom: 4,
                right: 0,
                left: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.xs,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? DesignTokens.primaryIndigo.withOpacity(0.2)
                          : DesignTokens.accentEmerald.withOpacity(0.2),
                      borderRadius: Spacing.borderRadiusSm,
                    ),
                    child: Text(
                      entryCount.toString(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? DesignTokens.primaryIndigo
                            : DesignTokens.accentEmerald,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDayEntries(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('EEEE, d. MMMM yyyy', 'de_DE');

    return Container(
      height: 200,
      padding: Spacing.paddingHorizontalMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Spacing.verticalSpaceMd,
          Row(
            children: [
              Icon(
                Icons.event_note_rounded,
                color: DesignTokens.primaryIndigo,
                size: Spacing.iconMd,
              ),
              Spacing.horizontalSpaceSm,
              Text(
                'Einträge am ${dateFormat.format(_selectedDate)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Spacing.verticalSpaceSm,
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: Spacing.md),
              itemCount: _groupedEntries[_selectedDate]?.length ?? 0,
              itemBuilder: (context, index) {
                final entry = _groupedEntries[_selectedDate]![index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: Spacing.sm),
                  child: CompactEntryCard(
                    entry: entry,
                    onTap: () => _navigateToEditEntry(entry),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayEntries(
    BuildContext context,
    bool isDark,
    DateTime date, {
    bool showTimeline = false,
  }) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('EEEE, d. MMMM yyyy', 'de_DE');
    final timeFormat = DateFormat('HH:mm', 'de_DE');
    
    final entries = _groupedEntries[date] ?? [];
    
    if (entries.isEmpty) {
      return _buildEmptyDayState(context, date);
    }
    
    // Sort entries by time
    entries.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    
    if (showTimeline) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: Spacing.paddingHorizontalMd,
            child: Row(
              children: [
                Icon(
                  Icons.event_note_rounded,
                  color: DesignTokens.primaryIndigo,
                  size: Spacing.iconMd,
                ),
                Spacing.horizontalSpaceSm,
                Text(
                  dateFormat.format(date),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Spacing.verticalSpaceMd,
          Expanded(
            child: ListView.builder(
              padding: Spacing.paddingHorizontalMd,
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                final time = timeFormat.format(entry.dateTime);
                
                // Add time separator if this is the first entry or if the hour changed
                final showTimeSeparator = index == 0 || 
                    entry.dateTime.hour != entries[index - 1].dateTime.hour;
                
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
                            child: CompactEntryCard(
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
          ),
        ],
      );
    } else {
      return ListView.builder(
        padding: Spacing.paddingHorizontalMd,
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: Spacing.sm),
            child: CompactEntryCard(
              entry: entry,
              onTap: () => _navigateToEditEntry(entry),
            ),
          );
        },
      );
    }
  }

  Widget _buildEmptyDayState(BuildContext context, DateTime date) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('EEEE, d. MMMM yyyy', 'de_DE');

    return Padding(
      padding: Spacing.paddingMd,
      child: GlassCard(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
              'Keine Einträge für ${dateFormat.format(date)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState(BuildContext context, bool isDark) {
    return Padding(
      padding: Spacing.paddingMd,
      child: GlassCard(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: Spacing.iconXl,
              color: DesignTokens.errorRed,
            ),
            Spacing.verticalSpaceMd,
            Text(
              'Fehler beim Laden',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: DesignTokens.errorRed,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            Spacing.verticalSpaceXs,
            Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            Spacing.verticalSpaceMd,
            ElevatedButton(
              onPressed: _loadEntries,
              child: const Text('Erneut versuchen'),
            ),
          ],
        ),
      ),
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

  String _getWeekdayName(int weekday, {bool short = false}) {
    final weekdays = short
        ? ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So']
        : ['Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag', 'Sonntag'];
    return weekdays[weekday - 1];
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}