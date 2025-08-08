import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
// removed unused import: package:flutter/foundation.dart // cleaned by BereinigungsAgent
import '../services/analytics_service.dart';
import '../services/enhanced_analytics_service.dart';
import '../utils/service_locator.dart'; // refactored by ArchitekturAgent
import '../widgets/glass_card.dart';
import '../widgets/header_bar.dart';
import '../widgets/insight_card.dart';
import '../widgets/charts/line_chart_widget.dart';
import '../widgets/charts/bar_chart_widget.dart';
import '../widgets/charts/pie_chart_widget.dart';
import '../widgets/charts/heatmap_widget.dart';
import '../widgets/charts/correlation_matrix_widget.dart';
import '../widgets/charts/trend_comparison_widget.dart';
import '../widgets/charts/predictive_trend_widget.dart';
import '../widgets/charts/budget_tracking_widget.dart';
import '../theme/design_tokens.dart';
import '../theme/spacing.dart';
import '../utils/performance_helper.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final AnalyticsService _analyticsService = ServiceLocator.get<AnalyticsService>(); // refactored by ArchitekturAgent
  late final EnhancedAnalyticsService _enhancedAnalyticsService;
  
  TimePeriod _selectedPeriod = TimePeriod.thisWeek;
  Map<String, dynamic>? _comprehensiveStats;
  Map<String, dynamic>? _enhancedStats;
  List<Map<String, dynamic>>? _consumptionTrends;
  List<Map<String, dynamic>>? _substanceStats;
  Map<String, dynamic>? _costAnalysis;
  Map<String, dynamic>? _enhancedCostAnalysis;
  Map<String, dynamic>? _riskAnalysis;
  Map<String, dynamic>? _patternAnalysis;
  Map<String, dynamic>? _correlationAnalysis;
  
  bool _isLoading = true;
  bool _isDisposed = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _enhancedAnalyticsService = EnhancedAnalyticsService();
    _tabController = TabController(length: 3, vsync: this);
    _loadStatistics();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStatistics() async {
    if (_isDisposed) return;
    
    // Use performance helper to measure execution time in debug mode
    await PerformanceHelper.measureExecutionTime(() async {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        // Load enhanced analytics data
        final results = await Future.wait([
          _enhancedAnalyticsService.getEnhancedComprehensiveStats(_selectedPeriod),
          _analyticsService.getConsumptionTrends(_selectedPeriod),
          _analyticsService.getSubstanceStats(_selectedPeriod),
          _enhancedAnalyticsService.getEnhancedCostAnalysis(_selectedPeriod),
          _analyticsService.getRiskAnalysis(_selectedPeriod),
          _enhancedAnalyticsService.getDetailedPatternAnalysis(),
          _enhancedAnalyticsService.getSubstanceRelationshipAnalysis(),
        ]);

        if (_isDisposed) return;

        setState(() {
          _enhancedStats = results[0] as Map<String, dynamic>;
          _comprehensiveStats = _enhancedStats!; // For backward compatibility
          _consumptionTrends = results[1] as List<Map<String, dynamic>>;
          _substanceStats = results[2] as List<Map<String, dynamic>>;
          _enhancedCostAnalysis = results[3] as Map<String, dynamic>;
          _costAnalysis = _enhancedCostAnalysis!; // For backward compatibility
          _riskAnalysis = results[4] as Map<String, dynamic>;
          _patternAnalysis = results[5] as Map<String, dynamic>;
          _correlationAnalysis = results[6] as Map<String, dynamic>;
          _isLoading = false;
        });
      } catch (e) {
        if (_isDisposed) return;
        
        setState(() {
          _errorMessage = 'Fehler beim Laden der Statistiken: $e';
          _isLoading = false;
        });
      }
    }, tag: 'Enhanced Statistics Loading');
  }
  
  // Original method (replaced with the above)
  Future<void> _loadStatisticsOriginal() async {
    if (_isDisposed) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _analyticsService.getComprehensiveStats(_selectedPeriod),
        _analyticsService.getConsumptionTrends(_selectedPeriod),
        _analyticsService.getSubstanceStats(_selectedPeriod),
        _analyticsService.getCostAnalysis(_selectedPeriod),
        _analyticsService.getRiskAnalysis(_selectedPeriod),
      ]);

      if (_isDisposed) return;

      setState(() {
        _comprehensiveStats = results[0] as Map<String, dynamic>;
        _consumptionTrends = results[1] as List<Map<String, dynamic>>;
        _substanceStats = results[2] as List<Map<String, dynamic>>;
        _costAnalysis = results[3] as Map<String, dynamic>;
        _riskAnalysis = results[4] as Map<String, dynamic>;
        _isLoading = false;
      });
    } catch (e) {
      if (_isDisposed) return;
      
      setState(() {
        _errorMessage = 'Fehler beim Laden der Statistiken: $e';
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
          HeaderBar(
            title: 'Statistiken & Analyse',
            subtitle: _getPeriodDisplayName(_selectedPeriod),
            showLightningIcon: false,
            customIcon: Icons.analytics_rounded,
            showBackButton: false, // This is in main navigation
          ),
          
          Spacing.verticalSpaceMd,
          
          Padding(
            padding: Spacing.paddingHorizontalMd,
            child: _buildTimePeriodSelector(context, isDark),
          ),
          
          Spacing.verticalSpaceMd,
          
          Padding(
            padding: Spacing.paddingHorizontalMd,
            child: _buildTabBar(context, isDark),
          ),
          
          Expanded(
            child: _buildTabBarView(context, isDark),
          ),
        ],
      ),
    );
  }

  // Helper method to get period display name
  String _getPeriodDisplayName(TimePeriod period) {
    switch (period) {
      case TimePeriod.today:
        return 'Heute';
      case TimePeriod.thisWeek:
        return 'Diese Woche';
      case TimePeriod.thisMonth:
        return 'Dieser Monat';
      case TimePeriod.last30Days:
        return 'Letzte 30 Tage';
      case TimePeriod.thisYear:
        return 'Dieses Jahr';
      case TimePeriod.allTime:
        return 'Gesamt';
    }
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.analytics_rounded,
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
                          'Statistiken & Analyse',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Detaillierte Auswertung Ihrer Daten',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.8),
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
    );
  }

  Widget _buildTimePeriodSelector(BuildContext context, bool isDark) {
    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: TimePeriod.values.length,
        itemBuilder: (context, index) {
          final period = TimePeriod.values[index];
          final isSelected = period == _selectedPeriod;
          
          return Padding(
            padding: EdgeInsets.only(
              right: index < TimePeriod.values.length - 1 ? Spacing.sm : 0,
            ),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPeriod = period;
                });
                _loadStatistics();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: Spacing.sm,
                  horizontal: Spacing.md,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? DesignTokens.primaryGradient
                      : null,
                  color: isSelected
                      ? null
                      : isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected
                        ? DesignTokens.primaryIndigo.withOpacity(0.3)
                        : isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.black.withOpacity(0.1),
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: DesignTokens.primaryIndigo.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    _getPeriodDisplayName(period),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).textTheme.bodyMedium?.color,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ).animate().fadeIn(
      duration: DesignTokens.animationMedium,
      delay: const Duration(milliseconds: 300),
    );
  }

  Widget _buildTabBar(BuildContext context, bool isDark) {
    return GlassCard(
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: DesignTokens.primaryIndigo.withOpacity(0.2),
          borderRadius: Spacing.borderRadiusSm,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: DesignTokens.primaryIndigo,
        unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
        tabs: const [
          Tab(text: 'Übersicht'),
          Tab(text: 'Trends'),
          Tab(text: 'Kosten'),
        ],
      ),
    ).animate().fadeIn(
      duration: DesignTokens.animationMedium,
      delay: const Duration(milliseconds: 400),
    );
  }

  Widget _buildTabBarView(BuildContext context, bool isDark) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState(context, isDark);
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildOverviewTab(context, isDark),
        _buildTrendsTab(context, isDark),
        _buildCostsTab(context, isDark),
      ],
    );
  }

  Widget _buildOverviewTab(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      padding: Spacing.paddingMd,
      child: Column(
        children: [
          // Enhanced stats grid with comparisons
          _buildEnhancedStatsGrid(context, isDark),
          Spacing.verticalSpaceLg,
          
          // Insights section
          _buildInsightsSection(context, isDark),
          Spacing.verticalSpaceLg,
          
          // Pattern analysis
          _buildPatternAnalysisSection(context, isDark),
          Spacing.verticalSpaceLg,
          
          _buildRiskDistribution(context, isDark),
          Spacing.verticalSpaceLg,
          _buildTopSubstances(context, isDark),
          Spacing.verticalSpaceLg,
          _buildTimePatterns(context, isDark),
          const SizedBox(height: 120), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildTrendsTab(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      padding: Spacing.paddingMd,
      child: Column(
        children: [
          // Trend comparison
          _buildTrendComparison(context, isDark),
          Spacing.verticalSpaceLg,
          
          // Predictive trend analysis
          _buildPredictiveTrends(context, isDark),
          Spacing.verticalSpaceLg,
          
          _buildConsumptionTrends(context, isDark),
          Spacing.verticalSpaceLg,
          
          // Time pattern heatmap
          _buildTimePatternHeatmap(context, isDark),
          Spacing.verticalSpaceLg,
          
          // Substance correlations
          _buildSubstanceCorrelations(context, isDark),
          Spacing.verticalSpaceLg,
          
          _buildSubstanceComparison(context, isDark),
          Spacing.verticalSpaceLg,
          _buildCategoryDistribution(context, isDark),
          const SizedBox(height: 120), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildCostsTab(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      padding: Spacing.paddingMd,
      child: Column(
        children: [
          // Enhanced cost overview with predictions
          _buildEnhancedCostOverview(context, isDark),
          Spacing.verticalSpaceLg,
          
          // Budget tracking
          _buildBudgetTracking(context, isDark),
          Spacing.verticalSpaceLg,
          
          // Cost efficiency insights
          _buildCostEfficiencySection(context, isDark),
          Spacing.verticalSpaceLg,
          
          _buildCostTrends(context, isDark),
          Spacing.verticalSpaceLg,
          _buildExpensiveSubstances(context, isDark),
          const SizedBox(height: 120), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, bool isDark) {
    final stats = _comprehensiveStats!;
    
    // Determine if we should use animations based on device capabilities
    final useAnimations = PerformanceHelper.shouldEnableAnimations();
    
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: Spacing.md,
      mainAxisSpacing: Spacing.md,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          context,
          'Einträge',
          stats['totalEntries'].toString(),
          Icons.note_rounded,
          DesignTokens.primaryIndigo,
        ),
        _buildStatCard(
          context,
          'Substanzen',
          stats['uniqueSubstances'].toString(),
          Icons.science_rounded,
          DesignTokens.accentCyan,
        ),
        _buildStatCard(
          context,
          'Gesamtkosten',
          '${(stats['totalCost'] as double).toStringAsFixed(2).replaceAll('.', ',')}€',
          Icons.euro_rounded,
          DesignTokens.accentEmerald,
        ),
        _buildStatCard(
          context,
          'Ø pro Tag',
          '${(stats['avgEntriesPerDay'] as double).toStringAsFixed(1)} Einträge',
          Icons.trending_up_rounded,
          DesignTokens.warningYellow,
        ),
      ],
    ).animate(target: useAnimations ? 1 : 0).fadeIn(
      duration: useAnimations 
          ? PerformanceHelper.getAnimationDuration(DesignTokens.animationMedium)
          : Duration.zero,
      delay: const Duration(milliseconds: 500),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return GlassCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: Spacing.iconLg,
            color: color,
          ),
          Spacing.verticalSpaceSm,
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
            textAlign: TextAlign.center,
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

  Widget _buildRiskDistribution(BuildContext context, bool isDark) {
    final riskData = _comprehensiveStats!['riskDistribution'] as Map<String, int>;
    final chartData = riskData.entries.map((entry) => {
      'label': _getRiskLevelDisplayName(entry.key),
      'value': entry.value,
    }).toList();

    return GlassCard(
      child: PieChartWidget(
        data: chartData,
        title: 'Risiko-Verteilung',
        colors: const [
          DesignTokens.successGreen,
          DesignTokens.warningYellow,
          DesignTokens.errorRed,
          Color(0xFF991B1B),
        ],
      ),
    ).animate().fadeIn(
      duration: DesignTokens.animationMedium,
      delay: const Duration(milliseconds: 600),
    );
  }

  Widget _buildTopSubstances(BuildContext context, bool isDark) {
    final substanceStats = _substanceStats!.take(5).toList();
    final chartData = substanceStats.map((substance) => {
      'label': substance['substanceName'],
      'value': substance['usageCount'],
    }).toList();

    return GlassCard(
      child: BarChartWidget(
        data: chartData,
        title: 'Top 5 Substanzen',
        xAxisLabel: 'Substanzen',
        yAxisLabel: 'Anzahl Einträge',
        barColors: const [
          DesignTokens.primaryIndigo,
          DesignTokens.accentCyan,
          DesignTokens.accentEmerald,
          DesignTokens.warningYellow,
          DesignTokens.errorRed,
        ],
      ),
    ).animate().fadeIn(
      duration: DesignTokens.animationMedium,
      delay: const Duration(milliseconds: 700),
    );
  }

  Widget _buildTimePatterns(BuildContext context, bool isDark) {
    final hourlyData = _comprehensiveStats!['hourlyDistribution'] as Map<int, int>;
    final chartData = hourlyData.entries.map((entry) => {
      'label': '${entry.key}:00',
      'value': entry.value,
    }).toList();

    return GlassCard(
      child: LineChartWidget(
        data: chartData,
        title: 'Tageszeit-Muster',
        xAxisLabel: 'Uhrzeit',
        yAxisLabel: 'Anzahl Einträge',
        lineColor: DesignTokens.accentPurple,
      ),
    ).animate().fadeIn(
      duration: DesignTokens.animationMedium,
      delay: const Duration(milliseconds: 800),
    );
  }

  Widget _buildConsumptionTrends(BuildContext context, bool isDark) {
    final chartData = _consumptionTrends!.map((trend) => {
      'label': trend['period'].toString(),
      'value': trend['entryCount'],
    }).toList();

    return GlassCard(
      child: LineChartWidget(
        data: chartData,
        title: 'Konsum-Trends',
        xAxisLabel: _getPeriodAxisLabel(),
        yAxisLabel: 'Anzahl Einträge',
        lineColor: DesignTokens.primaryIndigo,
      ),
    ).animate().fadeIn(
      duration: DesignTokens.animationMedium,
      delay: const Duration(milliseconds: 500),
    );
  }

  Widget _buildSubstanceComparison(BuildContext context, bool isDark) {
    final chartData = _substanceStats!.map((substance) => {
      'label': substance['substanceName'],
      'value': substance['totalDosage'],
    }).toList();

    return GlassCard(
      child: BarChartWidget(
        data: chartData,
        title: 'Substanz-Vergleich (Gesamtdosis)',
        xAxisLabel: 'Substanzen',
        yAxisLabel: 'Gesamtdosis',
        barColors: const [
          DesignTokens.accentCyan,
          DesignTokens.accentEmerald,
          DesignTokens.warningYellow,
          DesignTokens.errorRed,
          DesignTokens.accentPurple,
        ],
      ),
    ).animate().fadeIn(
      duration: DesignTokens.animationMedium,
      delay: const Duration(milliseconds: 600),
    );
  }

  Widget _buildCategoryDistribution(BuildContext context, bool isDark) {
    final categoryData = _comprehensiveStats!['categoryDistribution'] as Map<String, int>;
    final chartData = categoryData.entries.map((entry) => {
      'label': _getCategoryDisplayName(entry.key),
      'value': entry.value,
    }).toList();

    return GlassCard(
      child: PieChartWidget(
        data: chartData,
        title: 'Kategorie-Verteilung',
        colors: const [
          DesignTokens.infoBlue,
          DesignTokens.warningOrange,
          DesignTokens.primaryPurple,
          DesignTokens.successGreen,
          DesignTokens.accentCyan,
          DesignTokens.neutral500,
        ],
      ),
    ).animate().fadeIn(
      duration: DesignTokens.animationMedium,
      delay: const Duration(milliseconds: 700),
    );
  }

  Widget _buildCostOverview(BuildContext context, bool isDark) {
    final costAnalysis = _costAnalysis!;
    
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: Spacing.md,
      mainAxisSpacing: Spacing.md,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          context,
          'Gesamtkosten',
          '${(costAnalysis['totalCost'] as double).toStringAsFixed(2).replaceAll('.', ',')}€',
          Icons.euro_rounded,
          DesignTokens.accentEmerald,
        ),
        _buildStatCard(
          context,
          'Ø pro Eintrag',
          '${(costAnalysis['avgCostPerEntry'] as double).toStringAsFixed(2).replaceAll('.', ',')}€',
          Icons.calculate_rounded,
          DesignTokens.primaryIndigo,
        ),
      ],
    ).animate().fadeIn(
      duration: DesignTokens.animationMedium,
      delay: const Duration(milliseconds: 500),
    );
  }

  Widget _buildCostTrends(BuildContext context, bool isDark) {
    final costTrends = _costAnalysis!['costTrends'] as List<dynamic>;
    final chartData = costTrends.map((trend) => {
      'label': trend['month'].toString(),
      'value': (trend['monthlyCost'] as num).toDouble(),
    }).toList();

    return GlassCard(
      child: LineChartWidget(
        data: chartData,
        title: 'Kosten-Trends',
        xAxisLabel: 'Monat',
        yAxisLabel: 'Kosten (€)',
        lineColor: DesignTokens.accentEmerald,
      ),
    ).animate().fadeIn(
      duration: DesignTokens.animationMedium,
      delay: const Duration(milliseconds: 600),
    );
  }

  Widget _buildExpensiveSubstances(BuildContext context, bool isDark) {
    final expensiveSubstances = _costAnalysis!['expensiveSubstances'] as List<dynamic>;
    final chartData = expensiveSubstances.take(5).map((substance) => {
      'label': substance['substanceName'],
      'value': (substance['totalCost'] as num).toDouble(),
    }).toList();

    return GlassCard(
      child: BarChartWidget(
        data: chartData,
        title: 'Teuerste Substanzen',
        xAxisLabel: 'Substanzen',
        yAxisLabel: 'Gesamtkosten (€)',
        barColors: const [
          DesignTokens.errorRed,
          DesignTokens.warningYellow,
          DesignTokens.warningOrange,
          DesignTokens.accentEmerald,
          DesignTokens.primaryIndigo,
        ],
      ),
    ).animate().fadeIn(
      duration: DesignTokens.animationMedium,
      delay: const Duration(milliseconds: 700),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: Spacing.paddingMd,
        child: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              ),
              Spacing.verticalSpaceXs,
              Text(
                _errorMessage!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              Spacing.verticalSpaceMd,
              ElevatedButton(
                onPressed: _loadStatistics,
                child: const Text('Erneut versuchen'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getPeriodAxisLabel() {
    switch (_selectedPeriod) {
      case TimePeriod.today:
        return 'Stunden';
      case TimePeriod.thisWeek:
      case TimePeriod.thisMonth:
      case TimePeriod.last30Days:
        return 'Tage';
      case TimePeriod.thisYear:
      case TimePeriod.allTime:
        return 'Monate';
    }
  }

  String _getRiskLevelDisplayName(String riskLevel) {
    switch (riskLevel) {
      case 'low':
        return 'Niedrig';
      case 'medium':
        return 'Mittel';
      case 'high':
        return 'Hoch';
      case 'critical':
        return 'Kritisch';
      default:
        return riskLevel;
    }
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'medication':
        return 'Medikament';
      case 'stimulant':
        return 'Stimulans';
      case 'depressant':
        return 'Depressivum';
      case 'supplement':
        return 'Supplement';
      case 'recreational':
        return 'Freizeit';
      case 'other':
        return 'Sonstiges';
      default:
        return category;
    }
  }

  // New enhanced methods

  Widget _buildEnhancedStatsGrid(BuildContext context, bool isDark) {
    final stats = _comprehensiveStats!;
    final changes = _enhancedStats?['changes'] as Map<String, dynamic>? ?? {};
    
    // Determine if we should use animations based on device capabilities
    final useAnimations = PerformanceHelper.shouldEnableAnimations();
    
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: Spacing.md,
      mainAxisSpacing: Spacing.md,
      childAspectRatio: 1.3,
      children: [
        _buildEnhancedStatCard(
          context,
          'Einträge',
          stats['totalEntries'].toString(),
          Icons.note_rounded,
          DesignTokens.primaryIndigo,
          changePercentage: changes['entryChange'],
        ),
        _buildEnhancedStatCard(
          context,
          'Substanzen',
          stats['uniqueSubstances'].toString(),
          Icons.science_rounded,
          DesignTokens.accentCyan,
          changePercentage: changes['substanceChange'],
        ),
        _buildEnhancedStatCard(
          context,
          'Gesamtkosten',
          '${(stats['totalCost'] as double).toStringAsFixed(2).replaceAll('.', ',')}€',
          Icons.euro_rounded,
          DesignTokens.accentEmerald,
          changePercentage: changes['costChange'],
        ),
        _buildEnhancedStatCard(
          context,
          'Ø pro Tag',
          '${(stats['avgEntriesPerDay'] as double).toStringAsFixed(1)} Einträge',
          Icons.trending_up_rounded,
          DesignTokens.warningYellow,
        ),
      ],
    ).animate(target: useAnimations ? 1 : 0).fadeIn(
      duration: useAnimations 
          ? PerformanceHelper.getAnimationDuration(DesignTokens.animationMedium)
          : Duration.zero,
      delay: const Duration(milliseconds: 500),
    );
  }

  Widget _buildEnhancedStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color, {
    double? changePercentage,
  }) {
    final theme = Theme.of(context);
    
    return GlassCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                size: Spacing.iconMd,
                color: color,
              ),
              if (changePercentage != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: changePercentage > 0 
                        ? DesignTokens.errorRed.withOpacity(0.1)
                        : changePercentage < 0 
                            ? DesignTokens.successGreen.withOpacity(0.1)
                            : DesignTokens.neutral500.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        changePercentage > 0 
                            ? Icons.trending_up_rounded
                            : changePercentage < 0 
                                ? Icons.trending_down_rounded
                                : Icons.trending_flat_rounded,
                        size: 12,
                        color: changePercentage > 0 
                            ? DesignTokens.errorRed
                            : changePercentage < 0 
                                ? DesignTokens.successGreen
                                : DesignTokens.neutral500,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${changePercentage.abs().toStringAsFixed(1)}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: changePercentage > 0 
                              ? DesignTokens.errorRed
                              : changePercentage < 0 
                                  ? DesignTokens.successGreen
                                  : DesignTokens.neutral500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          Spacing.verticalSpaceSm,
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsSection(BuildContext context, bool isDark) {
    final insights = _enhancedStats?['insights'] as List<dynamic>? ?? [];
    
    if (insights.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Wichtige Erkenntnisse',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Spacing.verticalSpaceMd,
        ...insights.asMap().entries.map((entry) {
          final index = entry.key;
          final insight = entry.value as String;
          
          return Padding(
            padding: EdgeInsets.only(bottom: index < insights.length - 1 ? Spacing.md : 0),
            child: InsightCard(
              title: 'Erkenntnis ${index + 1}',
              insight: insight,
              icon: _getInsightIcon(index),
              iconColor: _getInsightColor(index),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildPatternAnalysisSection(BuildContext context, bool isDark) {
    if (_patternAnalysis == null) return const SizedBox.shrink();
    
    final weekdayPatterns = _patternAnalysis!['weekdayPatterns'] as Map<String, dynamic>;
    final timeOfDayPatterns = _patternAnalysis!['timeOfDayPatterns'] as Map<String, dynamic>;
    final frequencyPatterns = _patternAnalysis!['frequencyPatterns'] as Map<String, dynamic>;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verhaltensmuster',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Spacing.verticalSpaceMd,
        
        // Weekday pattern
        PatternInsightCard(
          patternType: 'Wochentag-Muster',
          primaryMetric: weekdayPatterns['mostCommonWeekday'] as String? ?? 'Keine Daten',
          secondaryMetric: '',
          description: weekdayPatterns['weekdayInsight'] as String? ?? 'Keine Erkenntnisse verfügbar.',
          icon: Icons.calendar_view_week_rounded,
          color: DesignTokens.primaryIndigo,
        ),
        
        Spacing.verticalSpaceMd,
        
        // Time of day pattern
        PatternInsightCard(
          patternType: 'Tageszeit-Muster',
          primaryMetric: timeOfDayPatterns['mostCommonTimeOfDay'] as String? ?? 'Keine Daten',
          secondaryMetric: '',
          description: timeOfDayPatterns['timeOfDayInsight'] as String? ?? 'Keine Erkenntnisse verfügbar.',
          icon: Icons.access_time_rounded,
          color: DesignTokens.accentCyan,
        ),
        
        Spacing.verticalSpaceMd,
        
        // Frequency pattern
        PatternInsightCard(
          patternType: 'Häufigkeits-Muster',
          primaryMetric: '${(frequencyPatterns['averageFrequencyDays'] as double? ?? 0.0).toStringAsFixed(1)} Tage',
          secondaryMetric: 'Durchschnittlicher Abstand',
          description: frequencyPatterns['frequencyInsight'] as String? ?? 'Keine Erkenntnisse verfügbar.',
          icon: Icons.repeat_rounded,
          color: DesignTokens.accentEmerald,
        ),
      ],
    );
  }

  Widget _buildTimePatternHeatmap(BuildContext context, bool isDark) {
    if (_patternAnalysis == null) return const SizedBox.shrink();
    
    final timeOfDayPatterns = _patternAnalysis!['timeOfDayPatterns'] as Map<String, dynamic>;
    
    return GlassCard(
      child: HeatmapWidget(
        data: timeOfDayPatterns,
        title: 'Konsum-Heatmap: Tageszeit',
        xAxisLabel: 'Uhrzeit',
        yAxisLabel: 'Wochentag',
        height: 150,
      ),
    );
  }

  Widget _buildSubstanceCorrelations(BuildContext context, bool isDark) {
    if (_correlationAnalysis == null) return const SizedBox.shrink();
    
    final correlations = _correlationAnalysis!['correlations'] as Map<String, dynamic>;
    final correlationMatrix = correlations['correlationMatrix'] as List<dynamic>? ?? [];
    
    return GlassCard(
      child: CorrelationMatrixWidget(
        correlationData: correlationMatrix.cast<Map<String, dynamic>>(),
        title: 'Substanz-Korrelationen',
      ),
    );
  }

  Widget _buildEnhancedCostOverview(BuildContext context, bool isDark) {
    if (_enhancedCostAnalysis == null) return const SizedBox.shrink();
    
    final costAnalysis = _enhancedCostAnalysis!;
    final predictions = costAnalysis['predictions'] as Map<String, dynamic>? ?? {};
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: Spacing.md,
          mainAxisSpacing: Spacing.md,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              context,
              'Gesamtkosten',
              '${(costAnalysis['totalCost'] as double).toStringAsFixed(2).replaceAll('.', ',')}€',
              Icons.euro_rounded,
              DesignTokens.accentEmerald,
            ),
            _buildStatCard(
              context,
              'Ø pro Eintrag',
              '${(costAnalysis['avgCostPerEntry'] as double).toStringAsFixed(2).replaceAll('.', ',')}€',
              Icons.calculate_rounded,
              DesignTokens.primaryIndigo,
            ),
          ],
        ),
        
        if (predictions.isNotEmpty) ...[
          Spacing.verticalSpaceLg,
          
          // Cost predictions
          InsightCard(
            title: 'Kosten-Prognose',
            insight: 'Nächste Woche: ${(predictions['nextWeekPrediction'] as double? ?? 0.0).toStringAsFixed(2)}€\n'
                     'Nächster Monat: ${(predictions['nextMonthPrediction'] as double? ?? 0.0).toStringAsFixed(2)}€\n'
                     'Vertrauen: ${predictions['confidence'] as String? ?? 'Unbekannt'}',
            icon: Icons.psychology_rounded,
            iconColor: DesignTokens.warningYellow,
          ),
        ],
      ],
    );
  }

  Widget _buildCostEfficiencySection(BuildContext context, bool isDark) {
    if (_enhancedCostAnalysis == null) return const SizedBox.shrink();
    
    final costEfficiency = _enhancedCostAnalysis!['costEfficiency'] as Map<String, dynamic>? ?? {};
    final insights = _enhancedCostAnalysis!['insights'] as List<dynamic>? ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PatternInsightCard(
          patternType: 'Ausgaben-Effizienz',
          primaryMetric: costEfficiency['efficiency'] as String? ?? 'Unbekannt',
          secondaryMetric: 'Ø ${(costEfficiency['averageDailyCost'] as double? ?? 0.0).toStringAsFixed(2)}€/Tag',
          description: insights.isNotEmpty 
              ? insights.first as String 
              : 'Ihre Ausgaben sind über die Zeit analysiert.',
          icon: Icons.trending_up_rounded,
          color: DesignTokens.accentEmerald,
          progress: (costEfficiency['costVariability'] as double? ?? 0.0) / 100,
        ),
      ],
    );
  }

  IconData _getInsightIcon(int index) {
    const icons = [
      Icons.lightbulb_rounded,
      Icons.trending_up_rounded,
      Icons.info_rounded,
      Icons.warning_rounded,
      Icons.check_circle_rounded,
    ];
    return icons[index % icons.length];
  }

  Color _getInsightColor(int index) {
    const colors = [
      DesignTokens.primaryIndigo,
      DesignTokens.accentCyan,
      DesignTokens.accentEmerald,
      DesignTokens.warningYellow,
      DesignTokens.accentPurple,
    ];
    return colors[index % colors.length];
  }

  Widget _buildTrendComparison(BuildContext context, bool isDark) {
    if (_consumptionTrends == null || _consumptionTrends!.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // Split data into current and previous periods
    final totalData = _consumptionTrends!.length;
    final midPoint = totalData ~/ 2;
    
    final currentPeriodData = _consumptionTrends!.take(midPoint).toList();
    final previousPeriodData = _consumptionTrends!.skip(midPoint).toList();
    
    return TrendComparisonWidget(
      currentPeriodData: currentPeriodData,
      previousPeriodData: previousPeriodData,
      title: 'Trend-Vergleich: ${_getPeriodDisplayName(_selectedPeriod)}',
      currentPeriodLabel: 'Aktuelle Periode',
      previousPeriodLabel: 'Vorherige Periode',
      primaryColor: DesignTokens.primaryIndigo,
      secondaryColor: DesignTokens.neutral400,
    );
  }

  Widget _buildPredictiveTrends(BuildContext context, bool isDark) {
    if (_consumptionTrends == null || _consumptionTrends!.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // Reverse the data to have chronological order for prediction
    final historicalData = _consumptionTrends!.reversed.toList();
    
    return PredictiveTrendWidget(
      historicalData: historicalData,
      title: 'Vorhersage-Trends',
      metric: 'Einträge',
      forecastDays: _getForecastDays(),
      trendColor: DesignTokens.accentCyan,
    );
  }

  int _getForecastDays() {
    switch (_selectedPeriod) {
      case TimePeriod.today:
        return 1;
      case TimePeriod.thisWeek:
        return 7;
      case TimePeriod.thisMonth:
      case TimePeriod.last30Days:
        return 30;
      case TimePeriod.thisYear:
        return 90;
      case TimePeriod.allTime:
        return 30;
    }
  }

  Widget _buildBudgetTracking(BuildContext context, bool isDark) {
    if (_enhancedCostAnalysis == null) return const SizedBox.shrink();
    
    final costAnalysis = _enhancedCostAnalysis!;
    final dailyCosts = costAnalysis['dailyCosts'] as List<dynamic>? ?? [];
    final totalCost = costAnalysis['totalCost'] as double? ?? 0.0;
    
    // Calculate budget tracking metrics
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysElapsed = now.day;
    
    // Assume a monthly budget based on current spending patterns
    // In a real app, this would come from user settings
    final monthlyBudget = totalCost > 0 ? totalCost * 2 : 200.0; // Simple estimation
    
    return BudgetTrackingWidget(
      monthlyBudget: monthlyBudget,
      currentSpending: totalCost,
      daysInMonth: daysInMonth,
      daysElapsed: daysElapsed,
      dailySpending: dailyCosts.cast<Map<String, dynamic>>(),
      title: 'Budget-Tracking (${_getPeriodDisplayName(_selectedPeriod)})',
    );
  }
}