import '../services/analytics_service.dart';
import '../utils/service_locator.dart';

/// Enhanced analytics service that provides comprehensive insights and comparisons.
/// Extends the base analytics functionality with more detailed analysis.
class EnhancedAnalyticsService {
  late final AnalyticsService _analyticsService = ServiceLocator.get<AnalyticsService>();

  /// Get comprehensive insights with comparisons to previous periods
  Future<Map<String, dynamic>> getEnhancedComprehensiveStats(TimePeriod period) async {
    final currentStats = await _analyticsService.getComprehensiveStats(period);
    
    // Get previous period for comparison
    final previousPeriod = _getPreviousPeriod(period);
    final previousStats = await _analyticsService.getComprehensiveStats(previousPeriod);
    
    // Calculate changes
    final entryChange = _calculatePercentageChange(
      previousStats['totalEntries'] as int,
      currentStats['totalEntries'] as int,
    );
    
    final costChange = _calculatePercentageChange(
      previousStats['totalCost'] as double,
      currentStats['totalCost'] as double,
    );
    
    final substanceChange = _calculatePercentageChange(
      previousStats['uniqueSubstances'] as int,
      currentStats['uniqueSubstances'] as int,
    );
    
    // Generate insights
    final insights = await _generateComprehensiveInsights(currentStats, previousStats);
    
    return {
      ...currentStats,
      'previousPeriodStats': previousStats,
      'changes': {
        'entryChange': entryChange,
        'costChange': costChange,
        'substanceChange': substanceChange,
      },
      'insights': insights,
    };
  }

  /// Get detailed pattern analysis with insights
  Future<Map<String, dynamic>> getDetailedPatternAnalysis() async {
    final weekdayPatterns = await _analyticsService.getWeekdayPatterns();
    final timeOfDayPatterns = await _analyticsService.getTimeOfDayPatterns();
    final frequencyPatterns = await _analyticsService.getFrequencyPatterns();
    
    return {
      'weekdayPatterns': weekdayPatterns,
      'timeOfDayPatterns': timeOfDayPatterns,
      'frequencyPatterns': frequencyPatterns,
      'combinedInsights': _generatePatternInsights(weekdayPatterns, timeOfDayPatterns, frequencyPatterns),
    };
  }

  /// Get substance relationship analysis
  Future<Map<String, dynamic>> getSubstanceRelationshipAnalysis() async {
    final correlations = await _analyticsService.getSubstanceCorrelations();
    final substanceStats = await _analyticsService.getSubstanceStats(TimePeriod.allTime);
    
    // Generate substance insights
    final insights = _generateSubstanceInsights(correlations, substanceStats);
    
    return {
      'correlations': correlations,
      'substanceStats': substanceStats,
      'insights': insights,
    };
  }

  /// Get enhanced cost analysis with predictions and insights
  Future<Map<String, dynamic>> getEnhancedCostAnalysis(TimePeriod period) async {
    final costAnalysis = await _analyticsService.getCostAnalysis(period);
    
    // Calculate cost efficiency metrics
    final dailyCosts = costAnalysis['dailyCosts'] as List<dynamic>;
    final costEfficiency = _calculateCostEfficiency(dailyCosts);
    
    // Generate cost predictions
    final predictions = _generateCostPredictions(dailyCosts);
    
    // Generate cost insights
    final insights = _generateCostInsights(costAnalysis, costEfficiency);
    
    return {
      ...costAnalysis,
      'costEfficiency': costEfficiency,
      'predictions': predictions,
      'insights': insights,
    };
  }

  /// Get risk trend analysis
  Future<Map<String, dynamic>> getRiskTrendAnalysis(TimePeriod period) async {
    final riskAnalysis = await _analyticsService.getRiskAnalysis(period);
    final comprehensiveStats = await _analyticsService.getComprehensiveStats(period);
    
    final riskDistribution = comprehensiveStats['riskDistribution'] as Map<String, int>;
    final totalEntries = comprehensiveStats['totalEntries'] as int;
    
    // Calculate risk percentages
    final riskPercentages = <String, double>{};
    riskDistribution.forEach((level, count) {
      riskPercentages[level] = totalEntries > 0 ? (count / totalEntries) * 100 : 0.0;
    });
    
    // Generate risk insights
    final insights = _generateRiskInsights(riskDistribution, riskPercentages);
    
    return {
      ...riskAnalysis,
      'riskPercentages': riskPercentages,
      'insights': insights,
    };
  }

