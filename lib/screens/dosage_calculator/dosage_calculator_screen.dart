import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/services.dart';
import '../../models/dosage_calculator_user.dart';
import '../../models/dosage_calculator_substance.dart';
import '../../models/dosage_calculation.dart';
import '../../services/dosage_calculator_service.dart';
import '../../services/psychedelic_theme_service.dart' as service;
import '../../services/substance_service.dart';
import '../../services/timer_service.dart';
import '../../use_cases/entry_use_cases.dart';
import '../../utils/service_locator.dart'; // refactored by ArchitekturAgent
import '../../widgets/glass_card.dart';
import '../../widgets/pulsating_widgets.dart';
import '../../widgets/trippy_fab.dart';
import '../../widgets/header_bar.dart';
import '../../widgets/consistent_fab.dart';
import '../../widgets/dosage_calculator/bmi_indicator.dart';
import '../../widgets/dosage_calculator/substance_quick_card.dart';
import '../../widgets/layout_error_boundary.dart';
import '../../theme/design_tokens.dart';
import '../../theme/spacing.dart';
import 'user_profile_screen.dart';
import 'substance_search_screen.dart';

class DosageCalculatorScreen extends StatefulWidget {
  const DosageCalculatorScreen({super.key});

  @override
  State<DosageCalculatorScreen> createState() => _DosageCalculatorScreenState();
}

class _DosageCalculatorScreenState extends State<DosageCalculatorScreen> {
  late final DosageCalculatorService _dosageService = ServiceLocator.get<DosageCalculatorService>(); // refactored by ArchitekturAgent
  final _searchController = TextEditingController();

  // Constants for UI layout
  static const double _kSubstanceCardHeight = 288.0;

  DosageCalculatorUser? _currentUser;
  List<DosageCalculatorSubstance> _popularSubstances = [];
  List<Map<String, dynamic>> _recentCalculations = [];
  bool _isLoading = true;
  bool _isDisposed = false;
  String? _errorMessage;
  bool _isModalOpen = false; // Track modal state to prevent stacking

  // Timer state
  Timer? _activeTimer;
  DosageCalculatorSubstance? _timerSubstance;
  Duration _timerDuration = Duration.zero;
  Duration _remainingTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _searchController.dispose();
    _activeTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (_isDisposed) return;
    
    print('🔄 Loading dosage calculator data...');
    
    // Use post-frame callback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_isDisposed) return;
      
