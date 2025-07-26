import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../models/entry.dart';
import '../models/quick_button_config.dart';
import '../utils/service_locator.dart';
import '../use_cases/entry_use_cases.dart';
import '../use_cases/substance_use_cases.dart';
import '../interfaces/service_interfaces.dart';
import '../services/psychedelic_theme_service.dart';
import '../services/timer_service.dart';
import '../widgets/animated_entry_card.dart';
import '../widgets/glass_card.dart';
import '../widgets/pulsating_widgets.dart';
import '../widgets/quick_entry/quick_entry_bar.dart';
import '../widgets/active_timer_bar.dart';
import '../widgets/consistent_fab.dart';
import '../widgets/layout_error_boundary.dart';
import '../utils/error_handler.dart';
import '../utils/crash_protection.dart';
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

class _HomeScreenState extends State<HomeScreen> with SafeStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  bool _isQuickEntryEditMode = false;
  bool _animationsInitialized = false; // Track if animations have been played

  // Use Cases (injected via ServiceLocator)
  late final GetEntriesUseCase _getEntriesUseCase;
  late final CreateEntryUseCase _createEntryUseCase;
  late final ITimerService _timerService;
  late final IEntryService _entryService;
  
  // Services that don't have use cases yet (will be migrated in future phases)
  late final ISubstanceService _substanceService;
  late final IQuickButtonService _quickButtonService;

  // Quick Entry State
  List<QuickButtonConfig> _quickButtons = [];
  bool _isLoadingQuickButtons = true;
  
  // Loading State
  Future<List<Entry>>? _entriesFuture;
  
  // Navigation state to prevent SnackBar overlays during transitions
  bool _isNavigationTransition = false;

  @override
  void initState() {
    super.initState();
    
    if (kDebugMode) {
      print('🏠 HomeScreen initState gestartet');
    }
    
    _scrollController.addListener(_onScroll);
    
    // Initialize services and use cases from ServiceLocator in the next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeServices();
      }
    });
  }

  void _initializeServices() {
    try {
      if (kDebugMode) {
        print('🔧 HomeScreen: Initialisiere Services von ServiceLocator...');
      }
      
      // Get use cases and services from ServiceLocator
      _getEntriesUseCase = ServiceLocator.get<GetEntriesUseCase>();
      _createEntryUseCase = ServiceLocator.get<CreateEntryUseCase>();
      _timerService = ServiceLocator.get<ITimerService>();
      _entryService = ServiceLocator.get<IEntryService>();
      _substanceService = ServiceLocator.get<ISubstanceService>();
      _quickButtonService = ServiceLocator.get<IQuickButtonService>();
      
      if (kDebugMode) {
        print('✅ HomeScreen: Services und Use Cases erfolgreich initialisiert');
        print('📊 GetEntriesUseCase: ${_getEntriesUseCase.toString()}');
        print('➕ CreateEntryUseCase: ${_createEntryUseCase.toString()}');
        print('📝 EntryService: ${_entryService.toString()}');
        print('⚡ QuickButtonService: ${_quickButtonService.toString()}');
        print('⏰ TimerService: ${_timerService.toString()}');
        print('🧪 SubstanceService: ${_substanceService.toString()}');
      }
      
      // Load initial data
      _loadInitialData();
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ HomeScreen: Fehler beim Initialisieren der Services: $e');
      }
      
      // Fallback handling
      throw StateError('Failed to initialize HomeScreen services: $e');
    }
  }

  void _loadInitialData() {
    if (kDebugMode) {
      print('📥 HomeScreen: Lade initiale Daten...');
    }
    
    // Defer data loading to prevent setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadEntries();
        _loadQuickButtons();
      }
    });
  }

  void _refreshData() {
    if (kDebugMode) {
      print('🔄 HomeScreen: Aktualisiere Daten...');
    }
    
    _loadEntries();
    _loadQuickButtons();
    
    // Refresh active timers after loading
    _timerService.refreshActiveTimers();
  }

  void _loadEntries() {
    if (!mounted) return;
    
    if (kDebugMode) {
      print('📋 HomeScreen: Lade Einträge über GetEntriesUseCase...');
    }
    
    // Defer setState to prevent calling during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        safeSetState(() {
          _entriesFuture = _getEntriesUseCase.getAllEntries();
        });
      }
    });
  }

  @override
  void dispose() {
    if (kDebugMode) {
      print('🧹 HomeScreen dispose gestartet...');
    }
    
    try {
      _scrollController.removeListener(_onScroll);
      _scrollController.dispose();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Fehler beim Dispose des ScrollController: $e');
      }
    }
    
    if (kDebugMode) {
      print('✅ HomeScreen dispose abgeschlossen');
    }
    
    super.dispose();
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Reset navigation transition flag when widget updates
    _isNavigationTransition = false;
  }

  @override
  void deactivate() {
    // Set navigation transition flag when widget is being deactivated
    _isNavigationTransition = true;
    super.deactivate();
  }

  @override
  void activate() {
    super.activate();
    
    // Clear navigation transition flag after a short delay when reactivated
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _isNavigationTransition = false;
      }
    });
  }

  void _onScroll() {
    if (!mounted) return;
    
    try {
      final isScrolled = _scrollController.offset > 50;
      if (isScrolled != _isScrolled) {
        safeSetState(() {
          _isScrolled = isScrolled;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Fehler beim Scroll-Handling: $e');
      }
    }
  }

  Future<void> _loadQuickButtons() async {
    if (!mounted) return;
    
    try {
      if (kDebugMode) {
        print('⚡ HomeScreen: Lade QuickButtons...');
      }
      
      final buttons = await _quickButtonService.getAllQuickButtons();
      
      // Defer setState to prevent calling during build
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            safeSetState(() {
              _quickButtons = buttons;
              _isLoadingQuickButtons = false;
            });
            
            if (kDebugMode) {
              print('✅ HomeScreen: QuickButtons geladen: ${buttons.length} Buttons');
              for (int i = 0; i < buttons.length.clamp(0, 3); i++) {
                print('  - ${buttons[i].substanceName}: ${buttons[i].dosage}${buttons[i].unit}');
              }
            }
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ HomeScreen: Fehler beim Laden der QuickButtons: $e');
      }
      
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            safeSetState(() {
              _quickButtons = [];
              _isLoadingQuickButtons = false;
            });
          }
        });
      }
    }
  }

  Future<void> _handleQuickEntry(QuickButtonConfig config) async {
    try {
      final entry = Entry.create(
        substanceId: config.substanceId,
        substanceName: config.substanceName,
        dosage: config.dosage,
        unit: config.unit,
        cost: config.cost, // Include cost from quick button config
        dateTime: DateTime.now(),
        notes: 'Erstellt über Quick Entry',
        // Inherit color and icon from quick button
        icon: config.icon,
        color: config.color,
      );

      await _entryService.addEntry(entry);
      
      // Get substance to determine timer duration
      final substance = await _substanceService.getSubstanceById(config.substanceId);
      final fallbackDuration = const Duration(hours: 4); // Default fallback duration
      final timerDuration = substance?.duration ?? fallbackDuration;
      
      // Start timer automatically
      final entryWithTimer = await _timerService.startTimer(entry, customDuration: timerDuration);
      
      if (mounted) {
        _safeShowSnackBar(
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
        _refreshData();
      }
    } catch (e) {
      if (mounted) {
        _safeShowSnackBar(
          SnackBar(
            content: Text('Fehler beim Hinzufügen: $e'),
            backgroundColor: DesignTokens.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _stopActiveTimer() async {
    try {
      final activeTimer = _timerService.getActiveTimer();
      if (activeTimer == null || !mounted) return;
      
      await _timerService.stopTimer(activeTimer.id);
      
      if (mounted) {
        _safeShowSnackBar(
          SnackBar(
            content: Text('Timer für ${activeTimer.substanceName} gestoppt'),
            backgroundColor: DesignTokens.warningYellow,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Fehler beim Stoppen des Timers: $e');
      }
      
      if (mounted) {
        _safeShowSnackBar(
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
      final orderedIds = reorderedButtons.map((button) => button.id).toList();
      await _quickButtonService.reorderQuickButtons(orderedIds);
      safeSetState(() {
        _quickButtons = reorderedButtons;
        _isQuickEntryEditMode = false;
      });
      
      if (mounted) {
        _safeShowSnackBar(
          const SnackBar(
            content: Text('Reihenfolge erfolgreich aktualisiert'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _safeShowSnackBar(
        SnackBar(
          content: Text('Fehler beim Sortieren: $e'),
          backgroundColor: DesignTokens.errorRed,
        ),
      );
    }
  }

  Future<void> _showTimerStartDialog(BuildContext context, bool isDark) async {
    // Get available substances for timer selection
    final substances = await _substanceService.getAllSubstances();
    
    if (!mounted) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => _TimerStartModal(
        substances: substances,
        isDark: isDark,
        onTimerStarted: (substanceId, substanceName, duration) async {
          Navigator.of(context).pop();
          await _startNewTimer(substanceId, substanceName, duration);
        },
      ),
    );
  }

  Future<void> _startNewTimer(String substanceId, String substanceName, Duration duration) async {
    try {
      // Create a temporary entry for the timer
      final entry = Entry.create(
        substanceId: substanceId,
        substanceName: substanceName,
        dosage: 0.0, // Timer-only entry
        unit: 'Timer',
        dateTime: DateTime.now(),
        notes: 'Timer-Eintrag',
      );

      // Start the timer
      final timerEntry = await _timerService.startTimer(entry, customDuration: duration);
      
      if (mounted) {
        _safeShowSnackBar(
          SnackBar(
            content: Text('Timer für $substanceName gestartet (${_formatDuration(duration)})'),
            backgroundColor: DesignTokens.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _safeShowSnackBar(
          SnackBar(
            content: Text('Fehler beim Timer-Start: $e'),
            backgroundColor: DesignTokens.errorRed,
          ),
        );
      }
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    } else {
      return '${minutes}min';
    }
  }

  // Helper method to safely show SnackBars, preventing overlays during navigation
  void _safeShowSnackBar(SnackBar snackBar) {
    if (!mounted || _isNavigationTransition) return;
    
    // Clear any existing SnackBars first to prevent overlay effects
    ScaffoldMessenger.of(context).clearSnackBars();
    
    // Small delay to ensure clean transition
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted && !_isNavigationTransition) {
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('🎨 HomeScreen build() aufgerufen');
    }
    
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final now = DateTime.now();
    final dateFormat = DateFormat('d. MMMM yyyy', 'de_DE');

    return Consumer<PsychedelicThemeService>(
      builder: (context, psychedelicService, child) {
        final isPsychedelicMode = psychedelicService.isPsychedelicMode;
        
        // Early return if services are not initialized yet
        if (_entriesFuture == null) {
          if (kDebugMode) {
            print('⏳ HomeScreen: Services noch nicht initialisiert, zeige Loading...');
          }
          return Scaffold(
            backgroundColor: isPsychedelicMode 
              ? DesignTokens.psychedelicBackground 
              : null,
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Initialisiere App...'),
                ],
              ),
            ),
          );
        }
        
        return Scaffold(
          backgroundColor: isPsychedelicMode 
            ? DesignTokens.psychedelicBackground 
            : null,
          body: LayoutErrorBoundary(
            debugLabel: 'HomeScreen Main Body',
            child: Container(
              decoration: isPsychedelicMode 
                ? const BoxDecoration(
                    gradient: DesignTokens.psychedelicBackground1,
                  ) 
                : null,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const ClampingScrollPhysics(), // Add explicit physics
                slivers: [
                  _buildSliverAppBar(context, isDark, dateFormat.format(now), psychedelicService),
                SliverPadding(
                  padding: Spacing.paddingHorizontalMd,
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Active Timer Bar (only shown when timer is active)
                      LayoutErrorBoundary(
                        debugLabel: 'Active Timer Bar',
                        child: Consumer<TimerService>(
                          builder: (context, timerService, child) {
                            final activeTimer = timerService.getActiveTimer();
                            if (activeTimer != null && mounted) {
                              return LayoutBuilder(
                                builder: (context, constraints) {
                                  return Container(
                                    constraints: BoxConstraints(
                                      maxHeight: constraints.maxHeight * 0.15, // Use 15% of available height max
                                      minHeight: 25, // Ensure minimum usable height
                                    ),
                                    child: ActiveTimerBar(
                                      timer: activeTimer,
                                      onTap: () => _navigateToTimerDashboard(),
                                    ).animate().fadeIn(
                                      duration: DesignTokens.animationMedium,
                                      delay: const Duration(milliseconds: 200),
                                    ),
                                  );
                                },
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      
                      Spacing.verticalSpaceLg,
                      
                      // Quick Entry Bar with AnimatedSwitcher for overflow protection
                      LayoutErrorBoundary(
                        debugLabel: 'Quick Entry Bar Animated Container',
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: _isLoadingQuickButtons
                                  ? SizedBox(
                                      key: const ValueKey('quick_entry_loading'),
                                      height: 60, // Minimal height during loading
                                      child: Center(
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          child: const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: 16,
                                                height: 16,
                                                child: CircularProgressIndicator(strokeWidth: 2),
                                              ),
                                              SizedBox(width: 12),
                                              Text('Lade Quick-Buttons...'),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  : ConstrainedBox(
                                      key: const ValueKey('quick_entry_content'),
                                      constraints: BoxConstraints(
                                        maxHeight: constraints.maxHeight * 0.9, // Use 90% of available height
                                        minHeight: 80,
                                      ),
                                      child: SingleChildScrollView(
                                        physics: const ClampingScrollPhysics(),
                                        child: QuickEntryBar(
                                          quickButtons: _quickButtons.take(6).toList(), // Limit to 6 for performance
                                          onQuickEntry: _handleQuickEntry,
                                          onAddButton: _navigateToQuickButtonConfig,
                                          onEditMode: () {
                                            if (mounted) {
                                              safeSetState(() {
                                                _isQuickEntryEditMode = !_isQuickEntryEditMode;
                                              });
                                            }
                                          },
                                          isEditing: _isQuickEntryEditMode,
                                          onReorder: _reorderQuickButtons,
                                        ),
                                      ),
                                    ),
                            );
                          },
                        ),
                      ),
                      
                      // Use FutureBuilder for data-dependent sections with better error handling
                      FutureBuilder<List<Entry>>(
                        future: _entriesFuture,
                        builder: (context, snapshot) {
                          if (kDebugMode) {
                            print('🔄 HomeScreen FutureBuilder: ConnectionState=${snapshot.connectionState}');
                          }
                          
                          // Show loading state with better constraints
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            if (kDebugMode) {
                              print('🔄 HomeScreen: Zeige Loading-Zustand');
                            }
                            return Container(
                              constraints: const BoxConstraints(
                                minHeight: 200,
                                maxHeight: 400, // Increased to prevent overflow
                              ),
                              padding: const EdgeInsets.all(Spacing.lg),
                              child: const Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(height: 16),
                                    Text('Lade Einträge...'),
                                  ],
                                ),
                              ),
                            );
                          }
                          
                          // Handle errors gracefully without error boundary wrapper
                          if (snapshot.hasError) {
                            if (kDebugMode) {
                              print('❌ HomeScreen: Fehler beim Laden der Einträge: ${snapshot.error}');
                            }
                            return _buildErrorFallback(context, isDark);
                          }
                          
                          final entries = snapshot.data ?? [];
                          if (kDebugMode) {
                            print('✅ HomeScreen: ${entries.length} Einträge im Builder erhalten');
                          }
                          
                          // Wrap content sections individually for more granular error handling
                          // Only show error fallback for actual rendering errors, not layout overflow warnings
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min, // Use minimum required space
                            children: [
                              Spacing.verticalSpaceLg,
                              LayoutErrorBoundary(
                                debugLabel: 'Recent Entries Section',
                                fallback: Container(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    'Fehler beim Laden der letzten Einträge',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                                    ),
                                  ),
                                ),
                                child: _buildRecentEntriesSection(context, isDark, entries),
                              ),
                              Spacing.verticalSpaceLg,
                              LayoutErrorBoundary(
                                debugLabel: 'Today Stats Section',
                                fallback: Container(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    'Statistiken temporär nicht verfügbar',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                                    ),
                                  ),
                                ),
                                child: _buildTodayStatsSection(context, isDark),
                              ),
                              Spacing.verticalSpaceLg,
                              LayoutErrorBoundary(
                                debugLabel: 'Quick Insights Section',
                                fallback: Container(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    'Insights temporär nicht verfügbar',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                                    ),
                                  ),
                                ),
                                child: _buildQuickInsightsSection(context, isDark),
                              ),
                            ],
                          );
                        },
                      ),
                  
                  const SizedBox(height: 120), // Bottom padding for navigation
                ]),
              ),
            ),
          ],
          ), // Close CustomScrollView
          ), // Close Container
          ), // Close LayoutErrorBoundary
          floatingActionButton: Consumer<PsychedelicThemeService>(
            builder: (context, psychedelicService, child) {
              return Consumer<TimerService>(
                builder: (context, timerService, child) {
                  final theme = Theme.of(context);
                  final isDark = theme.brightness == Brightness.dark;
                  final hasActiveTimer = timerService.isTimerActive();
                  
                  final speedDialChildren = <SpeedDialChild>[
                    FABHelper.createSpeedDialChild(
                      icon: Icons.add_rounded,
                      label: 'Neuer Eintrag',
                      backgroundColor: DesignTokens.primaryIndigo,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AddEntryScreen(),
                          ),
                        ).then((result) {
                          if (result == true && mounted) {
                            _refreshData(); // Refresh data instead of just setState
                          }
                        });
                      },
                    ),
                    if (!hasActiveTimer)
                      FABHelper.createSpeedDialChild(
                        icon: Icons.timer_rounded,
                        label: 'Timer starten',
                        backgroundColor: DesignTokens.accentPurple,
                        onTap: () => _showTimerStartDialog(context, isDark),
                      ),
                    if (hasActiveTimer)
                      FABHelper.createSpeedDialChild(
                        icon: Icons.timer_off_rounded,
                        label: 'Timer stoppen',
                        backgroundColor: DesignTokens.warningYellow,
                        onTap: () => _stopActiveTimer(),
                      ),
                  ];

                  final fab = ConsistentFAB(
                    speedDialChildren: speedDialChildren,
                    mainIcon: Icons.speed_rounded,
                    backgroundColor: DesignTokens.accentPink,
                    onMainAction: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AddEntryScreen(),
                        ),
                      ).then((result) {
                        if (result == true && mounted) {
                          _refreshData(); // Refresh data instead of just setState
                        }
                      });
                    },
                  );

                  // Only wrap with animation in trippy mode
                  if (psychedelicService.isPsychedelicMode) {
                    return AnimatedRotationFAB(
                      isTrippyMode: true,
                      child: fab,
                    );
                  }
                  
                  return fab;
                },
              );
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
      expandedHeight: 140, // Increased for better text accommodation
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Improved padding
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Improved header with better text scaling
                      Row(
                        children: [
                          // Animated logo container with better constraints
                          PulsatingWidget(
                            isEnabled: isPsychedelic,
                            glowColor: substanceColors['primary'],
                            intensity: 0.5,
                            child: Container(
                              constraints: const BoxConstraints(
                                minWidth: 40,
                                minHeight: 40,
                                maxWidth: 56,
                                maxHeight: 56,
                              ),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withOpacity(0.15),
                                    Colors.white.withOpacity(0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isPsychedelic 
                                        ? substanceColors['primary']! 
                                        : Colors.black).withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
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
                              child: LayoutBuilder(
                                builder: (context, titleConstraints) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Improved title with responsive sizing
                                      ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth: titleConstraints.maxWidth,
                                        ),
                                        child: Text(
                                          'Konsum Tracker Pro',
                                          style: theme.textTheme.headlineMedium?.copyWith(
                                            color: isPsychedelic
                                                ? DesignTokens.textPsychedelicPrimary
                                                : Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: _getResponsiveHeaderSize(titleConstraints.maxWidth),
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
                                          maxLines: 2, // Allow wrapping for long titles
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),                        ],
                      ).animate().fadeIn(
                        duration: DesignTokens.animationSlow,
                        delay: const Duration(milliseconds: 200),
                      ).slideX(
                        begin: -0.3,
                        end: 0,
                        duration: DesignTokens.animationSlow,
                        curve: DesignTokens.curveEaseOut,
                      ),
                      const SizedBox(height: 8), // Improved spacing
                      // Improved date text with responsive sizing
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: constraints.maxWidth * 0.8,
                        ),
                        child: Text(
                          dateText,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isPsychedelic 
                                ? DesignTokens.textPsychedelicSecondary 
                                : Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w400,
                            fontSize: _getResponsiveDateSize(constraints.maxWidth),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to get responsive header size
  double _getResponsiveHeaderSize(double availableWidth) {
    if (availableWidth < 200) {
      return 18.0; // Very small screens
    } else if (availableWidth < 280) {
      return 20.0; // Small screens
    } else if (availableWidth < 350) {
      return 22.0; // Medium screens
    } else {
      return 26.0; // Large screens
    }
  }

  // Helper method to get responsive date size
  double _getResponsiveDateSize(double availableWidth) {
    if (availableWidth < 200) {
      return 12.0; // Very small screens
    } else if (availableWidth < 280) {
      return 13.0; // Small screens
    } else if (availableWidth < 350) {
      return 14.0; // Medium screens
    } else {
      return 16.0; // Large screens
    }
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
            'Noch keine Einträge vorhanden',
            'Fügen Sie Ihren ersten Eintrag hinzu, um loszulegen',
            Icons.note_add_outlined,
          )
        else
          _buildEntriesCards(entries),
      ],
    );
  }

  Widget _buildEntriesCards(List<Entry> entries) {
    return Column(
      children: List.generate(entries.take(3).length, (index) {
        final entryData = entries.take(3).elementAt(index);
        
        try {
          // Only animate if animations should be enabled
          Widget card = CompactEntryCard(
            entry: entryData,
            onTap: () => _navigateToEditEntry(entryData),
          );
          
          if (PerformanceHelper.shouldEnableAnimations()) {
            card = card.animate().fadeIn(
              duration: PerformanceHelper.getAnimationDuration(DesignTokens.animationMedium),
              delay: Duration(milliseconds: 1000 + (index * 100).toInt()),
            );
          }
          
          return Padding(
            padding: const EdgeInsets.only(bottom: Spacing.sm),
            child: card,
          );
        } catch (e) {
          if (kDebugMode) {
            print('❌ Fehler beim Rendern von Entry Card ${entryData.id}: $e');
          }
          
          // Fallback simple card on error
          return Padding(
            padding: const EdgeInsets.only(bottom: Spacing.sm),
            child: Card(
              child: ListTile(
                title: Text(entryData.substanceName ?? 'Unbekannt'),
                subtitle: Text('${entryData.dosage} ${entryData.unit}'),
                trailing: Text('${entryData.cost?.toStringAsFixed(2) ?? '0.00'}€'),
                onTap: () => _navigateToEditEntry(entryData),
              ),
            ),
          );
        }
      }),
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
              ErrorHandler.logError('HOME_SCREEN', 'Fehler beim Laden der Statistiken: ${snapshot.error}');
              return _buildStatsError(context, isDark);
            } else {
              final stats = snapshot.data ?? {};
              final todayEnt = stats['todayEntries'] ?? 0;
              final todayCost = stats['todayCost'] ?? 0.0;
              final todaySubstances = stats['todaySubstances'] ?? 0;

              try {
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
                      ),
                    ),
                  ],
                );
              } catch (e) {
                ErrorHandler.logError('HOME_SCREEN', 'Fehler beim Rendern der Statistik-Karten: $e');
                return _buildStatsError(context, isDark);
              }
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

  Widget _buildErrorFallback(BuildContext context, bool isDark) {
    if (kDebugMode) {
      print('❌ HomeScreen: Zeige Error-Fallback');
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Spacing.verticalSpaceLg,
        _buildErrorState(
          context,
          isDark,
          'Fehler beim Laden der Einträge',
          'Die Einträge konnten nicht geladen werden. Bitte überprüfen Sie die Logs für weitere Details.',
          Icons.error_outline,
        ),
        Spacing.verticalSpaceLg,
        
        // Show a retry button
        Center(
          child: ElevatedButton.icon(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh),
            label: const Text('Erneut versuchen'),
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignTokens.primaryIndigo,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        
        Spacing.verticalSpaceLg,
        // Still show today stats and insights even if entries failed
        _buildTodayStatsSection(context, isDark),
        Spacing.verticalSpaceLg,
        _buildQuickInsightsSection(context, isDark),
      ],
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
                  label: const Text('Ersten Eintrag erstellen'),
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

  // Navigation methods with mounted checks
  Future<void> _navigateToAddEntry() async {
    if (!mounted) return;
    
    try {
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const AddEntryScreen(),
        ),
      );

      if (result == true && mounted) {
        _refreshData(); // Refresh data instead of just setState
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Navigation zu AddEntry fehlgeschlagen: $e');
      }
    }
  }

  Future<void> _navigateToEditEntry(Entry entry) async {
    if (!mounted) return;
    
    try {
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => EditEntryScreen(entry: entry),
        ),
      );

      if (result == true && mounted) {
        _refreshData(); // Refresh data instead of just setState
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Navigation zu EditEntry fehlgeschlagen: $e');
      }
    }
  }

  void _navigateToEntryList() {
    if (!mounted) return;
    
    try {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const EntryListScreen(),
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Navigation zu EntryList fehlgeschlagen: $e');
      }
    }
  }

  void _navigateToDayDetail(DateTime date) {
    if (!mounted) return;
    
    try {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DayDetailScreen(date: date),
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Navigation zu DayDetail fehlgeschlagen: $e');
      }
    }
  }

  void _navigateToTimerDashboard() {
    if (!mounted) return;
    
    try {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const TimerDashboardScreen(),
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Navigation zu TimerDashboard fehlgeschlagen: $e');
      }
    }
  }
}