  // Helper methods
  TimePeriod _getPreviousPeriod(TimePeriod period) {
    switch (period) {
      case TimePeriod.today:
        return TimePeriod.today; // Compare with yesterday (implement if needed)
      case TimePeriod.thisWeek:
        return TimePeriod.thisWeek; // Compare with last week
      case TimePeriod.thisMonth:
        return TimePeriod.thisMonth; // Compare with last month
      case TimePeriod.last30Days:
        return TimePeriod.last30Days;
      case TimePeriod.thisYear:
        return TimePeriod.thisYear;
      case TimePeriod.allTime:
        return TimePeriod.allTime;
    }
  }

  double _calculatePercentageChange(num oldValue, num newValue) {
    if (oldValue == 0) return newValue > 0 ? 100.0 : 0.0;
    return ((newValue - oldValue) / oldValue) * 100;
  }

  List<String> _generateComprehensiveInsights(
    Map<String, dynamic> currentStats,
    Map<String, dynamic> previousStats,
  ) {
    final insights = <String>[];
    
    final currentEntries = currentStats['totalEntries'] as int;
    final previousEntries = previousStats['totalEntries'] as int;
    final currentCost = currentStats['totalCost'] as double;
    final avgEntriesPerDay = currentStats['avgEntriesPerDay'] as double;
    
    // Entry insights
    if (currentEntries > previousEntries) {
      final increase = ((currentEntries - previousEntries) / previousEntries * 100).toStringAsFixed(1);
      insights.add('Ihr Konsum ist um $increase% gestiegen im Vergleich zum vorherigen Zeitraum.');
    } else if (currentEntries < previousEntries) {
      final decrease = ((previousEntries - currentEntries) / previousEntries * 100).toStringAsFixed(1);
      insights.add('Ihr Konsum ist um $decrease% gesunken im Vergleich zum vorherigen Zeitraum.');
    }
    
    // Frequency insights
    if (avgEntriesPerDay > 2) {
      insights.add('Sie konsumieren häufig (${avgEntriesPerDay.toStringAsFixed(1)} Einträge pro Tag). Überlegen Sie, ob dies Ihren Zielen entspricht.');
    } else if (avgEntriesPerDay < 0.5) {
      insights.add('Ihr Konsum ist sehr moderat (${avgEntriesPerDay.toStringAsFixed(1)} Einträge pro Tag).');
    }
    
    // Cost insights
    if (currentCost > 100) {
      insights.add('Ihre Ausgaben sind relativ hoch (${currentCost.toStringAsFixed(2)}€). Berücksichtigen Sie Ihr Budget.');
    }
    
    return insights;
  }

  List<String> _generatePatternInsights(
    Map<String, dynamic> weekdayPatterns,
    Map<String, dynamic> timeOfDayPatterns,
    Map<String, dynamic> frequencyPatterns,
  ) {
    final insights = <String>[];
    
    // Add weekday insight
    final weekdayInsight = weekdayPatterns['weekdayInsight'] as String;
    if (weekdayInsight.isNotEmpty && weekdayInsight != 'Keine klaren Muster erkennbar.') {
      insights.add(weekdayInsight);
    }
    
    // Add time of day insight
    final timeOfDayInsight = timeOfDayPatterns['timeOfDayInsight'] as String;
    if (timeOfDayInsight.isNotEmpty && timeOfDayInsight != 'Keine klaren Muster erkennbar.') {
      insights.add(timeOfDayInsight);
    }
    
    // Add frequency insight
    final frequencyInsight = frequencyPatterns['frequencyInsight'] as String;
    if (frequencyInsight.isNotEmpty && frequencyInsight != 'Keine klaren Muster erkennbar.') {
      insights.add(frequencyInsight);
    }
    
    return insights;
  }

  List<String> _generateSubstanceInsights(
    Map<String, dynamic> correlations,
    List<Map<String, dynamic>> substanceStats,
  ) {
    final insights = <String>[];
    
    // Correlation insights
    final correlationInsight = correlations['correlationInsight'] as String;
    if (correlationInsight.isNotEmpty && correlationInsight != 'Keine klaren Korrelationen erkennbar.') {
      insights.add(correlationInsight);
    }
    
    // Most used substance insight
    if (substanceStats.isNotEmpty) {
      final mostUsed = substanceStats.first;
      final substanceName = mostUsed['substanceName'] as String;
      final usageCount = mostUsed['usageCount'] as int;
      insights.add('Ihre am häufigsten verwendete Substanz ist $substanceName ($usageCount Mal verwendet).');
    }
    
    return insights;
  }

