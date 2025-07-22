/// Comprehensive Mock Services for Testing
/// 
/// Phase 6: Testing Implementation - Mock Infrastructure
/// Provides mockable implementations of all service interfaces
/// 
/// Author: Code Quality Improvement Agent
/// Date: Phase 6 - Testing Implementation

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/interfaces/service_interfaces.dart';
import '../../lib/models/entry.dart';
import '../../lib/models/substance.dart';
import '../../lib/models/quick_button_config.dart';

/// Mock Entry Service for testing
class MockEntryService extends ChangeNotifier implements IEntryService {
  final List<Entry> _entries = [];
  final List<Entry> _activeTimerEntries = [];

  @override
  Future<String> createEntry(Entry entry) async {
    _entries.add(entry);
    notifyListeners();
    return entry.id;
  }

  @override
  Future<String> addEntry(Entry entry) async {
    return createEntry(entry);
  }

  @override
  Future<Entry> createEntryWithTimer(Entry entry, {Duration? customDuration, required dynamic timerService}) async {
    final entryWithTimer = entry.copyWith(
      timerStartTime: DateTime.now(),
      duration: customDuration ?? const Duration(hours: 2),
    );
    _entries.add(entryWithTimer);
    _activeTimerEntries.add(entryWithTimer);
    notifyListeners();
    return entryWithTimer;
  }

  @override
  Future<List<Entry>> getAllEntries() async {
    return List.from(_entries);
  }

  @override
  Future<List<Entry>> getEntriesByDateRange(DateTime start, DateTime end) async {
    return _entries.where((entry) {
      return entry.timestamp.isAfter(start) && entry.timestamp.isBefore(end);
    }).toList();
  }

  @override
  Future<List<Entry>> getEntriesBySubstance(String substanceId) async {
    return _entries.where((entry) => entry.substanceId == substanceId).toList();
  }