// hints reduziert durch HintOptimiererAgent

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

// Timer Start Modal
class _TimerStartModal extends StatefulWidget {
  final List<dynamic> substances; // Using dynamic to handle different substance types
  final bool isDark;
  final Function(String, String, Duration) onTimerStarted;

  const _TimerStartModal({
    required this.substances,
    required this.isDark,
    required this.onTimerStarted,
  });

  @override
  State<_TimerStartModal> createState() => _TimerStartModalState();
}

class _TimerStartModalState extends State<_TimerStartModal> with SafeStateMixin {
  String? selectedSubstanceId;
  String? selectedSubstanceName;
  int selectedMinutes = 30;
  final List<int> timerOptions = [15, 30, 45, 60, 90, 120, 180, 240, 360];
  final TextEditingController _customTimeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return Container(
      height: mediaQuery.size.height * 0.8,
      decoration: BoxDecoration(
        color: widget.isDark ? Colors.grey[900] : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildModalHeader(context),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Substanz auswählen',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSubstanceSelection(),
                  const SizedBox(height: 24),
                  Text(
                    'Timer-Dauer',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTimerSelection(),
                  const SizedBox(height: 24),
                  _buildCustomTimeInput(),
                  const Spacer(),
                  _buildStartButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModalHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DesignTokens.primaryIndigo,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer_rounded, color: Colors.white),
          const SizedBox(width: 12),
          Text(
            'Timer starten',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSubstanceSelection() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.substances.length,
        itemBuilder: (context, index) {
          final substance = widget.substances[index];
          final substanceId = substance.id ?? substance.substanceId ?? '';
          final substanceName = substance.name ?? substance.substanceName ?? '';
          final isSelected = selectedSubstanceId == substanceId;
          
          return GestureDetector(
            onTap: () {
              if (mounted) {
                safeSetState(() {
                  selectedSubstanceId = substanceId;
                  selectedSubstanceName = substanceName;
                });
              }
            },
            child: Container(
              width: 100,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? DesignTokens.primaryIndigo : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? DesignTokens.primaryIndigo : Colors.grey.withOpacity(0.3),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medication_rounded,
                    size: 32,
                    color: isSelected ? Colors.white : Colors.grey[600],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    substanceName,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[600],
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimerSelection() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: timerOptions.map((minutes) {
        final isSelected = selectedMinutes == minutes;
        return GestureDetector(
          onTap: () {
            if (mounted) {
              safeSetState(() {
                selectedMinutes = minutes;
                _customTimeController.clear();
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? DesignTokens.accentPurple : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? DesignTokens.accentPurple : Colors.grey.withOpacity(0.3),
              ),
            ),
            child: Text(
              '${minutes}min',
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCustomTimeInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Eigene Zeit eingeben (Minuten)',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _customTimeController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'z.B. 90',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            if (value.isNotEmpty) {
              final minutes = int.tryParse(value);
              if (minutes != null && minutes > 0) {
                if (mounted) {
                  safeSetState(() {
                    selectedMinutes = minutes;
                  });
                }
              }
            }
          },
        ),
        if (_customTimeController.text.isNotEmpty && selectedMinutes > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Entspricht: ${_formatDuration(Duration(minutes: selectedMinutes))}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: DesignTokens.primaryIndigo,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStartButton() {
    final isValid = selectedSubstanceId != null && selectedMinutes > 0;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isValid 
          ? () => widget.onTimerStarted(
              selectedSubstanceId!,
              selectedSubstanceName!,
              Duration(minutes: selectedMinutes),
            )
          : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: DesignTokens.accentPurple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Timer starten',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours} Stunde${hours == 1 ? '' : 'n'}${minutes > 0 ? ', $minutes Min' : ''}';
    } else {
      return '$minutes Min';
    }
  }
}