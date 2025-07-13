import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/foundation.dart';
import '../services/analytics_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/charts/line_chart_widget.dart';
import '../widgets/charts/bar_chart_widget.dart';
import '../widgets/charts/pie_chart_widget.dart';
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
  final AnalyticsService _analyticsService = AnalyticsService();
  
  TimePeriod _selectedPeriod = TimePeriod.thisWeek;
  Map<String, dynamic>? _comprehensiveStats;
  List<Map<String, dynamic>>? _consumptionTrends;
  List<Map<String, dynamic>>? _substanceStats;
  Map<String, dynamic>? _costAnalysis;
  Map<String, dynamic>? _riskAnalysis;
  
  bool _isLoading = true;
  bool _isDisposed = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
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
        // Load all the pattern analysis data
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
    }, tag: 'Statistics Loading');
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
          _buildAppBar(context, isDark),
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
    return GlassCard(
      child: Row(
        children: TimePeriod.values.map((period) {
          final isSelected = period == _selectedPeriod;
          return Expanded(
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
                  horizontal: Spacing.xs,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? DesignTokens.primaryIndigo.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: Spacing.borderRadiusSm,
                ),
                child: Text(
                  _getPeriodDisplayName(period),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isSelected
                        ? DesignTokens.primaryIndigo
                        : Theme.of(context).textTheme.bodySmall?.color,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }).toList(),
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
          _buildStatsGrid(context, isDark),
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
          _buildConsumptionTrends(context, isDark),
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
          _buildCostOverview(context, isDark),
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

  String _getPeriodDisplayName(TimePeriod period) {
    switch (period) {
      case TimePeriod.today:
        return 'Heute';
      case TimePeriod.thisWeek:
        return 'Woche';
      case TimePeriod.thisMonth:
        return 'Monat';
      case TimePeriod.thisYear:
        return 'Jahr';
      case TimePeriod.allTime:
        return 'Gesamt';
    }
  }

  String _getPeriodAxisLabel() {
    switch (_selectedPeriod) {
      case TimePeriod.today:
        return 'Stunden';
      case TimePeriod.thisWeek:
      case TimePeriod.thisMonth:
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
}