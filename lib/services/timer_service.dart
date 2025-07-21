import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/entry.dart';
import '../models/substance.dart';
import '../utils/error_handler.dart';
import 'entry_service.dart';
import 'substance_service.dart';
import 'notification_service.dart';

class TimerService extends ChangeNotifier {
  static final TimerService _instance = TimerService._internal();
  factory TimerService() => _instance;
  TimerService._internal();

  final EntryService _entryService = EntryService();
  final SubstanceService _substanceService = SubstanceService();
  final NotificationService _notificationService = NotificationService();

  Timer? _timerCheckTimer;
  Timer? _notificationDebounceTimer;
  final List<Entry> _activeTimers = [];
  SharedPreferences? _prefs;
  bool _isDisposed = false;
  bool _isInitialized = false;
  bool _pendingNotification = false;

  // Timer persistence keys
  static const String _activeTimerCountKey = 'active_timer_count';
  static const String _activeTimerKeyPrefix = 'active_timer_';

  // Initialize timer service
  Future<void> init() async {
    if (_isInitialized || _isDisposed) return;
    
    try {
      ErrorHandler.logTimer('INIT', 'TimerService Initialisierung gestartet');
      
      _prefs = await SharedPreferences.getInstance();
      await _loadActiveTimers();
      
      // Only restore from database, not from preferences to prevent duplication
      // The database is the single source of truth for active timers
      ErrorHandler.logTimer('INIT', 'Timer aus Datenbank geladen, Preferences-Wiederherstellung übersprungen um Duplikate zu vermeiden');
      
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

  // Debounced notification to prevent excessive updates
  void _notifyListenersDebounced() {
    if (_isDisposed) return;
    
    _pendingNotification = true;
    _notificationDebounceTimer?.cancel();
    _notificationDebounceTimer = Timer(const Duration(milliseconds: 100), () {
      if (_pendingNotification && !_isDisposed) {
        _notifyListenersDebounced();
        _pendingNotification = false;
      }
    });
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
        
        // Notify listeners if any timers were removed
        if (expiredTimers.isNotEmpty) {
          _notifyListenersDebounced();
        }
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
        
        // Clear specific timer preferences when timer expires
        await _clearSpecificTimerPrefs();
        
        // Save to preferences
        await _saveTimersToPrefs();
        
        // Notify listeners of timer state change
        _notifyListenersDebounced();
        
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
      
      // Check for duplicate timer instances for the same entry
      if (hasTimerWithId(entry.id)) {
        ErrorHandler.logWarning('TIMER_SERVICE', 'Timer für ${entry.substanceName} bereits aktiv - stoppe den vorhandenen');
        await stopTimer(entry);
      }
      
      // Allow multiple timers to run concurrently - no need to stop existing timers
      ErrorHandler.logTimer('CONCURRENT', 'Erlaube gleichzeitige Timer. Aktive Timer: ${_activeTimers.length}');

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

        // Save to preferences using the specific format requested
        await _saveTimerToSpecificPrefs(now, duration, entry.substanceId);
        
        // Also save to the old format for backward compatibility
        await _saveTimersToPrefs();
        
        // Notify listeners of timer state change
        _notifyListenersDebounced();
        
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

        // Clear specific timer preferences when stopping
        await _clearSpecificTimerPrefs();

        // Save to preferences
        await _saveTimersToPrefs();
        
        // Notify listeners of timer state change
        _notifyListenersDebounced();
        
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

  // Get current active timer (alternative method name for compatibility)
  Entry? getActiveTimer() {
    return currentActiveTimer;
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

  // Check if timer service has any active timer (for HomeScreen usage)
  bool isTimerActive() {
    return hasAnyActiveTimer;
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

  // Refresh active timers from database (call this when timers might have been added from other sources)
  Future<void> refreshActiveTimers() async {
    if (_isDisposed) return;
    
    try {
      ErrorHandler.logTimer('REFRESH', 'Aktualisiere aktive Timer von der Datenbank');
      
      final oldCount = _activeTimers.length;
      await _loadActiveTimers();
      final newCount = _activeTimers.length;
      
      if (oldCount != newCount) {
        ErrorHandler.logTimer('REFRESH', 'Timer-Anzahl geändert: $oldCount -> $newCount');
        _notifyListenersDebounced();
      }
      
      ErrorHandler.logSuccess('TIMER_SERVICE', 'Aktive Timer erfolgreich aktualisiert');
    } catch (e) {
      ErrorHandler.logError('TIMER_SERVICE', 'Fehler beim Aktualisieren aktiver Timer: $e');
    }
  }

  // Save timer data to specific SharedPreferences keys as requested
  Future<void> _saveTimerToSpecificPrefs(DateTime startTime, Duration duration, String substanceId) async {
    if (_prefs == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('timer_startTime', startTime.toIso8601String());
      await prefs.setInt('timer_duration', duration.inSeconds);
      await prefs.setString('timer_substanceId', substanceId);
      
      ErrorHandler.logTimer('SAVE_SPECIFIC', 'Timer gespeichert: startTime=${startTime.toIso8601String()}, duration=${duration.inSeconds}s, substanceId=$substanceId');
    } catch (e) {
      ErrorHandler.logError('TIMER_SERVICE', 'Fehler beim Speichern des Timers in spezifische Preferences: $e');
    }
  }

  // Clear specific timer preferences
  Future<void> _clearSpecificTimerPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('timer_startTime');
      await prefs.remove('timer_duration');
      await prefs.remove('timer_substanceId');
      
      ErrorHandler.logTimer('CLEAR_SPECIFIC', 'Spezifische Timer-Preferences geleert');
    } catch (e) {
      ErrorHandler.logError('TIMER_SERVICE', 'Fehler beim Löschen der spezifischen Timer-Preferences: $e');
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

  // Restore timer from specific SharedPreferences keys as requested
  Future<void> restoreTimer() async {
    if (_isDisposed) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final startTimeString = prefs.getString('timer_startTime');
      final durationSeconds = prefs.getInt('timer_duration');
      final substanceId = prefs.getString('timer_substanceId');
      
      ErrorHandler.logTimer('RESTORE_SPECIFIC', 'Lade Timer: startTime=${startTimeString ?? 'null'}, duration=${durationSeconds ?? 'null'}s, substanceId=${substanceId ?? 'null'}');
      
      // Check if all required data is present and valid
      if (startTimeString != null && 
          startTimeString.isNotEmpty && 
          durationSeconds != null && 
          durationSeconds > 0 && 
          substanceId != null && 
          substanceId.isNotEmpty) {
        
        final startTime = DateTime.tryParse(startTimeString);
        final duration = Duration(seconds: durationSeconds);
        
        // Validate parsed data
        if (startTime != null && duration.inSeconds > 0) {
          // Check if timer is still valid (not expired)
          final endTime = startTime.add(duration);
          final now = DateTime.now();
          
          if (now.isBefore(endTime)) {
            // Timer is still active, restore it
            try {
              // Get substance details
              final substance = await _substanceService.getSubstanceById(substanceId);
              if (substance != null) {
                // Create a timer entry with the original start time
                final entry = Entry.create(
                  substanceId: substanceId,
                  substanceName: substance.name,
                  dosage: 0.0, // Timer-only entry
                  unit: 'Timer',
                  dateTime: startTime,
                  notes: 'Wiederhergestellter Timer',
                  timerStartTime: startTime,
                  timerEndTime: endTime,
                  timerCompleted: false,
                  timerNotificationSent: false,
                );
                
                // Add directly to database and active timers without calling startTimer
                // to avoid overwriting the restored times
                await _entryService.createEntry(entry);
                _activeTimers.add(entry);
                
                // Notify listeners of timer state change
                _notifyListenersDebounced();
                
                ErrorHandler.logSuccess('TIMER_SERVICE', 'Timer erfolgreich wiederhergestellt für ${substance.name}');
              } else {
                ErrorHandler.logWarning('TIMER_SERVICE', 'Substanz nicht gefunden für Timer-Wiederherstellung: $substanceId');
                await _clearSpecificTimerPrefs();
              }
            } catch (e) {
              ErrorHandler.logError('TIMER_SERVICE', 'Fehler beim Wiederherstellen des Timers: $e');
              await _clearSpecificTimerPrefs();
            }
          } else {
            ErrorHandler.logWarning('TIMER_SERVICE', 'Timer bereits abgelaufen - lösche Preferences');
            await _clearSpecificTimerPrefs();
          }
        } else {
          ErrorHandler.logWarning('TIMER_SERVICE', 'Ungültige Timer-Daten gefunden - lösche Preferences');
          await _clearSpecificTimerPrefs();
        }
      } else {
        ErrorHandler.logTimer('RESTORE_SPECIFIC', 'Keine vollständigen Timer-Daten in Preferences gefunden - überspringe Wiederherstellung');
      }
    } catch (e) {
      ErrorHandler.logError('TIMER_SERVICE', 'Fehler beim Wiederherstellen des Timers aus spezifischen Preferences: $e');
      // Clear potentially corrupted data
      await _clearSpecificTimerPrefs();
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
  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    
    try {
      ErrorHandler.logDispose('TIMER_SERVICE', 'TimerService dispose gestartet');
      
      _timerCheckTimer?.cancel();
      _timerCheckTimer = null;
      _notificationDebounceTimer?.cancel();
      _notificationDebounceTimer = null;
      _activeTimers.clear();
      
      // Clear timer preferences
      _clearTimerPrefs();
      
      _isInitialized = false;
      
      ErrorHandler.logSuccess('TIMER_SERVICE', 'TimerService dispose abgeschlossen');
    } catch (e) {
      ErrorHandler.logError('TIMER_SERVICE', 'Fehler beim Dispose des TimerService: $e');
    }
    
    super.dispose();
  }
}