import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../interfaces/service_interfaces.dart';

class SettingsService extends ChangeNotifier implements ISettingsService {
  static const String _isDarkModeKey = 'isDarkMode';
  static const String _isFirstLaunchKey = 'isFirstLaunch';
  static const String _languageKey = 'language';
  static const String _notificationsEnabledKey = 'notificationsEnabled';
  static const String _biometricAuthEnabledKey = 'biometricAuthEnabled';
  static const String _autoBackupEnabledKey = 'autoBackupEnabled';
  static const String _dataRetentionDaysKey = 'dataRetentionDays';

  SharedPreferences? _prefs;
  bool _isDarkMode = false;
  bool _isFirstLaunch = true;
  String _language = 'de';
  bool _notificationsEnabled = true;
  bool _biometricAuthEnabled = false;
  bool _autoBackupEnabled = false;
  int _dataRetentionDays = 365;

  // Getters
  Future<bool> get isDarkMode async {
    await _ensureInitialized();
    return _isDarkMode;
  }

  Future<bool> get isFirstLaunch async {
    await _ensureInitialized();
    return _isFirstLaunch;
  }

  Future<String> get language async {
    await _ensureInitialized();
    return _language;
  }

  Future<bool> get notificationsEnabled async {
    await _ensureInitialized();
    return _notificationsEnabled;
  }

  Future<bool> get biometricAuthEnabled async {
    await _ensureInitialized();
    return _biometricAuthEnabled;
  }

  Future<bool> get autoBackupEnabled async {
    await _ensureInitialized();
    return _autoBackupEnabled;
  }

  Future<int> get dataRetentionDays async {
    await _ensureInitialized();
    return _dataRetentionDays;
  }

  // Initialize SharedPreferences
  Future<void> _ensureInitialized() async {
    if (_prefs == null) {
      await init();
    }
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSettings();
  }

  // Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    if (_prefs == null) return;

    _isDarkMode = _prefs!.getBool(_isDarkModeKey) ?? false;
    _isFirstLaunch = _prefs!.getBool(_isFirstLaunchKey) ?? true;
    _language = _prefs!.getString(_languageKey) ?? 'de';
    _notificationsEnabled = _prefs!.getBool(_notificationsEnabledKey) ?? true;
    _biometricAuthEnabled = _prefs!.getBool(_biometricAuthEnabledKey) ?? false;
    _autoBackupEnabled = _prefs!.getBool(_autoBackupEnabledKey) ?? false;
    _dataRetentionDays = _prefs!.getInt(_dataRetentionDaysKey) ?? 365;