  Map<String, dynamic> _calculateCostEfficiency(List<dynamic> dailyCosts) {
    if (dailyCosts.isEmpty) {
      return {
        'averageDailyCost': 0.0,
        'costVariability': 0.0,
        'efficiency': 'Keine Daten',
      };
    }
    
    final costs = dailyCosts.map((d) => (d['dailyCost'] as num).toDouble()).toList();
    final average = costs.reduce((a, b) => a + b) / costs.length;
    
    // Calculate standard deviation for variability
    final variance = costs.map((c) => (c - average) * (c - average)).reduce((a, b) => a + b) / costs.length;
    final standardDeviation = variance > 0 ? variance : 0.0;
    
    final variability = average > 0 ? (standardDeviation / average) * 100 : 0.0;
    
    String efficiency;
    if (variability < 20) {
      efficiency = 'Konstant';
    } else if (variability < 50) {
      efficiency = 'Moderat variabel';
    } else {
      efficiency = 'Stark variabel';
    }
    
    return {
      'averageDailyCost': average,
      'costVariability': variability,
      'efficiency': efficiency,
    };
  }

  Map<String, dynamic> _generateCostPredictions(List<dynamic> dailyCosts) {
    if (dailyCosts.length < 7) {
      return {
        'nextWeekPrediction': 0.0,
        'nextMonthPrediction': 0.0,
        'confidence': 'Niedrig',
      };
    }
    
    // Simple linear trend calculation
    final recent = dailyCosts.take(7).map((d) => (d['dailyCost'] as num).toDouble()).toList();
    final recentAverage = recent.reduce((a, b) => a + b) / recent.length;
    
    // Predict next week and month based on recent trend
    final nextWeekPrediction = recentAverage * 7;
    final nextMonthPrediction = recentAverage * 30;
    
    return {
      'nextWeekPrediction': nextWeekPrediction,
      'nextMonthPrediction': nextMonthPrediction,
      'confidence': dailyCosts.length > 30 ? 'Hoch' : 'Mittel',
    };
  }

  List<String> _generateCostInsights(
    Map<String, dynamic> costAnalysis,
    Map<String, dynamic> costEfficiency,
  ) {
    final insights = <String>[];
    
    final totalCost = costAnalysis['totalCost'] as double;
    final avgCostPerEntry = costAnalysis['avgCostPerEntry'] as double;
    final efficiency = costEfficiency['efficiency'] as String;
    
    if (totalCost > 500) {
      insights.add('Ihre Gesamtkosten sind sehr hoch (${totalCost.toStringAsFixed(2)}€). Erwägen Sie eine Budgetplanung.');
    } else if (totalCost > 200) {
      insights.add('Ihre Ausgaben sind moderat (${totalCost.toStringAsFixed(2)}€).');
    }
    
    if (avgCostPerEntry > 20) {
      insights.add('Ihre durchschnittlichen Kosten pro Eintrag sind hoch (${avgCostPerEntry.toStringAsFixed(2)}€).');
    }
    
    insights.add('Ihre Ausgaben sind $efficiency über die Zeit.');
    
    return insights;
  }

  List<String> _generateRiskInsights(
    Map<String, int> riskDistribution,
    Map<String, double> riskPercentages,
  ) {
    final insights = <String>[];
    
    final highRiskPercentage = (riskPercentages['high'] ?? 0.0) + (riskPercentages['critical'] ?? 0.0);
    final lowRiskPercentage = riskPercentages['low'] ?? 0.0;
    
    if (highRiskPercentage > 30) {
      insights.add('${highRiskPercentage.toStringAsFixed(1)}% Ihrer Einträge sind mit hohem Risiko verbunden. Bitte seien Sie vorsichtig.');
    } else if (highRiskPercentage > 10) {
      insights.add('${highRiskPercentage.toStringAsFixed(1)}% Ihrer Einträge haben ein erhöhtes Risiko.');
    }
    
    if (lowRiskPercentage > 70) {
      insights.add('Der Großteil Ihrer Einträge (${lowRiskPercentage.toStringAsFixed(1)}%) ist mit niedrigem Risiko verbunden.');
    }
    
    return insights;
  }
}