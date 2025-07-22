/// Service Interfaces for Dependency Inversion
/// 
/// Phase 3: Architecture Improvements - Interface Abstractions
/// Enables loose coupling and better testability
/// 
/// Author: Code Quality Improvement Agent
/// Date: Phase 3 - Architecture Improvements

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/entry.dart';
import '../models/substance.dart';

/// Interface for Entry Service operations
abstract class IEntryService extends ChangeNotifier {
  Future<String> createEntry(Entry entry);
  Future<String> addEntry(Entry entry);
  Future<Entry> createEntryWithTimer(Entry entry, {Duration? customDuration, required dynamic timerService});
  Future<List<Entry>> getAllEntries();
  Future<List<Entry>> getEntriesByDateRange(DateTime start, DateTime end);
  Future<List<Entry>> getEntriesBySubstance(String substanceId);
  Future<Entry?> getEntryById(String id);
  Future<void> updateEntry(Entry entry);
  Future<void> deleteEntry(String id);
  Future<List<Entry>> getActiveTimerEntries();
  Future<void> updateEntryTimer(String id, DateTime? timerStartTime, Duration? duration);
}

/// Interface for Substance Service operations  
abstract class ISubstanceService extends ChangeNotifier {
  Future<void> createSubstance(Substance substance);
  Future<List<Substance>> getAllSubstances();
  Future<Substance?> getSubstanceById(String id);
  Future<Substance?> getSubstanceByName(String name);
  Future<void> updateSubstance(Substance substance);
  Future<void> deleteSubstance(String id);
  Future<List<Substance>> searchSubstances(String query);
  Future<List<Substance>> getRecentSubstances(int limit);
  Future<void> loadPredefinedSubstances();
}

/// Interface for Timer Service operations
abstract class ITimerService extends ChangeNotifier {
  Future<void> init();
  Future<Entry> startTimer(Entry entry, {Duration? customDuration});
  Future<void> stopTimer(String entryId);
  Future<void> pauseTimer(String entryId);
  Future<void> resumeTimer(String entryId);
  Duration? getRemainingTime(String entryId);
  bool isTimerActive(String entryId);
  List<Entry> get activeTimers;
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
}