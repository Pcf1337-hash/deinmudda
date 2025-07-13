import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../models/entry.dart';
import '../../services/entry_service.dart';
import '../../services/analytics_service.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/charts/line_chart_widget.dart';
import '../../widgets/charts/bar_chart_widget.dart';
import '../../widgets/charts/pie_chart_widget.dart';
import '../../theme/design_tokens.dart';
import '../../theme/spacing.dart';

class PatternAnalysisScreen extends StatefulWidget {
  const PatternAnalysisScreen({super.key});

  @override
  State<PatternAnalysisScreen> createState() => _PatternAnalysisScreenState();
}

class _PatternAnalysisScreenState extends State<PatternAnalysisScreen> {
  final EntryService _entryService = EntryService();
  final AnalyticsService _analyticsService = AnalyticsService();
  
  bool _isLoading = true;
  String? _errorMessage;
  
  // Analysis data
  Map<String, dynamic>? _weekdayPatterns;
  Map<String, dynamic>? _timeOfDayPatterns;
  Map<String, dynamic>? _frequencyPatterns;
  Map<String, dynamic>? _substanceCorrelations;
  List<Map<String, dynamic>>? _consumptionTrends;

  @override
  void initState() {
    super.initState();
    _loadAnalysisData();
  }

  Future<void> _loadAnalysisData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load all the pattern analysis data
      final weekdayPatterns = await _analyticsService.getWeekdayPatterns();
      final timeOfDayPatterns = await _analyticsService.getTimeOfDayPatterns();
      final frequencyPatterns = await _analyticsService.getFrequencyPatterns();
      final substanceCorrelations = await _analyticsService.getSubstanceCorrelations();
      final consumptionTrends = await _analyticsService.getConsumptionTrends(TimePeriod.allTime);
      
