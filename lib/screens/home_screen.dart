import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../models/entry.dart';
import '../models/quick_button_config.dart';
import '../services/entry_service.dart';
import '../services/quick_button_service.dart';
import '../services/timer_service.dart';
import '../services/substance_service.dart';
import '../services/psychedelic_theme_service.dart';
import '../widgets/animated_entry_card.dart';
import '../widgets/glass_card.dart';
import '../widgets/pulsating_widgets.dart';
import '../widgets/quick_entry/quick_entry_bar.dart';
import '../widgets/active_timer_bar.dart';
import 'entry_list_screen.dart';
import 'edit_entry_screen.dart';
import 'add_entry_screen.dart';
import 'quick_entry/quick_button_config_screen.dart';
import 'quick_entry/quick_entry_management_screen.dart';
import 'calendar/day_detail_screen.dart';
import 'advanced_search_screen.dart';
import 'calendar/pattern_analysis_screen.dart';
import 'data_export_screen.dart';
import 'timer_dashboard_screen.dart';
import '../theme/design_tokens.dart';
import '../theme/spacing.dart';
import '../utils/performance_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  bool _isQuickEntryEditMode = false;

  // Services
  final EntryService _entryService = EntryService();
  final QuickButtonService _quickButtonService = QuickButtonService();
  final TimerService _timerService = TimerService();
  final SubstanceService _substanceService = SubstanceService();

  // Quick Entry State
  List<QuickButtonConfig> _quickButtons = [];
  bool _isLoadingQuickButtons = true;
  
  // Timer State
  Entry? _activeTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadQuickButtons();
    _loadActiveTimer();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final isScrolled = _scrollController.offset > 50;
    if (isScrolled != _isScrolled) {
      setState(() {
        _isScrolled = isScrolled;
      });
    }
  }

  Future<void> _loadActiveTimer() async {
    try {
      final activeTimer = _timerService.currentActiveTimer;
      if (mounted) {
        setState(() {
          _activeTimer = activeTimer;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading active timer: $e');
      }
    }
  }

  Future<void> _loadQuickButtons() async {
    try {
      final buttons = await _quickButtonService.getAllQuickButtons();
      setState(() {
        _quickButtons = buttons;
        _isLoadingQuickButtons = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingQuickButtons = false;
      });
    }
  }

  Future<void> _handleQuickEntry(QuickButtonConfig config) async {
    try {
      final entry = Entry.create(
        substanceId: config.substanceId,
        substanceName: config.substanceName,
        dosage: config.dosage,
        unit: config.unit,
        dateTime: DateTime.now(),
        notes: 'Erstellt über Quick Entry',
      );

      await _entryService.addEntry(entry);
      
      // Get substance to determine timer duration
      final substance = await _substanceService.getSubstanceById(config.substanceId);
      final fallbackDuration = const Duration(hours: 4); // Default fallback duration
      final timerDuration = substance?.duration ?? fallbackDuration;
      
      // Start timer automatically
      final entryWithTimer = await _timerService.startTimer(entry, customDuration: timerDuration);
      
      // Update active timer state using addPostFrameCallback to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _activeTimer = entryWithTimer;
          });
        }
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${config.substanceName} (${config.formattedDosage}) hinzugefügt - Timer gestartet'),
            backgroundColor: DesignTokens.successGreen,
            action: SnackBarAction(
              label: 'Bearbeiten',
              textColor: Colors.white,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EditEntryScreen(entry: entryWithTimer),
                  ),
                );
              },
            ),
          ),
        );
        
        // Refresh the home screen to show the new entry
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Hinzufügen: $e'),
            backgroundColor: DesignTokens.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _stopActiveTimer() async {
    if (_activeTimer == null) return;
    
    try {
      await _timerService.stopTimer(_activeTimer!);
      
      // Update state using addPostFrameCallback
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _activeTimer = null;
          });
        }
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Timer für ${_activeTimer!.substanceName} gestoppt'),
            backgroundColor: DesignTokens.warningYellow,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Stoppen des Timers: $e'),
            backgroundColor: DesignTokens.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _navigateToQuickButtonConfig() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const QuickButtonConfigScreen(),
      ),
    );

    if (result == true) {
      _loadQuickButtons();
    }
  }

  Future<void> _navigateToQuickEntryManagement() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const QuickEntryManagementScreen(),
      ),
    );

    if (result == true) {
      _loadQuickButtons();
    }
  }

  Future<void> _reorderQuickButtons(List<QuickButtonConfig> reorderedButtons) async {
    try {
      await _quickButtonService.reorderQuickButtons(reorderedButtons);
      setState(() {
        _quickButtons = reorderedButtons;
        _isQuickEntryEditMode = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reihenfolge erfolgreich aktualisiert'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim Sortieren: $e'),
          backgroundColor: DesignTokens.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final now = DateTime.now();
    final dateFormat = DateFormat('d. MMMM yyyy', 'de_DE');

    return Consumer<PsychedelicThemeService>(
      builder: (context, psychedelicService, child) {
        return Scaffold(
          body: CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildSliverAppBar(context, isDark, dateFormat.format(now), psychedelicService),
              SliverPadding(
                padding: Spacing.paddingHorizontalMd,
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Active Timer Bar (only shown when timer is active)
                    if (_activeTimer != null)
                      ActiveTimerBar(
                        timer: _activeTimer!,
                        onTap: () => _navigateToTimerDashboard(),
                      ).animate().fadeIn(
                        duration: DesignTokens.animationMedium,
                        delay: const Duration(milliseconds: 200),
                      ).slideY(
                        begin: -0.3,
                        end: 0,
                        duration: DesignTokens.animationMedium,
                        curve: DesignTokens.curveEaseOut,
                      ),
                    
                    Spacing.verticalSpaceLg,
                    
                    // Quick Entry Bar
                    if (!_isLoadingQuickButtons)
                      QuickEntryBar(
                        quickButtons: _quickButtons.take(6).toList(), // Limit to 6 for performance
                        onQuickEntry: _handleQuickEntry,
                        onAddButton: _navigateToQuickButtonConfig,
                        onEditMode: () {
                          setState(() {
                            _isQuickEntryEditMode = !_isQuickEntryEditMode;
                          });
                        },
                        isEditing: _isQuickEntryEditMode,
                        onReorder: _reorderQuickButtons,
                      ).animate().fadeIn(
                        duration: DesignTokens.animationMedium,
                        delay: const Duration(milliseconds: 400),
                      ).slideY(
                        begin: 0.3,
                        end: 0,
                        duration: DesignTokens.animationMedium,
                        curve: DesignTokens.curveEaseOut,
                      ),
                    
                    // Use FutureBuilder for data-dependent sections to improve loading performance
                    FutureBuilder<List<Entry>>(
                      future: _entryService.getAllEntries(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(Spacing.lg),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Spacing.verticalSpaceLg,
                        _buildRecentEntriesSection(context, isDark, snapshot.data),
                        Spacing.verticalSpaceLg,
                        _buildTodayStatsSection(context, isDark),
                        Spacing.verticalSpaceLg,
                        _buildQuickInsightsSection(context, isDark),
                      ],
                    );
                  },
                ),
                
                const SizedBox(height: 120), // Bottom padding for navigation
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: Consumer<PsychedelicThemeService>(
        builder: (context, psychedelicService, child) {
          final speedDial = SpeedDial(
            tooltip: 'Aktionen',
            backgroundColor: DesignTokens.accentPink,
            overlayOpacity: 0.4,
            overlayColor: Colors.black,
            spaceBetweenChildren: 12,
            buttonSize: const Size(56, 56),
            childrenButtonSize: const Size(48, 48),
            direction: SpeedDialDirection.up,
            switchLabelPosition: false,
            closeManually: false,
            children: [
              SpeedDialChild(
                child: const Icon(Icons.add_rounded),
                label: 'Neuer Eintrag',
                backgroundColor: DesignTokens.primaryIndigo,
                foregroundColor: Colors.white,
                labelStyle: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                labelBackgroundColor: DesignTokens.primaryIndigo.withOpacity(0.9),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AddEntryScreen(),
                    ),
                  ).then((result) {
                    if (result == true) {
                      setState(() {}); // Refresh the screen
                    }
                  });
                },
              ),
              if (_activeTimer != null)
                SpeedDialChild(
                  child: const Icon(Icons.timer_off_rounded),
                  label: 'Timer stoppen',
                  backgroundColor: DesignTokens.warningYellow,
                  foregroundColor: Colors.white,
                  labelStyle: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  labelBackgroundColor: DesignTokens.warningYellow.withOpacity(0.9),
                  onTap: () => _stopActiveTimer(),
                ),
            ],
            child: const Icon(Icons.speed_rounded),
          );

          // Only wrap with animation in trippy mode
          if (psychedelicService.isPsychedelicMode) {
            return AnimatedRotationFAB(
              isTrippyMode: true,
              child: speedDial,
            );
          }
          
          return speedDial;
        },
      ),
    );
      }, // End of Consumer builder
    );
  }

  Widget _buildSliverAppBar(BuildContext context, bool isDark, String dateText, PsychedelicThemeService psychedelicService) {
    final theme = Theme.of(context);
    final substanceColors = psychedelicService.getCurrentSubstanceColors();
    final isPsychedelic = psychedelicService.isPsychedelicMode && isDark;

    return SliverAppBar(
      expandedHeight: 120, // Reduced from 150 to 120
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: isPsychedelic
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      DesignTokens.psychedelicBackground,
                      substanceColors['primary']!.withOpacity(0.1),
                      DesignTokens.psychedelicBackground,
                    ],
                  )
                : isDark
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Reduced padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Replace static text with animated logo
                  Row(
                    children: [
                      // Animated logo container
                      PulsatingWidget(
                        isEnabled: isPsychedelic,
                        glowColor: substanceColors['primary'],
                        intensity: 0.5,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 3000),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, value, child) {
                              return Transform.rotate(
                                angle: value * 6.28, // Full rotation
                                child: ShaderMask(
                                  shaderCallback: (bounds) {
                                    return LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.white,
                                        Colors.white.withOpacity(0.8),
                                        isPsychedelic ? substanceColors['primary']! : DesignTokens.accentCyan,
                                        Colors.white,
                                      ],
                                      stops: [0.0, 0.3, 0.7, 1.0],
                                      transform: GradientRotation(value * 3.14),
                                    ).createShader(bounds);
                                  },
                                  child: const Icon(
                                    Icons.psychology_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: PulsatingWidget(
                          isEnabled: isPsychedelic,
                          glowColor: substanceColors['primary'],
                          intensity: 0.3,
                          child: ShaderMask(
                            shaderCallback: (bounds) {
                              return LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: isPsychedelic ? [
                                  substanceColors['primary']!,
                                  DesignTokens.textPsychedelicPrimary,
                                  substanceColors['primary']!,
                                  Colors.white,
                                ] : [
                                  Colors.white,
                                  Colors.white,
                                  Colors.white,
                                  Colors.white,
                                ],
                                stops: isPsychedelic ? [0.0, 0.3, 0.7, 1.0] : [0.0, 0.3, 0.7, 1.0],
                              ).createShader(bounds);
                            },
                            child: TweenAnimationBuilder<double>(
                              duration: const Duration(milliseconds: 2000),
                              tween: Tween(begin: 0.0, end: 1.0),
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: 1.0 + (isPsychedelic ? (0.05 * (1.0 - value)) : 0.0),
                                  child: Text(
                                    'Konsum Tracker Pro',
                                    style: theme.textTheme.headlineMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      shadows: isPsychedelic ? [
                                        Shadow(
                                          color: substanceColors['primary']!.withOpacity(0.3),
                                          blurRadius: 10,
                                        ),
                                      ] : [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              onEnd: () {
                                // Restart animation in trippy mode
                                if (isPsychedelic && mounted) {
                                  setState(() {});
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(
                    duration: DesignTokens.animationSlow,
                    delay: const Duration(milliseconds: 200),
                  ).slideX(
                    begin: -0.3,
                    end: 0,
                    duration: DesignTokens.animationSlow,
                    curve: DesignTokens.curveEaseOut,
                  ),
                  const SizedBox(height: 4), // Reduced from Spacing.verticalSpaceXs
                  Text(
                    dateText,
                    style: theme.textTheme.bodyMedium?.copyWith( // Changed from bodyLarge to bodyMedium
                      color: isPsychedelic 
                          ? DesignTokens.textPsychedelicSecondary 
                          : Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w400,
                    ),
                  ).animate().fadeIn(
                    duration: DesignTokens.animationSlow,
                    delay: const Duration(milliseconds: 400),
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

  Widget _buildRecentEntriesSection(BuildContext context, bool isDark, List<Entry>? entries) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Letzte Einträge',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () => _navigateToEntryList(),
              child: const Text('Alle anzeigen'),
            ),
          ],
        ).animate().fadeIn(
          duration: DesignTokens.animationMedium,
          delay: const Duration(milliseconds: 900),
        ),
        Spacing.verticalSpaceMd,
        if (entries == null)
          _buildRecentEntriesLoading()
        else if (entries.isEmpty)
          _buildEmptyState(
            context,
            isDark,
            'Noch keine Einträge',
            'Fügen Sie Ihren ersten Eintrag hinzu',
            Icons.note_add_outlined,
          )
        else
          Column(
            children: List.generate(entries.take(3).length, (index) {
              final entryData = entries.take(3).elementAt(index);
              
              // Only animate if animations should be enabled
              Widget card = CompactEntryCard(
                entry: entryData,
                onTap: () => _navigateToEditEntry(entryData),
              );
              
              if (PerformanceHelper.shouldEnableAnimations()) {
                card = card.animate().fadeIn(
                  duration: PerformanceHelper.getAnimationDuration(DesignTokens.animationMedium),
                  delay: Duration(milliseconds: 1000 + (index * 100).toInt()),
                ).slideY(
                  begin: 0.3,
                  end: 0,
                  duration: PerformanceHelper.getAnimationDuration(DesignTokens.animationMedium),
                  curve: DesignTokens.curveEaseOut,
                );
              }
              
              return Padding(
                padding: const EdgeInsets.only(bottom: Spacing.sm),
                child: card,
              );
            }),
          ),
      ],
    );
  }

  Widget _buildTodayStatsSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Heute',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () => _navigateToDayDetail(DateTime.now()),
              child: const Text('Details'),
            ),
          ],
        ).animate().fadeIn(
          duration: DesignTokens.animationMedium,
          delay: const Duration(milliseconds: 1100),
        ),
        Spacing.verticalSpaceMd,
        FutureBuilder<Map<String, dynamic>>(
          future: _entryService.getStatistics(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildStatsLoading();
            } else if (snapshot.hasError) {
              return _buildStatsError(context, isDark);
            } else {
              final stats = snapshot.data ?? {};
              final todayEnt = stats['todayEntries'] ?? 0;
              final todayCost = stats['todayCost'] ?? 0.0;
              final todaySubstances = stats['todaySubstances'] ?? 0;

              return Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      isDark,
                      'Einträge',
                      todayEnt.toString(),
                      Icons.note_rounded,
                      DesignTokens.primaryIndigo,
                    ).animate().fadeIn(
                      duration: DesignTokens.animationMedium,
                      delay: const Duration(milliseconds: 1200),
                    ).slideY(
                      begin: 0.3,
                      end: 0,
                      duration: DesignTokens.animationMedium,
                      curve: DesignTokens.curveEaseOut,
                    ),
                  ),
                  Spacing.horizontalSpaceMd,
                  Expanded(
                    child: _buildStatCard(
                      context,
                      isDark,
                      'Kosten',
                      '${todayCost.toStringAsFixed(2).replaceAll('.', ',')}€',
                      Icons.euro_rounded,
                      DesignTokens.accentEmerald,
                    ).animate().fadeIn(
                      duration: DesignTokens.animationMedium,
                      delay: const Duration(milliseconds: 1300),
                    ).slideY(
                      begin: 0.3,
                      end: 0,
                      duration: DesignTokens.animationMedium,
                      curve: DesignTokens.curveEaseOut,
                    ),
                  ),
                  Spacing.horizontalSpaceMd,
                  Expanded(
                    child: _buildStatCard(
                      context,
                      isDark,
                      'Substanzen',
                      todaySubstances.toString(),
                      Icons.science_rounded,
                      DesignTokens.accentCyan,
                    ).animate().fadeIn(
                      duration: DesignTokens.animationMedium,
                      delay: const Duration(milliseconds: 1400),
                    ).slideY(
                      begin: 0.3,
                      end: 0,
                      duration: DesignTokens.animationMedium,
                      curve: DesignTokens.curveEaseOut,
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    bool isDark,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return GlassCard(
      child: Column(
        children: [
          Icon(
            icon,
            size: Spacing.iconLg,
            color: color,
          ),
          Spacing.verticalSpaceSm,
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInsightsSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Schnelle Einblicke',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ).animate().fadeIn(
          duration: DesignTokens.animationMedium,
          delay: const Duration(milliseconds: 1500),
        ),
        Spacing.verticalSpaceMd,
        FutureBuilder<Map<String, dynamic>>(
          future: _entryService.getStatistics(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildInsightsLoading();
            } else if (snapshot.hasError) {
              return _buildInsightsError(context, isDark);
            } else {
              final stats = snapshot.data ?? {};
              final mostUsedSubstance = stats['mostUsedSubstance'] ?? 'Keine Daten';
              final averageDailyCost = stats['averageDailyCost'] ?? 0.0;
              final totalEntries = stats['totalEntries'] ?? 0;

              return Column(
                children: [
                  _buildInsightCard(
                    context,
                    isDark,
                    'Häufigste Substanz',
                    mostUsedSubstance,
                    Icons.trending_up_rounded,
                    DesignTokens.accentPurple,
                  ).animate().fadeIn(
                    duration: DesignTokens.animationMedium,
                    delay: const Duration(milliseconds: 1600),
                  ).slideY(
                    begin: 0.3,
                    end: 0,
                    duration: DesignTokens.animationMedium,
                    curve: DesignTokens.curveEaseOut,
                  ),
                  Spacing.verticalSpaceSm,
                  _buildInsightCard(
                    context,
                    isDark,
                    'Durchschnittliche Tageskosten',
                    '${averageDailyCost.toStringAsFixed(2).replaceAll('.', ',')}€',
                    Icons.analytics_rounded,
                    DesignTokens.warningYellow,
                  ).animate().fadeIn(
                    duration: DesignTokens.animationMedium,
                    delay: const Duration(milliseconds: 1700),
                  ).slideY(
                    begin: 0.3,
                    end: 0,
                    duration: DesignTokens.animationMedium,
                    curve: DesignTokens.curveEaseOut,
                  ),
                  Spacing.verticalSpaceSm,
                  _buildInsightCard(
                    context,
                    isDark,
                    'Gesamte Einträge',
                    totalEntries.toString(),
                    Icons.inventory_rounded,
                    DesignTokens.accentEmerald,
                  ).animate().fadeIn(
                    duration: DesignTokens.animationMedium,
                    delay: const Duration(milliseconds: 1800),
                  ).slideY(
                    begin: 0.3,
                    end: 0,
                    duration: DesignTokens.animationMedium,
                    curve: DesignTokens.curveEaseOut,
                  ),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildInsightCard(
    BuildContext context,
    bool isDark,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return GlassCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(Spacing.sm),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: Spacing.borderRadiusMd,
            ),
            child: Icon(
              icon,
              size: Spacing.iconMd,
              color: color,
            ),
          ),
          Spacing.horizontalSpaceMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Loading states
  Widget _buildRecentEntriesLoading() {
    return Column(
      children: List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: Spacing.sm),
          child: const EntryCardSkeleton(isCompact: true),
        );
      }),
    );
  }

  Widget _buildStatsLoading() {
    return Row(
      children: List.generate(3, (index) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index < 2 ? Spacing.md : 0,
            ),
            child: GlassCard(
              child: Column(
                children: [
                  Container(
                    width: Spacing.iconLg,
                    height: Spacing.iconLg,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: Spacing.borderRadiusSm,
                    ),
                  ),
                  Spacing.verticalSpaceSm,
                  Container(
                    width: 40,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: Spacing.borderRadiusSm,
                    ),
                  ),
                  Spacing.verticalSpaceXs,
                  Container(
                    width: 60,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: Spacing.borderRadiusSm,
                    ),
                  ),
                ],
              ),
            ).animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: const Duration(milliseconds: 1500)),
          ),
        );
      }),
    );
  }

  Widget _buildInsightsLoading() {
    return Column(
      children: List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: Spacing.sm),
          child: GlassCard(
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: Spacing.borderRadiusMd,
                  ),
                ),
                Spacing.horizontalSpaceMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: Spacing.borderRadiusSm,
                        ),
                      ),
                      Spacing.verticalSpaceXs,
                      Container(
                        width: 100,
                        height: 18,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3),
                          borderRadius: Spacing.borderRadiusSm,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: const Duration(milliseconds: 1500)),
        );
      }),
    );
  }

  // Error states
  Widget _buildRecentEntriesError(BuildContext context, bool isDark) {
    return _buildErrorState(
      context,
      isDark,
      'Fehler beim Laden der Einträge',
      'Versuchen Sie es später erneut',
      Icons.error_outline_rounded,
    );
  }

  Widget _buildStatsError(BuildContext context, bool isDark) {
    return _buildErrorState(
      context,
      isDark,
      'Fehler beim Laden der Statistiken',
      'Versuchen Sie es später erneut',
      Icons.analytics_outlined,
    );
  }

  Widget _buildInsightsError(BuildContext context, bool isDark) {
    return _buildErrorState(
      context,
      isDark,
      'Fehler beim Laden der Einblicke',
      'Versuchen Sie es später erneut',
      Icons.insights_outlined,
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    bool isDark,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return GlassCard(
      child: Column(
        children: [
          Icon(
            icon,
            size: Spacing.iconXl,
            color: DesignTokens.errorRed,
          ),
          Spacing.verticalSpaceMd,
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: DesignTokens.errorRed,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          Spacing.verticalSpaceXs,
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    bool isDark,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Center( // Center the entire empty state
      child: Container(
        padding: const EdgeInsets.all(24), // Add padding around the card
        child: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min, // Use minimum size needed
            children: [
              Icon(
                icon,
                size: Spacing.iconXl,
                color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
              ),
              Spacing.verticalSpaceMd,
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              Spacing.verticalSpaceXs,
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              Spacing.verticalSpaceMd,
              Container(
                width: double.infinity, // Make button full width of card
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToAddEntry(),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Ersten Button erstellen'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignTokens.primaryIndigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), // Better padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // More rounded corners
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Navigation methods
  Future<void> _navigateToAddEntry() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddEntryScreen(),
      ),
    );

    if (result == true) {
      setState(() {}); // Refresh the home screen
    }
  }

  Future<void> _navigateToEditEntry(Entry entry) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditEntryScreen(entry: entry),
      ),
    );

    if (result == true) {
      setState(() {}); // Refresh the home screen
    }
  }

  void _navigateToEntryList() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EntryListScreen(),
      ),
    );
  }

  void _navigateToDayDetail(DateTime date) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DayDetailScreen(date: date),
      ),
    );
  }

  void _navigateToAdvancedSearch() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AdvancedSearchScreen(),
      ),
    );
  }

  void _navigateToPatternAnalysis() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PatternAnalysisScreen(),
      ),
    );
  }

  void _navigateToDataExport() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const DataExportScreen(),
      ),
    );
  }

  void _navigateToTimerDashboard() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const TimerDashboardScreen(),
      ),
    );
  }
}

