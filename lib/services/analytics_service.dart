import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import 'dart:math' as math;
import '../models/entry.dart';
import '../models/substance.dart';
import 'database_service.dart';
import '../utils/performance_helper.dart';

// Time Period Enum - Top-level definition
enum TimePeriod {
  today,
  thisWeek,
  thisMonth,
  last30Days,
  thisYear,
  allTime,
}

class AnalyticsService {
  final DatabaseService _databaseService = DatabaseService();

  // Get comprehensive statistics for a time period
  Future<Map<String, dynamic>> getComprehensiveStats(TimePeriod period) async {
    try {
      // Use performance helper to measure execution time in debug mode
      return await PerformanceHelper.measureExecutionTime(() async {
        final db = await _databaseService.database;
        final dateRange = _getDateRange(period);
        
        // Basic counts
        final totalEntries = await _getEntryCount(db, dateRange);
        final uniqueSubstances = await _getUniqueSubstanceCount(db, dateRange);
        final totalCost = await _getTotalCost(db, dateRange);
        
        // Advanced analytics
        final avgEntriesPerDay = await _getAverageEntriesPerDay(db, dateRange);
        final avgCostPerEntry = totalEntries > 0 ? totalCost / totalEntries : 0.0;
        final avgCostPerDay = await _getAverageCostPerDay(db, dateRange);
        
        // Most used substance
        final mostUsedSubstance = await _getMostUsedSubstance(db, dateRange);
        final mostExpensiveSubstance = await _getMostExpensiveSubstance(db, dateRange);
        
        // Risk analysis
        final riskDistribution = await _getRiskDistribution(db, dateRange);
        
        // Category analysis
        final categoryDistribution = await _getCategoryDistribution(db, dateRange);
        
        // Time patterns
        final hourlyDistribution = await _getHourlyDistribution(db, dateRange);
        final weekdayDistribution = await _getWeekdayDistribution(db, dateRange);
        
        return {
          'period': period.name,
          'dateRange': dateRange,
          'totalEntries': totalEntries,
          'uniqueSubstances': uniqueSubstances,
          'totalCost': totalCost,
          'avgEntriesPerDay': avgEntriesPerDay,
          'avgCostPerEntry': avgCostPerEntry,
          'avgCostPerDay': avgCostPerDay,
          'mostUsedSubstance': mostUsedSubstance,
          'mostExpensiveSubstance': mostExpensiveSubstance,
          'riskDistribution': riskDistribution,
          'categoryDistribution': categoryDistribution,
          'hourlyDistribution': hourlyDistribution,
          'weekdayDistribution': weekdayDistribution,
        };
      }, tag: 'Comprehensive Stats');
    } catch (e) {
      throw Exception('Failed to get comprehensive stats: $e');
    }
  }

  // Get consumption trends over time
  Future<List<Map<String, dynamic>>> getConsumptionTrends(TimePeriod period) async {
    try {
      final db = await _databaseService.database;
      final dateRange = _getDateRange(period);
      
      String groupBy;
      String dateFormat;
      
      switch (period) {
        case TimePeriod.today:
          groupBy = "strftime('%H', dateTime)";
          dateFormat = 'hour';
          break;
        case TimePeriod.thisWeek:
          groupBy = "strftime('%Y-%m-%d', dateTime)";
          dateFormat = 'day';
          break;
        case TimePeriod.thisMonth:
          groupBy = "strftime('%Y-%m-%d', dateTime)";
          dateFormat = 'day';
          break;
        case TimePeriod.thisYear:
          groupBy = "strftime('%Y-%m', dateTime)";
          dateFormat = 'month';
          break;
        case TimePeriod.allTime:
          groupBy = "strftime('%Y-%m', dateTime)";
          dateFormat = 'month';
          break;
      }
      
      final result = await db.rawQuery('''
        SELECT 
          $groupBy as period,
          COUNT(*) as entryCount,
          SUM(cost) as totalCost,
          COUNT(DISTINCT substanceName) as uniqueSubstances
        FROM entries 
        WHERE dateTime BETWEEN ? AND ?
        GROUP BY $groupBy
        ORDER BY period ASC
      ''', [dateRange['start'], dateRange['end']]);
      
      return result.map((row) => {
        'period': row['period'],
        'entryCount': row['entryCount'] as int,
        'totalCost': (row['totalCost'] as num?)?.toDouble() ?? 0.0,
        'uniqueSubstances': row['uniqueSubstances'] as int,
        'dateFormat': dateFormat,
      }).toList();
    } catch (e) {
      throw Exception('Failed to get consumption trends: $e');
    }
  }

