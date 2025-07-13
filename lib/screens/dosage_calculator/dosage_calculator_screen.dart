import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../../models/dosage_calculator_user.dart';
import '../../models/dosage_calculator_substance.dart';
import '../../models/dosage_calculation.dart';
import '../../services/dosage_calculator_service.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/dosage_calculator/bmi_indicator.dart';
import '../../widgets/dosage_calculator/substance_quick_card.dart';
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
  final DosageCalculatorService _dosageService = DosageCalculatorService();
  final _searchController = TextEditingController();

  DosageCalculatorUser? _currentUser;
  List<DosageCalculatorSubstance> _popularSubstances = [];
  List<Map<String, dynamic>> _recentCalculations = [];
  bool _isLoading = true;
  bool _isDisposed = false;
  String? _errorMessage;

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
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _dosageService.getUserProfile();
      final allSubstances = await _dosageService.getAllDosageSubstances();
      final popularSubstances = allSubstances.take(6).toList();
      final history = await _dosageService.getDosageCalculationHistory();

      if (_isDisposed) return;

      setState(() {
        _currentUser = user;
        _popularSubstances = popularSubstances;
        _recentCalculations = history;
        _isLoading = false;
      });
    } catch (e) {
      if (_isDisposed) return;
      
      setState(() {
        _errorMessage = 'Fehler beim Laden der Daten: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Column(
        children: [
          _buildModernAppBar(context, isDark),
          Expanded(
            child: _isLoading 
                ? _buildLoadingState()
                : _errorMessage != null
                    ? _buildErrorCard(context, isDark)
                    : CustomScrollView(
                        slivers: [
                          SliverPadding(
                            padding: Spacing.paddingHorizontalMd,
                            sliver: SliverList(
                              delegate: SliverChildListDelegate([
                                _buildUserProfileSection(context, isDark),
                                const SizedBox(height: Spacing.lg),
                                _buildSearchSection(context, isDark),
                                const SizedBox(height: Spacing.lg),
                                _buildPopularSubstancesSection(context, isDark),
                                const SizedBox(height: Spacing.lg),
                                _buildSafetyWarningSection(context, isDark),
                                if (_recentCalculations.isNotEmpty) ...[
                                  const SizedBox(height: Spacing.lg),
                                  _buildRecentCalculationsSection(context, isDark),
                                ],
                                const SizedBox(height: 120),
                              ]),
                            ),
                          ),
                        ],
                      ),
          ),
        ],
      ),
      floatingActionButton: _buildSpeedDial(context, isDark),
    );
  }

  Widget _buildModernAppBar(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return Container(
      height: 160,
      decoration: BoxDecoration(
        gradient: isDark
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
            color: DesignTokens.accentCyan.withOpacity(0.3),
            blurRadius: 20,
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
              padding: Spacing.paddingMd,
              child: Column(
                children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  ),
                  const Spacer(),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
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
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Sicher',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.calculate_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dosisrechner Pro',
                          style: theme.textTheme.headlineMedium?.copyWith(
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
                        const SizedBox(height: 4),
                        Text(
                          'Präzise Dosierungsempfehlungen',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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

  Widget _buildErrorCard(BuildContext context, bool isDark) {
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

  Widget _buildUserProfileSection(BuildContext context, bool isDark) {
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

  Widget _buildSearchSection(BuildContext context, bool isDark) {
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

  Widget _buildPopularSubstancesSection(BuildContext context, bool isDark) {
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
          LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth;
              final cardWidth = ((availableWidth - Spacing.md) / 2).clamp(160.0, 180.0);
              
              return Wrap(
                spacing: Spacing.md,
                runSpacing: Spacing.md,
                children: _popularSubstances.take(4).map((substance) {
                  return RepaintBoundary(
                    child: SizedBox(
                      width: cardWidth,
                      height: 240,
                      child: _buildEnhancedSubstanceCard(context, substance, isDark),
                    ),
                  );
                }).toList(),
              );
            },
          )
        else
          Container(
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
    final recommendedDose = _currentUser != null
        ? (substance.calculateDosage(_currentUser!.weightKg, DosageIntensity.light) * 0.8) // 20% reduction
        : substance.lightDosePerKg * 70; // Default weight estimate

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: substanceColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: substanceColor.withOpacity(0.1),
            blurRadius: 40,
            offset: const Offset(0, 16),
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
              gradient: isDark
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.black.withOpacity(0.4),
                        Colors.black.withOpacity(0.2),
                        substanceColor.withOpacity(0.1),
                      ],
                    )
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.9),
                        Colors.white.withOpacity(0.7),
                        substanceColor.withOpacity(0.1),
                      ],
                    ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: substanceColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon and administration route
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: substanceColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: substanceColor.withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(
                        _getSubstanceIcon(substance.name),
                        color: substanceColor,
                        size: 24,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: substanceColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: substanceColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        substance.administrationRoute,
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
                
                // Substance name with glow effect
                Text(
                  substance.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: substanceColor,
                    fontSize: 16,
                    shadows: [
                      Shadow(
                        color: substanceColor.withOpacity(0.5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 8),
                
                // Duration with icon
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      color: isDark ? Colors.white70 : Colors.grey[600],
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        substance.duration,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white70 : Colors.grey[600],
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Recommended dose section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: substanceColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: substanceColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Empfohlene Dosis',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: substanceColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${recommendedDose.toStringAsFixed(1)} mg',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: substanceColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '(15-20% reduziert)',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white60 : Colors.grey[600],
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Action button
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () => _calculateDosage(substance),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: substanceColor.withOpacity(0.2),
                      foregroundColor: substanceColor,
                      side: BorderSide(
                        color: substanceColor.withOpacity(0.5),
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                      shadowColor: substanceColor.withOpacity(0.3),
                    ),
                    child: Text(
                      'Berechnen',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: substanceColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Berechnen',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: substanceColor,
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

  Widget _buildSafetyWarningSection(BuildContext context, bool isDark) {
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

  Widget _buildRecentCalculationsSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Letzte Berechnungen',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: Spacing.md),
        Column(
          children: _recentCalculations.map((calculation) {
            return Padding(
              padding: const EdgeInsets.only(bottom: Spacing.sm),
              child: GlassCard(
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(Spacing.xs),
                    decoration: BoxDecoration(
                      color: DesignTokens.accentCyan.withOpacity(0.1),
                      borderRadius: Spacing.borderRadiusSm,
                    ),
                    child: Icon(
                      Icons.history_rounded,
                      color: DesignTokens.accentCyan,
                      size: Spacing.iconMd,
                    ),
                  ),
                  title: Text(calculation['substance'] ?? 'Unbekannt'),
                  subtitle: Text('${calculation['dosage']} • ${calculation['date']}'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded),
                  onTap: () {
                    // TODO: Show calculation details
                  },
                ),
              ),
            );
          }).toList(),
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
            backgroundColor: DesignTokens.errorRed,
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

  Widget _buildSpeedDial(BuildContext context, bool isDark) {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 24),
      backgroundColor: isDark ? DesignTokens.neonPurple : DesignTokens.primaryIndigo,
      foregroundColor: Colors.white,
      elevation: 8.0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
      ),
      children: [
        SpeedDialChild(
          child: Icon(Icons.add_rounded, color: Colors.white),
          backgroundColor: DesignTokens.accentCyan,
          label: 'Neuer Eintrag',
          labelStyle: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
          onTap: () => _showAddEntryDialog(context, isDark),
        ),
        SpeedDialChild(
          child: Icon(Icons.timer_rounded, color: Colors.white),
          backgroundColor: DesignTokens.accentEmerald,
          label: 'Timer starten',
          labelStyle: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
          onTap: () => _showTimerDialog(context, isDark),
        ),
      ],
    );
  }

  void _showAddEntryDialog(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddEntryModal(
        onSubstanceSelected: (substance) {
          Navigator.of(context).pop();
          _calculateDosage(substance);
        },
        substances: _popularSubstances,
        isDark: isDark,
      ),
    );
  }

  void _showTimerDialog(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TimerSelectionModal(
        substances: _popularSubstances,
        isDark: isDark,
        onTimerStarted: (substance, duration) {
          Navigator.of(context).pop();
          _startTimerForSubstance(substance, duration);
        },
      ),
    );
  }

  void _startTimerForSubstance(DosageCalculatorSubstance substance, Duration duration) {
    setState(() {
      _timerSubstance = substance;
      _timerDuration = duration;
      _remainingTime = duration;
    });
    
    _activeTimer?.cancel();
    _activeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isDisposed) {
        timer.cancel();
        return;
      }
      
      setState(() {
        _remainingTime = _remainingTime - const Duration(seconds: 1);
        
        if (_remainingTime.inSeconds <= 0) {
          _stopTimer();
        }
      });
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Timer für ${substance.name} gestartet (${_formatDuration(duration)})'),
        backgroundColor: DesignTokens.successGreen,
      ),
    );
  }

  void _stopTimer() {
    _activeTimer?.cancel();
    setState(() {
      _activeTimer = null;
      _timerSubstance = null;
      _timerDuration = Duration.zero;
      _remainingTime = Duration.zero;
    });
  }

  Color _getSubstanceColor(String substanceName) {
    final substanceColorMap = DesignTokens.getSubstanceColor(substanceName);
    return substanceColorMap['primary'] ?? DesignTokens.primaryIndigo;
  }
}

// Vereinfachte DosageResultCard
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
  DosageIntensity _selectedIntensity = DosageIntensity.light;

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
        LayoutBuilder(
          builder: (context, constraints) {
            return Row(
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
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                intensity.displayName,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? color : null,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '${dose.toStringAsFixed(1)} mg',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isSelected ? color : Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
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
                  'Empfohlene Dosis',
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
    switch (intensity) {
      case DosageIntensity.light:
        return widget.calculation.lightDose;
      case DosageIntensity.normal:
        return widget.calculation.normalDose;
      case DosageIntensity.strong:
        return widget.calculation.strongDose;
    }
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