      if (mounted) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });
      }

      try {
        // Load user profile first
        print('👤 Loading user profile...');
        final user = await _dosageService.getUserProfile();
        print('✅ User profile loaded: ${user != null ? 'Yes' : 'No'}');
        
        // Load all substances - ensure we don't proceed until substances are loaded
        print('💊 Loading substances...');
        final allSubstances = await _dosageService.getAllDosageSubstances();
        print('✅ Loaded ${allSubstances.length} substances');
        
        // Validate that substances are loaded properly
        if (allSubstances.isEmpty) {
          throw Exception('Keine Substanzen gefunden. Bitte prüfen Sie die Datenbank.');
        }
        
        // Take only validated substances with proper data
        final popularSubstances = allSubstances
            .where((substance) => 
              substance.name.isNotEmpty && 
              substance.lightDosePerKg > 0 &&
              substance.normalDosePerKg > 0 &&
              substance.strongDosePerKg > 0
            )
            .take(6)
            .toList();
        
        print('✅ Filtered to ${popularSubstances.length} valid substances');
        
        print('📊 Loading calculation history...');
        final history = await _dosageService.getDosageCalculationHistory();
        print('✅ Loaded ${history.length} calculation entries');

        if (_isDisposed) return;

        if (mounted) {
          setState(() {
            _currentUser = user;
            _popularSubstances = popularSubstances;
            _recentCalculations = history;
            _isLoading = false;
          });
        }
        
        print('✅ Data loading completed successfully');
      } catch (e, stackTrace) {
        print('❌ Error loading data: $e');
        print('Stack trace: $stackTrace');
        
        if (_isDisposed) return;
        
        if (mounted) {
          setState(() {
            _errorMessage = 'Fehler beim Laden der Daten: $e';
            _isLoading = false;
            // Ensure we have empty lists on error
            _popularSubstances = [];
            _recentCalculations = [];
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<service.PsychedelicThemeService>(
      builder: (context, psychedelicService, child) {
        final isPsychedelicMode = psychedelicService.isPsychedelicMode;
        
        return Scaffold(
          backgroundColor: isPsychedelicMode 
            ? DesignTokens.psychedelicBackground 
            : null,
          body: Container(
            decoration: isPsychedelicMode 
              ? const BoxDecoration(
                  gradient: DesignTokens.psychedelicBackground1,
                ) 
              : null,
            child: Column(
              children: [
                HeaderBar(
                  title: 'Dosisrechner',
                  subtitle: 'Sichere Dosierung berechnen',
                  showBackButton: false,
                  showLightningIcon: true,
                ),
                Expanded(
                  child: LayoutErrorBoundary(
                    debugLabel: 'Dosage Calculator Main Content',
                    child: _isLoading 
                        ? _buildLoadingState()
                        : _errorMessage != null
                            ? _buildErrorCard(context, isDark, psychedelicService)
                            : SafeScrollableColumn(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                children: [
                                  const SizedBox(height: 16),
                                  _buildUserProfileSection(context, isDark, psychedelicService),
                                  const SizedBox(height: 24),
                                  _buildSearchSection(context, isDark, psychedelicService),
                                  const SizedBox(height: 24),
                                  _buildPopularSubstancesSection(context, isDark, psychedelicService),
                                  const SizedBox(height: 24),
                                  _buildSafetyWarningSection(context, isDark, psychedelicService),
                                  if (_recentCalculations.isNotEmpty) ...[
                                    const SizedBox(height: 24),
                                    _buildRecentCalculationsSection(context, isDark, psychedelicService),
                                  ],
                                  const SizedBox(height: 120), // Space for FAB
                                ],
                              ),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: _buildSpeedDial(context, isDark, psychedelicService),
        );
      },
    );
  }

  Widget _buildModernAppBar(BuildContext context, bool isDark, service.PsychedelicThemeService psychedelicService) {
    final theme = Theme.of(context);
    final isPsychedelicMode = psychedelicService.isPsychedelicMode;
    final substanceColors = psychedelicService.getCurrentSubstanceColors();

    return Container(
      height: 140, // Consistent with other screens
      decoration: BoxDecoration(
        gradient: isPsychedelicMode
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  DesignTokens.psychedelicBackground,
                  substanceColors['primary']!.withOpacity(0.3),
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
                      Color(0xFF533483),
                    ],
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      DesignTokens.accentCyan,
                      DesignTokens.accentPurple,
                      DesignTokens.accentPink,
                    ],
                  ),
        boxShadow: [
          BoxShadow(
            color: isPsychedelicMode
                ? substanceColors['glow']!.withOpacity(0.5)
                : DesignTokens.accentCyan.withOpacity(0.3),
            blurRadius: isPsychedelicMode ? 30 : 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Timer banner if active
          if (_activeTimer != null) _buildTimerBanner(context, isDark),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Reduced padding
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    padding: EdgeInsets.zero, // Minimize padding
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                  const SizedBox(width: 8), // Reduced spacing
                  Container(
                    padding: const EdgeInsets.all(8), // Reduced from 12 to 8
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12), // Reduced from 16 to 12
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.2),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 2000),
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
                                  Colors.cyan.withOpacity(0.6),
                                  Colors.white,
                                ],
                                stops: [0.0, 0.3, 0.7, 1.0],
                                transform: GradientRotation(value * 3.14),
                              ).createShader(bounds);
                            },
                            child: const Icon(
                              Icons.calculate_rounded,
                              color: Colors.white,
                              size: 24, // Reduced from 28 to 24
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12), // Reduced spacing
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Dosisrechner Pro',
                            style: theme.textTheme.titleLarge?.copyWith( // Changed from headlineMedium to titleLarge
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              shadows: [
                                Shadow(
                                  color: DesignTokens.accentCyan.withOpacity(0.5),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 2), // Reduced from 4 to 2
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Präzise Dosierungsempfehlungen',
                              style: theme.textTheme.bodySmall?.copyWith( // Changed from bodyMedium to bodySmall
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Reduced padding
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16), // Reduced from 20 to 16
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_user_rounded,
                          color: Colors.white,
                          size: 14, // Reduced from 16 to 14
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Sicher',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11, // Reduced from 12 to 11
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerBanner(BuildContext context, bool isDark) {
    if (_timerSubstance == null) return const SizedBox.shrink();
    
    final progress = _timerDuration.inMilliseconds > 0
        ? ((_timerDuration.inMilliseconds - _remainingTime.inMilliseconds) / _timerDuration.inMilliseconds)
        : 0.0;
    
    final substanceColor = _getSubstanceColor(_timerSubstance!.name);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: substanceColor.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: substanceColor.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.timer_rounded,
            color: substanceColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_timerSubstance!.name} Timer',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: substanceColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        backgroundColor: substanceColor.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(substanceColor),
                        minHeight: 4,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDuration(_remainingTime),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: substanceColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _stopTimer,
            icon: Icon(
              Icons.stop_rounded,
              color: substanceColor,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  Widget _buildErrorCard(BuildContext context, bool isDark, service.PsychedelicThemeService psychedelicService) {
    return Padding(
      padding: Spacing.paddingMd,
      child: GlassCard(
        child: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: DesignTokens.errorRed,
              size: Spacing.iconLg,
            ),
            const SizedBox(width: Spacing.md),
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
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: Spacing.paddingMd,
      child: Column(
        children: List.generate(3, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: Spacing.md),
            child: GlassCard(
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: Spacing.borderRadiusMd,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildUserProfileSection(BuildContext context, bool isDark, service.PsychedelicThemeService psychedelicService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Benutzerprofil',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: Spacing.md),
        GlassCard(
          onTap: () => _navigateToUserProfile(),
          child: _currentUser != null
              ? _buildUserProfileContent(context, isDark)
              : _buildCreateProfileContent(context, isDark),
        ),
      ],
    );
  }

  Widget _buildUserProfileContent(BuildContext context, bool isDark) {
    final user = _currentUser!;
    
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: DesignTokens.successGreen.withOpacity(0.1),
            borderRadius: Spacing.borderRadiusMd,
            border: Border.all(
              color: DesignTokens.successGreen.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Icon(
            Icons.person_rounded,
            color: DesignTokens.successGreen,
            size: Spacing.iconLg,
          ),
        ),
        const SizedBox(width: Spacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profil aktiv',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: DesignTokens.successGreen,
                ),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                '${user.formattedWeight} • ${user.formattedHeight} • ${user.formattedAge}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                'BMI: ${user.formattedBmi} (${user.bmiCategory})',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.arrow_forward_ios_rounded,
          size: Spacing.iconSm,
          color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
        ),
      ],
    );
  }

  Widget _buildCreateProfileContent(BuildContext context, bool isDark) {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: DesignTokens.warningYellow.withOpacity(0.1),
            borderRadius: Spacing.borderRadiusMd,
            border: Border.all(
              color: DesignTokens.warningYellow.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Icon(
            Icons.person_add_rounded,
            color: DesignTokens.warningYellow,
            size: Spacing.iconLg,
          ),
        ),
        const SizedBox(width: Spacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profil erstellen',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: DesignTokens.warningYellow,
                ),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                'Erstellen Sie ein Profil für präzise Dosierungsberechnungen',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        Icon(
          Icons.arrow_forward_ios_rounded,
          size: Spacing.iconSm,
          color: DesignTokens.warningYellow,
        ),
      ],
    );
  }

  Widget _buildSearchSection(BuildContext context, bool isDark, service.PsychedelicThemeService psychedelicService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Substanz suchen',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: Spacing.md),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: DesignTokens.accentCyan.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: GlassCard(
            onTap: () => _navigateToSubstanceSearch(),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: DesignTokens.accentCyan.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: DesignTokens.accentCyan.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: DesignTokens.accentCyan.withOpacity(0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.search_rounded,
                      color: DesignTokens.accentCyan,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Substanz suchen',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: DesignTokens.accentCyan,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Dosierungsberechnung starten',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: DesignTokens.accentCyan,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPopularSubstancesSection(BuildContext context, bool isDark, service.PsychedelicThemeService psychedelicService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Häufig verwendet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () => _navigateToSubstanceSearch(),
              child: const Text('Alle anzeigen'),
            ),
          ],
        ),
        const SizedBox(height: Spacing.md),
        if (_popularSubstances.isNotEmpty)
          LayoutErrorBoundary(
            debugLabel: 'Popular Substances Wrap',
            child: Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              children: _popularSubstances.take(4).map((substance) {
                return SizedBox(
                  width: (MediaQuery.of(context).size.width - (16 * 3)) / 2, // Account for padding
                  height: _kSubstanceCardHeight, // Fixed height to prevent overflow
                  child: RepaintBoundary(
                    key: Key('substance_card_${substance.name}_${substance.hashCode}_${DateTime.now().millisecondsSinceEpoch % 10000}'),
                    child: _buildEnhancedSubstanceCard(context, substance, isDark),
                  ),
                );
              }).toList(),
            ),
          )
        else
          SizedBox(
            height: 200,
            child: Center(
              child: Text(
                'Keine Substanzen verfügbar',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
            ),
          ),
      ],
    );
  }


  Widget _buildEnhancedSubstanceCard(BuildContext context, DosageCalculatorSubstance substance, bool isDark) {
    final theme = Theme.of(context);
    final substanceColor = _getSubstanceColor(substance.name);
    final calculatedDose = _currentUser != null
        ? substance.calculateDosage(_currentUser!.weightKg, DosageIntensity.normal)
        : substance.normalDosePerKg * 70; // Default weight estimate
    final recommendedDose = _currentUser != null
        ? _currentUser!.getRecommendedDose(calculatedDose)
        : calculatedDose * 0.8; // Default 20% reduction

    // Get effective gradient colors based on administration route
    final isOral = substance.administrationRoute.toLowerCase() == 'oral';
    final List<Color> effectiveGradientColors = _getEffectiveGradientColors(isDark, isOral, substanceColor);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _kSubstanceCardHeight, // Fixed height to prevent overflow
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: substanceColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _calculateDosage(substance),
          borderRadius: BorderRadius.circular(24),
          splashColor: Colors.white.withOpacity(0.1),
          highlightColor: Colors.white.withOpacity(0.05),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // Background gradient
                Container(
                  height: _kSubstanceCardHeight, // Match outer container height
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: effectiveGradientColors,
                    ),
                  ),
                ),
                
                // Glassmorphism effect
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    height: _kSubstanceCardHeight, // Match outer container height
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.white.withOpacity(0.2),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.2)
                            : Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
                
                // Content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with icon and administration route
                        Row(
                          children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(0.15)
                                  : Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getSubstanceIcon(substance.name),
                              color: isDark
                                  ? Colors.white.withOpacity(0.9)
                                  : Colors.white,
                              size: 20,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: substanceColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: substanceColor.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              isOral ? 'Oral' : 'Nasal',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: substanceColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Substance name
                      Text(
                        substance.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: isDark
                              ? Colors.white.withOpacity(0.95)
                              : Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 6),
                      
                      // Risk assessment below substance name
                      _buildRiskAssessment(context, substance, isDark),
                      
                      const SizedBox(height: 12),
                      
                      // Dosage information
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: substanceColor.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _currentUser != null 
                                  ? _currentUser!.getDosageLabel() 
                                  : 'Empfohlene Dosis:',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark
                                    ? Colors.white.withOpacity(0.8)
                                    : Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${recommendedDose.toStringAsFixed(1)} mg',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: isDark
                                    ? Colors.white.withOpacity(0.95)
                                    : Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 22,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Duration display with enhanced styling
                      Consumer<service.PsychedelicThemeService>(
                        builder: (context, themeService, child) {
                          final timeDisplay = Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.schedule_rounded,
                                  color: isDark
                                      ? Colors.white.withOpacity(0.8)
                                      : Colors.white.withOpacity(0.9),
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  substance.duration,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: isDark
                                        ? Colors.white.withOpacity(0.8)
                                        : Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          );

                          // Add pulsating effect in trippy mode
                          if (themeService.isPsychedelicMode) {
                            return PulsatingWidget(
                              isEnabled: true,
                              glowColor: substanceColor,
                              child: timeDisplay,
                            );
                          }

                          return timeDisplay;
                        },
                      ),
                    ],
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

  Widget _buildRiskAssessment(BuildContext context, DosageCalculatorSubstance substance, bool isDark) {
    final theme = Theme.of(context);
    
    // Determine risk level based on substance type
    String riskText;
    Color riskColor;
    IconData riskIcon;
    
    final substanceName = substance.name.toLowerCase();
    if (substanceName.contains('lsd') || substanceName.contains('psilocybin')) {
      riskText = 'Mittleres Risiko';
      riskColor = DesignTokens.warningOrange;
      riskIcon = Icons.warning_amber_rounded;
    } else if (substanceName.contains('mdma') || substanceName.contains('amphetamin')) {
      riskText = 'Hohes Risiko';
      riskColor = DesignTokens.errorRed;
      riskIcon = Icons.error_rounded;
    } else if (substanceName.contains('cannabis')) {
      riskText = 'Niedriges Risiko';
      riskColor = DesignTokens.successGreen;
      riskIcon = Icons.check_circle_rounded;
    } else if (substanceName.contains('ketamin') || substanceName.contains('cocaine')) {
      riskText = 'Sehr hohes Risiko';
      riskColor = DesignTokens.riskCritical;
      riskIcon = Icons.dangerous_rounded;
    } else {
      riskText = 'Unbekanntes Risiko';
      riskColor = DesignTokens.warningYellow;
      riskIcon = Icons.help_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: riskColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: riskColor.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            riskIcon,
            color: riskColor,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            riskText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: riskColor,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  /// Determines effective gradient colors based on administration route and theme
  List<Color> _getEffectiveGradientColors(bool isDark, bool isOral, Color substanceColor) {
    if (isOral) {
      // Warm colors for oral administration
      if (isDark) {
        return [
          Colors.black.withOpacity(0.4),
          Colors.black.withOpacity(0.2),
          Color.lerp(substanceColor, Colors.orange, 0.2)!.withOpacity(0.3),
        ];
      } else {
        return [
          Colors.white.withOpacity(0.9),
          Colors.white.withOpacity(0.7),
          Color.lerp(substanceColor, Colors.deepOrange, 0.1)!.withOpacity(0.3),
        ];
      }
    } else {
      // Cool colors for nasal administration
      if (isDark) {
        return [
          Colors.black.withOpacity(0.4),
          Colors.black.withOpacity(0.2),
          Color.lerp(substanceColor, Colors.blue, 0.2)!.withOpacity(0.3),
        ];
      } else {
        return [
          Colors.white.withOpacity(0.9),
          Colors.white.withOpacity(0.7),
          Color.lerp(substanceColor, Colors.indigo, 0.1)!.withOpacity(0.3),
        ];
      }
    }
  }

  Widget _buildImprovedSubstanceCard(BuildContext context, DosageCalculatorSubstance substance) {
    return SubstanceQuickCard(
      substance: substance,
      userWeight: _currentUser?.weightKg,
      onTap: () => _calculateDosage(substance),
      showDosagePreview: true,
      isCompact: false,
    );
  }

  Widget _buildSimpleSubstanceCard(BuildContext context, DosageCalculatorSubstance substance) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final substanceColor = _getSubstanceColor(substance.name);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: substanceColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _calculateDosage(substance),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.white,
              borderRadius: BorderRadius.circular(16),
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
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: substanceColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getSubstanceIcon(substance.name),
                        color: substanceColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        substance.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: substanceColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (substance.description.isNotEmpty) ...[
                  Text(
                    substance.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                ],
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Dosierung',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        substance.durationWithIcon,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: substanceColor,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getSubstanceIcon(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('mdma') || lowerName.contains('ecstasy')) {
      return Icons.favorite_rounded;
    } else if (lowerName.contains('lsd') || lowerName.contains('acid')) {
      return Icons.psychology_rounded;
    } else if (lowerName.contains('cannabis') || lowerName.contains('weed')) {
      return Icons.grass_rounded;
    } else if (lowerName.contains('psilocybin') || lowerName.contains('mushroom')) {
      return Icons.forest_rounded;
    } else if (lowerName.contains('cocaine') || lowerName.contains('amphetamine')) {
      return Icons.flash_on_rounded;
    } else if (lowerName.contains('alcohol')) {
      return Icons.local_bar_rounded;
    } else if (lowerName.contains('caffeine')) {
      return Icons.coffee_rounded;
    }
    return Icons.science_rounded;
  }

  Widget _buildSafetyWarningSection(BuildContext context, bool isDark, service.PsychedelicThemeService psychedelicService) {
    return GlassCard(
      borderColor: DesignTokens.errorRed.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_rounded,
                color: DesignTokens.errorRed,
                size: Spacing.iconMd,
              ),
              const SizedBox(width: Spacing.sm),
              Text(
                'Wichtiger Hinweis',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: DesignTokens.errorRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Text(
            'Der Dosisrechner dient ausschließlich informativen Zwecken. Die berechneten Werte sind Richtwerte und ersetzen keine medizinische Beratung. Jeder Konsum erfolgt auf eigene Verantwortung.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            'Grundlegende Sicherheitsprinzipien:',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: DesignTokens.errorRed,
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            '• Beginnen Sie immer mit der niedrigsten Dosis\n• Warten Sie die volle Wirkdauer ab\n• Kombinieren Sie niemals verschiedene Substanzen\n• Verwenden Sie eine Feinwaage für genaue Dosierung\n• Sorgen Sie für eine sichere Umgebung und Begleitung\n• Bei gesundheitlichen Problemen konsultieren Sie einen Arzt',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Container(
            padding: const EdgeInsets.all(Spacing.sm),
            decoration: BoxDecoration(
              color: DesignTokens.warningYellow.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: DesignTokens.warningYellow.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: DesignTokens.warningYellow,
                  size: Spacing.iconSm,
                ),
                const SizedBox(width: Spacing.xs),
                Expanded(
                  child: Text(
                    'Erstellen Sie ein Benutzerprofil für präzise, gewichtsbezogene Dosierungsberechnungen.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: DesignTokens.warningYellow,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentCalculationsSection(BuildContext context, bool isDark, service.PsychedelicThemeService psychedelicService) {
    if (_recentCalculations.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Letzte Berechnungen',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          constraints: const BoxConstraints(
            maxHeight: 300, // Constrain height to prevent overflow
          ),
          child: LayoutErrorBoundary(
            debugLabel: 'Recent Calculations List',
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentCalculations.length.clamp(0, 5), // Limit to 5 items
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final calculation = _recentCalculations[index];
                final calculationId = calculation['id']?.toString() ?? '';
                final substanceName = calculation['substance']?.toString() ?? '';
                final uniqueKey = 'recent_calc_${calculationId}_${substanceName}_$index'; // More unique key
                
                return LayoutErrorBoundary(
                  debugLabel: 'Recent Calculation Item',
                  child: RepaintBoundary(
                    key: Key(uniqueKey),
                    child: GlassCard(
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: DesignTokens.accentCyan.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.history_rounded,
                            color: DesignTokens.accentCyan,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          substanceName.isNotEmpty ? substanceName : 'Unbekannt',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${calculation['dosage']?.toString() ?? 'N/A'} • ${calculation['date']?.toString() ?? 'N/A'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded),
                        onTap: () {
                          // TODO: Show calculation details
                          print('Tapped on calculation: $substanceName');
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _navigateToUserProfile() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const UserProfileScreen(),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  Future<void> _navigateToSubstanceSearch() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SubstanceSearchScreen(),
      ),
    );

    if (result != null) {
      _loadData();
    }
  }

  Future<void> _calculateDosage(DosageCalculatorSubstance substance) async {
    if (_isDisposed) return;
    
    print('🧮 Starting dosage calculation for: ${substance.name}');
    
    // Validate substance data before proceeding
    if (substance.name.isEmpty || 
        substance.lightDosePerKg <= 0 ||
        substance.normalDosePerKg <= 0 ||
        substance.strongDosePerKg <= 0) {
      print('❌ Invalid substance data: ${substance.name}');
      if (mounted && !_isDisposed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler: Ungültige Substanzdaten für ${substance.name}'),
            backgroundColor: DesignTokens.errorRed,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }
    
    if (_currentUser == null) {
      print('⚠️ No user profile found, showing create profile dialog');
      _showCreateProfileDialog();
      return;
    }

    // Prevent multiple simultaneous calculations
    if (_isModalOpen) {
      print('⚠️ Modal already open, ignoring calculation request');
      return;
    }

    try {
      print('📊 Calculating dosage for user weight: ${_currentUser!.weightKg} kg');
      
      final lightDose = substance.calculateDosage(_currentUser!.weightKg, DosageIntensity.light);
      final normalDose = substance.calculateDosage(_currentUser!.weightKg, DosageIntensity.normal);
      final strongDose = substance.calculateDosage(_currentUser!.weightKg, DosageIntensity.strong);
      
      print('✅ Calculated doses - Light: $lightDose, Normal: $normalDose, Strong: $strongDose');
      
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
      
      await _showDosageResult(substance, calculation);
    } catch (e, stackTrace) {
      print('❌ Error during dosage calculation: $e');
      print('Stack trace: $stackTrace');
      
      if (mounted && !_isDisposed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler bei der Berechnung: $e'),
            backgroundColor: DesignTokens.errorRed,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _showCreateProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profil erforderlich'),
        content: const Text(
          'Für die Dosierungsberechnung benötigen Sie ein Benutzerprofil mit Ihren körperlichen Daten.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToUserProfile();
            },
            child: const Text('Profil erstellen'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDosageResult(DosageCalculatorSubstance substance, DosageCalculation calculation) async {
    if (_isDisposed) return;
    
    if (_isModalOpen) {
      print('⚠️ Modal already open, ignoring request');
      return;
    }
    
    try {
      print('🔄 Showing dosage result modal for substance: ${substance.name}');
      
      if (!mounted) {
        print('❌ Widget not mounted, cannot show modal');
        return;
      }
      
      _isModalOpen = true;
      
      // Use a post-frame callback to ensure the context is ready
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted || _isDisposed) {
          _isModalOpen = false;
          return;
        }
        
        try {
          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            isDismissible: true,
            enableDrag: true,
            useSafeArea: true,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9,
              maxWidth: MediaQuery.of(context).size.width,
            ),
            builder: (BuildContext modalContext) {
              print('✅ Modal builder called successfully');
              return LayoutErrorBoundary(
                debugLabel: 'Dosage Result Modal',
                child: _SafeDosageResultCard(
                  substance: substance,
                  calculation: calculation,
                  user: _currentUser!,
                ),
              );
            },
          );
          
          print('✅ Modal dismissed successfully');
        } catch (e, stackTrace) {
          print('❌ Error showing modal: $e');
          print('Stack trace: $stackTrace');
          
          if (mounted && !_isDisposed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Fehler beim Anzeigen der Dosierungsberechnung: $e'),
                backgroundColor: DesignTokens.errorRed,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        } finally {
          _isModalOpen = false;
        }
      });
    } catch (e, stackTrace) {
      print('❌ Error setting up dosage result modal: $e');
      print('Stack trace: $stackTrace');
      
      _isModalOpen = false;
      
      if (mounted && !_isDisposed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Anzeigen der Dosierungsberechnung: $e'),
            backgroundColor: DesignTokens.errorRed,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Widget _buildSpeedDial(BuildContext context, bool isDark, service.PsychedelicThemeService psychedelicService) {
    final speedDialChildren = <SpeedDialChild>[
      FABHelper.createSpeedDialChild(
        icon: Icons.add_rounded,
        label: 'Neuer Eintrag',
        backgroundColor: DesignTokens.primaryIndigo,
        onTap: () => _showAddEntryDialogWithBlur(context, isDark, psychedelicService),
      ),
      FABHelper.createSpeedDialChild(
        icon: Icons.timer_rounded,
        label: 'Timer starten',
        backgroundColor: DesignTokens.accentPurple,
        onTap: () => _showTimerDialogWithBlur(context, isDark, psychedelicService),
      ),
    ];

    return ConsistentFAB(
      speedDialChildren: speedDialChildren,
      mainIcon: Icons.calculate_rounded,
      backgroundColor: DesignTokens.accentPink,
      onMainAction: () => _showAddEntryDialogWithBlur(context, isDark, psychedelicService),
    );
  }

  void _showAddEntryDialogWithBlur(BuildContext context, bool isDark, service.PsychedelicThemeService psychedelicService) {
    if (_isDisposed) return;
    
    try {
      print('🔄 Showing add entry modal...');
      
      if (!mounted) {
        print('❌ Widget not mounted, cannot show add entry modal');
        return;
      }
      
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withOpacity(0.5),
        isDismissible: true,
        enableDrag: true,
        useSafeArea: true,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        builder: (modalContext) {
          print('✅ Add entry modal builder called');
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: _AddEntryModal(
              onSubstanceSelected: (substance) {
                print('✅ Substance selected: ${substance.name}');
                Navigator.of(modalContext).pop();
                if (mounted && !_isDisposed) {
                  _calculateDosage(substance);
                }
              },
              substances: _popularSubstances,
              isDark: isDark,
            ),
          );
        },
      );
    } catch (e, stackTrace) {
      print('❌ Error showing add entry modal: $e');
      print('Stack trace: $stackTrace');
      
      if (mounted && !_isDisposed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Öffnen des Dialogs: $e'),
            backgroundColor: DesignTokens.errorRed,
          ),
        );
      }
    }
  }

  void _showTimerDialogWithBlur(BuildContext context, bool isDark, service.PsychedelicThemeService psychedelicService) {
    if (_isDisposed) return;
    
    try {
      print('🔄 Showing timer modal...');
      
      if (!mounted) {
        print('❌ Widget not mounted, cannot show timer modal');
        return;
      }
      
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withOpacity(0.5),
        isDismissible: true,
        enableDrag: true,
        useSafeArea: true,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        builder: (modalContext) {
          print('✅ Timer modal builder called');
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: _TimerSelectionModal(
              substances: _popularSubstances,
              isDark: isDark,
              onTimerStarted: (substance, duration) {
                print('✅ Timer started for: ${substance.name}, duration: $duration');
                Navigator.of(modalContext).pop();
                if (mounted && !_isDisposed) {
                  _startTimerForSubstance(substance, duration);
                }
              },
            ),
          );
        },
      );
    } catch (e, stackTrace) {
      print('❌ Error showing timer modal: $e');
      print('Stack trace: $stackTrace');
      
      if (mounted && !_isDisposed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Öffnen des Timer-Dialogs: $e'),
            backgroundColor: DesignTokens.errorRed,
          ),
        );
      }
    }
  }



  void _startTimerForSubstance(DosageCalculatorSubstance substance, Duration duration) {
    if (_isDisposed) return;
    
    if (mounted) {
      setState(() {
        _timerSubstance = substance;
        _timerDuration = duration;
        _remainingTime = duration;
      });
    }
    
    _activeTimer?.cancel();
    _activeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isDisposed) {
        timer.cancel();
        return;
      }
      
      if (mounted) {
        setState(() {
          _remainingTime = _remainingTime - const Duration(seconds: 1);
          
          if (_remainingTime.inSeconds <= 0) {
            _stopTimer();
          }
        });
      }
    });
    
    if (mounted && !_isDisposed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Timer für ${substance.name} gestartet (${_formatDuration(duration)})'),
          backgroundColor: DesignTokens.successGreen,
        ),
      );
    }
  }

  void _stopTimer() {
    _activeTimer?.cancel();
    if (mounted && !_isDisposed) {
      setState(() {
        _activeTimer = null;
        _timerSubstance = null;
        _timerDuration = Duration.zero;
        _remainingTime = Duration.zero;
      });
    }
  }

  Color _getSubstanceColor(String substanceName) {
    final substanceColorMap = DesignTokens.getSubstanceColor(substanceName);
    return substanceColorMap['primary'] ?? DesignTokens.primaryIndigo;
  }
}