      setState(() {
        _weekdayPatterns = weekdayPatterns;
        _timeOfDayPatterns = timeOfDayPatterns;
        _frequencyPatterns = frequencyPatterns;
        _substanceCorrelations = substanceCorrelations;
        _consumptionTrends = consumptionTrends;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Fehler beim Laden der Analyse-Daten: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
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
                _isLoading
                    ? _buildLoadingState()
                    : _buildAnalysisContent(context, isDark),
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
                    'Muster-Analyse',
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
            onPressed: _loadAnalysisData,
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

  Widget _buildLoadingState() {
    return Column(
      children: List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: Spacing.md),
          child: GlassCard(
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: Spacing.borderRadiusMd,
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: const Duration(milliseconds: 1500)),
        );
      }),
    );
  }

  Widget _buildAnalysisContent(BuildContext context, bool isDark) {
    if (_weekdayPatterns == null || 
        _timeOfDayPatterns == null || 
        _frequencyPatterns == null || 
        _substanceCorrelations == null ||
        _consumptionTrends == null) {
      return _buildNoDataState(context, isDark);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPatternSummary(context, isDark),
        Spacing.verticalSpaceLg,
        _buildWeekdayPatterns(context, isDark),
        Spacing.verticalSpaceLg,
        _buildTimeOfDayPatterns(context, isDark),
        Spacing.verticalSpaceLg,
        _buildFrequencyPatterns(context, isDark),
        Spacing.verticalSpaceLg,
        _buildSubstanceCorrelations(context, isDark),
        Spacing.verticalSpaceLg,
        _buildConsumptionTrends(context, isDark),
      ],
    );
  }

  Widget _buildPatternSummary(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    
    // Extract key insights
    final mostCommonWeekday = _weekdayPatterns!['mostCommonWeekday'] as String;
    final mostCommonTimeOfDay = _timeOfDayPatterns!['mostCommonTimeOfDay'] as String;
    final averageFrequency = _frequencyPatterns!['averageFrequencyDays'] as double;
    final mostCorrelatedSubstances = _substanceCorrelations!['mostCorrelatedPair'] as List<String>;
    
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.insights_rounded,
                color: DesignTokens.primaryIndigo,
                size: Spacing.iconMd,
              ),
              Spacing.horizontalSpaceSm,
              Text(
                'Erkannte Muster',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Spacing.verticalSpaceMd,
          _buildInsightItem(
            context,
            'Häufigster Wochentag',
            mostCommonWeekday,
            Icons.calendar_today_rounded,
            DesignTokens.accentCyan,
          ),
          Spacing.verticalSpaceSm,
          _buildInsightItem(
            context,
            'Häufigste Tageszeit',
            mostCommonTimeOfDay,
            Icons.access_time_rounded,
            DesignTokens.accentPurple,
          ),
          Spacing.verticalSpaceSm,
          _buildInsightItem(
            context,
            'Durchschnittliche Frequenz',
            'Alle ${averageFrequency.toStringAsFixed(1)} Tage',
            Icons.repeat_rounded,
            DesignTokens.accentEmerald,
          ),
          Spacing.verticalSpaceSm,
          _buildInsightItem(
            context,
            'Häufigste Kombination',
            mostCorrelatedSubstances.join(' & '),
            Icons.compare_arrows_rounded,
            DesignTokens.warningYellow,
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

  Widget _buildInsightItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(Spacing.xs),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: Spacing.borderRadiusSm,
          ),
          child: Icon(
            icon,
            color: color,
            size: Spacing.iconSm,
          ),
        ),
        Spacing.horizontalSpaceSm,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeekdayPatterns(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final weekdayData = _weekdayPatterns!['weekdayDistribution'] as Map<String, int>;
    
    // Convert to chart data format
    final chartData = weekdayData.entries.map((entry) => {
      'label': _getShortWeekdayName(entry.key),
      'value': entry.value,
    }).toList();
    
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_view_week_rounded,
                color: DesignTokens.primaryIndigo,
                size: Spacing.iconMd,
              ),
              Spacing.horizontalSpaceSm,
              Text(
                'Wochentag-Muster',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Spacing.verticalSpaceMd,
          SizedBox(
            height: 200,
            child: BarChartWidget(
              data: chartData,
              title: '',
              xAxisLabel: 'Wochentag',
              yAxisLabel: 'Anzahl Einträge',
              barColors: const [
                DesignTokens.primaryIndigo,
                DesignTokens.accentCyan,
                DesignTokens.accentEmerald,
                DesignTokens.accentPurple,
                DesignTokens.warningYellow,
                DesignTokens.errorRed,
                DesignTokens.infoBlue,
              ],
            ),
          ),
          Spacing.verticalSpaceMd,
          Text(
            _weekdayPatterns!['weekdayInsight'] as String,
            style: theme.textTheme.bodyMedium,
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

  Widget _buildTimeOfDayPatterns(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final timeData = _timeOfDayPatterns!['hourlyDistribution'] as Map<String, int>;
    
    // Convert to chart data format
    final chartData = timeData.entries.map((entry) => {
      'label': entry.key,
      'value': entry.value,
    }).toList();
    
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                color: DesignTokens.accentCyan,
                size: Spacing.iconMd,
              ),
              Spacing.horizontalSpaceSm,
              Text(
                'Tageszeit-Muster',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Spacing.verticalSpaceMd,
          SizedBox(
            height: 200,
            child: LineChartWidget(
              data: chartData,
              title: '',
              xAxisLabel: 'Stunde',
              yAxisLabel: 'Anzahl Einträge',
              lineColor: DesignTokens.accentCyan,
            ),
          ),
          Spacing.verticalSpaceMd,
          Text(
            _timeOfDayPatterns!['timeOfDayInsight'] as String,
            style: theme.textTheme.bodyMedium,
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

  Widget _buildFrequencyPatterns(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final frequencyData = _frequencyPatterns!['frequencyDistribution'] as Map<String, int>;
    
    // Convert to chart data format
    final chartData = frequencyData.entries.map((entry) => {
      'label': entry.key,
      'value': entry.value,
    }).toList();
    
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.repeat_rounded,
                color: DesignTokens.accentEmerald,
                size: Spacing.iconMd,
              ),
              Spacing.horizontalSpaceSm,
              Text(
                'Häufigkeits-Muster',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Spacing.verticalSpaceMd,
          SizedBox(
            height: 200,
            child: PieChartWidget(
              data: chartData,
              title: '',
              colors: const [
                DesignTokens.accentEmerald,
                DesignTokens.accentCyan,
                DesignTokens.primaryIndigo,
                DesignTokens.accentPurple,
                DesignTokens.warningYellow,
              ],
            ),
          ),
          Spacing.verticalSpaceMd,
          Text(
            _frequencyPatterns!['frequencyInsight'] as String,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
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

  Widget _buildSubstanceCorrelations(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final correlationData = _substanceCorrelations!['correlationMatrix'] as List<Map<String, dynamic>>;
    
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.compare_arrows_rounded,
                color: DesignTokens.warningYellow,
                size: Spacing.iconMd,
              ),
              Spacing.horizontalSpaceSm,
              Text(
                'Substanz-Korrelationen',
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
            itemCount: correlationData.length > 5 ? 5 : correlationData.length,
            itemBuilder: (context, index) {
              final correlation = correlationData[index];
              final substance1 = correlation['substance1'] as String;
              final substance2 = correlation['substance2'] as String;
              final correlationValue = (correlation['correlation'] as double).toStringAsFixed(2);
              final correlationStrength = correlation['strength'] as String;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: Spacing.sm),
                child: Container(
                  padding: Spacing.paddingMd,
                  decoration: BoxDecoration(
                    color: _getCorrelationColor(correlationStrength).withOpacity(0.1),
                    borderRadius: Spacing.borderRadiusMd,
                    border: Border.all(
                      color: _getCorrelationColor(correlationStrength).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$substance1 & $substance2',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Korrelation: $correlationValue ($correlationStrength)',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: _getCorrelationColor(correlationStrength),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        _getCorrelationIcon(correlationStrength),
                        color: _getCorrelationColor(correlationStrength),
                        size: Spacing.iconMd,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Spacing.verticalSpaceMd,
          Text(
            _substanceCorrelations!['correlationInsight'] as String,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    ).animate().fadeIn(
      duration: DesignTokens.animationMedium,
      delay: const Duration(milliseconds: 700),
    ).slideY(
      begin: 0.3,
      end: 0,
      duration: DesignTokens.animationMedium,
      curve: DesignTokens.curveEaseOut,
    );
  }

  Widget _buildConsumptionTrends(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    
    // Convert to chart data format
    final chartData = _consumptionTrends!.map((trend) => {
      'label': trend['period'].toString(),
      'value': trend['entryCount'] as int,
    }).toList();
    
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up_rounded,
                color: DesignTokens.primaryIndigo,
                size: Spacing.iconMd,
              ),
              Spacing.horizontalSpaceSm,
              Text(
                'Langzeit-Trends',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Spacing.verticalSpaceMd,
          SizedBox(
            height: 200,
            child: LineChartWidget(
              data: chartData,
              title: '',
              xAxisLabel: 'Zeit',
              yAxisLabel: 'Anzahl Einträge',
              lineColor: DesignTokens.primaryIndigo,
            ),
          ),
          Spacing.verticalSpaceMd,
          Text(
            'Dieser Graph zeigt die Entwicklung Ihres Konsums über Zeit. Achten Sie auf Muster wie steigende oder fallende Trends, die auf Veränderungen in Ihrem Konsumverhalten hindeuten könnten.',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    ).animate().fadeIn(
      duration: DesignTokens.animationMedium,
      delay: const Duration(milliseconds: 800),
    ).slideY(
      begin: 0.3,
      end: 0,
      duration: DesignTokens.animationMedium,
      curve: DesignTokens.curveEaseOut,
    );
  }

  Widget _buildNoDataState(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return GlassCard(
      child: Column(
        children: [
          Icon(
            Icons.insights_rounded,
            size: Spacing.iconXl,
            color: theme.iconTheme.color?.withOpacity(0.5),
          ),
          Spacing.verticalSpaceMd,
          Text(
            'Nicht genügend Daten',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          Spacing.verticalSpaceXs,
          Text(
            'Für eine aussagekräftige Muster-Analyse werden mehr Einträge benötigt. Fügen Sie weitere Einträge hinzu, um Muster in Ihrem Konsumverhalten zu erkennen.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
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

  String _getShortWeekdayName(String weekday) {
    switch (weekday.toLowerCase()) {
      case 'monday':
        return 'Mo';
      case 'tuesday':
        return 'Di';
      case 'wednesday':
        return 'Mi';
      case 'thursday':
        return 'Do';
      case 'friday':
        return 'Fr';
      case 'saturday':
        return 'Sa';
      case 'sunday':
        return 'So';
      default:
        return weekday;
    }
  }

  Color _getCorrelationColor(String strength) {
    switch (strength.toLowerCase()) {
      case 'stark':
      case 'strong':
        return DesignTokens.errorRed;
      case 'mittel':
      case 'medium':
        return DesignTokens.warningYellow;
      case 'schwach':
      case 'weak':
        return DesignTokens.accentEmerald;
      default:
        return DesignTokens.neutral500;
    }
  }

  IconData _getCorrelationIcon(String strength) {
    switch (strength.toLowerCase()) {
      case 'stark':
      case 'strong':
        return Icons.trending_up_rounded;
      case 'mittel':
      case 'medium':
        return Icons.trending_flat_rounded;
      case 'schwach':
      case 'weak':
        return Icons.trending_down_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }
}