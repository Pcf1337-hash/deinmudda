import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/design_tokens.dart';
import '../utils/error_handler.dart';
import '../interfaces/service_interfaces.dart';

class PsychedelicThemeService extends ChangeNotifier implements IPsychedelicThemeService {
  static const String _themeModeKey = 'theme_mode';
  static const String _animatedBackgroundKey = 'animated_background';
  static const String _pulsingButtonsKey = 'pulsing_buttons';
  static const String _glowIntensityKey = 'glow_intensity';
  static const String _currentSubstanceKey = 'current_substance';
  
  AppThemeMode _currentThemeMode = AppThemeMode.light;
  bool _isAnimatedBackgroundEnabled = true;
  bool _isPulsingButtonsEnabled = true;
  double _glowIntensity = 1.0;
  String _currentSubstance = 'default';
  
  SharedPreferences? _prefs;
  bool _isInitialized = false;
  
  AppThemeMode get currentThemeMode => _currentThemeMode;
  bool get isPsychedelicMode => _currentThemeMode == AppThemeMode.trippy;
  bool get isDarkMode => _currentThemeMode == AppThemeMode.dark;
  bool get isLightMode => _currentThemeMode == AppThemeMode.light;
  bool get isAnimatedBackgroundEnabled => _isAnimatedBackgroundEnabled;
  bool get isPulsingButtonsEnabled => _isPulsingButtonsEnabled;
  double get glowIntensity => _glowIntensity;
  String get currentSubstance => _currentSubstance;
  bool get isInitialized => _isInitialized;
  
  // Add getter for trippy mode state
  bool get isTrippyMode => _currentThemeMode == AppThemeMode.trippy;
  
  // Get the effective theme mode, considering system preference
  AppThemeMode get effectiveThemeMode {
    if (_currentThemeMode == AppThemeMode.system) {
      // Get system brightness and return appropriate mode
      final systemBrightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return systemBrightness == Brightness.dark ? AppThemeMode.dark : AppThemeMode.light;
    }
    return _currentThemeMode;
  }
  
  // Add theme getters for MaterialApp
  ThemeData get lightTheme => _buildLightTheme();
  ThemeData get darkTheme => _buildDarkTheme();
  ThemeData get trippyTheme => _buildTrippyTheme();
  
  Future<void> init() async {
    try {
      ErrorHandler.logTheme('INIT', 'PsychedelicThemeService Initialisierung gestartet');
      
      _prefs = await SharedPreferences.getInstance();
      await _loadSettings();
      
      _isInitialized = true;
      ErrorHandler.logSuccess('THEME_SERVICE', 'PsychedelicThemeService erfolgreich initialisiert');
      
      // Notify listeners that initialization is complete
      notifyListeners();
    } catch (e) {
      ErrorHandler.logError('THEME_SERVICE', 'Fehler bei PsychedelicThemeService init: $e');
      
      // Fallback to defaults
      _currentThemeMode = AppThemeMode.light;
      _isAnimatedBackgroundEnabled = true;
      _isPulsingButtonsEnabled = true;
      _glowIntensity = 1.0;
      _currentSubstance = 'default';
      _isInitialized = true;
      
      ErrorHandler.logWarning('THEME_SERVICE', 'Fallback-Werte für PsychedelicThemeService gesetzt');
      notifyListeners();
    }
  }

  Future<void> _loadSettings() async {
    if (_prefs == null) {
      ErrorHandler.logWarning('THEME_SERVICE', 'SharedPreferences nicht verfügbar');
      return;
    }
    
    try {
      // Load theme mode - default to system if no preference is saved
      final themeModeIndex = _prefs!.getInt(_themeModeKey);
      if (themeModeIndex == null) {
        // No saved preference, use system default
        _currentThemeMode = AppThemeMode.system;
      } else {
        _currentThemeMode = AppThemeMode.values[themeModeIndex.clamp(0, AppThemeMode.values.length - 1)];
      }
      
      // Load other settings
      _isAnimatedBackgroundEnabled = _prefs!.getBool(_animatedBackgroundKey) ?? true;
      _isPulsingButtonsEnabled = _prefs!.getBool(_pulsingButtonsKey) ?? true;
      _glowIntensity = _prefs!.getDouble(_glowIntensityKey) ?? 1.0;
      _currentSubstance = _prefs!.getString(_currentSubstanceKey) ?? 'default';
      
      ErrorHandler.logTheme('LOAD_SETTINGS', 'Theme-Einstellungen geladen: $_currentThemeMode');
    } catch (e) {
      ErrorHandler.logError('THEME_SERVICE', 'Fehler beim Laden der Theme-Einstellungen: $e');
    }
  }
  