  // Get substance usage statistics
  Future<List<Map<String, dynamic>>> getSubstanceStats(TimePeriod period) async {
    try {
      final db = await _databaseService.database;
      final dateRange = _getDateRange(period);
      
      final result = await db.rawQuery('''
        SELECT 
          substanceName,
          COUNT(*) as usageCount,
          SUM(cost) as totalCost,
          AVG(cost) as avgCost,
          SUM(dosage) as totalDosage,
          AVG(dosage) as avgDosage,
          unit,
          MIN(dateTime) as firstUsed,
          MAX(dateTime) as lastUsed
        FROM entries 
        WHERE dateTime BETWEEN ? AND ?
        GROUP BY substanceName, unit
        ORDER BY usageCount DESC
      ''', [dateRange['start'], dateRange['end']]);
      
      return result.map((row) => {
        'substanceName': row['substanceName'] as String,
        'usageCount': row['usageCount'] as int,
        'totalCost': (row['totalCost'] as num?)?.toDouble() ?? 0.0,
        'avgCost': (row['avgCost'] as num?)?.toDouble() ?? 0.0,
        'totalDosage': (row['totalDosage'] as num?)?.toDouble() ?? 0.0,
        'avgDosage': (row['avgDosage'] as num?)?.toDouble() ?? 0.0,
        'unit': row['unit'] as String,
        'firstUsed': row['firstUsed'] as String,
        'lastUsed': row['lastUsed'] as String,
      }).toList();
    } catch (e) {
      throw Exception('Failed to get substance stats: $e');
    }
  }

  // Get cost analysis
  Future<Map<String, dynamic>> getCostAnalysis(TimePeriod period) async {
    try {
      final db = await _databaseService.database;
      final dateRange = _getDateRange(period);
      
      // Total and average costs
      final totalCost = await _getTotalCost(db, dateRange);
      final entryCount = await _getEntryCount(db, dateRange);
      final avgCostPerEntry = entryCount > 0 ? totalCost / entryCount : 0.0;
      
      // Daily cost breakdown
      final dailyCosts = await db.rawQuery('''
        SELECT 
          strftime('%Y-%m-%d', dateTime) as date,
          SUM(cost) as dailyCost,
          COUNT(*) as dailyEntries
        FROM entries 
        WHERE dateTime BETWEEN ? AND ?
        GROUP BY strftime('%Y-%m-%d', dateTime)
        ORDER BY date DESC
      ''', [dateRange['start'], dateRange['end']]);
      
      // Most expensive substances
      final expensiveSubstances = await db.rawQuery('''
        SELECT 
          substanceName,
          SUM(cost) as totalCost,
          COUNT(*) as usageCount,
          AVG(cost) as avgCost
        FROM entries 
        WHERE dateTime BETWEEN ? AND ? AND cost > 0
        GROUP BY substanceName
        ORDER BY totalCost DESC
        LIMIT 10
      ''', [dateRange['start'], dateRange['end']]);
      
      // Cost trends
      final costTrends = await db.rawQuery('''
        SELECT 
          strftime('%Y-%m', dateTime) as month,
          SUM(cost) as monthlyCost,
          COUNT(*) as monthlyEntries
        FROM entries 
        WHERE dateTime BETWEEN ? AND ?
        GROUP BY strftime('%Y-%m', dateTime)
        ORDER BY month ASC
      ''', [dateRange['start'], dateRange['end']]);
      
      return {
        'totalCost': totalCost,
        'avgCostPerEntry': avgCostPerEntry,
        'dailyCosts': dailyCosts,
        'expensiveSubstances': expensiveSubstances,
        'costTrends': costTrends,
      };
    } catch (e) {
      throw Exception('Failed to get cost analysis: $e');
    }
  }