    notifyListeners();
  }

  // Set dark mode
  Future<void> setDarkMode(bool value) async {
    await _ensureInitialized();
    _isDarkMode = value;
    await _prefs!.setBool(_isDarkModeKey, value);
    notifyListeners();
  }

  // Toggle dark mode
  Future<void> toggleDarkMode() async {
    await setDarkMode(!_isDarkMode);
  }

  // Set first launch
  Future<void> setFirstLaunch(bool value) async {
    await _ensureInitialized();
    _isFirstLaunch = value;
    await _prefs!.setBool(_isFirstLaunchKey, value);
    notifyListeners();
  }

  // Set language
  Future<void> setLanguage(String value) async {
    await _ensureInitialized();
    _language = value;
    await _prefs!.setString(_languageKey, value);
    notifyListeners();
  }

  // Set notifications enabled
  Future<void> setNotificationsEnabled(bool value) async {
    await _ensureInitialized();
    _notificationsEnabled = value;
    await _prefs!.setBool(_notificationsEnabledKey, value);
    notifyListeners();
  }

  // Set biometric auth enabled
  Future<void> setBiometricAuthEnabled(bool value) async {
    await _ensureInitialized();
    _biometricAuthEnabled = value;
    await _prefs!.setBool(_biometricAuthEnabledKey, value);
    notifyListeners();
  }

  // Set auto backup enabled
  Future<void> setAutoBackupEnabled(bool value) async {
    await _ensureInitialized();
    _autoBackupEnabled = value;
    await _prefs!.setBool(_autoBackupEnabledKey, value);
    notifyListeners();
  }

  // Set data retention days
  Future<void> setDataRetentionDays(int value) async {
    await _ensureInitialized();
    _dataRetentionDays = value;
    await _prefs!.setInt(_dataRetentionDaysKey, value);
    notifyListeners();
  }

  // Reset all settings to default
  Future<void> resetToDefaults() async {
    await _ensureInitialized();
    await _prefs!.clear();
    await _loadSettings();
  }

  // Export settings as Map
  Future<Map<String, dynamic>> exportSettings() async {
    await _ensureInitialized();
    return {
      'isDarkMode': _isDarkMode,
      'language': _language,
      'notificationsEnabled': _notificationsEnabled,
      'biometricAuthEnabled': _biometricAuthEnabled,
      'autoBackupEnabled': _autoBackupEnabled,
      'dataRetentionDays': _dataRetentionDays,
    };
  }

  // Import settings from Map
  Future<void> importSettings(Map<String, dynamic> settings) async {
    await _ensureInitialized();
    
    if (settings.containsKey('isDarkMode')) {
      await setDarkMode(settings['isDarkMode'] as bool);
    }
    if (settings.containsKey('language')) {
      await setLanguage(settings['language'] as String);
    }
    if (settings.containsKey('notificationsEnabled')) {
      await setNotificationsEnabled(settings['notificationsEnabled'] as bool);
    }
    if (settings.containsKey('biometricAuthEnabled')) {
      await setBiometricAuthEnabled(settings['biometricAuthEnabled'] as bool);
    }
    if (settings.containsKey('autoBackupEnabled')) {
      await setAutoBackupEnabled(settings['autoBackupEnabled'] as bool);
    }
    if (settings.containsKey('dataRetentionDays')) {
      await setDataRetentionDays(settings['dataRetentionDays'] as int);
    }
  }

  // Get app version info
  Future<Map<String, String>> getAppInfo() async {
    // In a real app, you would use package_info_plus
    return {
      'version': '1.0.0',
      'buildNumber': '1',
      'appName': 'Konsum Tracker Pro',
    };
  }

  // Check if this is a fresh install
  Future<bool> isFreshInstall() async {
    await _ensureInitialized();
    return _isFirstLaunch;
  }

  // Mark onboarding as completed
  Future<void> completeOnboarding() async {
    await setFirstLaunch(false);
  }

  // Generic setting methods for interface compliance
  @override
  Future<T?> getSetting<T>(String key) async {
    await _ensureInitialized();
    final value = _prefs!.get(key);
    return value is T ? value : null;
  }

  @override
  Future<void> setSetting<T>(String key, T value) async {
    await _ensureInitialized();
    if (value is bool) {
      await _prefs!.setBool(key, value);
    } else if (value is String) {
      await _prefs!.setString(key, value);
    } else if (value is int) {
      await _prefs!.setInt(key, value);
    } else if (value is double) {
      await _prefs!.setDouble(key, value);
    } else if (value is List<String>) {
      await _prefs!.setStringList(key, value);
    }
    notifyListeners();
  }

  @override
  Future<void> deleteSetting(String key) async {
    await _ensureInitialized();
    await _prefs!.remove(key);
    notifyListeners();
  }

  @override
  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    await _ensureInitialized();
    return _prefs!.getBool(key) ?? defaultValue;
  }

  @override
  Future<void> setBool(String key, bool value) async {
    await _ensureInitialized();
    await _prefs!.setBool(key, value);
    notifyListeners();
  }

  @override
  Future<String> getString(String key, {String defaultValue = ''}) async {
    await _ensureInitialized();
    return _prefs!.getString(key) ?? defaultValue;
  }

  @override
  Future<void> setString(String key, String value) async {
    await _ensureInitialized();
    await _prefs!.setString(key, value);
    notifyListeners();
  }

  @override
  Future<int> getInt(String key, {int defaultValue = 0}) async {
    await _ensureInitialized();
    return _prefs!.getInt(key) ?? defaultValue;
  }

  @override
  Future<void> setInt(String key, int value) async {
    await _ensureInitialized();
    await _prefs!.setInt(key, value);
    notifyListeners();
  }
}