  Future<void> setThemeMode(AppThemeMode mode) async {
    _currentThemeMode = mode;
    await _prefs?.setInt(_themeModeKey, mode.index);
    notifyListeners();
  }
  
  Future<void> cycleThemeMode() async {
    final nextIndex = (_currentThemeMode.index + 1) % AppThemeMode.values.length;
    await setThemeMode(AppThemeMode.values[nextIndex]);
  }
  
  Future<void> togglePsychedelicMode() async {
    if (_currentThemeMode == AppThemeMode.trippy) {
      await setThemeMode(AppThemeMode.dark);
    } else {
      await setThemeMode(AppThemeMode.trippy);
    }
  }
  
  Future<void> toggleTrippyMode(bool value) async {
    if (value) {
      await setThemeMode(AppThemeMode.trippy);
    } else {
      await setThemeMode(AppThemeMode.dark);
    }
  }
  
  Future<void> setAnimatedBackground(bool enabled) async {
    _isAnimatedBackgroundEnabled = enabled;
    await _prefs?.setBool(_animatedBackgroundKey, enabled);
    notifyListeners();
  }
  
  Future<void> setPulsingButtons(bool enabled) async {
    _isPulsingButtonsEnabled = enabled;
    await _prefs?.setBool(_pulsingButtonsKey, enabled);
    notifyListeners();
  }
  
  Future<void> setGlowIntensity(double intensity) async {
    _glowIntensity = intensity.clamp(0.0, 2.0);
    await _prefs?.setDouble(_glowIntensityKey, _glowIntensity);
    notifyListeners();
  }
  
  Future<void> setCurrentSubstance(String substance) async {
    _currentSubstance = substance;
    await _prefs?.setString(_currentSubstanceKey, substance);
    notifyListeners();
  }
  