  // Get risk analysis
  Future<Map<String, dynamic>> getRiskAnalysis(TimePeriod period) async {
    try {
      final db = await _databaseService.database;
      final dateRange = _getDateRange(period);
      
      // Risk distribution from substances table
      final riskDistribution = await db.rawQuery('''
        SELECT 
          s.defaultRiskLevel,
          COUNT(e.id) as entryCount,
          SUM(e.cost) as totalCost
        FROM entries e
        LEFT JOIN substances s ON e.substanceId = s.id
        WHERE e.dateTime BETWEEN ? AND ?
        GROUP BY s.defaultRiskLevel
        ORDER BY s.defaultRiskLevel ASC
      ''', [dateRange['start'], dateRange['end']]);
      
      // High risk entries
      final highRiskEntries = await db.rawQuery('''
        SELECT 
          e.substanceName,
          e.dosage,
          e.unit,
          e.dateTime,
          s.defaultRiskLevel
        FROM entries e
        LEFT JOIN substances s ON e.substanceId = s.id
        WHERE e.dateTime BETWEEN ? AND ? AND s.defaultRiskLevel >= 2
        ORDER BY e.dateTime DESC
        LIMIT 20
      ''', [dateRange['start'], dateRange['end']]);
      
      return {
        'riskDistribution': riskDistribution,
        'highRiskEntries': highRiskEntries,
      };
    } catch (e) {
      throw Exception('Failed to get risk analysis: $e');
    }
  }

  // NEW METHODS FOR PATTERN ANALYSIS

  // Get weekday patterns
  Future<Map<String, dynamic>> getWeekdayPatterns() async {
    try {
      final db = await _databaseService.database;
      
      // Get weekday distribution
      final weekdayResult = await db.rawQuery('''
        SELECT 
          CASE strftime('%w', dateTime)
            WHEN '0' THEN 'Sunday'
            WHEN '1' THEN 'Monday'
            WHEN '2' THEN 'Tuesday'
            WHEN '3' THEN 'Wednesday'
            WHEN '4' THEN 'Thursday'
            WHEN '5' THEN 'Friday'
            WHEN '6' THEN 'Saturday'
          END as weekday,
          COUNT(*) as count
        FROM entries
        GROUP BY weekday
        ORDER BY 
          CASE weekday
            WHEN 'Monday' THEN 1
            WHEN 'Tuesday' THEN 2
            WHEN 'Wednesday' THEN 3
            WHEN 'Thursday' THEN 4
            WHEN 'Friday' THEN 5
            WHEN 'Saturday' THEN 6
            WHEN 'Sunday' THEN 7
          END
      ''');
      
      // Convert to map
      final weekdayDistribution = <String, int>{};
      for (final row in weekdayResult) {
        weekdayDistribution[row['weekday'] as String] = row['count'] as int;
      }
      
      // Find most common weekday
      String mostCommonWeekday = 'Keine Daten';
      int maxCount = 0;
      
      weekdayDistribution.forEach((weekday, count) {
        if (count > maxCount) {
          maxCount = count;
          mostCommonWeekday = _getWeekdayDisplayName(weekday);
        }
      });
      
      // Generate insight
      String weekdayInsight = 'Keine klaren Muster erkennbar.';
      
      if (weekdayDistribution.isNotEmpty) {
        final weekendCount = (weekdayDistribution['Saturday'] ?? 0) + (weekdayDistribution['Sunday'] ?? 0);
        final weekdayCount = weekdayDistribution.entries
            .where((e) => e.key != 'Saturday' && e.key != 'Sunday')
            .fold(0, (sum, e) => sum + e.value);
        
        if (weekendCount > weekdayCount) {
          weekdayInsight = 'Sie konsumieren häufiger am Wochenende als unter der Woche. Dies könnte auf ein Freizeitmuster hindeuten.';
        } else if (weekdayCount > weekendCount * 2) {
          weekdayInsight = 'Sie konsumieren deutlich häufiger unter der Woche. Dies könnte auf ein arbeitsbezogenes Muster hindeuten.';
        } else {
          weekdayInsight = 'Ihr Konsum ist relativ gleichmäßig über die Woche verteilt, mit einer leichten Häufung am $mostCommonWeekday.';
        }
      }
      
      return {
        'weekdayDistribution': weekdayDistribution,
        'mostCommonWeekday': mostCommonWeekday,
        'weekdayInsight': weekdayInsight,
      };
    } catch (e) {
      throw Exception('Failed to get weekday patterns: $e');
    }
  }

