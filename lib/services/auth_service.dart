import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../interfaces/service_interfaces.dart';

class AuthService extends ChangeNotifier implements IAuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  static const String _biometricEnabledKey = 'biometricEnabled';
  static const String _appLockEnabledKey = 'appLockEnabled';
  static const String _pinCodeKey = 'pinCode';

  bool _isAuthenticated = false;
  bool _isInitialized = false;

  bool get isAuthenticated => _isAuthenticated;

  @override
  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;
    // Initialization logic if needed
  }

  @override
  bool get requiresAuthentication {
    // Return true if any authentication method is enabled
    return true; // This would check if biometric or app lock is enabled
  }

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
  @override
  Future<bool> authenticateWithBiometrics({String? reason}) async {
    try {
      final result = await _localAuth.authenticate(
        localizedReason: reason ?? 'Bitte authentifizieren Sie sich, um fortzufahren',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      if (result) {
        _isAuthenticated = true;
        notifyListeners();
      }
      return result;
    } on PlatformException catch (_) {
      return false;
    }
  }

  @override
  Future<bool> authenticate() async {
    // Try biometric first if enabled, then fallback to PIN
    if (await isBiometricEnabled()) {
      return await authenticateWithBiometrics();
    }
    // For PIN authentication, this would need to be handled by UI
    return false;
  }

  @override
  Future<bool> isAuthenticated() async {
    return _isAuthenticated;
  }

  @override
  Future<void> logout() async {
    _isAuthenticated = false;
    notifyListeners();
  }

  @override
  Future<void> enableAuthentication() async {
    await setAppLockEnabled(true);
  }

  @override
  Future<void> disableAuthentication() async {
    await setAppLockEnabled(false);
    await setBiometricEnabled(false);
  }

  // Authenticate with PIN
  Future<bool> authenticateWithPIN(String enteredPIN) async {
    final result = await verifyPinCode(enteredPIN);
    if (result) {
      _isAuthenticated = true;
      notifyListeners();
    }
    return result;
  }

  @override
  Future<bool> verifyPinCode(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final storedPIN = prefs.getString(_pinCodeKey);
    
    if (storedPIN == null) return false;
    return pin == storedPIN;
  }

  // Set PIN code
  @override
  Future<void> setPinCode(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinCodeKey, pin);
  }

  // Check if PIN is set
  Future<bool> isPINSet() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_pinCodeKey);
  }

  // Enable/disable biometric authentication
  @override
  Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, enabled);
    notifyListeners();
  }

  // Check if biometric authentication is enabled
  @override
  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricEnabledKey) ?? false;
  }

  // Enable/disable app lock
  @override
  Future<void> setAppLockEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_appLockEnabledKey, enabled);
    notifyListeners();
  }

  // Check if app lock is enabled
  @override
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