import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  static const String _biometricEnabledKey = 'biometricEnabled';
  static const String _appLockEnabledKey = 'appLockEnabled';
  static const String _pinCodeKey = 'pinCode';

  // Check if device supports biometric authentication
  Future<bool> isBiometricAvailable() async {
    try {
      final canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final canAuthenticate = canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();
      return canAuthenticate;
    } on PlatformException catch (_) {
      return false;
    }
  }

  // Get available biometric types
  Future<List<String>> getAvailableBiometrics() async {
    try {
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      final biometricNames = <String>[];
      
      if (availableBiometrics.contains(BiometricType.face)) {
        biometricNames.add('Face ID');
      }
      if (availableBiometrics.contains(BiometricType.fingerprint)) {
        biometricNames.add('Fingerabdruck');
      }
      if (availableBiometrics.contains(BiometricType.iris)) {
        biometricNames.add('Iris');
      }
      if (availableBiometrics.contains(BiometricType.strong)) {
        biometricNames.add('Starke Biometrie');
      }
      if (availableBiometrics.contains(BiometricType.weak)) {
        biometricNames.add('Schwache Biometrie');
      }
      
      return biometricNames;
    } on PlatformException catch (_) {
      return [];
    }
  }

  // Authenticate with biometrics
  Future<bool> authenticateWithBiometrics() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Bitte authentifizieren Sie sich, um fortzufahren',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on PlatformException catch (_) {
      return false;
    }
  }

  // Authenticate with PIN
  Future<bool> authenticateWithPIN(String enteredPIN) async {
    final prefs = await SharedPreferences.getInstance();
    final storedPIN = prefs.getString(_pinCodeKey);
    
    if (storedPIN == null) return false;
    return enteredPIN == storedPIN;
  }

  // Set PIN code
  Future<void> setPINCode(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinCodeKey, pin);
  }

  // Check if PIN is set
  Future<bool> isPINSet() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_pinCodeKey);
  }

  // Enable/disable biometric authentication
  Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, enabled);
  }

  // Check if biometric authentication is enabled
  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricEnabledKey) ?? false;
  }

  // Enable/disable app lock
  Future<void> setAppLockEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_appLockEnabledKey, enabled);
  }

  // Check if app lock is enabled
  Future<bool> isAppLockEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_appLockEnabledKey) ?? false;
  }

  // Validate PIN format
  bool isValidPIN(String pin) {
    // PIN must be 4-6 digits
    final pinRegex = RegExp(r'^\d{4,6}$');
    return pinRegex.hasMatch(pin);
  }

  // Clear all authentication settings
  Future<void> clearAuthSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_biometricEnabledKey);
    await prefs.remove(_appLockEnabledKey);
    await prefs.remove(_pinCodeKey);
  }
}