// Safer DosageResultCard with better error handling
class _SafeDosageResultCard extends StatefulWidget {
  final DosageCalculatorSubstance substance;
  final DosageCalculation calculation;
  final DosageCalculatorUser user;

  const _SafeDosageResultCard({
    required this.substance,
    required this.calculation,
    required this.user,
  });

  @override
  State<_SafeDosageResultCard> createState() => _SafeDosageResultCardState();
}

class _SafeDosageResultCardState extends State<_SafeDosageResultCard> {
  DosageIntensity _selectedIntensity = DosageIntensity.normal; // Start with normal/optimal dose

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: mediaQuery.size.height * 0.9,
        maxWidth: mediaQuery.size.width,
        minHeight: 300, // Ensure minimum height
      ),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            _buildHeader(context, isDark),
            SafeExpanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: 200,
                    maxWidth: mediaQuery.size.width - 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
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
            ),
          ],
        ),
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
        mainAxisSize: MainAxisSize.min,
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Dosierungsberechnung',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      widget.substance.name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.substance.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.indigo,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Dosierungsbereich: ${widget.substance.lightDosePerKg.toStringAsFixed(1)} - ${widget.substance.strongDosePerKg.toStringAsFixed(1)} mg/kg',
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
        mainAxisSize: MainAxisSize.min,
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.monitor_weight_rounded, color: Colors.indigo),
                    const SizedBox(height: 4),
                    Text(
                      widget.user.formattedWeight,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.indigo,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Gewicht', 
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.analytics_rounded, color: Colors.green),
                    const SizedBox(height: 4),
                    Text(
                      widget.user.formattedBmi,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'BMI', 
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_rounded, color: Colors.cyan),
                    const SizedBox(height: 4),
                    Text(
                      widget.user.formattedAge,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.cyan,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Alter', 
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Dosierungsstärke wählen',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: DosageIntensity.values.map((intensity) {
                  final isSelected = intensity == _selectedIntensity;
                  final color = _getDosageColor(intensity);
                  final dose = _getDoseForIntensity(intensity);
                  final cardWidth = (constraints.maxWidth / 3).clamp(100.0, 150.0);

                  return Container(
                    width: cardWidth,
                    margin: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIntensity = intensity;
                        });
                      },
                      child: Container(
                        constraints: const BoxConstraints(
                          minHeight: 80,
                          maxHeight: 100,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? color : Colors.grey,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
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
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${dose.toStringAsFixed(1)} mg',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isSelected ? color : Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSelectedDosageInfo(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final color = _getDosageColor(_selectedIntensity);
    final dose = _getDoseForIntensity(_selectedIntensity);

    return Container(
      padding: const EdgeInsets.all(20),
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
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.user.getDosageLabel(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${dose.toStringAsFixed(1)} mg',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${_selectedIntensity.displayName} Intensität',
                  style: theme.textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Enhanced duration information with better styling
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
    final selectedDose = _getDoseForIntensity(_selectedIntensity);
    final substanceWarning = widget.substance.getSafetyWarning(selectedDose, widget.user.weightKg);

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
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_rounded,
                color: Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Sicherheitshinweise',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Dosage-specific warning if exists
          if (substanceWarning != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.red.withOpacity(0.4),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      substanceWarning,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Substance-specific safety notes
          Text(
            widget.substance.safetyNotes,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          
          // Enhanced general safety principles
          Text(
            'Grundlegende Sicherheitsprinzipien:',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '• Beginnen Sie immer mit der niedrigsten Dosis\n• Warten Sie die volle Wirkdauer ab (${widget.substance.duration})\n• Kombinieren Sie niemals verschiedene Substanzen\n• Verwenden Sie eine Feinwaage für genaue Dosierung\n• Sorgen Sie für eine sichere Umgebung und Begleitung\n• Bei Problemen sofort medizinische Hilfe suchen',
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
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _saveAsEntry(context),
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
    
    // Apply user's dosage strategy
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

  /// Saves the current dosage calculation as an entry with timer
  Future<void> _saveAsEntry(BuildContext context) async {
    try {
      // Get required services
      final createEntryUseCase = ServiceLocator.get<CreateEntryWithTimerUseCase>();
      final substanceService = ServiceLocator.get<SubstanceService>();
      
      // Find substance by name to get ID
      final substance = await substanceService.getSubstanceByName(widget.substance.name);
      if (substance == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Substanz nicht gefunden'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      
      // Get selected dose and unit
      final selectedDose = _getDoseForIntensity(_selectedIntensity);
      final unit = widget.calculation.unit;
      
      // Parse duration from substance
      final customDuration = TimerService.parseDurationFromString(widget.substance.duration);
      
      // Create entry with timer
      await createEntryUseCase.execute(
        substanceId: substance.id,
        dosage: selectedDose,
        unit: unit,
        customDuration: customDuration,
      );
      
      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Eintrag erfolgreich gespeichert und Timer gestartet'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate back
        Navigator.pop(context);
      }
    } catch (e) {
      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Speichern: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Modal for adding new entry
class _AddEntryModal extends StatelessWidget {
  final Function(DosageCalculatorSubstance) onSubstanceSelected;
  final List<DosageCalculatorSubstance> substances;
  final bool isDark;

  const _AddEntryModal({
    required this.onSubstanceSelected,
    required this.substances,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return Container(
      height: mediaQuery.size.height * 0.7,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildModalHeader(context, 'Neuer Eintrag', Icons.add_rounded),
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
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: substances.length,
                      itemBuilder: (context, index) {
                        final substance = substances[index];
                        return GestureDetector(
                          onTap: () => onSubstanceSelected(substance),
                          child: SubstanceQuickCard(
                            substance: substance,
                            showDosagePreview: false,
                            isCompact: true,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModalHeader(BuildContext context, String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
              : [DesignTokens.primaryIndigo, DesignTokens.primaryPurple],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Modal for timer selection
class _TimerSelectionModal extends StatefulWidget {
  final List<DosageCalculatorSubstance> substances;
  final bool isDark;
  final Function(DosageCalculatorSubstance, Duration) onTimerStarted;

  const _TimerSelectionModal({
    required this.substances,
    required this.isDark,
    required this.onTimerStarted,
  });

  @override
  State<_TimerSelectionModal> createState() => _TimerSelectionModalState();
}

class _TimerSelectionModalState extends State<_TimerSelectionModal> {
  DosageCalculatorSubstance? selectedSubstance;
  int selectedMinutes = 30;
  final List<int> timerOptions = [15, 30, 45, 60, 90, 120, 180, 240, 360];

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
          _buildModalHeader(context, 'Timer starten', Icons.timer_rounded),
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
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.substances.length,
                      itemBuilder: (context, index) {
                        final substance = widget.substances[index];
                        final isSelected = selectedSubstance == substance;
                        final color = _getSubstanceColor(substance.name);
                        
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedSubstance = substance;
                            });
                          },
                          child: Container(
                            width: 100,
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? color.withOpacity(0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? color : Colors.grey,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _getSubstanceIcon(substance.name),
                                  color: isSelected ? color : Colors.grey,
                                  size: 24,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  substance.name,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: isSelected ? color : null,
                                    fontWeight: isSelected ? FontWeight.w600 : null,
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
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Timer-Dauer',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 2.5,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: timerOptions.length,
                      itemBuilder: (context, index) {
                        final minutes = timerOptions[index];
                        final isSelected = selectedMinutes == minutes;
                        final color = DesignTokens.accentEmerald;
                        
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedMinutes = minutes;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? color.withOpacity(0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? color : Colors.grey,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${minutes} Min',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: isSelected ? color : null,
                                  fontWeight: isSelected ? FontWeight.w600 : null,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: selectedSubstance != null
                          ? () {
                              widget.onTimerStarted(
                                selectedSubstance!,
                                Duration(minutes: selectedMinutes),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignTokens.accentEmerald,
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
                  ),
                ],
                ),
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildModalHeader(BuildContext context, String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.isDark
              ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
              : [DesignTokens.primaryIndigo, DesignTokens.primaryPurple],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getSubstanceColor(String substanceName) {
    final substanceColorMap = DesignTokens.getSubstanceColor(substanceName);
    return substanceColorMap['primary'] ?? DesignTokens.primaryIndigo;
  }

  IconData _getSubstanceIcon(String substanceName) {
    final name = substanceName.toLowerCase();
    
    if (name.contains('mdma') || name.contains('ecstasy')) {
      return Icons.favorite_rounded;
    } else if (name.contains('lsd') || name.contains('acid')) {
      return Icons.psychology_rounded;
    } else if (name.contains('ketamin') || name.contains('ketamine')) {
      return Icons.medical_services_rounded;
    } else if (name.contains('kokain') || name.contains('cocaine')) {
      return Icons.bolt_rounded;
    } else if (name.contains('alkohol') || name.contains('alcohol')) {
      return Icons.local_bar_rounded;
    } else if (name.contains('cannabis') || name.contains('thc')) {
      return Icons.local_florist_rounded;
    } else if (name.contains('psilocybin') || name.contains('mushroom')) {
      return Icons.forest_rounded;
    } else if (name.contains('2c-b')) {
      return Icons.auto_awesome_rounded;
    } else if (name.contains('amphetamin') || name.contains('speed')) {
      return Icons.flash_on_rounded;
    } else {
      return Icons.science_rounded;
    }
  }
}
