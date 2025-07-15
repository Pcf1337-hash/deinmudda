import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/entry.dart';
import '../models/substance.dart';
import 'entry_service.dart';
import 'substance_service.dart';
import 'notification_service.dart';

class TimerService {
  static final TimerService _instance = TimerService._internal();
  factory TimerService() => _instance;
  TimerService._internal();

  final EntryService _entryService = EntryService();
  final SubstanceService _substanceService = SubstanceService();
  final NotificationService _notificationService = NotificationService();

  Timer? _timerCheckTimer;
  final List<Entry> _activeTimers = [];
  SharedPreferences? _prefs;

  // Timer persistence keys
  static const String _activeTimerCountKey = 'active_timer_count';
  static const String _activeTimerKeyPrefix = 'active_timer_';

  // Initialize timer service
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadActiveTimers();
    await _restoreTimersFromPrefs();
    _startTimerCheckLoop();
  }

  // Load active timers from database
  Future<void> _loadActiveTimers() async {
    try {
      final allEntries = await _entryService.getAllEntries();
      _activeTimers.clear();
      
      for (final entry in allEntries) {
        if (entry.hasTimer && entry.isTimerActive) {
          _activeTimers.add(entry);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading active timers: $e');
      }
    }
  }

  // Start timer check loop
  void _startTimerCheckLoop() {
    _timerCheckTimer?.cancel();
    _timerCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkTimers();
    });
  }

  // Check for expired timers
  Future<void> _checkTimers() async {
    if (_timerCheckTimer == null || !_timerCheckTimer!.isActive) {
      return; // Timer was cancelled, don't proceed
    }
    
    try {
      final now = DateTime.now();
      final expiredTimers = <Entry>[];

      for (final entry in _activeTimers) {
        if (entry.timerEndTime != null && 
            now.isAfter(entry.timerEndTime!) && 
            !entry.timerCompleted &&
            !entry.timerNotificationSent) {
          expiredTimers.add(entry);
        }
      }

      for (final entry in expiredTimers) {
        await _handleTimerExpired(entry);
      }

      // Remove expired timers from active list
      _activeTimers.removeWhere((entry) => expiredTimers.contains(entry));
    } catch (e) {
      if (kDebugMode) {
        print('Error checking timers: $e');
      }
    }
  }

  // Handle timer expiration
  Future<void> _handleTimerExpired(Entry entry) async {
    if (_timerCheckTimer == null || !_timerCheckTimer!.isActive) {
      return; // Timer was cancelled, don't proceed
    }
    
    try {
      // Send notification
      await _notificationService.showTimerExpiredNotification(
        substanceName: entry.substanceName,
        entryId: entry.id,
      );

      // Update entry to mark notification as sent
      final updatedEntry = entry.copyWith(
        timerNotificationSent: true,
        timerCompleted: true,
      );

      await _entryService.updateEntry(updatedEntry);
      
      // Save to preferences
      await _saveTimersToPrefs();
    } catch (e) {
      if (kDebugMode) {
        print('Error handling timer expiration: $e');
      }
    }
  }

  // Start timer for entry
  Future<Entry> startTimer(Entry entry, {Duration? customDuration}) async {
    try {
      // Stop any existing active timer first (only one timer allowed)
      if (_activeTimers.isNotEmpty) {
        for (final activeTimer in List.from(_activeTimers)) {
          await stopTimer(activeTimer);
        }
      }

      Duration? duration = customDuration;
      
      // If no custom duration, try to get duration from substance
      if (duration == null) {
        final substance = await _substanceService.getSubstanceById(entry.substanceId);
        duration = substance?.duration;
      }

      // If still no duration, use default 4 hours
      duration ??= const Duration(hours: 4);

      final now = DateTime.now();
      final timerEndTime = now.add(duration);

      final updatedEntry = entry.copyWith(
        timerStartTime: now,
        timerEndTime: timerEndTime,
        timerCompleted: false,
        timerNotificationSent: false,
      );

      await _entryService.updateEntry(updatedEntry);

      // Add to active timers
      _activeTimers.add(updatedEntry);

      // Save to preferences
      await _saveTimersToPrefs();

      return updatedEntry;
    } catch (e) {
      if (kDebugMode) {
        print('Error starting timer: $e');
      }
      return entry;
    }
  }

  // Stop timer for entry
  Future<Entry> stopTimer(Entry entry) async {
    try {
      final updatedEntry = entry.copyWith(
        timerCompleted: true,
      );

      await _entryService.updateEntry(updatedEntry);

      // Remove from active timers
      _activeTimers.removeWhere((e) => e.id == entry.id);

      // Save to preferences
      await _saveTimersToPrefs();

      return updatedEntry;
    } catch (e) {
      if (kDebugMode) {
        print('Error stopping timer: $e');
      }
      return entry;
    }
  }

  // Create entry with timer
  Future<Entry> createEntryWithTimer(Entry entry, {Duration? customDuration}) async {
    try {
      // First create the entry
      await _entryService.createEntry(entry);

      // Then start the timer
      return await startTimer(entry, customDuration: customDuration);
    } catch (e) {
      if (kDebugMode) {
        print('Error creating entry with timer: $e');
      }
      return entry;
    }
  }

  // Get all active timers
  List<Entry> get activeTimers => List.unmodifiable(_activeTimers);

  // Get current active timer (since only one is allowed)
  Entry? get currentActiveTimer => _activeTimers.isNotEmpty ? _activeTimers.first : null;

  // Check if there's any active timer
  bool get hasAnyActiveTimer => _activeTimers.isNotEmpty;

  // Check if entry has active timer
  bool hasActiveTimer(String entryId) {
    return _activeTimers.any((entry) => entry.id == entryId);
  }

  // Get remaining time for entry
  Duration? getRemainingTime(String entryId) {
    try {
      final entry = _activeTimers.firstWhere(
        (e) => e.id == entryId,
        orElse: () => throw StateError('Timer not found'),
      );
      return entry.remainingTime;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting remaining time: $e');
      }
      return null;
    }
  }

  // Get timer progress for entry
  double getTimerProgress(String entryId) {
    try {
      final entry = _activeTimers.firstWhere((e) => e.id == entryId);
      return entry.timerProgress;
    } catch (e) {
      return 0.0;
    }
  }

  // Check if timer with this ID already exists to prevent duplicates
  bool hasTimerWithId(String entryId) {
    return _activeTimers.any((timer) => timer.id == entryId);
  }

  // Safe way to get timer by ID
  Entry? getTimerById(String entryId) {
    try {
      return _activeTimers.firstWhere((timer) => timer.id == entryId);
    } catch (e) {
      return null;
    }
  }

  // Parse duration from string (e.g., "4–6 hours", "30–60 min")
  static Duration? parseDurationFromString(String durationString) {
    final normalizedString = durationString.toLowerCase().trim();
    
    // Handle various duration formats
    if (normalizedString.contains('h')) {
      // Extract hours
      final match = RegExp(r'(\d+)').firstMatch(normalizedString);
      if (match != null) {
        final hours = int.tryParse(match.group(1)!) ?? 4;
        return Duration(hours: hours);
      }
    } else if (normalizedString.contains('min')) {
      // Extract minutes
      final match = RegExp(r'(\d+)').firstMatch(normalizedString);
      if (match != null) {
        final minutes = int.tryParse(match.group(1)!) ?? 60;
        return Duration(minutes: minutes);
      }
    } else if (normalizedString.contains('stunden')) {
      // German format
      final match = RegExp(r'(\d+)').firstMatch(normalizedString);
      if (match != null) {
        final hours = int.tryParse(match.group(1)!) ?? 4;
        return Duration(hours: hours);
      }
    }
    
    // Default fallback
    return const Duration(hours: 4);
  }

  // Update timer duration for an active timer
  Future<Entry> updateTimerDuration(Entry entry, Duration newDuration) async {
    try {
      if (!_activeTimers.any((e) => e.id == entry.id)) {
        throw StateError('Timer not found in active timers');
      }

      // Calculate new end time based on the new duration
      final startTime = entry.timerStartTime ?? DateTime.now();
      final newEndTime = startTime.add(newDuration);

      final updatedEntry = entry.copyWith(
        timerEndTime: newEndTime,
        timerCompleted: false,
        timerNotificationSent: false,
      );

      await _entryService.updateEntry(updatedEntry);

      // Update the active timer in the list
      final index = _activeTimers.indexWhere((e) => e.id == entry.id);
      if (index != -1) {
        _activeTimers[index] = updatedEntry;
      }

      // Save to preferences
      await _saveTimersToPrefs();

      return updatedEntry;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating timer duration: $e');
      }
      return entry;
    }
  }

  // Save timers to SharedPreferences for persistence
  Future<void> _saveTimersToPrefs() async {
    if (_prefs == null) return;
    
    try {
      await _prefs!.setInt(_activeTimerCountKey, _activeTimers.length);
      
      for (int i = 0; i < _activeTimers.length; i++) {
        final entry = _activeTimers[i];
        await _prefs!.setString('${_activeTimerKeyPrefix}${i}_id', entry.id);
        await _prefs!.setString('${_activeTimerKeyPrefix}${i}_substance', entry.substanceName);
        await _prefs!.setString('${_activeTimerKeyPrefix}${i}_start_time', entry.timerStartTime?.toIso8601String() ?? '');
        await _prefs!.setString('${_activeTimerKeyPrefix}${i}_end_time', entry.timerEndTime?.toIso8601String() ?? '');
        await _prefs!.setBool('${_activeTimerKeyPrefix}${i}_completed', entry.timerCompleted);
        await _prefs!.setBool('${_activeTimerKeyPrefix}${i}_notification_sent', entry.timerNotificationSent);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving timers to prefs: $e');
      }
    }
  }

  // Restore timers from SharedPreferences
  Future<void> _restoreTimersFromPrefs() async {
    if (_prefs == null) return;
    
    try {
      final count = _prefs!.getInt(_activeTimerCountKey) ?? 0;
      if (count == 0) return;

      for (int i = 0; i < count; i++) {
        final id = _prefs!.getString('${_activeTimerKeyPrefix}${i}_id');
        final substance = _prefs!.getString('${_activeTimerKeyPrefix}${i}_substance');
        final startTimeStr = _prefs!.getString('${_activeTimerKeyPrefix}${i}_start_time');
        final endTimeStr = _prefs!.getString('${_activeTimerKeyPrefix}${i}_end_time');
        final completed = _prefs!.getBool('${_activeTimerKeyPrefix}${i}_completed') ?? false;
        final notificationSent = _prefs!.getBool('${_activeTimerKeyPrefix}${i}_notification_sent') ?? false;

        if (id != null && substance != null && startTimeStr != null && endTimeStr != null) {
          final startTime = DateTime.tryParse(startTimeStr);
          final endTime = DateTime.tryParse(endTimeStr);

          if (startTime != null && endTime != null && !completed) {
            // Check if timer is still active (not expired)
            final now = DateTime.now();
            if (now.isBefore(endTime)) {
              // Try to get the full entry from database
              try {
                final allEntries = await _entryService.getAllEntries();
                final entry = allEntries.firstWhere((e) => e.id == id);
                
                if (!_activeTimers.any((e) => e.id == id)) {
                  _activeTimers.add(entry);
                }
              } catch (e) {
                if (kDebugMode) {
                  print('Could not restore timer entry $id: $e');
                }
              }
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error restoring timers from prefs: $e');
      }
    }
  }

  // Clear timer preferences
  Future<void> _clearTimerPrefs() async {
    if (_prefs == null) return;
    
    try {
      final count = _prefs!.getInt(_activeTimerCountKey) ?? 0;
      await _prefs!.remove(_activeTimerCountKey);
      
      for (int i = 0; i < count; i++) {
        await _prefs!.remove('${_activeTimerKeyPrefix}${i}_id');
        await _prefs!.remove('${_activeTimerKeyPrefix}${i}_substance');
        await _prefs!.remove('${_activeTimerKeyPrefix}${i}_start_time');
        await _prefs!.remove('${_activeTimerKeyPrefix}${i}_end_time');
        await _prefs!.remove('${_activeTimerKeyPrefix}${i}_completed');
        await _prefs!.remove('${_activeTimerKeyPrefix}${i}_notification_sent');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing timer prefs: $e');
      }
    }
  }

  // Dispose timer service
  void dispose() {
    _timerCheckTimer?.cancel();
    _timerCheckTimer = null;
    _activeTimers.clear();
    _clearTimerPrefs();
  }
}