  // Get time of day patterns
  Future<Map<String, dynamic>> getTimeOfDayPatterns() async {
    try {
      final db = await _databaseService.database;
      
      // Get hourly distribution
      final hourlyResult = await db.rawQuery('''
        SELECT 
          strftime('%H', dateTime) as hour,
          COUNT(*) as count
        FROM entries
        GROUP BY hour
        ORDER BY hour
      ''');
      
      // Convert to map
      final hourlyDistribution = <String, int>{};
      for (final row in hourlyResult) {
        hourlyDistribution[row['hour'] as String] = row['count'] as int;
      }
      
      // Categorize into time of day
      int morningCount = 0; // 6-12
      int afternoonCount = 0; // 12-18
      int eveningCount = 0; // 18-24
      int nightCount = 0; // 0-6
      
      hourlyDistribution.forEach((hour, count) {
        final hourInt = int.parse(hour);
        if (hourInt >= 6 && hourInt < 12) {
          morningCount += count;
        } else if (hourInt >= 12 && hourInt < 18) {
          afternoonCount += count;
        } else if (hourInt >= 18 && hourInt < 24) {
          eveningCount += count;
        } else {
          nightCount += count;
        }
      });
      
      // Find most common time of day
      String mostCommonTimeOfDay = 'Keine Daten';
      int maxCount = 0;
      
      final timeOfDayMap = {
        'Morgen (6-12 Uhr)': morningCount,
        'Nachmittag (12-18 Uhr)': afternoonCount,
        'Abend (18-24 Uhr)': eveningCount,
        'Nacht (0-6 Uhr)': nightCount,
      };
      
      timeOfDayMap.forEach((timeOfDay, count) {
        if (count > maxCount) {
          maxCount = count;
          mostCommonTimeOfDay = timeOfDay;
        }
      });
      
      // Generate insight
      String timeOfDayInsight = 'Keine klaren Muster erkennbar.';
      
      if (hourlyDistribution.isNotEmpty) {
        if (eveningCount > morningCount + afternoonCount) {
          timeOfDayInsight = 'Sie konsumieren deutlich häufiger am Abend. Dies könnte auf ein Entspannungsmuster nach der Arbeit hindeuten.';
        } else if (nightCount > morningCount + afternoonCount) {
          timeOfDayInsight = 'Sie konsumieren auffällig häufig in der Nacht. Dies könnte auf Schlafprobleme oder nächtliche Aktivitäten hindeuten.';
        } else if (morningCount > eveningCount + afternoonCount) {
          timeOfDayInsight = 'Sie konsumieren häufig am Morgen. Dies könnte auf ein Muster zur Tagesbewältigung hindeuten.';
        } else {
          timeOfDayInsight = 'Ihr Konsum ist am häufigsten am $mostCommonTimeOfDay.';
        }
      }
      
      return {
        'hourlyDistribution': hourlyDistribution,
        'timeOfDayDistribution': timeOfDayMap,
        'mostCommonTimeOfDay': mostCommonTimeOfDay,
        'timeOfDayInsight': timeOfDayInsight,
      };
    } catch (e) {
      throw Exception('Failed to get time of day patterns: $e');
    }
  }

