/// Comprehensive Mock Services for Testing - MAJOR ERROR FIXES APPLIED
/// 
/// CRITICAL FIXES IMPLEMENTED:
/// 1. Fixed type compatibility issues - All mocks now properly implement interfaces
/// 2. Added missing MockQuickButtonService with complete IQuickButtonService implementation
/// 3. Fixed MockTimerService to include missing methods (startTimer, activeTimers getters)
/// 4. Resolved duplicate method definitions in MockNotificationService and MockSettingsService
/// 5. Fixed MockAuthService variable name inconsistencies and missing interface methods
/// 6. Added comprehensive error handling and null safety throughout
/// 
/// For beginners: Mock services simulate real services during testing without
/// actual database operations or network calls. This allows tests to run quickly
/// and reliably by providing predictable, controlled responses.
/// 
/// These mocks implement the same interfaces as production services, ensuring
/// that tests accurately reflect how the real application will behave.
/// 
/// Phase 6: Testing Implementation - Mock Infrastructure
/// Provides mockable implementations of all service interfaces
/// 
/// Author: Code Quality Improvement Agent
/// Date: Phase 6 - Testing Implementation - Error Fixes Applied

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
  Future<void> init() async {
    await initialize();
  }

  @override
  Future<void> dispose() async {
    _isDisposed = true;
    _activeTimers.clear();
    super.dispose();
  }

  @override
  Future<Entry> startTimer(Entry entry, {Duration? customDuration}) async {
    if (_isDisposed) throw Exception('Timer service is disposed');
    
    final duration = customDuration ?? const Duration(hours: 2);
    final entryWithTimer = entry.copyWith(
      timerStartTime: DateTime.now(),
      duration: duration,
    );
    
    _activeTimers[entry.id] = {
      'entry': entryWithTimer,
      'duration': duration,
      'startTime': DateTime.now(),
    };
    notifyListeners();
    
    return entryWithTimer;
  }

  @override
  Future<void> createEntryWithTimer(Entry entry, Duration duration) async {
    // This method is deprecated in favor of startTimer
    await startTimer(entry, customDuration: duration);
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
  bool isTimerActive() {
    return _activeTimers.isNotEmpty;
  }

  @override
  List<Entry> get activeTimers {
    return _activeTimers.values.map((timer) => timer['entry'] as Entry).toList();
  }

  @override
  bool get hasAnyActiveTimer {
    return _activeTimers.isNotEmpty;
  }

  @override
  Entry? get currentActiveTimer {
    if (_activeTimers.isEmpty) return null;
    return _activeTimers.values.first['entry'] as Entry;
  }

  @override
  Future<void> refreshActiveTimers() async {
    // Mock implementation - no-op
    notifyListeners();
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
  Future<void> init() async {
    // Mock initialization
  }

  @override
  Future<void> showTimerNotification(String entryId, String substanceName, Duration remainingTime) async {
    _sentNotifications.add({
      'type': 'timer',
      'entryId': entryId,
      'substanceName': substanceName,
      'remainingTime': remainingTime,
    });
  }

  @override
  Future<void> showTimerExpiredNotification(String entryId, String substanceName) async {
    _sentNotifications.add({
      'type': 'timer_expired',
      'entryId': entryId,
      'substanceName': substanceName,
    });
  }

  @override
  Future<void> cancelNotification(String entryId) async {
    _sentNotifications.removeWhere((notification) => notification['entryId'] == entryId);
  }

  @override
  Future<void> cancelAllNotifications() async {
    _sentNotifications.clear();
  }

  @override
  Future<void> initialize() async {
    // Mock initialization - keeping for backward compatibility
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

  // Add missing interface methods
  @override
  Future<void> init() async {
    await initialize();
  }

  @override
  Future<T?> getSetting<T>(String key) async {
    return _settings[key] as T?;
  }

  @override
  Future<void> setSetting<T>(String key, T value) async {
    _settings[key] = value;
    notifyListeners();
  }

  @override
  Future<void> deleteSetting(String key) async {
    _settings.remove(key);
    notifyListeners();
  }

  // Settings-specific getters
  @override
  Future<bool> get isDarkMode async => _settings['dark_mode'] ?? false;

  @override
  Future<bool> get isFirstLaunch async => _settings['first_launch'] ?? true;

  @override
  Future<String> get language async => _settings['language'] ?? 'en';

  @override
  Future<bool> get notificationsEnabled async => _settings['notifications_enabled'] ?? true;

  @override
  Future<bool> get biometricAuthEnabled async => _settings['biometric_auth'] ?? false;

  @override
  Future<bool> get autoBackupEnabled async => _settings['auto_backup'] ?? false;

  @override
  Future<int> get dataRetentionDays async => _settings['data_retention_days'] ?? 365;

  // Add other required methods with basic implementations
  @override
  Future<Map<String, dynamic>> exportSettings() async => Map.from(_settings);

  @override
  Future<void> importSettings(Map<String, dynamic> settings) async {
    _settings.addAll(settings);
    notifyListeners();
  }

  @override
  Future<void> resetToDefaults() async {
    _settings.clear();
    await initialize();
  }

  @override
  Future<Map<String, dynamic>> getAppInfo() async => {
    'version': '1.0.0+1',
    'buildNumber': '1',
    'appName': 'Konsum Tracker Pro Test',
  };

  @override
  Future<void> completeOnboarding() async {
    _settings['first_launch'] = false;
    notifyListeners();
  }
}

/// Mock Auth Service for testing
class MockAuthService extends ChangeNotifier implements IAuthService {
  bool _isAuthenticatedState = false;
  bool _biometricEnabledState = false;

  @override
  Future<void> initialize() async {
    // Mock initialization
  }

  @override
  Future<void> init() async {
    await initialize();
  }

  @override
  Future<bool> isAuthenticated() async => _isAuthenticatedState;

  @override
  bool get requiresAuthentication => true;

  @override
  Future<bool> isBiometricEnabled() async => _biometricEnabledState;

  @override
  Future<bool> authenticate() async {
    // Mock authentication - always succeeds in tests
    _isAuthenticatedState = true;
    notifyListeners();
    return true;
  }

  @override
  Future<bool> authenticateWithBiometrics({String? reason}) async {
    if (!_biometricEnabledState) return false;
    
    _isAuthenticatedState = true;
    notifyListeners();
    return true;
  }

  @override
  Future<void> logout() async {
    _isAuthenticatedState = false;
    notifyListeners();
  }

  @override
  Future<void> enableAuthentication() async {
    _biometricEnabledState = true;
    notifyListeners();
  }

  @override
  Future<void> disableAuthentication() async {
    _biometricEnabledState = false;
    _isAuthenticatedState = false;
    notifyListeners();
  }

  @override
  Future<bool> isBiometricAvailable() async {
    // Mock biometric availability
    return true;
  }

  @override
  Future<List<String>> getAvailableBiometrics() async {
    // Mock available biometric types
    return ['fingerprint', 'face'];
  }

  // Add PIN-related methods
  @override
  Future<bool> verifyPinCode(String pin) async {
    // Mock PIN verification - accept any non-empty PIN
    return pin.isNotEmpty;
  }

  @override
  Future<void> setPinCode(String pin) async {
    // Mock PIN setting
    _isAuthenticatedState = true;
    notifyListeners();
  }

  // Missing interface methods
  @override
  Future<void> setBiometricEnabled(bool enabled) async {
    _biometricEnabledState = enabled;
    notifyListeners();
  }

  @override
  Future<bool> isAppLockEnabled() async {
    return _biometricEnabledState;
  }

  @override
  Future<void> setAppLockEnabled(bool enabled) async {
    _biometricEnabledState = enabled;
    notifyListeners();
  }

  @override
  Stream<bool> get authStateStream => Stream.value(_isAuthenticatedState);

  // Test helper methods
  void setMockAuthenticated(bool authenticated) {
    _isAuthenticatedState = authenticated;
    notifyListeners();
  }

  void setMockBiometricEnabled(bool enabled) {
    _biometricEnabledState = enabled;
    notifyListeners();
  }
}

/// Mock Quick Button Service for testing
class MockQuickButtonService implements IQuickButtonService {
  final List<QuickButtonConfig> _quickButtons = [];
  int _nextPosition = 0;

  @override
  Future<String> createQuickButton(QuickButtonConfig config) async {
    final configWithPosition = config.copyWith(position: _nextPosition++);
    _quickButtons.add(configWithPosition);
    return configWithPosition.id;
  }

  @override
  Future<List<QuickButtonConfig>> getAllQuickButtons() async {
    return List.from(_quickButtons);
  }

  @override
  Future<QuickButtonConfig?> getQuickButtonById(String id) async {
    try {
      return _quickButtons.firstWhere((config) => config.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateQuickButton(QuickButtonConfig config) async {
    final index = _quickButtons.indexWhere((c) => c.id == config.id);
    if (index != -1) {
      _quickButtons[index] = config;
    }
  }

  @override
  Future<void> deleteQuickButton(String id) async {
    _quickButtons.removeWhere((config) => config.id == id);
  }

  @override
  Future<void> reorderQuickButtons(List<String> orderedIds) async {
    final reorderedButtons = <QuickButtonConfig>[];
    for (int i = 0; i < orderedIds.length; i++) {
      final config = _quickButtons.firstWhere((c) => c.id == orderedIds[i]);
      reorderedButtons.add(config.copyWith(position: i));
    }
    _quickButtons.clear();
    _quickButtons.addAll(reorderedButtons);
  }

  @override
  Future<Entry> executeQuickButton(String quickButtonId) async {
    final config = await getQuickButtonById(quickButtonId);
    if (config == null) {
      throw Exception('Quick button not found: $quickButtonId');
    }
    
    // Create a mock entry based on the quick button configuration
    return Entry.create(
      substanceId: config.substanceId,
      dosage: config.dosage,
      unit: config.unit,
      notes: 'Quick entry from button: ${config.label}',
    );
  }

  @override
  Future<void> toggleQuickButtonActive(String id, bool isActive) async {
    final index = _quickButtons.indexWhere((c) => c.id == id);
    if (index != -1) {
      _quickButtons[index] = _quickButtons[index].copyWith(isActive: isActive);
    }
  }

  @override
  Future<List<QuickButtonConfig>> getActiveQuickButtons() async {
    return _quickButtons.where((config) => config.isActive).toList();
  }

  @override
  Future<void> updateQuickButtonPosition(String id, int newPosition) async {
    final index = _quickButtons.indexWhere((c) => c.id == id);
    if (index != -1) {
      _quickButtons[index] = _quickButtons[index].copyWith(position: newPosition);
    }
  }

  // Test helper methods
  void clearAllQuickButtons() {
    _quickButtons.clear();
    _nextPosition = 0;
  }

  void addMockQuickButton(QuickButtonConfig config) {
    _quickButtons.add(config.copyWith(position: _nextPosition++));
  }
}