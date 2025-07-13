import 'dart:async';
import 'package:flutter/foundation.dart';
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

  // Initialize timer service
  Future<void> init() async {
    await _loadActiveTimers();
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
    final entry = _activeTimers.firstWhere(
      (e) => e.id == entryId,
      orElse: () => throw StateError('Timer not found'),
    );
    return entry.remainingTime;
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

  // Dispose timer service
  void dispose() {
    _timerCheckTimer?.cancel();
    _activeTimers.clear();
  }
}