  // Get frequency patterns
  Future<Map<String, dynamic>> getFrequencyPatterns() async {
    try {
      final db = await _databaseService.database;
      
      // Get all entries ordered by date
      final entriesResult = await db.query(
        'entries',
        columns: ['dateTime'],
        orderBy: 'dateTime ASC',
      );
      
      if (entriesResult.isEmpty) {
        return {
          'frequencyDistribution': <String, int>{},
          'averageFrequencyDays': 0.0,
          'frequencyInsight': 'Nicht genügend Daten für eine Frequenzanalyse.',
        };
      }
      
      // Calculate days between entries
      final List<int> daysBetween = [];
      DateTime? previousDate;
      
      for (final entry in entriesResult) {
        final currentDate = DateTime.parse(entry['dateTime'] as String);
        
        if (previousDate != null) {
          final difference = currentDate.difference(previousDate).inDays;
          if (difference > 0) { // Only count different days
            daysBetween.add(difference);
          }
        }
        
        previousDate = currentDate;
      }
      
      // Calculate frequency distribution
      final frequencyDistribution = <String, int>{
        'Täglich': 0,
        'Alle 2-3 Tage': 0,
        'Wöchentlich': 0,
        'Alle 2 Wochen': 0,
        'Monatlich': 0,
        'Seltener': 0,
      };
      
      for (final days in daysBetween) {
        if (days == 1) {
          frequencyDistribution['Täglich'] = (frequencyDistribution['Täglich'] ?? 0) + 1;
        } else if (days >= 2 && days <= 3) {
          frequencyDistribution['Alle 2-3 Tage'] = (frequencyDistribution['Alle 2-3 Tage'] ?? 0) + 1;
        } else if (days >= 4 && days <= 7) {
          frequencyDistribution['Wöchentlich'] = (frequencyDistribution['Wöchentlich'] ?? 0) + 1;
        } else if (days >= 8 && days <= 14) {
          frequencyDistribution['Alle 2 Wochen'] = (frequencyDistribution['Alle 2 Wochen'] ?? 0) + 1;
        } else if (days >= 15 && days <= 31) {
          frequencyDistribution['Monatlich'] = (frequencyDistribution['Monatlich'] ?? 0) + 1;
        } else {
          frequencyDistribution['Seltener'] = (frequencyDistribution['Seltener'] ?? 0) + 1;
        }
      }
      
      // Calculate average frequency
      final averageFrequencyDays = daysBetween.isEmpty 
          ? 0.0 
          : daysBetween.reduce((a, b) => a + b) / daysBetween.length;
      
      // Generate insight
      String frequencyInsight = 'Keine klaren Muster erkennbar.';
      
      if (daysBetween.isNotEmpty) {
        if (averageFrequencyDays < 2) {
          frequencyInsight = 'Sie konsumieren im Durchschnitt täglich. Dies deutet auf ein regelmäßiges Konsummuster hin.';
        } else if (averageFrequencyDays < 4) {
          frequencyInsight = 'Sie konsumieren im Durchschnitt alle ${averageFrequencyDays.toStringAsFixed(1)} Tage. Dies deutet auf ein häufiges Konsummuster hin.';
        } else if (averageFrequencyDays < 8) {
          frequencyInsight = 'Sie konsumieren im Durchschnitt etwa wöchentlich. Dies deutet auf ein regelmäßiges, aber moderates Konsummuster hin.';
        } else if (averageFrequencyDays < 15) {
          frequencyInsight = 'Sie konsumieren im Durchschnitt etwa alle zwei Wochen. Dies deutet auf ein gelegentliches Konsummuster hin.';
        } else if (averageFrequencyDays < 32) {
          frequencyInsight = 'Sie konsumieren im Durchschnitt etwa monatlich. Dies deutet auf ein seltenes Konsummuster hin.';
        } else {
          frequencyInsight = 'Sie konsumieren im Durchschnitt seltener als monatlich. Dies deutet auf ein sehr seltenes Konsummuster hin.';
        }
      }
      
      return {
        'frequencyDistribution': frequencyDistribution,
        'averageFrequencyDays': averageFrequencyDays,
        'frequencyInsight': frequencyInsight,
      };
    } catch (e) {
      throw Exception('Failed to get frequency patterns: $e');
    }
  }

