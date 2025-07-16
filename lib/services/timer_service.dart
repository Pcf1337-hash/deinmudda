import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/entry.dart';
import '../models/substance.dart';
import '../utils/error_handler.dart';
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
  bool _isDisposed = false;
  bool _isInitialized = false;

  // Timer persistence keys
  static const String _activeTimerCountKey = 'active_timer_count';
  static const String _activeTimerKeyPrefix = 'active_timer_';
  
  // Simple timer persistence keys (as requested in problem statement)
  static const String _timerStartTimeKey = 'timer_startTime';
  static const String _timerDurationKey = 'timer_duration';
  static const String _timerSubstanceIdKey = 'timer_substanceId';

  // Initialize timer service
  Future<void> init() async {
    if (_isInitialized || _isDisposed) return;
    
    try {
      ErrorHandler.logTimer('INIT', 'TimerService Initialisierung gestartet');
      
      _prefs = await SharedPreferences.getInstance();
      await _loadActiveTimers();
      await _restoreTimersFromPrefs();
      await restoreTimer(); // Add call to restore simple timer values
      _startTimerCheckLoop();
      
      _isInitialized = true;
      ErrorHandler.logSuccess('TIMER_SERVICE', 'TimerService erfolgreich initialisiert');
    } catch (e) {
      ErrorHandler.logError('TIMER_SERVICE', 'Fehler bei TimerService init: $e');
      
      // Fallback initialization
      try {
        _prefs = await SharedPreferences.getInstance();
        _startTimerCheckLoop();
        _isInitialized = true;
        ErrorHandler.logWarning('TIMER_SERVICE', 'Fallback-Initialisierung erfolgreich');
      } catch (fallbackError) {
        ErrorHandler.logError('TIMER_SERVICE', 'Auch Fallback-Initialisierung fehlgeschlagen: $fallbackError');
      }
    }
  }

  // Load active timers from database
  Future<void> _loadActiveTimers() async {
    try {
      if (kDebugMode) {
        print('⏰ Lade aktive Timer aus der Datenbank...');
      }
      
      final allEntries = await _entryService.getAllEntries();
      _activeTimers.clear();
      
      for (final entry in allEntries) {
        if (entry.hasTimer && entry.isTimerActive) {
          _activeTimers.add(entry);
        }
      }
      
      if (kDebugMode) {
        print('✅ ${_activeTimers.length} aktive Timer geladen');
      }
    } catch (e) {
      ErrorHandler.logError('TIMER_SERVICE', 'Fehler beim Laden aktiver Timer: $e');
      
      // Ensure the list is cleared on error
      _activeTimers.clear();
    }
  }

  // Start timer check loop with better error handling
  void _startTimerCheckLoop() {
    if (_isDisposed) return;
    
    try {
      _timerCheckTimer?.cancel();
      _timerCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
        if (!_isDisposed) {
          _checkTimers();
        }
      });
      
      ErrorHandler.logTimer('CHECK_LOOP', 'Timer-Check-Loop gestartet');
    } catch (e) {
      ErrorHandler.logError('TIMER_SERVICE', 'Fehler beim Starten des Timer-Check-Loops: $e');
    }
  }

  // Check for expired timers with improved error handling
  Future<void> _checkTimers() async {
    if (_isDisposed || _timerCheckTimer == null || !_timerCheckTimer!.isActive) {
      return; // Service was disposed or timer was cancelled, don't proceed
    }
    
    try {
      final now = DateTime.now();
      final expiredTimers = <Entry>[];

      // Create a copy of the list to avoid concurrent modification
      final activeTimersCopy = List<Entry>.from(_activeTimers);

      for (final entry in activeTimersCopy) {
        if (entry.timerEndTime != null && 
            now.isAfter(entry.timerEndTime!) && 
            !entry.timerCompleted &&
            !entry.timerNotificationSent) {
          expiredTimers.add(entry);
        }
      }

      for (final entry in expiredTimers) {
        if (!_isDisposed) {
          await _handleTimerExpired(entry);
        }
      }

      // Remove expired timers from active list
      if (!_isDisposed) {
        _activeTimers.removeWhere((entry) => expiredTimers.contains(entry));
      }
      
      if (expiredTimers.isNotEmpty) {
        ErrorHandler.logTimer('CHECK', '${expiredTimers.length} Timer abgelaufen und verarbeitet');
      }
    } catch (e) {
      ErrorHandler.logError('TIMER_SERVICE', 'Fehler beim Überprüfen der Timer: $e');
    }
  }

  // Handle timer expiration
  Future<void> _handleTimerExpired(Entry entry) async {
    if (_isDisposed || _timerCheckTimer == null || !_timerCheckTimer!.isActive) {
      return; // Service was disposed or timer was cancelled, don't proceed
    }
    
    try {
      ErrorHandler.logTimer('EXPIRED', 'Timer für ${entry.substanceName} abgelaufen');
      
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

      if (!_isDisposed) {
        await _entryService.updateEntry(updatedEntry);
        
        // Save to preferences
        await _saveTimersToPrefs();
        
        // Clear simple timer values when timer expires
        await _clearSimpleTimerPrefs();
        
        ErrorHandler.logSuccess('TIMER_SERVICE', 'Timer-Ablauf erfolgreich verarbeitet');
      }
    } catch (e) {
      ErrorHandler.logError('TIMER_SERVICE', 'Fehler beim Verarbeiten des Timer-Ablaufs: $e');
    }
  }

  // Start timer for entry
  Future<Entry> startTimer(Entry entry, {Duration? customDuration}) async {
    if (_isDisposed) {
      ErrorHandler.logError('TIMER_SERVICE', 'Versuch Timer zu starten, aber Service ist disposed');
      return entry;
    }
    
    try {
      ErrorHandler.logTimer('START', 'Timer wird für ${entry.substanceName} gestartet');
      
      // Check for duplicate timer instances
      if (hasTimerWithId(entry.id)) {
        ErrorHandler.logWarning('TIMER_SERVICE', 'Timer für ${entry.substanceName} bereits aktiv - stoppe zuerst den vorhandenen');
        await stopTimer(entry);
      }
      
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

      if (!_isDisposed) {
        await _entryService.updateEntry(updatedEntry);

        // Add to active timers
        _activeTimers.add(updatedEntry);

        // Save to preferences (existing complex format)
        await _saveTimersToPrefs();
        
        // Save simple timer values to SharedPreferences as requested
        await _saveSimpleTimerToPrefs(now, duration, entry.substanceId);
        
        ErrorHandler.logSuccess('TIMER_SERVICE', 'Timer erfolgreich gestartet für ${entry.substanceName} (${_formatDuration(duration)})');
        ErrorHandler.logTimer('STATUS', 'Aktive Timer: ${_activeTimers.length}, End-Zeit: ${timerEndTime.toIso8601String()}');
      }

      return updatedEntry;
    } catch (e) {
      ErrorHandler.logError('TIMER_SERVICE', 'Fehler beim Starten des Timers: $e');
      return entry;
    }
  }

  // Stop timer for entry
  Future<Entry> stopTimer(Entry entry) async {
    if (_isDisposed) {
      ErrorHandler.logError('TIMER_SERVICE', 'Versuch Timer zu stoppen, aber Service ist disposed');
      return entry;
    }
    
    try {
      ErrorHandler.logTimer('STOP', 'Timer wird für ${entry.substanceName} gestoppt');
      
      final updatedEntry = entry.copyWith(
        timerCompleted: true,
      );

      if (!_isDisposed) {
        await _entryService.updateEntry(updatedEntry);

        // Remove from active timers
        _activeTimers.removeWhere((e) => e.id == entry.id);

        // Save to preferences
        await _saveTimersToPrefs();
        
        // Clear simple timer values when timer is stopped
        await _clearSimpleTimerPrefs();
        
        ErrorHandler.logSuccess('TIMER_SERVICE', 'Timer erfolgreich gestoppt für ${entry.substanceName}');
      }

      return updatedEntry;
    } catch (e) {
      ErrorHandler.logError('TIMER_SERVICE', 'Fehler beim Stoppen des Timers: $e');
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
  Entry? get currentActiveTimer {
    try {
      return _activeTimers.isNotEmpty ? _activeTimers.first : null;
    } catch (e) {
      ErrorHandler.logError('TIMER_SERVICE', 'Fehler beim Abrufen des aktiven Timers: $e');
      return null;
    }
  }

  // Check if there's any active timer
  bool get hasAnyActiveTimer {
    if (_isDisposed) return false;
    
    try {
      return _activeTimers.isNotEmpty;
    } catch (e) {
      ErrorHandler.logError('TIMER_SERVICE', 'Fehler beim Prüfen auf aktive Timer: $e');
      return false;
    }
  }

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

  // Format duration for display
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    } else {
      return '${minutes}min';
    }
  }

  // Update timer duration for an active timer
  Future<Entry> updateTimerDuration(Entry entry, Duration newDuration) async {
    if (_isDisposed) {
      ErrorHandler.logError('TIMER_SERVICE', 'Versuch Timer zu aktualisieren, aber Service ist disposed');
      return entry;
    }
    
    try {
      ErrorHandler.logTimer('UPDATE', 'Timer-Dauer wird für ${entry.substanceName} aktualisiert');
      
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

      if (!_isDisposed) {
        await _entryService.updateEntry(updatedEntry);

        // Update the active timer in the list
        final index = _activeTimers.indexWhere((e) => e.id == entry.id);
        if (index != -1) {
          _activeTimers[index] = updatedEntry;
        }

        // Save to preferences
        await _saveTimersToPrefs();
        
        ErrorHandler.logSuccess('TIMER_SERVICE', 'Timer-Dauer erfolgreich aktualisiert für ${entry.substanceName}');
      }

      return updatedEntry;
    } catch (e) {
      ErrorHandler.logError('TIMER_SERVICE', 'Fehler beim Aktualisieren der Timer-Dauer: $e');
      return entry;
    }
  }

  // Save simple timer values to SharedPreferences as requested in problem statement
  Future<void> _saveSimpleTimerToPrefs(DateTime startTime, Duration duration, String substanceId) async {
    if (_prefs == null) return;
    
    try {
      await _prefs!.setString(_timerStartTimeKey, startTime.toIso8601String());
      await _prefs!.setInt(_timerDurationKey, duration.inSeconds);
      await _prefs!.setString(_timerSubstanceIdKey, substanceId);
      
      ErrorHandler.logTimer('SIMPLE_SAVE', 'Einfache Timer-Werte gespeichert: Start=${startTime.toIso8601String()}, Duration=${duration.inSeconds}s, SubstanceId=$substanceId');
    } catch (e) {
      ErrorHandler.logError('TIMER_SERVICE', 'Fehler beim Speichern einfacher Timer-Werte: $e');
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

  // Restore timer from simple SharedPreferences values as requested in problem statement
  Future<void> restoreTimer() async {
    if (_prefs == null) return;
    
    try {
      final startTimeStr = _prefs!.getString(_timerStartTimeKey);
      final durationSeconds = _prefs!.getInt(_timerDurationKey);
      final substanceId = _prefs!.getString(_timerSubstanceIdKey);
      
      if (startTimeStr != null && durationSeconds != null && substanceId != null) {
        try {
          final startTime = DateTime.parse(startTimeStr);
          final duration = Duration(seconds: durationSeconds);
          
          ErrorHandler.logTimer('RESTORE', 'Lade Timer-Werte: Start=$startTimeStr, Duration=${durationSeconds}s, SubstanceId=$substanceId');
          
          // Check if timer is still active (not expired)
          final now = DateTime.now();
          final endTime = startTime.add(duration);
          
          if (now.isBefore(endTime)) {
            // Try to find the entry by substanceId and restart timer
            try {
              final allEntries = await _entryService.getAllEntries();
              final entry = allEntries.firstWhere((e) => e.substanceId == substanceId);
              
              // Restart the timer with the original values
              await startTimer(entry, customDuration: duration);
              
              ErrorHandler.logSuccess('TIMER_SERVICE', 'Timer erfolgreich wiederhergestellt für Substanz-ID: $substanceId');
            } catch (e) {
              ErrorHandler.logError('TIMER_SERVICE', 'Fehler beim Wiederherstellen des Timer-Eintrags für Substanz-ID $substanceId: $e');
              // Clean up invalid timer data
              await _clearSimpleTimerPrefs();
            }
          } else {
            ErrorHandler.logWarning('TIMER_SERVICE', 'Timer bereits abgelaufen - entferne gespeicherte Werte');
            await _clearSimpleTimerPrefs();
          }
        } catch (e) {
          ErrorHandler.logError('TIMER_SERVICE', 'Fehler beim Parsen der Timer-Werte: $e');
          // Clean up invalid timer data
          await _clearSimpleTimerPrefs();
        }
      } else {
        ErrorHandler.logTimer('RESTORE', 'Keine einfachen Timer-Werte in SharedPreferences gefunden');
      }
    } catch (e) {
      ErrorHandler.logError('TIMER_SERVICE', 'Fehler beim Wiederherstellen des Timers: $e');
      // Fallback/Reset: Clean up any corrupted data
      await _clearSimpleTimerPrefs();
    }
  }

  // Clear simple timer preferences
  Future<void> _clearSimpleTimerPrefs() async {
    if (_prefs == null) return;
    
    try {
      await _prefs!.remove(_timerStartTimeKey);
      await _prefs!.remove(_timerDurationKey);
      await _prefs!.remove(_timerSubstanceIdKey);
      
      ErrorHandler.logTimer('CLEAR', 'Einfache Timer-Werte aus SharedPreferences entfernt');
    } catch (e) {
      ErrorHandler.logError('TIMER_SERVICE', 'Fehler beim Entfernen einfacher Timer-Werte: $e');
    }
  }

  // Restore timers from SharedPreferences
  Future<void> _restoreTimersFromPrefs() async {
    if (_prefs == null) return;
    
    try {
      final count = _prefs!.getInt(_activeTimerCountKey) ?? 0;
      if (count == 0) {
        ErrorHandler.logTimer('RESTORE', 'Keine Timer in Preferences gefunden');
        return;
      }

      ErrorHandler.logTimer('RESTORE', 'Wiederherstellen von $count Timer(n) aus Preferences...');

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
                  ErrorHandler.logSuccess('TIMER_SERVICE', 'Timer für $substance erfolgreich wiederhergestellt');
                }
              } catch (e) {
                ErrorHandler.logError('TIMER_SERVICE', 'Fehler beim Wiederherstellen des Timer-Eintrags $id: $e');
              }
            } else {
              ErrorHandler.logWarning('TIMER_SERVICE', 'Timer für $substance bereits abgelaufen - überspringe');
            }
          }
        }
      }
      
      ErrorHandler.logTimer('RESTORE', 'Timer-Wiederherstellung abgeschlossen. Aktive Timer: ${_activeTimers.length}');
    } catch (e) {
      ErrorHandler.logError('TIMER_SERVICE', 'Fehler beim Wiederherstellen der Timer aus Preferences: $e');
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
    if (_isDisposed) return;
    _isDisposed = true;
    
    try {
      ErrorHandler.logDispose('TIMER_SERVICE', 'TimerService dispose gestartet');
      
      _timerCheckTimer?.cancel();
      _timerCheckTimer = null;
      _activeTimers.clear();
      
      // Clear timer preferences (fire and forget)
      _clearTimerPrefs();
      
      // Clear simple timer preferences (fire and forget)
      _clearSimpleTimerPrefs();
      
      _isInitialized = false;
      
      ErrorHandler.logSuccess('TIMER_SERVICE', 'TimerService dispose abgeschlossen');
    } catch (e) {
      ErrorHandler.logError('TIMER_SERVICE', 'Fehler beim Dispose des TimerService: $e');
    }
  }
}