  @override
  Future<Entry?> getEntryById(String id) async {
    try {
      return _entries.firstWhere((entry) => entry.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateEntry(Entry entry) async {
    final index = _entries.indexWhere((e) => e.id == entry.id);
    if (index != -1) {
      _entries[index] = entry;
      notifyListeners();
    }
  }

  @override
  Future<void> deleteEntry(String id) async {
    _entries.removeWhere((entry) => entry.id == id);
    _activeTimerEntries.removeWhere((entry) => entry.id == id);
    notifyListeners();
  }

  @override
  Future<List<Entry>> getActiveTimerEntries() async {
    return List.from(_activeTimerEntries);
  }

  @override
  Future<void> updateEntryTimer(String id, DateTime? timerStartTime, Duration? duration) async {
    final index = _entries.indexWhere((e) => e.id == id);
    if (index != -1) {
      _entries[index] = _entries[index].copyWith(
        timerStartTime: timerStartTime,
        duration: duration,
      );
      
      if (timerStartTime != null && duration != null) {
        if (!_activeTimerEntries.any((e) => e.id == id)) {
          _activeTimerEntries.add(_entries[index]);
        }
      } else {
        _activeTimerEntries.removeWhere((e) => e.id == id);
      }
      notifyListeners();
    }
  }

  // Test helper methods
  void clearAllEntries() {
    _entries.clear();
    _activeTimerEntries.clear();
    notifyListeners();
  }

  void addMockEntry(Entry entry) {
    _entries.add(entry);
    notifyListeners();
  }
}

/// Mock Substance Service for testing
class MockSubstanceService extends ChangeNotifier implements ISubstanceService {
  final List<Substance> _substances = [];

  @override
  Future<String> createSubstance(Substance substance) async {
    _substances.add(substance);
    notifyListeners();
    return substance.id;
  }

  @override
  Future<List<Substance>> getAllSubstances() async {
    return List.from(_substances);
  }

  @override
  Future<Substance?> getSubstanceById(String id) async {
    try {
      return _substances.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Substance?> getSubstanceByName(String name) async {
    try {
      return _substances.firstWhere((s) => s.name.toLowerCase() == name.toLowerCase());
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateSubstance(Substance substance) async {
    final index = _substances.indexWhere((s) => s.id == substance.id);
    if (index != -1) {
      _substances[index] = substance;
      notifyListeners();
    }
  }

  @override
  Future<void> deleteSubstance(String id) async {
    _substances.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  @override
  Future<List<Substance>> searchSubstances(String query) async {
    return _substances.where((s) => 
      s.name.toLowerCase().contains(query.toLowerCase()) ||
      s.notes.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  @override
  Future<List<Substance>> getSubstancesByCategory(SubstanceCategory category) async {
    return _substances.where((s) => s.category == category).toList();
  }

  @override
  Future<List<Substance>> getMostUsedSubstances({int limit = 10}) async {
    // Mock implementation - in real app would be based on usage statistics
    return _substances.take(limit).toList();
  }

  @override
  Future<void> initializeDefaultSubstances() async {
    // Add some default test substances
    final defaultSubstances = [
      Substance.create(
        name: 'Test Substance 1',
        category: SubstanceCategory.medication,
        defaultRiskLevel: RiskLevel.low,
        pricePerUnit: 1.0,
        defaultUnit: 'mg',
      ),
      Substance.create(
        name: 'Test Substance 2',
        category: SubstanceCategory.supplement,
        defaultRiskLevel: RiskLevel.medium,
        pricePerUnit: 2.0,
        defaultUnit: 'ml',
      ),
    ];

    _substances.addAll(defaultSubstances);
    notifyListeners();
  }

  @override
  Future<List<String>> getAllUsedUnits() async {
    return ['mg', 'ml', 'g', 'pills'];
  }

  @override
  Future<List<String>> getSuggestedUnits() async {
    return ['mg', 'ml', 'g'];
  }

  @override
  Future<bool> unitExists(String unit) async {
    final units = await getAllUsedUnits();
    return units.contains(unit);
  }

  @override
  Future<List<Substance>> getSubstancesByUnit(String unit) async {
    return _substances.where((s) => s.defaultUnit == unit).toList();
  }

  @override
  String? validateUnit(String? unit) {
    if (unit == null || unit.isEmpty) {
      return 'Unit is required';
    }
    if (unit.length > 10) {
      return 'Unit too long';
    }
    return null;
  }

  // Test helper methods
  void clearAllSubstances() {
    _substances.clear();
    notifyListeners();
  }

  void addMockSubstance(Substance substance) {
    _substances.add(substance);
    notifyListeners();
  }
}

/// Mock Timer Service for testing
class MockTimerService extends ChangeNotifier implements ITimerService {
  final Map<String, Map<String, dynamic>> _activeTimers = {};
  bool _isDisposed = false;

  @override
  Future<void> initialize() async {
    // Mock initialization
  }

  @override
  Future<void> dispose() async {
    _isDisposed = true;
    _activeTimers.clear();
    super.dispose();
  }

  @override
  Future<void> createEntryWithTimer(Entry entry, Duration duration) async {
    if (_isDisposed) return;
    
    _activeTimers[entry.id] = {
      'entry': entry,
      'duration': duration,
      'startTime': DateTime.now(),
    };
    notifyListeners();
  }

  @override
  Future<void> stopTimer(String entryId) async {
    if (_isDisposed) return;
    
    _activeTimers.remove(entryId);
    notifyListeners();
  }

  @override
  Future<void> pauseTimer(String entryId) async {
    if (_isDisposed) return;
    
    final timer = _activeTimers[entryId];
    if (timer != null) {
      timer['isPaused'] = true;
      timer['pauseTime'] = DateTime.now();
      notifyListeners();
    }
  }

  @override
  Future<void> resumeTimer(String entryId) async {
    if (_isDisposed) return;
    
    final timer = _activeTimers[entryId];
    if (timer != null) {
      timer['isPaused'] = false;
      timer.remove('pauseTime');
      notifyListeners();
    }
  }

  @override
  Map<String, Entry> getActiveTimers() {
    return Map.fromEntries(
      _activeTimers.entries.map((e) => MapEntry(e.key, e.value['entry'] as Entry))
    );
  }

  @override
  bool hasActiveTimer(String entryId) {
    return _activeTimers.containsKey(entryId);
  }

  @override
  Duration? getRemainingTime(String entryId) {
    final timer = _activeTimers[entryId];
    if (timer == null) return null;

    final startTime = timer['startTime'] as DateTime;
    final duration = timer['duration'] as Duration;
    final elapsed = DateTime.now().difference(startTime);
    
    final remaining = duration - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  @override
  bool isTimerPaused(String entryId) {
    final timer = _activeTimers[entryId];
    return timer?['isPaused'] == true;
  }

  @override
  double getTimerProgress(String entryId) {
    final timer = _activeTimers[entryId];
    if (timer == null) return 0.0;

    final startTime = timer['startTime'] as DateTime;
    final duration = timer['duration'] as Duration;
    final elapsed = DateTime.now().difference(startTime);
    
    final progress = elapsed.inMilliseconds / duration.inMilliseconds;
    return progress.clamp(0.0, 1.0);
  }

  // Test helper methods
  void clearAllTimers() {
    _activeTimers.clear();
    notifyListeners();
  }

  void addMockTimer(String entryId, Entry entry, Duration duration) {
    _activeTimers[entryId] = {
      'entry': entry,
      'duration': duration,
      'startTime': DateTime.now(),
    };
    notifyListeners();
  }
}

/// Mock Notification Service for testing
class MockNotificationService implements INotificationService {
  final List<Map<String, dynamic>> _sentNotifications = [];

  @override
  Future<void> initialize() async {
    // Mock initialization
  }

  @override
  Future<void> scheduleTimerNotification(String entryId, String substanceName, Duration delay) async {
    _sentNotifications.add({
      'type': 'timer',
      'entryId': entryId,
      'substanceName': substanceName,
      'delay': delay,
      'scheduledAt': DateTime.now(),
    });
  }

  @override
  Future<void> cancelTimerNotification(String entryId) async {
    _sentNotifications.removeWhere((notification) => 
      notification['entryId'] == entryId && notification['type'] == 'timer'
    );
  }

  @override
  Future<void> showImmediateNotification(String title, String body) async {
    _sentNotifications.add({
      'type': 'immediate',
      'title': title,
      'body': body,
      'sentAt': DateTime.now(),
    });
  }

  @override
  Future<void> cancelAllNotifications() async {
    _sentNotifications.clear();
  }

  @override
  Future<bool> areNotificationsEnabled() async {
    return true; // Mock: always enabled in tests
  }

  @override
  Future<void> requestPermissions() async {
    // Mock: permissions always granted in tests
  }

  // Test helper methods
  List<Map<String, dynamic>> getSentNotifications() {
    return List.from(_sentNotifications);
  }

  void clearNotifications() {
    _sentNotifications.clear();
  }

  bool hasNotificationForEntry(String entryId) {
    return _sentNotifications.any((notification) => notification['entryId'] == entryId);
  }
}

/// Mock Settings Service for testing
class MockSettingsService extends ChangeNotifier implements ISettingsService {
  final Map<String, dynamic> _settings = {};

  @override
  Future<void> initialize() async {
    // Mock initialization with default values
    _settings.addAll({
      'notifications_enabled': true,
      'dark_mode': false,
      'timer_sound': true,
      'biometric_auth': false,
    });
  }

  @override
  Future<T?> get<T>(String key) async {
    return _settings[key] as T?;
  }

  @override
  Future<void> set<T>(String key, T value) async {
    _settings[key] = value;
    notifyListeners();
  }

  @override
  Future<void> remove(String key) async {
    _settings.remove(key);
    notifyListeners();
  }

  @override
  Future<void> clear() async {
    _settings.clear();
    notifyListeners();
  }

  @override
  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    return _settings[key] as bool? ?? defaultValue;
  }

  @override
  Future<void> setBool(String key, bool value) async {
    await set(key, value);
  }

  @override
  Future<int> getInt(String key, {int defaultValue = 0}) async {
    return _settings[key] as int? ?? defaultValue;
  }

  @override
  Future<void> setInt(String key, int value) async {
    await set(key, value);
  }

  @override
  Future<double> getDouble(String key, {double defaultValue = 0.0}) async {
    return _settings[key] as double? ?? defaultValue;
  }

  @override
  Future<void> setDouble(String key, double value) async {
    await set(key, value);
  }

  @override
  Future<String> getString(String key, {String defaultValue = ''}) async {
    return _settings[key] as String? ?? defaultValue;
  }

  @override
  Future<void> setString(String key, String value) async {
    await set(key, value);
  }

  @override
  Future<List<String>> getStringList(String key, {List<String> defaultValue = const []}) async {
    return (_settings[key] as List<dynamic>?)?.cast<String>() ?? defaultValue;
  }

  @override
  Future<void> setStringList(String key, List<String> value) async {
    await set(key, value);
  }

  @override
  Future<bool> containsKey(String key) async {
    return _settings.containsKey(key);
  }

  @override
  Set<String> getKeys() {
    return _settings.keys.toSet();
  }

  @override
  Future<void> reload() async {
    // Mock reload - no-op in tests
  }

  // Test helper methods
  void clearAllSettings() {
    _settings.clear();
    notifyListeners();
  }

  void setMockSetting(String key, dynamic value) {
    _settings[key] = value;
    notifyListeners();
  }

  Map<String, dynamic> getAllSettings() {
    return Map.from(_settings);
  }
}

/// Mock Auth Service for testing
class MockAuthService extends ChangeNotifier implements IAuthService {
  bool _isAuthenticated = false;
  bool _biometricEnabled = false;

  @override
  Future<void> initialize() async {
    // Mock initialization
  }

  @override
  bool get isAuthenticated => _isAuthenticated;

  @override
  bool get isBiometricEnabled => _biometricEnabled;

  @override
  Future<bool> authenticate({String? reason}) async {
    // Mock authentication - always succeeds in tests
    _isAuthenticated = true;
    notifyListeners();
    return true;
  }

  @override
  Future<bool> authenticateWithBiometrics({String? reason}) async {
    if (!_biometricEnabled) return false;
    
    _isAuthenticated = true;
    notifyListeners();
    return true;
  }

  @override
  Future<void> logout() async {
    _isAuthenticated = false;
    notifyListeners();
  }

  @override
  Future<bool> isBiometricAvailable() async {
    return true; // Mock: always available in tests
  }

  @override
  Future<void> enableBiometric() async {
    _biometricEnabled = true;
    notifyListeners();
  }

  @override
  Future<void> disableBiometric() async {
    _biometricEnabled = false;
    notifyListeners();
  }

  @override
  Stream<bool> get authStateStream => Stream.value(_isAuthenticated);

  // Test helper methods
  void setMockAuthenticated(bool authenticated) {
    _isAuthenticated = authenticated;
    notifyListeners();
  }

  void setMockBiometricEnabled(bool enabled) {
    _biometricEnabled = enabled;
    notifyListeners();
  }
}