  // Get substance correlations
  Future<Map<String, dynamic>> getSubstanceCorrelations() async {
    try {
      final db = await _databaseService.database;
      
      // Get all substances
      final substancesResult = await db.query(
        'substances',
        columns: ['id', 'name'],
      );
      
      if (substancesResult.length < 2) {
        return {
          'correlationMatrix': <Map<String, dynamic>>[],
          'mostCorrelatedPair': <String>['Keine Daten', 'Keine Daten'],
          'correlationInsight': 'Nicht genügend Substanzen für eine Korrelationsanalyse.',
        };
      }
      
      // Get all entries grouped by date
      final entriesResult = await db.rawQuery('''
        SELECT 
          substanceName,
          strftime('%Y-%m-%d', dateTime) as date
        FROM entries
        ORDER BY date
      ''');
      
      // Build substance usage by date
      final substancesByDate = <String, Set<String>>{};
      
      for (final entry in entriesResult) {
        final date = entry['date'] as String;
        final substance = entry['substanceName'] as String;
        
        if (!substancesByDate.containsKey(date)) {
          substancesByDate[date] = <String>{};
        }
        
        substancesByDate[date]!.add(substance);
      }
      
      // Calculate correlations
      final correlationMatrix = <Map<String, dynamic>>[];
      final substances = substancesResult.map((s) => s['name'] as String).toList();
      
      for (int i = 0; i < substances.length; i++) {
        for (int j = i + 1; j < substances.length; j++) {
          final substance1 = substances[i];
          final substance2 = substances[j];
          
          int coOccurrences = 0;
          int substance1Occurrences = 0;
          int substance2Occurrences = 0;
          
          substancesByDate.forEach((date, substancesUsed) {
            final hasSubstance1 = substancesUsed.contains(substance1);
            final hasSubstance2 = substancesUsed.contains(substance2);
            
            if (hasSubstance1) substance1Occurrences++;
            if (hasSubstance2) substance2Occurrences++;
            if (hasSubstance1 && hasSubstance2) coOccurrences++;
          });
          
          // Calculate correlation coefficient (simple version)
          double correlation = 0;
          if (substance1Occurrences > 0 && substance2Occurrences > 0) {
            correlation = coOccurrences / 
                Math.sqrt(substance1Occurrences.toDouble() * substance2Occurrences.toDouble());
          }
          
          // Determine strength
          String strength;
          if (correlation >= 0.7) {
            strength = 'Stark';
          } else if (correlation >= 0.4) {
            strength = 'Mittel';
          } else {
            strength = 'Schwach';
          }
          
          correlationMatrix.add({
            'substance1': substance1,
            'substance2': substance2,
            'correlation': correlation,
            'coOccurrences': coOccurrences,
            'strength': strength,
          });
        }
      }
      
      // Sort by correlation
      correlationMatrix.sort((a, b) => 
          (b['correlation'] as double).compareTo(a['correlation'] as double));
      
      // Find most correlated pair
      List<String> mostCorrelatedPair = ['Keine Daten', 'Keine Daten'];
      if (correlationMatrix.isNotEmpty) {
        mostCorrelatedPair = [
          correlationMatrix.first['substance1'] as String,
          correlationMatrix.first['substance2'] as String,
        ];
      }
      
      // Generate insight
      String correlationInsight = 'Keine klaren Korrelationen erkennbar.';
      
      if (correlationMatrix.isNotEmpty) {
        final topCorrelation = correlationMatrix.first;
        final substance1 = topCorrelation['substance1'] as String;
        final substance2 = topCorrelation['substance2'] as String;
        final strength = topCorrelation['strength'] as String;
        
        if (strength == 'Stark') {
          correlationInsight = 'Es besteht eine starke Korrelation zwischen $substance1 und $substance2. Sie werden häufig zusammen konsumiert.';
        } else if (strength == 'Mittel') {
          correlationInsight = 'Es besteht eine mittlere Korrelation zwischen $substance1 und $substance2. Sie werden gelegentlich zusammen konsumiert.';
        } else {
          correlationInsight = 'Es besteht eine schwache Korrelation zwischen $substance1 und $substance2. Sie werden selten zusammen konsumiert.';
        }
      }
      
      return {
        'correlationMatrix': correlationMatrix,
        'mostCorrelatedPair': mostCorrelatedPair,
        'correlationInsight': correlationInsight,
      };
    } catch (e) {
      throw Exception('Failed to get substance correlations: $e');
    }
  }

  // Helper methods
  Map<String, String> _getDateRange(TimePeriod period) {
    final now = DateTime.now();
    DateTime start;
    DateTime end = now;
    
    switch (period) {
      case TimePeriod.today:
        start = DateTime(now.year, now.month, now.day);
        end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case TimePeriod.thisWeek:
        start = now.subtract(Duration(days: now.weekday - 1));
        start = DateTime(start.year, start.month, start.day);
        break;
      case TimePeriod.thisMonth:
        start = DateTime(now.year, now.month, 1);
        break;
      case TimePeriod.last30Days:
        start = now.subtract(const Duration(days: 30));
        start = DateTime(start.year, start.month, start.day);
        break;
      case TimePeriod.thisYear:
        start = DateTime(now.year, 1, 1);
        break;
      case TimePeriod.allTime:
        start = DateTime(2020, 1, 1); // Reasonable start date
        break;
    }
    
    return {
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
    };
  }

