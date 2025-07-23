/// Service Interfaces for Dependency Inversion
/// 
/// Phase 3: Architecture Improvements - Interface Abstractions
/// Enables loose coupling and better testability
/// 
/// Author: Code Quality Improvement Agent
/// Date: Phase 3 - Architecture Improvements

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/entry.dart';
import '../models/substance.dart';
import '../models/quick_button_config.dart';

/// Custom ThemeMode with psychedelic support
enum AppThemeMode { light, dark, trippy, system }

/// Interface for Entry Service operations
abstract class IEntryService extends ChangeNotifier {
  Future<String> createEntry(Entry entry);
  Future<String> addEntry(Entry entry);
  Future<Entry> createEntryWithTimer(Entry entry, {Duration? customDuration, required ITimerService timerService});
  Future<List<Entry>> getAllEntries();
  Future<List<Entry>> getEntriesByDateRange(DateTime start, DateTime end);
  Future<List<Entry>> getEntriesBySubstance(String substanceId);
  Future<Entry?> getEntryById(String id);
  Future<void> updateEntry(Entry entry);
  Future<void> deleteEntry(String id);
  Future<List<Entry>> getActiveTimerEntries();
  Future<void> updateEntryTimer(String id, DateTime? timerStartTime, Duration? duration);
  Future<Map<String, dynamic>> getStatistics();
  Future<Map<String, dynamic>> getCostStatistics();
  Future<List<Entry>> advancedSearch(Map<String, dynamic> searchParams);
}

/// Interface for Substance Service operations  
abstract class ISubstanceService extends ChangeNotifier {
  Future<String> createSubstance(Substance substance);
  Future<List<Substance>> getAllSubstances();
  Future<Substance?> getSubstanceById(String id);
  Future<Substance?> getSubstanceByName(String name);
  Future<void> updateSubstance(Substance substance);
  Future<void> deleteSubstance(String id);
  Future<List<Substance>> searchSubstances(String query);
  Future<List<Substance>> getSubstancesByCategory(SubstanceCategory category);
  Future<List<Substance>> getMostUsedSubstances({int limit = 10});
  Future<void> initializeDefaultSubstances();
  Future<List<String>> getAllUsedUnits();
  Future<List<String>> getSuggestedUnits();
  Future<bool> unitExists(String unit);
  Future<List<Substance>> getSubstancesByUnit(String unit);
  String? validateUnit(String? unit);
  List<String> getRecommendedUnitsForCategory(SubstanceCategory category);
}

/// Interface for Timer Service operations
abstract class ITimerService extends ChangeNotifier {
  Future<void> init();
  Future<Entry> startTimer(Entry entry, {Duration? customDuration});
  Future<void> stopTimer(String entryId);
  Future<void> pauseTimer(String entryId);
  Future<void> resumeTimer(String entryId);
  Duration? getRemainingTime(String entryId);
  bool isTimerActive();
  bool hasActiveTimer(String entryId);
  double getTimerProgress(String entryId);
  List<Entry> get activeTimers;
  bool get hasAnyActiveTimer;
  Entry? get currentActiveTimer;
  Entry? getActiveTimer(); // Add missing method
  Future<void> refreshActiveTimers();
  @override
  void dispose();
}

/// Interface for Notification Service operations
abstract class INotificationService {
  Future<void> init();
  Future<void> showTimerNotification(String entryId, String substanceName, Duration remainingTime);
  Future<void> showTimerExpiredNotification(String entryId, String substanceName);
  Future<void> cancelNotification(String entryId);
  Future<void> cancelAllNotifications();
}

/// Interface for Settings Service operations
abstract class ISettingsService extends ChangeNotifier {
  Future<void> init();
  Future<T?> getSetting<T>(String key);
  Future<void> setSetting<T>(String key, T value);
  Future<void> deleteSetting(String key);
  Future<bool> getBool(String key, {bool defaultValue = false});
  Future<void> setBool(String key, bool value);
  Future<String> getString(String key, {String defaultValue = ''});
  Future<void> setString(String key, String value);
  Future<int> getInt(String key, {int defaultValue = 0});
  Future<void> setInt(String key, int value);
  