// Glass Empty State Widget
class GlassEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onAction;

  const GlassEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          Icon(
            icon,
            size: Spacing.iconXl,
            color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
          ),
          Spacing.verticalSpaceMd,
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          Spacing.verticalSpaceXs,
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          if (actionText != null && onAction != null) ...[
            Spacing.verticalSpaceMd,
            ElevatedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add_rounded),
              label: Text(actionText!),
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
}

// Animated rotation FAB widget for trippy mode
class AnimatedRotationFAB extends StatefulWidget {
  final bool isTrippyMode;
  final Widget child;

  const AnimatedRotationFAB({
    super.key,
    required this.isTrippyMode,
    required this.child,
  });

  @override
  State<AnimatedRotationFAB> createState() => _AnimatedRotationFABState();
}

class _AnimatedRotationFABState extends State<AnimatedRotationFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1200), // Slightly longer for more dramatic effect
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 4.0, // 4 full rotations for wilder effect
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _triggerRotation() {
    if (widget.isTrippyMode && mounted) {
      _rotationController.forward().then((_) {
        if (mounted) {
          _rotationController.reset();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value * 3.14159265359, // Convert to radians
          child: GestureDetector(
            onTap: _triggerRotation,
            child: widget.child,
          ),
        );
      },
    );
  }
}