  Future<int> _getEntryCount(Database db, Map<String, String> dateRange) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM entries WHERE dateTime BETWEEN ? AND ?',
      [dateRange['start'], dateRange['end']]
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> _getUniqueSubstanceCount(Database db, Map<String, String> dateRange) async {
    final result = await db.rawQuery(
      'SELECT COUNT(DISTINCT substanceName) as count FROM entries WHERE dateTime BETWEEN ? AND ?',
      [dateRange['start'], dateRange['end']]
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<double> _getTotalCost(Database db, Map<String, String> dateRange) async {
    final result = await db.rawQuery(
      'SELECT SUM(cost) as total FROM entries WHERE dateTime BETWEEN ? AND ?',
      [dateRange['start'], dateRange['end']]
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> _getAverageEntriesPerDay(Database db, Map<String, String> dateRange) async {
    final startDate = DateTime.parse(dateRange['start']!);
    final endDate = DateTime.parse(dateRange['end']!);
    final daysDiff = endDate.difference(startDate).inDays + 1;
    
    final entryCount = await _getEntryCount(db, dateRange);
    return daysDiff > 0 ? entryCount / daysDiff : 0.0;
  }

  Future<double> _getAverageCostPerDay(Database db, Map<String, String> dateRange) async {
    final startDate = DateTime.parse(dateRange['start']!);
    final endDate = DateTime.parse(dateRange['end']!);
    final daysDiff = endDate.difference(startDate).inDays + 1;
    
    final totalCost = await _getTotalCost(db, dateRange);
    return daysDiff > 0 ? totalCost / daysDiff : 0.0;
  }

  Future<String> _getMostUsedSubstance(Database db, Map<String, String> dateRange) async {
    final result = await db.rawQuery('''
      SELECT substanceName, COUNT(*) as count 
      FROM entries 
      WHERE dateTime BETWEEN ? AND ?
      GROUP BY substanceName 
      ORDER BY count DESC 
      LIMIT 1
    ''', [dateRange['start'], dateRange['end']]);
    
    return result.isNotEmpty ? result.first['substanceName'] as String : 'Keine Daten';
  }

  Future<String> _getMostExpensiveSubstance(Database db, Map<String, String> dateRange) async {
    final result = await db.rawQuery('''
      SELECT substanceName, SUM(cost) as totalCost 
      FROM entries 
      WHERE dateTime BETWEEN ? AND ? AND cost > 0
      GROUP BY substanceName 
      ORDER BY totalCost DESC 
      LIMIT 1
    ''', [dateRange['start'], dateRange['end']]);
    
    return result.isNotEmpty ? result.first['substanceName'] as String : 'Keine Daten';
  }

  Future<Map<String, int>> _getRiskDistribution(Database db, Map<String, String> dateRange) async {
    final result = await db.rawQuery('''
      SELECT 
        s.defaultRiskLevel,
        COUNT(e.id) as count
      FROM entries e
      LEFT JOIN substances s ON e.substanceId = s.id
      WHERE e.dateTime BETWEEN ? AND ?
      GROUP BY s.defaultRiskLevel
    ''', [dateRange['start'], dateRange['end']]);
    
    final Map<String, int> distribution = {
      'low': 0,
      'medium': 0,
      'high': 0,
      'critical': 0,
    };
    
    for (final row in result) {
      final riskLevel = row['defaultRiskLevel'] as int?;
      final count = row['count'] as int;
      
      switch (riskLevel) {
        case 0:
          distribution['low'] = count;
          break;
        case 1:
          distribution['medium'] = count;
          break;
        case 2:
          distribution['high'] = count;
          break;
        case 3:
          distribution['critical'] = count;
          break;
      }
    }
    
    return distribution;
  }

  Future<Map<String, int>> _getCategoryDistribution(Database db, Map<String, String> dateRange) async {
    final result = await db.rawQuery('''
      SELECT 
        s.category,
        COUNT(e.id) as count
      FROM entries e
      LEFT JOIN substances s ON e.substanceId = s.id
      WHERE e.dateTime BETWEEN ? AND ?
      GROUP BY s.category
    ''', [dateRange['start'], dateRange['end']]);
    
    final Map<String, int> distribution = {
      'medication': 0,
      'stimulant': 0,
      'depressant': 0,
      'supplement': 0,
      'recreational': 0,
      'other': 0,
    };
    
    for (final row in result) {
      final category = row['category'] as int?;
      final count = row['count'] as int;
      
      switch (category) {
        case 0:
          distribution['medication'] = count;
          break;
        case 1:
          distribution['stimulant'] = count;
          break;
        case 2:
          distribution['depressant'] = count;
          break;
        case 3:
          distribution['supplement'] = count;
          break;
        case 4:
          distribution['recreational'] = count;
          break;
        case 5:
          distribution['other'] = count;
          break;
      }
    }
    
    return distribution;
  }

  Future<Map<int, int>> _getHourlyDistribution(Database db, Map<String, String> dateRange) async {
    final result = await db.rawQuery('''
      SELECT 
        CAST(strftime('%H', dateTime) AS INTEGER) as hour,
        COUNT(*) as count
      FROM entries 
      WHERE dateTime BETWEEN ? AND ?
      GROUP BY hour
      ORDER BY hour ASC
    ''', [dateRange['start'], dateRange['end']]);
    
    final Map<int, int> distribution = {};
    for (int i = 0; i < 24; i++) {
      distribution[i] = 0;
    }
    
    for (final row in result) {
      final hour = row['hour'] as int;
      final count = row['count'] as int;
      distribution[hour] = count;
    }
    
    return distribution;
  }

  Future<Map<int, int>> _getWeekdayDistribution(Database db, Map<String, String> dateRange) async {
    final result = await db.rawQuery('''
      SELECT 
        CAST(strftime('%w', dateTime) AS INTEGER) as weekday,
        COUNT(*) as count
      FROM entries 
      WHERE dateTime BETWEEN ? AND ?
      GROUP BY weekday
      ORDER BY weekday ASC
    ''', [dateRange['start'], dateRange['end']]);
    
    final Map<int, int> distribution = {};
    for (int i = 0; i < 7; i++) {
      distribution[i] = 0;
    }
    
    for (final row in result) {
      final weekday = row['weekday'] as int;
      final count = row['count'] as int;
      distribution[weekday] = count;
    }
    
    return distribution;
  }

  // Get comparison between two periods
  Future<Map<String, dynamic>> getComparison(TimePeriod currentPeriod, TimePeriod previousPeriod) async {
    try {
      final currentStats = await getComprehensiveStats(currentPeriod);
      final previousStats = await getComprehensiveStats(previousPeriod);
      
      final entryChange = _calculatePercentageChange(
        previousStats['totalEntries'] as int,
        currentStats['totalEntries'] as int,
      );
      
      final costChange = _calculatePercentageChange(
        previousStats['totalCost'] as double,
        currentStats['totalCost'] as double,
      );
      
      return {
        'current': currentStats,
        'previous': previousStats,
        'entryChange': entryChange,
        'costChange': costChange,
      };
    } catch (e) {
      throw Exception('Failed to get comparison: $e');
    }
  }

  double _calculatePercentageChange(num oldValue, num newValue) {
    if (oldValue == 0) return newValue > 0 ? 100.0 : 0.0;
    return ((newValue - oldValue) / oldValue) * 100;
  }

  String _getWeekdayDisplayName(String weekday) {
    switch (weekday.toLowerCase()) {
      case 'monday':
        return 'Montag';
      case 'tuesday':
        return 'Dienstag';
      case 'wednesday':
        return 'Mittwoch';
      case 'thursday':
        return 'Donnerstag';
      case 'friday':
        return 'Freitag';
      case 'saturday':
        return 'Samstag';
      case 'sunday':
        return 'Sonntag';
      default:
        return weekday;
    }
  }
}

// Math utility class for analytics calculations
class Math {
  static double sqrt(double value) {
    return value <= 0 ? 0 : math.sqrt(value);
  }
}