  // Get current substance colors safely
  Map<String, Color> getCurrentSubstanceColors() {
    try {
      return DesignTokens.getSubstanceColor(_currentSubstance);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting substance colors: $e');
      }
      return {
        'primary': const Color(0xFFff00ff),
        'secondary': const Color(0xFF00f7ff),
        'accent': const Color(0xFFffff00),
      };
    }
  }

  // Get appropriate theme based on settings with error handling
  @override
  ThemeData get currentTheme => getTheme();

  ThemeData getTheme() {
    try {
      final effectiveMode = effectiveThemeMode;
      switch (effectiveMode) {
        case AppThemeMode.light:
          return _buildLightTheme();
        case AppThemeMode.dark:
          return _buildDarkTheme();
        case AppThemeMode.trippy:
          return _buildTrippyTheme();
        case AppThemeMode.system:
          // This case should not happen as effectiveThemeMode resolves system
          final systemBrightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
          return systemBrightness == Brightness.dark ? _buildDarkTheme() : _buildLightTheme();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error building theme: $e');
      }
      // Fallback to light theme
      return _buildLightTheme();
    }
  }

  // Initialize method for interface compliance
  @override
  Future<void> init() async {
    if (_isInitialized) return;
    await initialize();
  }
  
  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: DesignTokens.primaryIndigo,
        brightness: Brightness.light,
      ),
      textTheme: _buildStandardTextTheme(false),
      elevatedButtonTheme: _buildStandardElevatedButtonTheme(DesignTokens.primaryIndigo),
      floatingActionButtonTheme: _buildStandardFABTheme(DesignTokens.primaryIndigo),
      appBarTheme: _buildStandardAppBarTheme(false),
    );
  }
  
  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: DesignTokens.primaryIndigo,
        brightness: Brightness.dark,
      ),
      textTheme: _buildStandardTextTheme(true),
      elevatedButtonTheme: _buildStandardElevatedButtonTheme(DesignTokens.primaryIndigo),
      floatingActionButtonTheme: _buildStandardFABTheme(DesignTokens.primaryIndigo),
      appBarTheme: _buildStandardAppBarTheme(true),
    );
  }
  
  ThemeData _buildTrippyTheme() {
    final substanceColors = getCurrentSubstanceColors();
    final primaryColor = substanceColors['primary'] ?? const Color(0xFFff00ff); // Neon magenta
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        background: const Color(0xFF2c2c2c), // Trippy background color
        surface: const Color(0xFF2c2c2c).withOpacity(0.8),
        surfaceVariant: const Color(0xFF2c2c2c).withOpacity(0.6),
        primary: primaryColor,
        secondary: const Color(0xFF00f7ff), // Neon cyan
        tertiary: const Color(0xFFff00ff), // Neon magenta
        onBackground: Colors.white,
        onSurface: Colors.white,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onTertiary: Colors.black,
        outline: const Color(0xFF00f7ff).withOpacity(0.3),
      ),
      scaffoldBackgroundColor: const Color(0xFF2c2c2c),
      textTheme: _buildTrippyTextTheme(),
      elevatedButtonTheme: _buildTrippyElevatedButtonTheme(primaryColor),
      floatingActionButtonTheme: _buildTrippyFABTheme(primaryColor),
      bottomNavigationBarTheme: _buildTrippyBottomNavTheme(),
      appBarTheme: _buildTrippyAppBarTheme(),
      iconTheme: const IconThemeData(
        color: Colors.white,
        size: 24,
      ),
      primaryIconTheme: IconThemeData(
        color: primaryColor,
        size: 24,
      ),
      splashFactory: NoSplash.splashFactory, // Disable splash for trippy mode
    );
  }
  
  TextTheme _buildStandardTextTheme(bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor = isDark ? Colors.white70 : Colors.black54;
    
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: textColor,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: textColor,
        letterSpacing: -0.25,
      ),
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: secondaryTextColor,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: secondaryTextColor,
      ),
    );
  }

  TextTheme _buildTrippyTextTheme() {
    return const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: -0.5,
        shadows: [
          Shadow(
            color: Color(0xFFff00ff),
            blurRadius: 8,
          ),
          Shadow(
            color: Color(0xFF00f7ff),
            blurRadius: 12,
          ),
        ],
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: -0.25,
        shadows: [
          Shadow(
            color: Color(0xFFff00ff),
            blurRadius: 6,
          ),
        ],
      ),
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        shadows: [
          Shadow(
            color: Color(0xFF00f7ff),
            blurRadius: 4,
          ),
        ],
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Colors.white,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Colors.white70,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: Colors.white60,
      ),
    );
  }
  
  ElevatedButtonThemeData _buildStandardElevatedButtonTheme(Color primaryColor) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
      ),
    );
  }

  ElevatedButtonThemeData _buildTrippyElevatedButtonTheme(Color primaryColor) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor.withOpacity(0.8),
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: primaryColor,
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
      ),
    );
  }

  FloatingActionButtonThemeData _buildStandardFABTheme(Color primaryColor) {
    return FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 6,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    );
  }

  FloatingActionButtonThemeData _buildTrippyFABTheme(Color primaryColor) {
    return FloatingActionButtonThemeData(
      backgroundColor: primaryColor.withOpacity(0.8),
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        side: BorderSide(
          color: primaryColor,
          width: 2,
        ),
      ),
    );
  }

  AppBarTheme _buildStandardAppBarTheme(bool isDark) {
    return AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: isDark ? Colors.white : Colors.black,
      iconTheme: IconThemeData(
        color: isDark ? Colors.white : Colors.black,
      ),
    );
  }

  AppBarTheme _buildTrippyAppBarTheme() {
    return const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
    );
  }

  BottomNavigationBarThemeData _buildTrippyBottomNavTheme() {
    return BottomNavigationBarThemeData(
      backgroundColor: const Color(0xFF2c2c2c).withOpacity(0.9),
      selectedItemColor: const Color(0xFFff00ff),
      unselectedItemColor: Colors.white60,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    );
  }
  
  // Helper method to get glow effect based on intensity
  BoxShadow getGlowEffect(Color color, {double radius = 20}) {
    return BoxShadow(
      color: color.withOpacity(0.3 * _glowIntensity),
      blurRadius: radius * _glowIntensity,
      spreadRadius: (radius * 0.2) * _glowIntensity,
    );
  }
  
  // Helper method to get multiple glow effects
  List<BoxShadow> getMultipleGlowEffects(Color color, {double radius = 20}) {
    return [
      BoxShadow(
        color: color.withOpacity(0.3 * _glowIntensity),
        blurRadius: radius * _glowIntensity,
        spreadRadius: (radius * 0.2) * _glowIntensity,
      ),
      BoxShadow(
        color: color.withOpacity(0.1 * _glowIntensity),
        blurRadius: (radius * 2) * _glowIntensity,
        spreadRadius: (radius * 0.4) * _glowIntensity,
      ),
    ];
  }

  // Safe way to get theme provider from context
  static PsychedelicThemeService? of(BuildContext context) {
    try {
      return context.read<PsychedelicThemeService>();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting PsychedelicThemeService: $e');
      }
      return null;
    }
  }

  // Safe way to watch theme provider from context
  static PsychedelicThemeService? watch(BuildContext context) {
    try {
      return context.watch<PsychedelicThemeService>();
    } catch (e) {
      if (kDebugMode) {
        print('Error watching PsychedelicThemeService: $e');
      }
      return null;
    }
  }
}