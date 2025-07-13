import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

class AppIconGenerator {
  // Generate substance category icon
  static IconData getSubstanceCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'medication':
      case 'medikament':
        return Icons.medication_rounded;
      case 'stimulant':
      case 'stimulans':
        return Icons.flash_on_rounded;
      case 'depressant':
      case 'depressivum':
        return Icons.bedtime_rounded;
      case 'supplement':
      case 'nahrungsergänzung':
        return Icons.health_and_safety_rounded;
      case 'recreational':
      case 'freizeitsubstanz':
        return Icons.celebration_rounded;
      case 'other':
      case 'sonstiges':
      default:
        return Icons.science_rounded;
    }
  }

  // Generate substance icon based on name
  static IconData getSubstanceIcon(String substanceName) {
    final name = substanceName.toLowerCase();
    
    // Caffeine and stimulants
    if (name.contains('kaffee') || name.contains('coffee') || name.contains('koffein')) {
      return Icons.local_cafe_rounded;
    }
    if (name.contains('energie') || name.contains('energy')) {
      return Icons.flash_on_rounded;
    }
    if (name.contains('tee') || name.contains('tea')) {
      return Icons.emoji_food_beverage_rounded;
    }
    
    // Alcohol
    if (name.contains('alkohol') || name.contains('alcohol')) {
      return Icons.local_bar_rounded;
    }
    if (name.contains('bier') || name.contains('beer')) {
      return Icons.sports_bar_rounded;
    }
    if (name.contains('wein') || name.contains('wine')) {
      return Icons.wine_bar_rounded;
    }
    
    // Tobacco and smoking
    if (name.contains('zigarette') || name.contains('cigarette') || 
        name.contains('tabak') || name.contains('tobacco') ||
        name.contains('nikotin') || name.contains('nicotine')) {
      return Icons.smoking_rooms_rounded;
    }
    
    // Cannabis
    if (name.contains('cannabis') || name.contains('marihuana') || 
        name.contains('marijuana') || name.contains('thc') ||
        name.contains('cbd') || name.contains('hanf')) {
      return Icons.local_florist_rounded;
    }
    
    // Medications
    if (name.contains('medikament') || name.contains('medication') ||
        name.contains('tablette') || name.contains('tablet') ||
        name.contains('pille') || name.contains('pill')) {
      return Icons.medication_rounded;
    }
    if (name.contains('ibuprofen') || name.contains('aspirin') ||
        name.contains('paracetamol') || name.contains('schmerzmittel')) {
      return Icons.healing_rounded;
    }
    
    // Vitamins and supplements
    if (name.contains('vitamin') || name.contains('supplement') ||
        name.contains('nahrungsergänzung')) {
      return Icons.health_and_safety_rounded;
    }
    if (name.contains('protein') || name.contains('eiweiß')) {
      return Icons.fitness_center_rounded;
    }
    if (name.contains('omega') || name.contains('fischöl')) {
      return Icons.water_drop_rounded;
    }
    
    // Psychedelics
    if (name.contains('lsd') || name.contains('psilocybin') ||
        name.contains('mdma') || name.contains('ecstasy') ||
        name.contains('2c-b') || name.contains('dmt')) {
      return Icons.psychology_rounded;
    }
    
    // Depressants
    if (name.contains('benzodiazepin') || name.contains('xanax') ||
        name.contains('valium') || name.contains('lorazepam')) {
      return Icons.bedtime_rounded;
    }
    if (name.contains('ketamin') || name.contains('ketamine')) {
      return Icons.medical_services_rounded;
    }
    
    // Stimulants
    if (name.contains('kokain') || name.contains('cocaine') ||
        name.contains('amphetamin') || name.contains('speed')) {
      return Icons.bolt_rounded;
    }
    
    // Sleep aids
    if (name.contains('melatonin') || name.contains('schlafmittel') ||
        name.contains('sleep')) {
      return Icons.bedtime_rounded;
    }
    
    // Default icon
    return Icons.science_rounded;
  }

  // Generate risk level icon
  static IconData getRiskLevelIcon(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'low':
      case 'niedrig':
        return Icons.check_circle_rounded;
      case 'medium':
      case 'mittel':
        return Icons.warning_rounded;
      case 'high':
      case 'hoch':
        return Icons.error_rounded;
      case 'critical':
      case 'kritisch':
        return Icons.dangerous_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  // Generate category color
  static Color getSubstanceCategoryColor(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'medication':
      case 'medikament':
        return DesignTokens.infoBlue;
      case 'stimulant':
      case 'stimulans':
        return DesignTokens.warningOrange;
      case 'depressant':
      case 'depressivum':
        return DesignTokens.primaryPurple;
      case 'supplement':
      case 'nahrungsergänzung':
        return DesignTokens.successGreen;
      case 'recreational':
      case 'freizeitsubstanz':
        return DesignTokens.accentCyan;
      case 'other':
      case 'sonstiges':
      default:
        return DesignTokens.neutral500;
    }
  }

  // Generate risk level color
  static Color getRiskLevelColor(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'low':
      case 'niedrig':
        return DesignTokens.successGreen;
      case 'medium':
      case 'mittel':
        return DesignTokens.warningOrange;
      case 'high':
      case 'hoch':
        return DesignTokens.errorRed;
      case 'critical':
      case 'kritisch':
        return DesignTokens.errorRed;
      default:
        return DesignTokens.neutral500;
    }
  }

  // Generate substance color based on name hash
  static Color getSubstanceColor(String substanceName) {
    final hash = substanceName.hashCode;
    final colors = [
      DesignTokens.primaryIndigo,
      DesignTokens.accentCyan,
      DesignTokens.accentEmerald,
      DesignTokens.accentPurple,
      DesignTokens.warningYellow,
      DesignTokens.errorRed,
    ];
    return colors[hash.abs() % colors.length];
  }

  // Generate navigation icon
  static IconData getNavigationIcon(String screenName, {bool isActive = false}) {
    switch (screenName.toLowerCase()) {
      case 'home':
        return isActive ? Icons.home_rounded : Icons.home_outlined;
      case 'statistics':
      case 'statistiken':
        return isActive ? Icons.analytics_rounded : Icons.analytics_outlined;
      case 'calendar':
      case 'kalender':
        return isActive ? Icons.calendar_today_rounded : Icons.calendar_today_outlined;
      case 'settings':
      case 'einstellungen':
        return isActive ? Icons.settings_rounded : Icons.settings_outlined;
      default:
        return Icons.help_outline_rounded;
    }
  }

  // Generate action icon
  static IconData getActionIcon(String actionName) {
    switch (actionName.toLowerCase()) {
      case 'add':
      case 'hinzufügen':
        return Icons.add_rounded;
      case 'edit':
      case 'bearbeiten':
        return Icons.edit_rounded;
      case 'delete':
      case 'löschen':
        return Icons.delete_rounded;
      case 'save':
      case 'speichern':
        return Icons.save_rounded;
      case 'cancel':
      case 'abbrechen':
        return Icons.cancel_rounded;
      case 'search':
      case 'suchen':
        return Icons.search_rounded;
      case 'filter':
      case 'filtern':
        return Icons.filter_list_rounded;
      case 'sort':
      case 'sortieren':
        return Icons.sort_rounded;
      case 'export':
      case 'exportieren':
        return Icons.download_rounded;
      case 'import':
      case 'importieren':
        return Icons.upload_rounded;
      case 'backup':
      case 'sicherung':
        return Icons.backup_rounded;
      case 'restore':
      case 'wiederherstellen':
        return Icons.restore_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  // Generate status icon
  static IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'erfolgreich':
        return Icons.check_circle_rounded;
      case 'error':
      case 'fehler':
        return Icons.error_rounded;
      case 'warning':
      case 'warnung':
        return Icons.warning_rounded;
      case 'info':
      case 'information':
        return Icons.info_rounded;
      case 'loading':
      case 'laden':
        return Icons.hourglass_empty_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  // Generate unit icon
  static IconData getUnitIcon(String unit) {
    switch (unit.toLowerCase()) {
      case 'mg':
      case 'g':
      case 'kg':
        return Icons.scale_rounded;
      case 'ml':
      case 'l':
        return Icons.local_drink_rounded;
      case 'stück':
      case 'piece':
      case 'pcs':
        return Icons.looks_one_rounded;
      case 'ie':
      case 'iu':
        return Icons.health_and_safety_rounded;
      case '%':
        return Icons.percent_rounded;
      case '°c':
      case 'celsius':
        return Icons.thermostat_rounded;
      default:
        return Icons.straighten_rounded;
    }
  }
}