  // Settings-specific getters and setters
  Future<bool> get isDarkMode;
  Future<bool> get isFirstLaunch;
  Future<String> get language;
  Future<bool> get notificationsEnabled;
  Future<bool> get biometricAuthEnabled;
  Future<bool> get autoBackupEnabled;
  Future<int> get dataRetentionDays;
  
  Future<void> setDarkMode(bool value);
  Future<void> toggleDarkMode();
  Future<void> setFirstLaunch(bool value);
  Future<void> setLanguage(String value);
  Future<void> setNotificationsEnabled(bool value);
  Future<void> setBiometricAuthEnabled(bool value);
  Future<void> setAutoBackupEnabled(bool value);
  Future<void> setDataRetentionDays(int value);
  
  Future<Map<String, dynamic>> exportSettings();
  Future<void> importSettings(Map<String, dynamic> settings);
  Future<Map<String, String>> getAppInfo();
  Future<bool> isFreshInstall();
  Future<void> completeOnboarding();
}

/// Interface for Authentication Service operations
abstract class IAuthService extends ChangeNotifier {
  Future<void> init();
  Future<bool> authenticate();
  Future<bool> isAuthenticated();
  Future<void> logout();
  bool get requiresAuthentication;
  Future<void> enableAuthentication();
  Future<void> disableAuthentication();
  Future<bool> isBiometricAvailable();
  Future<List<String>> getAvailableBiometrics();
  Future<bool> authenticateWithBiometrics({String? reason});
  Future<bool> isBiometricEnabled();
  Future<void> setBiometricEnabled(bool enabled);
  Future<bool> isAppLockEnabled();
  Future<void> setAppLockEnabled(bool enabled);
  Future<bool> verifyPinCode(String pin);
  Future<void> setPinCode(String pin);
}

/// Interface for Quick Button Service operations
abstract class IQuickButtonService {
  Future<String> createQuickButton(QuickButtonConfig config);
  Future<List<QuickButtonConfig>> getAllQuickButtons();
  Future<QuickButtonConfig?> getQuickButtonById(String id);
  Future<void> updateQuickButton(QuickButtonConfig config);
  Future<void> deleteQuickButton(String id);
  Future<void> reorderQuickButtons(List<String> orderedIds);
  Future<Entry> executeQuickButton(String quickButtonId);
  Future<void> toggleQuickButtonActive(String id, bool isActive);
  Future<List<QuickButtonConfig>> getActiveQuickButtons();
  Future<void> updateQuickButtonPosition(String id, int newPosition);
}

/// Interface for Psychedelic Theme Service operations
abstract class IPsychedelicThemeService extends ChangeNotifier {
  Future<void> init();
  AppThemeMode get currentThemeMode;
  bool get isPsychedelicMode;
  bool get isDarkMode;
  bool get isLightMode;
  bool get isTrippyMode;
  bool get isAnimatedBackgroundEnabled;
  bool get isPulsingButtonsEnabled;
  double get glowIntensity;
  String get currentSubstance;
  bool get isInitialized;
  AppThemeMode get effectiveThemeMode;
  ThemeData get lightTheme;
  ThemeData get darkTheme;
  ThemeData get trippyTheme;
  ThemeData get currentTheme;
  Future<void> setThemeMode(AppThemeMode mode);
  Future<void> togglePsychedelicMode();
  Future<void> toggleDarkMode(); // Add missing method
  Future<void> setAnimatedBackground(bool enabled);
  Future<void> setPulsingButtons(bool enabled);
  Future<void> setGlowIntensity(double intensity);
  Future<void> setCurrentSubstance(String substance);
  Color getPrimaryColorForSubstance(String substance);
  LinearGradient getGradientForSubstance(String substance);
  Future<void> initialize(); // Add missing method
}